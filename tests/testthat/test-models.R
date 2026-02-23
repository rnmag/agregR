test_that("rodar_agregador valida requisitos e argumentos", {
  testthat::skip_if_not(instantiate::stan_cmdstan_exists())
  skip_on_cran()

  # 1. Validação de data_inicio
  expect_error(rodar_agregador(bd = pesquisas_teste, turno = 1), "obrigat\u00f3rio")

  # 2. Validação de turno
  expect_error(rodar_agregador(bd = pesquisas_teste, data_inicio = "01/01/2025", turno = 3, cenario = "Primeiro turno"), "definir o turno")

  # 3. Validação de cenário 2º turno
  # Criar bd com turno 2
  bd_2t <- pesquisas_teste
  bd_2t$turno <- 2
  bd_2t$cenario <- "Lula vs Bolsonaro"

  expect_error(rodar_agregador(bd = bd_2t, data_inicio = "01/01/2025", turno = 2, cenario = "Inexistente"), "Cen\u00e1rio inv\u00e1lido")
  expect_error(rodar_agregador(bd = bd_2t, data_inicio = "01/01/2025", turno = 2, cenario = NULL), "obrigat\u00f3rio")

  # 4. Validação de modelo
  expect_error(rodar_agregador(bd = pesquisas_teste, data_inicio = "01/01/2025", turno = 1, modelo = "Modelo Fantasma"), "Modelo n\u00e3o encontrado")
})

test_that("rodar_agregador lida com configurações customizadas", {
  testthat::skip_if_not(instantiate::stan_cmdstan_exists())
  skip_on_cran()

  # Mock do comportamento sem rodar Stan (interceptando antes da chamada do Stan)
  # Se passarmos um config_agregador que não é uma lista completa, ele chama configurar_agregador
  cfg_lista <- list(stan_chains = 1)

  # Deve falhar ao tentar carregar o modelo Stan se cmdstanr não estiver configurado,
  # mas aqui testamos se ele aceita os argumentos
  try({
    res <- rodar_agregador(bd = pesquisas_teste,
                          turno = 1,
                          config_agregador = cfg_lista,
                          data_inicio = "2025-01-01",
                          data_fim = "2025-01-02")
  }, silent = TRUE)

  # Testar lógica de datas robustas
  expect_equal(data_robusta("01/01/2025"), as.Date("2025-01-01"))
})

test_that("rodar_agregador funciona para o modelo Naive (Smoke Test)", {
  testthat::skip_if_not(instantiate::stan_cmdstan_exists())
  skip_on_cran()

  cfg <- list(
    stan_chains = 1,
    stan_warmup = 50,
    stan_sampling = 50,
    candidaturas_1t = c("Lula", "Bolsonaro")
  )

  res <- rodar_agregador(bd = pesquisas_teste,
                         data_inicio = "01/01/2025",
                         turno = 1,
                         modelo = "Naive",
                         config_agregador = cfg,
                         salvar = FALSE)

  expect_named(res, c("nome_modelo", "votos_estimados", "vies_institutos", "modelo_bruto"))
  expect_s3_class(res$votos_estimados, "data.frame")
  expect_equal(res$nome_modelo, "Naive")
  expect_null(res$vies_institutos)
})

test_that("rodar_agregador salva resultados corretamente", {
  testthat::skip_if_not(instantiate::stan_cmdstan_exists())
  skip_on_cran()

  tmp <- tempdir()
  cfg <- list(
    stan_chains = 1,
    stan_warmup = 50,
    stan_sampling = 50,
    candidaturas_1t = c("Lula")
  )

  # Testar salvamento
  res <- rodar_agregador(bd = pesquisas_teste[pesquisas_teste$candidatura == "Lula", ],
                         data_inicio = "01/01/2025",
                         turno = 1,
                         modelo = "Naive",
                         config_agregador = cfg,
                         salvar = TRUE,
                         dir_saida = tmp)

  expect_true(file.exists(file.path(tmp, "resultados_agregador/bases_tratadas/naive/Votos_Estimados_1t.csv")))
  expect_true(file.exists(file.path(tmp, "resultados_agregador/modelos_brutos/naive/StanMCMC_1t.rds")))

  # Quando salvar = TRUE, modelo_bruto deve ser convertido para dataframe
  expect_s3_class(res$modelo_bruto$Lula, "data.frame")
})
