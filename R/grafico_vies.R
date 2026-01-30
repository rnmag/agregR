#' @encoding UTF-8
#' @title Plot Institute Bias
#' @description Generates a plot visualizing the bias of polling institutes.
#' @param bd The results object returned by `rodar_agregador`.
#' @param candidaturas A character vector of candidate names to include in the plot.
#' @param salvar Logical. If TRUE, saves the plot to disk.
#' @param config_grafico A list of graphic parameters created by `configurar_grafico()`.
#' @param dir_saida Output directory for the saved plot if `salvar = TRUE`.
#' @param ... Additional arguments.
#' @return A ggplot2 object.
#' @export
#' @examples
#' if (instantiate::stan_cmdstan_exists()) {
#'   result <- rodar_agregador(turno = 2, cenario = "Lula vs Bolsonaro", salvar = FALSE)
#'
#'   # Standard bias plot
#'   grafico_vies(
#'     result,
#'     candidaturas = c("Lula", "Bolsonaro"),
#'     salvar = FALSE
#'   )
#'
#'   # Altering candidate colors
#'   grafico_vies(
#'     result,
#'     candidaturas = c("Lula", "Bolsonaro"),
#'     salvar = FALSE,
#'     config_grafico = configurar_grafico(
#'       cores_candidaturas = c(Lula = "darkred")
#'     )
#'   )
#' }
#' @importFrom purrr map_chr map list_rbind
#' @importFrom cli cli_abort cli_alert_success cli_alert_info
#' @importFrom dplyr mutate filter distinct n_distinct
#' @importFrom ggplot2 ggplot aes geom_vline scale_fill_manual scale_x_continuous labs theme_bw theme element_text position_dodge ggsave
#' @importFrom ggdist stat_gradientinterval
#' @importFrom stringr str_to_title
#' @importFrom ragg agg_png
grafico_vies <- function(bd,
                         candidaturas,
                         salvar = FALSE,
                         config_grafico = configurar_grafico(),
                         dir_saida = ".",
                         ...) {

  # 1. Configuração e validação -----------------------------------------------

  # Padronizar nomes das candidaturas
  candidaturas <- map_chr(candidaturas,
                          nome_robusto)

  # Registrar fonte
  registrar_fonte()

  # Erro se objeto vier do modelo "Naive"
  if (bd$nome_modelo == "Naive") cli_abort("O gr\u00e1fico de vi\u00e9s n\u00e3o \u00e9 aplic\u00e1vel ao modelo 'Naive'.")

  # Verificar se candidaturas existem nos resultados
  for (i in candidaturas) {

    if (is.null(bd$modelo_bruto[[i]])) {

      cli_abort("Candidatura {.val {i}} n\u00e3o encontrada nos resultados do modelo.")

    }

  }

  # Rótulos dependentes do modelo
  if (bd$nome_modelo %in% c("Vi\u00e9s Relativo sem Pesos", "Vi\u00e9s Relativo com Pesos")) {

    titulo_grafico <- "Vi\u00e9s Relativo dos Institutos"
    subtitulo_grafico <- "Modelo ancorado na estimativa m\u00e9dia dos institutos"
    rotulo_eixo_x <- "Vi\u00e9s em rela\u00e7\u00e3o \u00e0 m\u00e9dia dos institutos"

  } else if (bd$nome_modelo == "Vi\u00e9s Emp\u00edrico") {

    titulo_grafico <- "Vi\u00e9s dos Institutos"
    subtitulo_grafico <- "Modelo ancorado no desempenho dos institutos na elei\u00e7\u00e3o anterior"
    rotulo_eixo_x <- "Vi\u00e9s"

  } else if (bd$nome_modelo == "Retrospectivo") {

    titulo_grafico <- "Vi\u00e9s dos Institutos"
    subtitulo_grafico <- "Modelo ancorado no resultado final da elei\u00e7\u00e3o"
    rotulo_eixo_x <- "Vi\u00e9s"

  }

  # 2. Gerar distribuições a posteriori ---------------------------------------
  # Extrair distribuição posterior para plotar os gradientes de cada candidato
  posterior <- map(candidaturas,
                   extrair_amostras_post,
                   parametro = "delta",
                   bd = bd) |>
    list_rbind() |>
    # Candidaturas na ordem do vetor, institutos em ordem alfabética
    mutate(candidatura = factor(candidatura, levels = rev(candidaturas)),
           instituto = factor(instituto, levels = rev(sort(unique(instituto)))))

  # 3. Gráfico ----------------------------------------------------------------
  p <- posterior |>
    ggplot(aes(y = instituto,
               x = valor_estimado,
               fill = candidatura)) +
    stat_gradientinterval(position = position_dodge(width = 0.75)) +
    geom_vline(xintercept = 0) +
    # Legenda
    scale_fill_manual(values = unlist(config_grafico$cores_candidaturas[candidaturas]),
                      breaks = candidaturas) +
    # Eixos
    scale_x_continuous(labels = scales::label_percent(),
                       limits = c(-1, 1) * max(abs(c(max(posterior$valor_estimado),
                                                     min(posterior$valor_estimado))))) +
    # Rótulos
    labs(title = titulo_grafico,
         subtitle = subtitulo_grafico,
         caption = paste("Estimativas baseadas em",
                         n_distinct(na.omit(bd$votos_estimados$pesquisa_id)),
                         "pesquisas publicadas entre",
                         str_to_title(format(min(bd$votos_estimados$dia), "%B/%y")),
                         "e",
                         str_to_title(format(max(bd$votos_estimados$dia), "%B/%y")),
                         "\nModelo:",
                         bd$nome_modelo),
         x = rotulo_eixo_x,
         y = NULL,
         fill = "Candidaturas") +
    # Tema
    theme_bw() +
    theme(text = element_text(family = config_grafico$fonte),
          plot.title = element_text(face = "bold", size = 18, hjust = .5),
          plot.subtitle = element_text(hjust = .5, color = "#777777"),
          plot.caption = element_text(size = 7, color = "#777777"),
          panel.border = element_blank(),
          legend.title = element_text(face = "bold", size = 9),
          legend.text = element_text(size = 9),
          legend.position = "top",
          axis.ticks = element_blank(),
          axis.title = element_text(size = 11),
          axis.text.x = element_text(size = 11),
          axis.text.y = element_text(face = "bold", size = 11))

  # 4. Salvar resultados ------------------------------------------------------
  if (salvar) {

    nome_arquivo <- paste0("Vies_Institutos_",
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