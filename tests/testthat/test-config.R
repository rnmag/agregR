test_that("configurar_agregador aceita parâmetros customizados", {
  cfg <- configurar_agregador(stan_chains = 2, stan_warmup = 100)
  expect_equal(cfg$stan$chains, 2)
  expect_equal(cfg$stan$warmup, 100)
  expect_type(cfg, "list")
  expect_true(grepl("http", cfg$pesquisas))

  # Testar candidaturas customizadas
  cfg_cand <- configurar_agregador(candidaturas_1t = c("Teste1", "Teste2"))
  expect_equal(cfg_cand$candidaturas_1t, c("Teste1", "Teste2"))
})

test_that("configurar_grafico aceita parâmetros customizados", {
  # 1. Caso padrão
  cfg_padrao <- configurar_grafico()
  expect_equal(cfg_padrao$cores_candidaturas$Lula, "#CF4446")

  # 2. Sobrescrever cores
  cfg_cores <- configurar_grafico(cores_candidaturas = c(Lula = "black"))
  expect_equal(cfg_cores$cores_candidaturas$Lula, "black")
  expect_equal(cfg_cores$cores_candidaturas$Bolsonaro, "#446AAF") # Mantém outros

  # 3. Sobrescrever símbolos
  cfg_simb <- configurar_grafico(simbolos = c(Online = 5))
  expect_equal(cfg_simb$simbolos$Online, 5)
  expect_equal(cfg_simb$simbolos$Presencial, 1) # Mantém outros
})

test_that("configurar_prioris retorna parâmetros corretos para cada modelo", {
  # Naive
  p_naive <- configurar_prioris(nome = "Naive")
  expect_named(p_naive, c("mu_priori", "sd_mu_priori", "omega_eta_priori"))

  # Viés Relativo sem Pesos
  p_vies_sem <- configurar_prioris(nome = "Vi\u00e9s Relativo sem Pesos")
  expect_true("delta_priori" %in% names(p_vies_sem))
  expect_true("tau_priori" %in% names(p_vies_sem))
  expect_true("nu_priori" %in% names(p_vies_sem))

  # Viés Relativo com Pesos
  p_vies_com <- configurar_prioris(nome = "Vi\u00e9s Relativo com Pesos")
  expect_false("tau_priori" %in% names(p_vies_com))
  expect_true("sd_tau_priori" %in% names(p_vies_com))

  # Viés Empírico
  p_emp <- configurar_prioris(nome = "Vi\u00e9s Emp\u00edrico")
  expect_false("delta_priori" %in% names(p_emp))
  expect_true("sd_delta_priori" %in% names(p_emp))

  # Retrospectivo
  p_retro <- configurar_prioris(nome = "Retrospectivo")
  expect_true("delta_priori" %in% names(p_retro))

  # Substituir parâmetros
  p_custom <- configurar_prioris(nome = "Naive", mu_priori = 0.8)
  expect_equal(p_custom$mu_priori, 0.8)
})

test_that("configurar_prioris falha para modelo inexistente", {
  expect_error(configurar_prioris(nome = "Modelo Fantasma"))
})

test_that("defaults em configurar_prioris", {
  # Teste que sem argumentos, retorna default "Viés Relativo com Pesos"
  p_default <- configurar_prioris()
  expect_false("tau_priori" %in% names(p_default))
  expect_true("sd_tau_priori" %in% names(p_default))
  expect_equal(p_default$sd_delta_priori, 0.02)
  
  # Teste que sem nome mas com modificação, retorna apenas as modificações
  p_mod <- configurar_prioris(sd_mu_priori = 0.8)
  expect_equal(p_mod, list(sd_mu_priori = 0.8))
})
