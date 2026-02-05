#' @param nome_digitado Character. Candidate name provided by user.
#' @noRd
#' @importFrom stringi stri_trans_general
nome_robusto <- function(nome_digitado) {
  nomes_padronizados <- c("Lula",
                          "Bolsonaro",
                          "Ciro",
                          "Simone",
                          "Moro",
                          "Tarc\u00edsio",
                          "Fl\u00e1vio",
                          "Eduardo",
                          "Caiado",
                          "Zema",
                          "Ratinho Jr.",
                          "Renan")

  nomes_alternativos <- list(Lula = c("lula", "luiz inacio lula da silva", "luis inacio lula da silva"),
                             Bolsonaro = c("bolsonaro", "jair bolsonaro", "jair messias bolsonaro"),
                             Ciro = c("ciro", "ciro gomes", "gomes"),
                             Simone = c("simone", "simone tebet", "tebet"),
                             Moro = c("moro", "sergio moro"),
                             "Tarc\u00edsio" = c("tarcisio", "tarcisio de freitas", "freitas"),
                             "Fl\u00e1vio" = c("flavio", "flavio bolsonaro"),
                             Eduardo = c("eduardo", "eduardo bolsonaro"),
                             Caiado = c("caiado", "ronaldo caiado"),
                             Zema = c("zema", "romeu zema", "romeu"),
                             `Ratinho Jr.` = c("ratinho", "ratinho jr", "ratinho jr.", "ratinho junior"),
                             Renan = c("renan", "renan santos"))

  nome_digitado_ascii <- stringi::stri_trans_general(tolower(nome_digitado), "Latin-ASCII")

  for (i in nomes_padronizados) {
    if (nome_digitado_ascii %in% nomes_alternativos[[i]]) {
      return(i)
    }
  }

  return(nome_digitado)
}

#' @param x Date or character string.
#' @noRd
data_robusta <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }
  if (inherits(x, "Date") || inherits(x, "POSIXt")) {
    return(as.Date(x))
  }
  as.Date(lubridate::parse_date_time(x, orders = c("ymd", "dmy"), quiet = TRUE))
}

#' @param x Character vector.
#' @noRd
formatar_lista <- function(x) {
  n <- length(x)
  if (n == 0) return("")
  if (n == 1) return(as.character(x))
  if (n == 2) return(paste(x, collapse = " e "))
  paste0(paste(x[1:(n - 1)], collapse = ", "), " e ", x[n])
}

#' @param x Character.
#' @noRd
limpar_texto <- function(x) {
  stringi::stri_trans_general(gsub(" ", "_", x), "Latin-ASCII")
}

#' @param x Character.
#' @noRd
limpar_texto_minusculo <- function(x) {
  stringi::stri_trans_general(tolower(gsub(" ", "_", x)), "Latin-ASCII")
}

#' @param items Character vector.
#' @noRd
colar_ascii <- function(items) {
  stringi::stri_trans_general(paste0(items, collapse = "_"), "Latin-ASCII")
}

#' @param dir_base Character. Base directory.
#' @param nome_modelo Character. Model name.
#' @param nome_arquivo Character. File name.
#' @noRd
gerar_saida <- function(dir_base, nome_modelo, nome_arquivo = NULL) {
  # Subdiretório baseado no nome do modelo
  sub_dir <- limpar_texto_minusculo(nome_modelo)
  dir_completo <- file.path(dir_base, sub_dir)

  # Garantir existência
  if (!dir.exists(dir_completo)) {
    dir.create(dir_completo, recursive = TRUE)
  }

  if (is.null(nome_arquivo)) {
    return(dir_completo)
  }

  return(file.path(dir_completo, nome_arquivo))
}

#' @param turno Integer. Round number.
#' @param dados Data frame. Polling data.
#' @noRd
cenarios_disponiveis <- function(turno, dados) {
  cenarios <- ler_csv(dados) |>
    dplyr::filter(turno == !!turno) |>
    dplyr::pull(cenario) |>
    unique()

  return(cenarios)
}

