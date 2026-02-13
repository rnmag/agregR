#' @encoding UTF-8
#' @title Plot Prior vs Posterior
#' @description Generates a plot comparing prior and posterior distributions for candidates or bias.
#' @param bd The results object returned by `rodar_agregador`.
#' @param candidaturas A character vector of candidate names to include in the plot.
#' @param tipo The type of da to plot: "Vi\u00e9s" (for institute bias) or "Percentual" (for candidate voting share).
#' @param salvar Logical. If TRUE, saves the plot to disk.
#' @param config_agregador A list of configuration parameters created by `configurar_agregador()`.
#' @param config_grafico A list of graphic parameters created by `configurar_grafico()`.
#' @param config_prioris A list of model hyperparameters created by `configurar_prioris()`. If NULL, defaults are used based on `bd$nome_modelo`.
#' @param dir_saida Output directory for the saved plot if `salvar = TRUE`.
#' @return A ggplot2 object.
#' @export
#' @examples
#' if (instantiate::stan_cmdstan_exists()) {
#'   result <- rodar_agregador(turno = 2, cenario = "Lula vs Bolsonaro", salvar = FALSE)
#'
#'   # Prior vs Posterior plot for institute bias
#'   grafico_priori_posteriori(
#'     result,
#'     tipo = "Vi\u00e9s",
#'     candidaturas = c("Lula", "Bolsonaro"),
#'     salvar = FALSE
#'   )
#'
#'   # Altering candidate colors
#'   grafico_priori_posteriori(
#'     result,
#'     candidaturas = c("Lula", "Bolsonaro"),
#'     salvar = FALSE,
#'     config_grafico = configurar_grafico(
#'       cores_candidaturas = c(Lula = "darkred")
#'     )
#'   )
#' }
#' @importFrom cli cli_abort cli_alert_success cli_alert_info
#' @importFrom purrr map_chr map list_rbind pmap
#' @importFrom dplyr mutate filter inner_join bind_rows join_by
#' @importFrom tibble tibble as_tibble
#' @importFrom stats dnorm na.omit
#' @importFrom ggplot2 ggplot geom_density geom_line scale_fill_manual scale_color_manual scale_linetype_manual guides guide_legend labs theme_bw theme element_text scale_x_continuous geom_vline facet_wrap element_blank
#' @importFrom stringr str_to_title
#' @importFrom ragg agg_png
grafico_priori_posteriori <- function(bd,
                                      candidaturas,
                                      tipo = "Vi\u00e9s",
                                      salvar = FALSE,
                                      config_agregador = configurar_agregador(),
                                      config_grafico = configurar_grafico(),
                                      config_prioris = configurar_prioris(bd$nome_modelo),
                                      dir_saida = ".") {

  # 1. Configuração e validação -----------------------------------------------

  # Registrar fonte
  registrar_fonte(config_grafico$graf_agregador$dpi)

  # Identificar turno
  turno <- unique(na.omit(bd$votos_estimados$turno))

  # Padronizar nomes das candidaturas
  candidaturas <- map_chr(candidaturas,
                          nome_robusto)

  # Definir parâmetro a ser extraído conforme o tipo selecionado
  parametro <- if (tipo == "Vi\u00e9s") "delta" else "mu"

  # Validação do tipo
  if (!tipo %in% c("Percentual", "Vi\u00e9s")) {

    cli_abort("O argumento {.arg tipo} deve ser 'Percentual' ou 'Vi\u00e9s'.")

  }

  # Erro se tentar fazer gráfico de viés com modelo "Naive"
  if (tipo == "Vi\u00e9s" && bd$nome_modelo == "Naive") {

    cli_abort("No modelo 'Naive' n\u00e3o existe vi\u00e9s. Tente tipo = 'Percentual'.")

  }

  # Validação de candidaturas
  for (cand in candidaturas) {

    if (is.null(bd$modelo_bruto[[cand]])) {

      cli_abort("Candidatura {.val {cand}} n\u00e3o encontrada nos resultados do modelo.")

    }

  }

  # 2. Gerar distribuições a posteriori ---------------------------------------
  # Extrair amostras da posteriori para todas as candidaturas selecionadas
  dist_posteriori <- map(candidaturas,
                         extrair_amostras_post,
                         parametro = parametro,
                         bd = bd) |>
    list_rbind() |>
    # Candidaturas na ordem de entrada no vetor de argumentos
    mutate(candidatura = factor(candidatura, levels = candidaturas))

  # 3. Gerar distribuições a priori -------------------------------------------
  if (tipo == "Vi\u00e9s") {

    # Se o modelo for "Viés Empírico", calcular desempenhos dos institutos
    if (bd$nome_modelo == "Vi\u00e9s Emp\u00edrico") {

      prioris_emp <- map(candidaturas,
                         calcular_prioris_empiricas,
                         turno = turno,
                         institutos = bd$vies_institutos$instituto,
                         config_agregador = config_agregador) |>
        setNames(candidaturas) |>
        bind_rows(.id = "candidatura")

      vies_institutos <- bd$vies_institutos |>
        inner_join(prioris_emp, by = join_by(instituto, candidatura))

    } else {

      # Para os outros modelos, criar tibble com a priori definida na config. A
      # coluna mantém o nome emp_delta_priori para facilitar o pmap abaixo, mas
      # a priori não é empírica
      vies_institutos <- expand.grid(instituto = unique(bd$vies_institutos$instituto),
                                     candidatura = candidaturas,
                                     stringsAsFactors = FALSE) |>
        mutate(emp_delta_priori = as.numeric(config_prioris$delta_priori)) |>
        as_tibble() |>
        filter(instituto %in% unique(dist_posteriori$instituto))

    }

    # sd_delta_priori vem da config independentemente do modelo
    sd_delta_priori <- as.numeric(config_prioris$sd_delta_priori)

    # Criar as distibuições das prioris de cada instituto. pmap usa as colunas
    # de vies_institutos como argumentos para a função anônima
    dist_priori <- pmap(vies_institutos, \(instituto, emp_delta_priori, candidatura, ...) {
      tibble(x = seq(emp_delta_priori - 4 * sd_delta_priori,
                     emp_delta_priori + 4 * sd_delta_priori,
                     length.out = 200)) |>
        mutate(y = dnorm(x, mean = emp_delta_priori, sd = sd_delta_priori),
               instituto = instituto,
               candidatura = candidatura)
    }) |>
      list_rbind() |>
      # Candidaturas na ordem de entrada no vetor de argumentos
      mutate(candidatura = factor(candidatura, levels = candidaturas))

  } else {

    # Prioris para tipo = "Percentual" (mu)
    mu_priori <- as.numeric(config_prioris$mu_priori)
    sd_mu_priori <- as.numeric(config_prioris$sd_mu_priori)

    # Criar as distibuições das prioris de cada candidatura
    dist_priori <- map(candidaturas, \(candidatura) {
      tibble(x = seq(0, 1, length.out = 500)) |>
        mutate(y = dnorm(x, mean = mu_priori, sd = sd_mu_priori),
               candidatura = candidatura)
    }) |>
      list_rbind() |>
      # Candidaturas na ordem de entrada no vetor de argumentos
      mutate(candidatura = factor(candidatura, levels = candidaturas))

  }

  # 4. Gráfico ----------------------------------------------------------------
  p <- ggplot() +
    # Definição dos geoms
    geom_density(data = dist_posteriori,
                 aes(x = valor_estimado,
                     fill = candidatura),
                 color = "black",
                 alpha = 0.8,
                 linewidth = 0.3) +
    geom_line(data = dist_priori,
              aes(x = x,
                  y = y,
                  color = candidatura,
                  linetype = candidatura),
              linewidth = 1.5) +
    # Legendas
    scale_fill_manual(values = unlist(config_grafico$cores_candidaturas)) +
    scale_color_manual(values = unlist(config_grafico$cores_candidaturas)) +
    scale_linetype_manual(values = c("solid", "dashed", "twodash", "dotdash", "dotted")) +
    guides(color = guide_legend(order = 1),
           linetype = guide_legend(order = 1),
           fill = guide_legend(order = 2)) +
    # Rótulos
    labs(x = NULL,
         y = NULL,
         color = "Priori",
         linetype = "Priori",
         fill = "Posteriori",
         caption = paste("Estimativas baseadas em",
                         n_distinct(na.omit(bd$votos_estimados$pesquisa_id)),
                         "pesquisas publicadas entre",
                         str_to_title(format(min(bd$votos_estimados$dia), "%B/%y")),
                         "e",
                         str_to_title(format(max(bd$votos_estimados$dia), "%B/%y")),
                         "\nModelo:",
                         bd$nome_modelo)) +
    # Tema
    theme_bw() +
    theme(text = element_text(family = "Fira Sans"),
          plot.title = element_text(face = "bold", size = 18, hjust = .5),
          plot.subtitle = element_text(hjust = .5, color = "#777777"),
          plot.caption = element_text(size = 7, color = "#777777"),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_blank(),
          legend.position = "top",
          legend.title = element_text(face = "bold", size = 9),
          legend.text = element_text(size = 9),
          axis.ticks = element_blank(),
          axis.text.y = element_blank(),
          axis.line.x.bottom = element_blank(),
          strip.background = element_blank(),
          strip.text = element_text(face = "bold", size = 11))

  if (tipo == "Vi\u00e9s") {

    # Institutos em ordem alfabética
    dist_posteriori <- dist_posteriori |>
      mutate(instituto = factor(instituto, levels = rev(sort(unique(instituto)))))

    # Configurações específicas para tipo = "Viés"
    p <- p +
      scale_x_continuous(labels = scales::percent) +
      geom_vline(xintercept = 0) +
      labs(title = "Evolu\u00e7\u00e3o - Vi\u00e9s dos Institutos",
           subtitle = paste("Diferen\u00e7a entre as distribui\u00e7\u00f5es a priori e a posteriori no modelo", bd$nome_modelo)) +
      facet_wrap(~ instituto, scales = "free_x")

  } else {

    # Configurações específicas para tipo = "Percentual"
    p <- p +
      scale_x_continuous(limits = c(0, 1), labels = scales::percent) +
      geom_vline(xintercept = .5) +
      labs(title = "Evolu\u00e7\u00e3o - Inten\u00e7\u00e3o de Votos",
           subtitle = paste("Diferen\u00e7a entre as distribui\u00e7\u00f5es a priori e a posteriori no modelo", bd$nome_modelo)) +
      theme(panel.border = element_blank())

  }

  # 5. Salvar resultados ------------------------------------------------------
  if (salvar) {

    nome_arquivo <- paste0("Priori_posteriori_",
                           colar_ascii(tipo),
                           "_",
                           colar_ascii(candidaturas),
                           ".png")

    arquivo <- gerar_saida(file.path(dir_saida, config_grafico$dir_grafico), bd$nome_modelo, nome_arquivo)

    ggsave(arquivo,
           p,
           device = agg_png,
           width = config_grafico$graf_agregador$largura,
           height = config_grafico$graf_agregador$altura,
           units = config_grafico$graf_agregador$unidade,
           dpi = config_grafico$graf_agregador$dpi)

    cli_alert_success("Gr\u00e1fico salvo em {.file {arquivo}}")

  }

  return(p)

}
