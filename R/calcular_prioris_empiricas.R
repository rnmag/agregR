#' @noRd
#' @importFrom dplyr filter group_by summarise left_join mutate if_else
calcular_prioris_empiricas <- function(candidatura, turno, institutos, config_agregador) {

  # Carregar base histórica
  bd_historico <- tratar_bd_historico(bd = config_agregador$historico_pesquisas,
                                      primeiro_turno = data_robusta(config_agregador$data_primeiro_turno),
                                      segundo_turno = data_robusta(config_agregador$data_segundo_turno),
                                      config_agregador = config_agregador)

  # Atribuir erros históricos dos institutos às candidaturas do mesmo campo
  if (candidatura %in% unlist(config_agregador$direita_eleicao_atual)) {

    bd_historico <- bd_historico |> filter(nome_candidato == config_agregador$direita_eleicao_passada, turno == !!turno)

  } else if (candidatura %in% unlist(config_agregador$esquerda_eleicao_atual)) {

    bd_historico <- bd_historico |> filter(nome_candidato == config_agregador$esquerda_eleicao_passada, turno == !!turno)

  } else {

    bd_historico <- bd_historico |> filter(turno == !!turno)

  }

  # Erro médio por instituto
  resumo_historico <- bd_historico |>
    group_by(instituto) |>
    summarise(emp_delta_priori = mean(erro_total, na.rm = TRUE),
              emp_tau_priori = mean(erro_nao_amostral, na.rm = TRUE),
              .groups = "drop")

  # Juntar com lista de institutos do modelo e imputar médias para os faltantes
  vies_calculado <- tibble(instituto = unique(institutos)) |>
    left_join(resumo_historico, by = "instituto") |>
    mutate(emp_delta_priori = if_else(is.na(emp_delta_priori),
                                      mean(emp_delta_priori, na.rm = TRUE),
                                      emp_delta_priori),
           emp_tau_priori = if_else(is.na(emp_tau_priori),
                                    mean(emp_tau_priori, na.rm = TRUE),
                                    emp_tau_priori))

  return(vies_calculado)

}
