#' @title Configuration for Graphics
#' @description Defines configuration parameters for graphics, including colors, fonts, and dimensions.
#' @param fonte Font family (default: "Fira Sans").
#' @param cores_candidaturas Named vector or list of colors for candidates. Can be a partial override.
#' @param simbolos Named vector or list of symbols for methodologies. Can be a partial override.
#' @param graf_largura Width of saved plots.
#' @param graf_altura Height of saved plots.
#' @param graf_unidade Unit for dimensions ("px", "in", "cm", "mm").
#' @param graf_dpi DPI for saved plots.
#' @param dir_grafico Directory to save plots.
#' @return A list of graphic configuration parameters.
#' @export
#' @importFrom utils modifyList
#' @examples
#' # Alternative colors for use in the config_grafico argument in a plot
#' config_custom <- configurar_grafico(
#'   cores_candidaturas = c(Lula = "darkred")
#' )
configurar_grafico <- function(fonte = "Fira Sans",
                               cores_candidaturas = NULL,
                               simbolos = NULL,
                               graf_largura = 2918,
                               graf_altura = 1913,
                               graf_unidade = "px",
                               graf_dpi = 320,
                               dir_grafico = "resultados_agregador/graficos") {

  # Valores originais
  cores_padrao <- list(Lula = "#CF4446",
                       Bolsonaro = "#9000C8",
                       "Tarc\u00edsio" = "#008564",
                       "Fl\u00e1vio" = "#446AAF")

  simbolos_padrao <- list(Online = 3,
                          Presencial = 1,
                          "Telef\u00f4nica" = 19)

  # Mudanças do usuário
  cores_candidaturas <- if (is.null(cores_candidaturas)) {

    cores_padrao

  } else {

    modifyList(cores_padrao, as.list(cores_candidaturas))

  }

  simbolos <- if (is.null(simbolos)) {

    simbolos_padrao

  } else {

    modifyList(simbolos_padrao, as.list(simbolos))

  }

  list(fonte = fonte,
       cores_candidaturas = cores_candidaturas,
       simbolos = simbolos,
       graf_agregador = list(largura = graf_largura,
                             altura = graf_altura,
                             unidade = graf_unidade,
                             dpi = graf_dpi),
       dir_grafico = dir_grafico)
}
