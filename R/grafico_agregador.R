#' @encoding UTF-8
#' @title Plot Aggregator Results
#' @description Generates a plot of the aggregated poll results over time.
#' @param bd The results object returned by `rodar_agregador`.
#' @param salvar Logical. If TRUE, saves the plot to disk.
#' @param config_grafico A list of graphic parameters created by `configurar_grafico()`.
#' @param dir_saida Output directory for the saved plot if `salvar = TRUE`.
#' @param ... Additional arguments.
#' @return A ggplot2 object.
#' @export
#' @examples
#' if (instantiate::stan_cmdstan_exists()) {
#'   # Generate results
#'   result <- rodar_agregador(turno = 2, cenario = "Lula vs Bolsonaro", salvar = FALSE)
#'
#'   # Standard plot
#'   grafico_agregador(result, salvar = FALSE)
#'
#'   # Altering candidate colors
#'   grafico_agregador(
#'     result,
#'     salvar = FALSE,
#'     config_grafico = configurar_grafico(
#'       cores_candidaturas = c(Lula = "darkred")
#'     )
#'   )
#' }
#' @importFrom cli cli_abort cli_alert_success cli_alert_info
#' @importFrom ggplot2 ggplot aes geom_line geom_ribbon geom_point geom_text coord_cartesian scale_fill_manual scale_colour_manual scale_shape_manual guides guide_legend scale_y_continuous scale_x_date labs theme_bw theme element_text margin element_blank element_line element_rect ggsave expansion unit
#' @importFrom dplyr group_by slice_max if_else lag n_distinct
#' @importFrom stringr str_to_title
#' @importFrom lubridate year month
#' @importFrom ragg agg_png
grafico_agregador <- function(bd,
                              salvar = FALSE,
                              config_grafico = configurar_grafico(),
                              dir_saida = ".",
                              ...) {

  # 1. Configuração e validação -----------------------------------------------

  # Temporariamente desativar showtext
  showtext::showtext_auto(FALSE)

  # Identificar turno
  turno <- unique(na.omit(bd$votos_estimados$turno))

  # Configurações que dependem do turno
  if (turno == 1) {

    titulo_grafico <- "Agregador de Pesquisas - 1\u00ba Turno"
    nome_arquivo <- "Agregador_1t.png"

  } else if (turno == 2) {

    titulo_grafico <- "Agregador de Pesquisas - 2\u00ba Turno"
    sufixo_cenario <- colar_ascii(unique(bd$votos_estimados$candidatura))
    nome_arquivo <- paste0("Agregador_2t_", sufixo_cenario, ".png")

  } else {

    cli_abort("Obrigat\u00f3rio definir o turno. Use turno = 1 ou turno = 2.")

  }

  # Adaptar subtítulo ao modelo
  if (bd$nome_modelo == "Vi\u00e9s Relativo sem Pesos") {

    subtitulo_grafico <- "Estimativa das inten\u00e7\u00f5es de voto ajustada pelo vi\u00e9s dos institutos"

  } else if (bd$nome_modelo == "Vi\u00e9s Relativo com Pesos") {

    subtitulo_grafico <- "Estimativa das inten\u00e7\u00f5es de voto ponderada pelo erro dos institutos na elei\u00e7\u00e3o passada"

  } else if (bd$nome_modelo == "Vi\u00e9s Emp\u00edrico") {

    subtitulo_grafico <- "Estimativa das inten\u00e7\u00f5es de voto compensada pelo erro dos institutos na elei\u00e7\u00e3o passada"

  } else if (bd$nome_modelo == "Retrospectivo") {

    subtitulo_grafico <- "Recomposi\u00e7\u00e3o da trajet\u00f3ria das candidaturas ap\u00f3s resultado final"

  } else if (bd$nome_modelo == "Naive") {

    subtitulo_grafico <- "Estimativa das inten\u00e7\u00f5es de voto sem ajustes"

  }

  # 2. Gráfico ----------------------------------------------------------------
  p <- bd$votos_estimados |>
    ggplot(aes(x = dia,
               y = mediana)) +
    # Definição dos geoms
    geom_line(aes(color = candidatura),
              lineend = "round",
              linewidth = 1.5) +
    geom_ribbon(aes(ymin = li,
                    ymax = ls,
                    fill = candidatura),
                alpha = 0.1) +
    geom_point(aes(y = percentual_pesquisa,
                   color = candidatura,
                   shape = metodologia),
               size = 2,
               alpha = .8,
               na.rm = TRUE) +
    geom_text(data = bd$votos_estimados |>
                group_by(candidatura) |>
                slice_max(dia, n = 1, with_ties = FALSE),
              aes(label = percentual_estimado,
                  color = candidatura),
              size = 6,
              family = config_grafico$fonte,
              fontface = "bold",
              hjust = -.25,
              show.legend = FALSE) +
    coord_cartesian(clip = "off") + # percentuais podem passar a borda do gráfico
    # Legendas
    scale_fill_manual(values = unlist(config_grafico$cores_candidaturas)) +
    scale_colour_manual(values = unlist(config_grafico$cores_candidaturas)) +
    scale_shape_manual(values = unlist(config_grafico$simbolos), na.translate = FALSE) +
    guides(color = guide_legend(order = 1),
           fill = guide_legend(order = 1),
           shape = guide_legend(order = 2)) +
    # Eixos
    scale_y_continuous(expand = expansion(mult = c(.02, .02)),
                       labels = scales::label_percent(1)) +
    scale_x_date(expand = expansion(mult = c(.025, 0)),
                 limits = c(min(bd$votos_estimados$dia), max(bd$votos_estimados$dia)),
                 date_breaks = "1 month",
                 labels = \(x) {
                   if_else(is.na(lag(x)) | year(lag(x)) != year(x),
                           paste0(str_to_title(month(x, label = TRUE)), "\n", year(x)),
                           paste0(str_to_title(month(x, label = TRUE))))
                 }) +
    # Rótulos
    labs(title = titulo_grafico,
         subtitle = subtitulo_grafico,
         caption = paste("Estimativas baseadas em",
                         n_distinct(na.omit(bd$votos_estimados$pesquisa_id)),
                         "pesquisas publicadas entre",
                         str_to_title(format(min(bd$votos_estimados$dia), "%B/%y")),
                         "e",
                         str_to_title(format(max(bd$votos_estimados$dia), "%B/%y")),
                         "| Modelo:",
                         bd$nome_modelo,
                         "\nInstitutos:",
                         formatar_lista(unique(sort(bd$votos_estimados$instituto)))),
         color = "Candidaturas",
         fill = "Candidaturas",
         shape = "Metodologia") +
    # Tema
    theme_bw() +
    theme(text = element_text(family = config_grafico$fonte),
          plot.title = element_text(face = "bold", size = 18, hjust = .5),
          plot.subtitle = element_text(hjust = .5, color = "#777777"),
          plot.caption = element_text(size = 7, color = "#777777"),
          plot.margin = margin(.1, 1.5, .1, .1, "cm"),
          panel.grid.minor = element_blank(),
          panel.grid.major.x = element_blank(),
          panel.border = element_blank(),
          axis.line.x.bottom = element_line(color = "black", linewidth = 1),
          axis.title = element_blank(),
          axis.ticks = element_blank(),
          axis.text.x = element_text(size = 11),
          axis.text.y = element_text(size = 11),
          legend.title = element_text(face = "bold", size = 9),
          legend.text = element_text(size = 9),
          legend.position = "top",
          legend.box = "vertical",
          legend.spacing.y = unit(-10, "pt"),
          legend.background = element_rect(fill = "transparent"))

  # 3. Salvar resultados ------------------------------------------------------
  if (salvar) {

    arquivo <- gerar_saida(file.path(dir_saida, config_grafico$dir_grafico), bd$nome_modelo, nome_arquivo)

    # Registrar fonte antes de salvar
    registrar_fonte(config_grafico$graf_agregador$dpi)

    ggsave(arquivo,
           p,
           device = agg_png,
           width = config_grafico$graf_agregador$largura,
           height = config_grafico$graf_agregador$altura,
           units = config_grafico$graf_agregador$unidade,
           dpi = config_grafico$graf_agregador$dpi)

    cli_alert_success("Gr\u00e1fico salvo em {.file {arquivo}}")

  }

  # Registrar fonte para exibição em tela
  registrar_fonte(config_grafico$graf_agregador$dpi)

  return(p)

}
