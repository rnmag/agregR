#' @noRd
#' @param bd The results object returned by `rodar_agregador`.
#' @param cand Candidate name.
#' @param parametro Parameter to extract ("mu" or "delta").
#' @return A tibble with posterior samples.
#' @importFrom dplyr select mutate filter distinct inner_join all_of
#' @importFrom tidyr pivot_longer
#' @importFrom stringr str_extract
#' @importFrom tibble as_tibble tibble
#' @importFrom cli cli_abort
extrair_amostras_post <- function(bd,
                                  cand,
                                  parametro) {

  # Extrair amostras para a candidatura
  amostras <- bd$modelo_bruto[[cand]]

  # Verificar se é um objeto CmdStanMCMC (R6) ou já é um data.frame (salvo)
  if (inherits(amostras, "CmdStanMCMC")) {

    amostras <- amostras$draws(format = "df")

  } else {

    amostras <- amostras

  }

  if (parametro == "delta") {

    # Regex para capturar delta evitando delta_raw, delta_priori, etc
    vetor_delta <- grep("^delta\\[\\d+\\]$", colnames(amostras), value = TRUE)

    # Extrair amostras de delta
    posterior <- amostras |>
      as_tibble() |>
      select(all_of(vetor_delta)) |>
      pivot_longer(cols = everything(),
                   names_to = "variavel",
                   values_to = "valor_estimado") |>
      mutate(instituto_num = as.integer(str_extract(variavel, "\\d+")))

    # Mapear ids de institutos do Stan com seus respectivos nomes. Filtrar por
    # candidato para reproduzir a criação de instituto_num em ajustar_modelo()
    vies_cand <- bd$vies_institutos |>
      filter(candidatura == !!cand) |>
      distinct(instituto, instituto_num)

    # Juntar vieses com as amostras posteriores
    posterior <- posterior |>
      inner_join(vies_cand, by = "instituto_num") |>
      mutate(candidatura = cand, parametro = "delta")

  } else if (parametro == "mu") {

    # Regex para capturar mu evitando mu_raw, mu_priori, etc
    vetor_mu <- grep("^mu(\\[\\d+\\])?$", colnames(amostras), value = TRUE)

    # Extrair os índices
    indice_mu <- as.numeric(str_extract(vetor_mu, "\\d+"))

    # Selecionar a última posteriori, com fallback se não houver índice
    ultimo_mu <- if (all(is.na(indice_mu))) "mu" else paste0("mu[", max(indice_mu, na.rm = TRUE), "]")

    posterior <- tibble(valor_estimado = as.numeric(amostras[[ultimo_mu]]),
                        candidatura = cand,
                        parametro = "mu")

  } else {

    cli_abort("Par\u00e2metro {.val {parametro}} n\u00e3o suportado em extrair_amostras_post(). Utilize 'mu' ou 'delta'.")

  }

  return(posterior)

}