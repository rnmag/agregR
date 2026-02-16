test_that("extrair_amostras_post lida com objetos CmdStanMCMC e data.frames", {
  # Mock da classe CmdStanMCMC
  mock_cmdstan <- list(
    draws = function(format) {
      return(data.frame(`delta[1]` = c(0.1, 0.2),
                        `delta[2]` = c(-0.05, -0.04),
                        check.names = FALSE))
    }
  )
  class(mock_cmdstan) <- "CmdStanMCMC"

  bd_mock <- list(
    modelo_bruto = list(Lula = mock_cmdstan),
    vies_institutos = tibble::tibble(
      instituto = c("Datafolha", "Ipec"),
      instituto_num = c(1, 2),
      candidatura = "Lula"
    )
  )

  # Teste extração de delta
  res <- extrair_amostras_post(bd_mock, "Lula", "delta")
  expect_equal(nrow(res), 4) # 2 amostras * 2 institutos
  expect_equal(res$valor_estimado[1], 0.1)
  expect_true(all(res$parametro == "delta"))
})

test_that("extrair_amostras_post extrai parametro mu", {
  # Caso 1: mu com índices (mu[1], mu[2]...)
  amostras_idx <- data.frame(`mu[1]` = c(0.40, 0.41),
                             `mu[2]` = c(0.45, 0.46),
                             check.names = FALSE)

  bd_mock_idx <- list(modelo_bruto = list(Lula = amostras_idx))

  res_idx <- extrair_amostras_post(bd_mock_idx, "Lula", "mu")
  expect_equal(res_idx$valor_estimado, c(0.45, 0.46)) # Deve pegar o maior índice (mu[2])

  # Caso 2: mu sem índices (apenas "mu")
  amostras_simples <- data.frame(mu = c(0.50, 0.51))
  bd_mock_simples <- list(modelo_bruto = list(Bolsonaro = amostras_simples))

  res_simples <- extrair_amostras_post(bd_mock_simples, "Bolsonaro", "mu")
  expect_equal(res_simples$valor_estimado, c(0.50, 0.51))
})

test_that("extrair_amostras_post falha para parametro invalido", {
  bd_mock <- list(modelo_bruto = list(Lula = data.frame(mu = 1)))
  expect_error(extrair_amostras_post(bd_mock, "Lula", "parametro_fantasma"), "n\u00e3o suportado")
})
