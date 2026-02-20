#' @param bd Polling data frame.
#' @param turno Election round.
#' @param data_inicio Start date.
#' @param data_fim End date.
#' @param modelo Model name.
#' @param stan_compilado Compiled Stan model object.
#' @param config_agregador Aggregator configuration list.
#' @param config_prioris Hyperparameters list.
#' @noRd
#' @importFrom dplyr mutate distinct left_join arrange n_distinct filter pull inner_join group_by summarize ungroup pivot_wider everything select
#' @importFrom readr read_csv
#' @importFrom tibble tibble
#' @importFrom stringr str_extract
#' @importFrom cli cli_abort cli_alert_warning cli_h2
#' @importFrom tidyr pivot_wider
ajustar_modelo <- function(bd,
                           turno,
                           data_inicio,
                           data_fim,
                           modelo,
                           stan_compilado,
                           config_agregador,
                           config_prioris) {

  # 1. Preparação dos dados ---------------------------------------------------

  # Lista de candidaturas na ordem correta
  candidaturas_ordenadas <- sort(unique(bd$candidatura))
  n_candidatos <- length(candidaturas_ordenadas)

  # Enumeração contígua de instituto e metodologia
  bd <- bd |> mutate(instituto_num = as.integer(as.factor(instituto)),
                     metodologia_num = as.integer(as.factor(metodologia)))

  # Criar matriz de votos
  # Linhas: Pesquisas
  # Colunas: Candidatos (ordenados)
  bd_matrix <- bd |>
    mutate(votos = round(percentual_pesquisa * n_efetivo)) |>
    select(pesquisa_id, dia, instituto_num, metodologia_num, n_efetivo, candidatura, votos) |>
    pivot_wider(names_from = candidatura, values_from = votos, values_fill = 0) |>
    arrange(dia)
    
  # Garantir ordem das colunas de candidatos
  colunas_votos <- bd_matrix |> select(all_of(candidaturas_ordenadas)) |> as.matrix()
  
  # Base comum para dados_stan
  dados_stan <- list(
    total_dias = as.integer(data_fim - min(bd$dia)) + 1,
    n_pesquisas = nrow(bd_matrix),
    n_institutos = n_distinct(bd$instituto_num),
    n_candidatos = n_candidatos,
    n_dias = as.integer(bd_matrix$dia - min(bd$dia) + 1),
    instituto = bd_matrix$instituto_num,
    votos = colunas_votos,
    
    # Prioris Comuns
    lkj_corr_priori = config_prioris$lkj_corr_priori,
    
    mu_priori = rep(config_prioris$mu_priori, n_candidatos - 1),
    sd_mu_priori = rep(config_prioris$sd_mu_priori, n_candidatos - 1),
    
    omega_eta_priori = config_prioris$omega_eta_priori,
    sd_omega_eta_priori = config_prioris$sd_omega_eta_priori,
    
    nu_priori = rep(config_prioris$nu_priori, n_candidatos - 1),
    sd_nu_priori = rep(config_prioris$sd_nu_priori, n_candidatos - 1),
    
    omega_zeta_priori = config_prioris$omega_zeta_priori,
    sd_omega_zeta_priori = config_prioris$sd_omega_zeta_priori
  )

  # Adições específicas por modelo
  if (modelo == "Naive") {
    # Modelo Naive só precisa do básico já definido
    # (Não usa delta_priori nem tau_priori)
    
  } else if (modelo == "Retrospectivo") {
    
    # Adicionar prioris de viés e tau
    dados_stan$delta_priori <- config_prioris$delta_priori
    dados_stan$sd_delta_priori <- config_prioris$sd_delta_priori
    dados_stan$sd_tau_priori <- config_prioris$sd_tau_priori
    
    # Carregar e processar resultado final
    cli_alert_warning("Modelo Retrospectivo: Verificando resultados da elei\u00e7\u00e3o...")
    
    caminho_resultado <- if (is.null(config_agregador$resultado_eleicao_atual)) "resultado_eleicao_atual.csv" else config_agregador$resultado_eleicao_atual
    
    if (file.exists(caminho_resultado)) {
       resultados_df <- ler_csv(caminho_resultado) |>
        filter(nome %in% candidaturas_ordenadas, turno == !!turno) |>
        mutate(resultado = round(votos_recebidos / total_votos, 4))
       
       # Garantir ordem
       res_vetor <- resultados_df |>
         arrange(factor(nome, levels = candidaturas_ordenadas)) |>
         pull(resultado)
         
       # Se faltar candidato, preencher ou avisar (aqui assumimos completo)
       if(length(res_vetor) != n_candidatos) cli_alert_warning("N\u00famero de candidatos no resultado difere do esperado!")
       
       # Normalizar
       dados_stan$resultado_final <- res_vetor / sum(res_vetor)
    } else {
       cli_abort("Arquivo de resultados n\u00e3o encontrado para modelo Retrospectivo.")
    }

  } else {
    # Modelos de Viés (Relativo Com/Sem Pesos, Empírico)
    
    dados_stan$delta_priori <- config_prioris$delta_priori
    dados_stan$sd_delta_priori <- config_prioris$sd_delta_priori
    dados_stan$sd_tau_priori <- config_prioris$sd_tau_priori
    
    if (modelo == "Vi\u00e9s Relativo com Pesos") {
       # Calcular prioris empíricas e expandir para matriz
       prioris_emp <- calcular_prioris_empiricas(candidaturas_ordenadas[1], turno, unique(bd$instituto), config_agregador)
       
       erro_institutos_df <- bd |>
         distinct(instituto, instituto_num) |>
         left_join(prioris_emp, by = "instituto") |>
         arrange(instituto_num)
         
       # Expandir escalar para matriz [n_inst, P-1]
       dados_stan$emp_tau_priori <- matrix(rep(erro_institutos_df$emp_tau_priori, n_candidatos - 1), 
                                           nrow = nrow(erro_institutos_df), 
                                           ncol = n_candidatos - 1)
    }

    if (modelo == "Vi\u00e9s Relativo sem Pesos") {
       dados_stan$tau_priori <- config_prioris$tau_priori
    }
    
    if (modelo == "Vi\u00e9s Emp\u00edrico") {
       # Similar ao acima, mas para delta
       prioris_emp <- calcular_prioris_empiricas(candidaturas_ordenadas[1], turno, unique(bd$instituto), config_agregador)
       
       erro_institutos_df <- bd |>
         distinct(instituto, instituto_num) |>
         left_join(prioris_emp, by = "instituto") |>
         arrange(instituto_num)
         
       dados_stan$emp_delta_priori <- matrix(rep(erro_institutos_df$emp_delta_priori, n_candidatos - 1), 
                                             nrow = nrow(erro_institutos_df), 
                                             ncol = n_candidatos - 1)
       
       dados_stan$emp_tau_priori <- matrix(rep(erro_institutos_df$emp_tau_priori, n_candidatos - 1), 
                                           nrow = nrow(erro_institutos_df), 
                                           ncol = n_candidatos - 1)
    }
  }

  # 2. Rodar modelo e extrair resultados --------------------------------------

  cli_h2("Estimando inten\u00e7\u00e3o de votos (Multivariado)...")

  # Rodar o modelo
  modelo_bruto <- stan_compilado$sample(data = dados_stan,
                                        parallel_chains = config_agregador$stan$cores,
                                        chains = config_agregador$stan$chains,
                                        iter_warmup = config_agregador$stan$warmup,
                                        iter_sampling = config_agregador$stan$sampling,
                                        init = config_agregador$stan$init,
                                        adapt_delta = config_agregador$stan$adapt_delta)

  # Extrair draws de 'mu' e achatar
  sumario_votos <- modelo_bruto$summary("mu", ~quantile(.x, probs = c(0.025, 0.5, 0.975)))
  
  votos_estimados <- sumario_votos |>
    mutate(
      dia_idx = as.integer(str_extract(variable, "(?<=\\[)\\d+")),
      cand_idx = as.integer(str_extract(variable, "(?<=,)\\d+")),
      candidatura = candidaturas_ordenadas[cand_idx],
      dia = min(bd$dia) + dia_idx - 1,
      li = round(`2.5%`, 4),
      mediana = round(`50%`, 4),
      ls = round(`97.5%`, 4),
      percentual_estimado = scales::label_percent(1)(mediana)
    ) |>
    select(dia, candidatura, li, mediana, ls, percentual_estimado) |>
    right_join(bd, by = c("dia", "candidatura" = "candidatura")) |> 
    arrange(dia, candidatura)

  # Extração do viés de institutos (se não for Naive)
  vies_institutos <- NULL
  if (modelo != "Naive") {
    sumario_delta <- modelo_bruto$summary("delta", ~quantile(.x, probs = c(0.025, 0.5, 0.975)))
    
    vies_institutos <- sumario_delta |>
      mutate(
        inst_idx = as.integer(str_extract(variable, "(?<=\\[)\\d+")),
        cand_idx = as.integer(str_extract(variable, "(?<=,)\\d+"))
      ) |>
      mutate(
        candidatura = candidaturas_ordenadas[cand_idx],
        instituto_num = inst_idx,
        li = round(`2.5%`, 4),
        mediana = round(`50%`, 4),
        ls = round(`97.5%`, 4)
      ) |>
      inner_join(bd |> distinct(instituto, instituto_num), by = "instituto_num") |>
      select(instituto, candidatura, li, mediana, ls)
  }

  return(list(votos_estimados = votos_estimados,
              vies_institutos = vies_institutos,
              modelo_bruto = modelo_bruto))
}