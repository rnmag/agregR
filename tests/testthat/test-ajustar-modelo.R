test_that("ajustar_modelo prepara dados e delega ao Stan (Naive)", {
  # Mock do resultado do Stan
  mock_modelo_bruto <- list(
    summary = function(var, ...) {
      if (var == "mu") {
        return(tibble::tibble(variable = "mu[1]", `2.5%` = 0.44, `50%` = 0.45, `97.5%` = 0.46))
      }
    }
  )

  # Mock do modelo compilado
  mock_stan <- list(
    sample = function(data, ...) {
      # Verificar se os dados enviados ao Stan estão corretos para o modelo Naive
      expect_named(data, c("n_dias", "total_dias", "n_pesquisas", "percentual",
                           "sigma", "mu_priori", "sd_mu_priori", "omega_eta_priori"))
      return(mock_modelo_bruto)
    }
  )

  cfg <- configurar_agregador()
  prioris <- configurar_prioris("Naive")

  # Usar apenas 1 linha para simplificar
  bd_teste <- pesquisas_minimas[1, ]

  res <- ajustar_modelo(
    bd = bd_teste,
    candidatura = "Lula",
    turno = 1,
    data_inicio = as.Date("2025-01-01"),
    data_fim = as.Date("2025-01-01"),
    modelo = "Naive",
    stan_compilado = mock_stan,
    config_agregador = cfg,
    config_prioris = prioris
  )

  expect_named(res, c("votos_estimados", "vies_institutos", "modelo_bruto"))
  expect_null(res$vies_institutos)
  expect_equal(res$votos_estimados$mediana[1], 0.45)
})

test_that("ajustar_modelo lida com ramos de Viés Relativo e Empírico", {
  # Mock do resultado do Stan que inclui delta
  mock_modelo_bruto_3dias <- list(
    summary = function(var, ...) {
      if (var == "mu") {
        return(tibble::tibble(variable = paste0("mu[", 1:3, "]"), 
                              `2.5%` = rep(0.44, 3), `50%` = rep(0.45, 3), `97.5%` = rep(0.46, 3)))
      } else if (var == "delta") {
        return(tibble::tibble(variable = paste0("delta[", 1:3, "]"), 
                              `2.5%` = rep(-0.01, 3), `50%` = rep(0.01, 3), `97.5%` = rep(0.02, 3)))
      }
    }
  )

  mock_modelo_bruto_2dias <- list(
    summary = function(var, ...) {
      if (var == "mu") {
        return(tibble::tibble(variable = paste0("mu[", 1:2, "]"), 
                              `2.5%` = rep(0.44, 2), `50%` = rep(0.45, 2), `97.5%` = rep(0.46, 2)))
      } else if (var == "delta") {
        return(tibble::tibble(variable = paste0("delta[", 1:2, "]"), 
                              `2.5%` = rep(-0.01, 2), `50%` = rep(0.01, 2), `97.5%` = rep(0.02, 2)))
      }
    }
  )

  # 1. Teste para Viés Relativo sem Pesos
  mock_stan_sem_pesos <- list(
    sample = function(data, ...) {
      expect_true("n_institutos" %in% names(data))
      expect_true("delta_priori" %in% names(data))
      return(mock_modelo_bruto_3dias)
    }
  )

  res_sem <- ajustar_modelo(
    bd = pesquisas_minimas[c(1, 3, 5), ], # 3 institutos
    candidatura = "Lula",
    turno = 1,
    data_inicio = as.Date("2025-01-01"),
    data_fim = as.Date("2025-01-03"),
    modelo = "Vi\u00e9s Relativo sem Pesos",
    stan_compilado = mock_stan_sem_pesos,
    config_agregador = configurar_agregador(),
    config_prioris = configurar_prioris("Vi\u00e9s Relativo sem Pesos")
  )
  expect_s3_class(res_sem$vies_institutos, "data.frame")
  expect_equal(nrow(res_sem$vies_institutos), 3)

  # 2. Teste para Viés Relativo com Pesos
  mock_stan_com_pesos <- list(
    sample = function(data, ...) {
      expect_true("emp_tau_priori" %in% names(data))
      return(mock_modelo_bruto_2dias)
    }
  )

  # Passar dataframes para evitar ler_csv puxando da internet
  cfg_pesos <- configurar_agregador(
    historico_pesquisas = historico_teste, 
    resultado_eleicao_passada = resultados_teste,
    direita_eleicao_passada = "Bolsonaro",
    esquerda_eleicao_passada = "Lula"
  )

  res_com <- ajustar_modelo(
    bd = pesquisas_minimas[c(1, 3), ], # Datafolha e Ipec
    candidatura = "Lula",
    turno = 1,
    data_inicio = as.Date("2025-01-01"),
    data_fim = as.Date("2025-01-02"),
    modelo = "Vi\u00e9s Relativo com Pesos",
    stan_compilado = mock_stan_com_pesos,
    config_agregador = cfg_pesos,
    config_prioris = configurar_prioris("Vi\u00e9s Relativo com Pesos")
  )
  expect_s3_class(res_com$vies_institutos, "data.frame")

  # 3. Teste para Viés Empírico
  mock_stan_empirico <- list(
    sample = function(data, ...) {
      expect_true("emp_delta_priori" %in% names(data))
      return(mock_modelo_bruto_2dias)
    }
  )

  res_emp <- ajustar_modelo(
    bd = pesquisas_minimas[c(1, 3), ],
    candidatura = "Bolsonaro", # Testa candidatura da direita
    turno = 1,
    data_inicio = as.Date("2025-01-01"),
    data_fim = as.Date("2025-01-02"),
    modelo = "Vi\u00e9s Emp\u00edrico",
    stan_compilado = mock_stan_empirico,
    config_agregador = cfg_pesos,
    config_prioris = configurar_prioris("Vi\u00e9s Emp\u00edrico")
  )
  expect_s3_class(res_emp$vies_institutos, "data.frame")
})