#' @param caminho Character string (URL or path) or data frame.
#' @param arquivo_local_fallback Character. Filename to look for if URL fails.
#' @noRd
#' @importFrom readr read_csv read_csv2
#' @importFrom cli cli_alert_warning cli_abort cli_alert_success
ler_csv <- function(caminho, arquivo_local_fallback = NULL) {

  # Se já for dataframe, usa ele
  if (is.data.frame(caminho)) return(caminho)

  if (is.null(caminho)) return(NULL)

  # Função auxiliar tenta ler com diferentes delimitadores
  ler_robusto <- function(file) {
    # Tenta ler com ; (padrão brasileiro)
    dados <- read_csv2(file,
                       show_col_types = FALSE,
                       locale = locale(decimal_mark = ",",
                                       grouping_mark = "."))

    # Se falhar (apenas 1 coluna), tenta com ,
    if (ncol(dados) <= 1) {
      dados_comma <- suppressWarnings(read_csv(file, show_col_types = FALSE))
      if (ncol(dados_comma) > 1) {
        return(dados_comma)
      }
    }
    return(dados)
  }

  # Verifica se é URL
  verifica_url <- grepl("^http", caminho)

  if (verifica_url) {

    # Tenta ler da URL, se falhar retorna NULL
    dados <- tryCatch({
      ler_robusto(caminho)
    }, error = function(e) {
      NULL
    })

    if (!is.null(dados) && ncol(dados) > 1) {

      return(dados)

    }

    cli_alert_warning("Falha ao baixar dados da internet. Tentando arquivo local, que pode estar desatualizado.")

  }

  # Se falhou ou não é URL, tentar o fallback, se nãp houver tentamos o basename de 'caminho'
  arq_local <- if (verifica_url) {
    if (!is.null(arquivo_local_fallback)) arquivo_local_fallback else basename(caminho)
  } else {
    caminho
  }

  # É arquivo?
  if (file.exists(arq_local)) {
    return(ler_robusto(arq_local))
  }

  # Verifica se existem dados em inst/extdata
  arquivo_pacote <- system.file("extdata", basename(arq_local), package = "agregR")

  if (arquivo_pacote != "") {
    return(ler_robusto(arquivo_pacote))
  }

  cli_abort("N\u00e3o foi poss\u00edvel ler os dados. Verifique a configura\u00e7\u00e3o do agregador.")

}

#' @param dpi Numeric. DPI for showtext (default: 96).
#' @noRd
#' @importFrom sysfonts font_add font_families
#' @importFrom showtext showtext_auto showtext_opts
registrar_fonte <- function(dpi = 96) {

  # Configurar DPI para o showtext
  showtext::showtext_opts(dpi = dpi)

  # Checar se a fonte já está instalada sem avisos
  if ("Fira Sans" %in% sysfonts::font_families()) {
    showtext::showtext_auto()
    return(invisible())
  }

  # Localizar arquivos da fonte
  fonte_regular <- system.file("fonts", "FiraSans-Regular.ttf", package = "agregR")
  fonte_negrito <- system.file("fonts", "FiraSans-Bold.ttf", package = "agregR")
  fonte_italico <- system.file("fonts", "FiraSans-Italic.ttf", package = "agregR")

  # Registrar a fonte
  if (file.exists(fonte_regular) && file.exists(fonte_negrito) && file.exists(fonte_italico)) {
    sysfonts::font_add(family = "Fira Sans",
                       regular = fonte_regular,
                       italic = fonte_italico,
                       bold = fonte_negrito)

    # Usar a fonte
    showtext::showtext_auto()
  }
}

#' @importFrom stats setNames
#' @importFrom tidyselect everything
utils::globalVariables(c(
  "ambito", "candidatura", "cargo", "cenario", "data", "dia",
  "emp_delta_priori", "emp_tau_priori", "ep", "erro_nao_amostral",
  "erro_total", "historico_pesquisas_poder360", "instituto",
  "instituto_num", "li", "ls", "margem_mais", "margem_pesquisa",
  "mediana", "metodologia", "metodologia_num", "modelos",
  "n_efetivo", "nome", "nome_candidato", "percentual",
  "percentual_estimado", "percentual_pesquisa", "pesquisa_id",
  "qtd_entrevistas", "quantidade_entrevistas", "resultado",
  "sigla_uf", "total_votos", "turno", "valor_estimado",
  "variable", "variavel", "vies_institutos", "votos_estimados",
  "votos_recebidos", "x", "y"
))
