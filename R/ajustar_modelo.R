#' @param bd Polling data frame.
#' @param candidatura Candidate name.
#' @param turno Election round.
#' @param data_inicio Start date.
#' @param data_fim End date.
#' @param modelo Model name.
#' @param stan_compilado Compiled Stan model object.
#' @param config_agregador Aggregator configuration list.
#' @param config_prioris Hyperparameters list.
#' @noRd
#' @importFrom dplyr mutate distinct left_join arrange n_distinct filter pull inner_join
#' @importFrom readr read_csv
#' @importFrom tibble tibble
#' @importFrom stringr str_extract
#' @importFrom cli cli_abort cli_alert_warning cli_h2
ajustar_modelo <- function(bd,
                           candidatura,
                           turno,
                           data_inicio,
                           data_fim,
                           modelo,
                           stan_compilado,
                           config_agregador,
                           config_prioris) {

  # 1. Preparação dos dados ---------------------------------------------------

  # Enumeração contígua de instituto e metodologia após aplicação dos filtros
  # em rodar_agregador(), para evitar problemas de indexação no Stan. Essas va-
  # riáveis não servem como ids estáveis
  bd <- bd |> mutate(instituto_num = as.integer(as.factor(instituto)),
                     metodologia_num = as.integer(as.factor(metodologia)))

  # Cálculo de erros para os modelos que usam dados históricos
  if (modelo %in% c("Vi\u00e9s Relativo com Pesos", "Vi\u00e9s Emp\u00edrico")) {

    prioris_emp <- calcular_prioris_empiricas(candidatura, turno, unique(bd$instituto), config_agregador)

    erro_institutos <- bd |>
      distinct(instituto, instituto_num) |>
      left_join(prioris_emp, by = "instituto") |>
      arrange(instituto_num)

  }

  # Seleção de configurações do modelo
  # total_dias usa min(bd$dia) em vez de data_inicio para que as estimativas
  # sejam ancoradas na primeira pesquisa disponível no período, em vez de par-
  # tirem de um valor arbitrário como 50%
  if (modelo == "Vi\u00e9s Relativo sem Pesos") {

    dados_stan <- list(n_dias = as.integer(bd$dia - min(bd$dia) + 1),
                       total_dias = as.integer(data_fim - min(bd$dia)) + 1,
                       n_pesquisas = nrow(bd),
                       n_institutos = n_distinct(bd$instituto_num),
                       n_metodologias = n_distinct(bd$metodologia_num),
                       percentual = bd$percentual_pesquisa,
                       sigma = bd$ep,
                       instituto = bd$instituto_num,
                       metodologia = bd$metodologia_num,
                       # Hiperparâmetros
                       delta_priori = config_prioris$delta_priori,
                       sd_delta_priori = config_prioris$sd_delta_priori,
                       # gamma_priori = config_prioris$gamma_priori,
                       # sd_gamma_priori = config_prioris$sd_gamma_priori,
                       tau_priori = config_prioris$tau_priori,
                       sd_tau_priori = config_prioris$sd_tau_priori,
                       mu_priori = config_prioris$mu_priori,
                       sd_mu_priori = config_prioris$sd_mu_priori,
                       eta_priori = config_prioris$eta_priori,
                       sd_eta_priori = config_prioris$sd_eta_priori,
                       nu_priori = config_prioris$nu_priori,
                       sd_nu_priori = config_prioris$sd_nu_priori,
                       zeta_priori = config_prioris$zeta_priori,
                       sd_zeta_priori = config_prioris$sd_zeta_priori)

  } else if (modelo == "Vi\u00e9s Relativo com Pesos") {

    dados_stan <- list(n_dias = as.integer(bd$dia - min(bd$dia) + 1),
                       total_dias = as.integer(data_fim - min(bd$dia)) + 1,
                       n_pesquisas = nrow(bd),
                       n_institutos = n_distinct(bd$instituto_num),
                       n_metodologias = n_distinct(bd$metodologia_num),
                       percentual = bd$percentual_pesquisa,
                       sigma = bd$ep,
                       instituto = bd$instituto_num,
                       metodologia = bd$metodologia_num,
                       # Prioris empíricas (eleição anterior)
                       emp_tau_priori = erro_institutos$emp_tau_priori,
                       # Hiperparâmetros
                       delta_priori = config_prioris$delta_priori,
                       sd_delta_priori = config_prioris$sd_delta_priori,
                       # gamma_priori = config_prioris$gamma_priori,
                       # sd_gamma_priori = config_prioris$sd_gamma_priori,
                       sd_tau_priori = config_prioris$sd_tau_priori,
                       mu_priori = config_prioris$mu_priori,
                       sd_mu_priori = config_prioris$sd_mu_priori,
                       eta_priori = config_prioris$eta_priori,
                       sd_eta_priori = config_prioris$sd_eta_priori,
                       nu_priori = config_prioris$nu_priori,
                       sd_nu_priori = config_prioris$sd_nu_priori,
                       zeta_priori = config_prioris$zeta_priori,
                       sd_zeta_priori = config_prioris$sd_zeta_priori)

  } else if (modelo == "Vi\u00e9s Emp\u00edrico") {

    dados_stan <- list(n_dias = as.integer(bd$dia - min(bd$dia) + 1),
                       total_dias = as.integer(data_fim - min(bd$dia)) + 1,
                       n_pesquisas = nrow(bd),
                       n_institutos = n_distinct(bd$instituto_num),
                       n_metodologias = n_distinct(bd$metodologia_num),
                       percentual = bd$percentual_pesquisa,
                       sigma = bd$ep,
                       instituto = bd$instituto_num,
                       metodologia = bd$metodologia_num,
                       # Prioris empíricas (eleição anterior)
                       emp_delta_priori = erro_institutos$emp_delta_priori,
                       emp_tau_priori = erro_institutos$emp_tau_priori,
                       # Hiperparâmetros
                       sd_delta_priori = config_prioris$sd_delta_priori,
                       # gamma_priori = config_prioris$gamma_priori,
                       # sd_gamma_priori = config_prioris$sd_gamma_priori,
                       sd_tau_priori = config_prioris$sd_tau_priori,
                       mu_priori = config_prioris$mu_priori,
                       sd_mu_priori = config_prioris$sd_mu_priori,
                       eta_priori = config_prioris$eta_priori,
                       sd_eta_priori = config_prioris$sd_eta_priori,
                       nu_priori = config_prioris$nu_priori,
                       sd_nu_priori = config_prioris$sd_nu_priori,
                       zeta_priori = config_prioris$zeta_priori,
                       sd_zeta_priori = config_prioris$sd_zeta_priori)

  } else if (modelo == "Retrospectivo") {

    # Este modelo usa o resultado da eleição como ponto de partida e reconstroi a
    # trajetória da opinião pública de trás para frente. Não é um modelo útil du-
    # rante a campanha, mas depois da eleição ele pode calcular vieses precisos e
    # ajudar no diagnóstico dos outros modelos.
    #
    # Para rodá-lo corretamente, é necessário atualizar os resultados no arquivo
    # resultado_eleicao_atual.csv. O pacote fará essa atualização assim que os
    # resultados forem liberados.
    #
    # É recomendado preencher a coluna total_votos com a soma de votos válidos +
    # brancos/nulos, pois a base histórica de pesquisas do Poder360 apenas inclui
    # as intenções de voto nominais.

    cli_alert_warning(paste("Para fazer a an\u00e1lise retrospectiva, este modelo",
                            "depende dos resultados da elei\u00e7\u00e3o. Ele usa",
                            "esses resultados para calcular vieses precisos, auxiliando",
                            "o diagn\u00f3stico dos outros modelos."))

    cli_alert_warning("Atualizaremos os dados assim que estiverem dispon\u00edveis.")

    # Usar ler_csv para flexibilidade (URL ou local/extdata)
    caminho_resultado_atual <- if (is.null(config_agregador$resultado_eleicao_atual)) "resultado_eleicao_atual.csv" else config_agregador$resultado_eleicao_atual

    # Como ler_csv procura em inst/extdata, não precisamos verificar file.exists
    # aqui se usamos o nome padrão
    resultado_eleicao_atual <- ler_csv(caminho_resultado_atual) |>
      filter(nome == candidatura,
             turno == !!turno) |>
      mutate(resultado = round(votos_recebidos / total_votos, 4)) |>
      pull(resultado)

    dados_stan <- list(n_dias = as.integer(bd$dia - min(bd$dia) + 1),
                       total_dias = as.integer(data_fim - min(bd$dia)) + 1,
                       n_pesquisas = nrow(bd),
                       n_institutos = n_distinct(bd$instituto_num),
                       n_metodologias = n_distinct(bd$metodologia_num),
                       percentual = bd$percentual_pesquisa,
                       sigma = bd$ep,
                       instituto = bd$instituto_num,
                       metodologia = bd$metodologia_num,
                       # Resultado real da eleição
                       resultado_final = resultado_eleicao_atual,
                       # Hiperparâmetros
                       delta_priori = config_prioris$delta_priori,
                       sd_delta_priori = config_prioris$sd_delta_priori,
                       # gamma_priori = config_prioris$gamma_priori,
                       # sd_gamma_priori = config_prioris$sd_gamma_priori,
                       tau_priori = config_prioris$tau_priori,
                       sd_tau_priori = config_prioris$sd_tau_priori,
                       mu_priori = config_prioris$mu_priori,
                       sd_mu_priori = config_prioris$sd_mu_priori,
                       eta_priori = config_prioris$eta_priori,
                       sd_eta_priori = config_prioris$sd_eta_priori,
                       nu_priori = config_prioris$nu_priori,
                       sd_nu_priori = config_prioris$sd_nu_priori,
                       zeta_priori = config_prioris$zeta_priori,
                       sd_zeta_priori = config_prioris$sd_zeta_priori)

  } else if (modelo == "Naive") {

    dados_stan <- list(n_dias = as.integer(bd$dia - min(bd$dia) + 1),
                       total_dias = as.integer(data_fim - min(bd$dia)) + 1,
                       n_pesquisas = nrow(bd),
                       percentual = bd$percentual_pesquisa,
                       sigma = bd$ep,
                       # Hiperparâmetros
                       mu_priori = config_prioris$mu_priori,
                       sd_mu_priori = config_prioris$sd_mu_priori,
                       eta_priori = config_prioris$eta_priori,
                       sd_eta_priori = config_prioris$sd_eta_priori)

  } else {

    cli_abort("Modelo n\u00e3o encontrado. Use 'Vi\u00e9s Relativo sem Pesos', 'Vi\u00e9s Relativo com Pesos', 'Vi\u00e9s Emp\u00edrico', 'Retrospectivo' ou 'Naive'.")

  }

  # 2. Rodar modelo e extrair resultados --------------------------------------

  cli_h2("Estimando inten\u00e7\u00e3o de votos para: {.val {candidatura}}")

  # Rodar o modelo
  modelo_bruto <- stan_compilado$sample(data = dados_stan,
                                        parallel_chains = config_agregador$stan$cores,
                                        chains = config_agregador$stan$chains,
                                        iter_warmup = config_agregador$stan$warmup,
                                        iter_sampling = config_agregador$stan$sampling,
                                        init = config_agregador$stan$init,
                                        adapt_delta = config_agregador$stan$adapt_delta)

  # Extração das intenções de voto estimadas e junção com base de pesquisas
  sumario_votos <- modelo_bruto$summary("mu", ~quantile(.x, probs = c(0.025, 0.5, 0.975)))

  votos_estimados <- tibble(dia = seq.Date(min(bd$dia), data_fim, by = "day"),
                            li = round(sumario_votos$`2.5%`, 4),
                            mediana = round(sumario_votos$`50%`, 4),
                            ls = round(sumario_votos$`97.5%`, 4),
                            percentual_estimado = scales::label_percent(1)(mediana)) |>
    left_join(bd, by = "dia") |>
    arrange(dia)

  # Modelo Naive termina aqui
  if (modelo == "Naive") {
    return(list(votos_estimados = votos_estimados,
                vies_institutos = NULL,
                # vies_metodologia = NULL,
                modelo_bruto = modelo_bruto))
  }

  # Extração do viés de institutos
  sumario_vies_institutos <- modelo_bruto$summary("delta", ~ quantile(.x, probs = c(0.025, 0.5, 0.975))) |>
    mutate(instituto_num = as.numeric(str_extract(variable, "\\d+")))

  vies_institutos <- bd |>
    distinct(instituto, instituto_num) |>
    inner_join(tibble(instituto_num = sumario_vies_institutos$instituto_num,
                      li = round(sumario_vies_institutos$`2.5%`, 4),
                      mediana = round(sumario_vies_institutos$`50%`, 4),
                      ls = round(sumario_vies_institutos$`97.5%`, 4)),
               by = "instituto_num") |>
    arrange(instituto_num)

  # Extração do viés de metodologias
  # sumario_vies_metodologia <- modelo_bruto$summary("gamma", ~ quantile(.x, probs = c(0.025, 0.5, 0.975))) |>
  #   mutate(metodologia_num = as.numeric(str_extract(variable, "\\d+")))

  # vies_metodologia <- bd |>
  #   distinct(metodologia, metodologia_num) |>
  #   inner_join(tibble(metodologia_num = sumario_vies_metodologia$metodologia_num,
  #                     li = round(sumario_vies_metodologia$`2.5%`, 4),
  #                     mediana = round(sumario_vies_metodologia$`50%`, 4),
  #                     ls = round(sumario_vies_metodologia$`97.5%`, 4)),
  #              by = "metodologia_num") |>
  #   arrange(metodologia_num)

  return(list(votos_estimados = votos_estimados,
              vies_institutos = vies_institutos,
              # vies_metodologia = vies_metodologia,
              modelo_bruto = modelo_bruto))

}