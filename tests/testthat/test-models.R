test_that("rodar_agregador funciona para o modelo Naive (Smoke Test)", {
  testthat::skip_if_not(instantiate::stan_cmdstan_exists())
  skip_on_cran()

  # Simulação rápida
  cfg <- list(
    stan_chains = 1,
    stan_warmup = 50,
    stan_sampling = 50,
    candidaturas_1t = c("Lula", "Bolsonaro")
  )

  res <- rodar_agregador(bd = pesquisas_teste,
                         turno = 1,
                         modelo = "Naive",
                         config_agregador = cfg,
                         salvar = FALSE)

  expect_named(res, c("nome_modelo", "votos_estimados", "vies_institutos", "modelo_bruto"))
  expect_s3_class(res$votos_estimados, "data.frame")
  expect_equal(res$nome_modelo, "Naive")
  expect_null(res$vies_institutos)
})

test_that("rodar_agregador valida cenários de segundo turno", {
  # Sem cenário deve dar erro
  expect_error(rodar_agregador(bd = pesquisas_teste, turno = 2, cenario = NULL))

  # Cenário inexistente deve dar erro
  expect_error(rodar_agregador(bd = pesquisas_teste, turno = 2, cenario = "Inexistente"))
})
