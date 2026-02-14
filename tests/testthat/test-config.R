test_that("configurar_agregador aceita parâmetros customizados", {
  cfg <- configurar_agregador(stan_chains = 2, stan_warmup = 100)
  expect_equal(cfg$stan$chains, 2)
  expect_equal(cfg$stan$warmup, 100)
  expect_type(cfg, "list")
  expect_true(grepl("http", cfg$pesquisas))
})

test_that("configurar_prioris retorna parâmetros corretos para cada modelo", {
  # Naive
  p_naive <- configurar_prioris(nome = "Naive")
  expect_named(p_naive, c("mu_priori", "sd_mu_priori", "omega_eta_priori", "sd_omega_eta_priori"))

  # Viés Relativo sem Pesos
  p_vies <- configurar_prioris(nome = "Vi\u00e9s Relativo sem Pesos")
  expect_true("delta_priori" %in% names(p_vies))
  expect_true("tau_priori" %in% names(p_vies))

  # Substituir parâmetros
  p_custom <- configurar_prioris(nome = "Naive", mu_priori = 0.8)
  expect_equal(p_custom$mu_priori, 0.8)
})

test_that("configurar_prioris falha para modelo inexistente", {
  expect_error(configurar_prioris(nome = "Modelo Fantasma"))
})