test_that("ajustar_modelo funciona para o modelo Retrospectivo", {
  mock_modelo_bruto <- list(
    summary = function(var, ...) {
      if (var == "mu") {
        return(tibble::tibble(variable = "mu[1]", `2.5%` = 0.44, `50%` = 0.45, `97.5%` = 0.46))
      } else if (var == "delta") {
        return(tibble::tibble(variable = "delta[1]", `2.5%` = -0.01, `50%` = 0.01, `97.5%` = 0.02))
      }
    }
  )

  mock_stan <- list(
    sample = function(data, ...) {
      expect_true("resultado_final" %in% names(data))
      return(mock_modelo_bruto)
    }
  )

  # Fornecer dataframe de resultado atual para evitar ler_csv da rede
  cfg <- configurar_agregador(resultado_eleicao_atual = resultados_teste)

  res <- ajustar_modelo(
    bd = pesquisas_minimas[1:2, ],
    candidatura = "Lula",
    turno = 1,
    data_inicio = as.Date("2025-01-01"),
    data_fim = as.Date("2025-01-01"),
    modelo = "Retrospectivo",
    stan_compilado = mock_stan,
    config_agregador = cfg,
    config_prioris = configurar_prioris("Retrospectivo")
  )

  expect_named(res, c("votos_estimados", "vies_institutos", "modelo_bruto"))
})

test_that("ajustar_modelo falha para modelo inexistente", {
  expect_error(
    ajustar_modelo(
      bd = pesquisas_minimas[1, ],
      candidatura = "Lula",
      turno = 1,
      data_inicio = as.Date("2025-01-01"),
      data_fim = as.Date("2025-01-01"),
      modelo = "Inexistente",
      stan_compilado = list(),
      config_agregador = list(),
      config_prioris = list()
    ),
    "Modelo n\u00e3o encontrado"
  )
})
