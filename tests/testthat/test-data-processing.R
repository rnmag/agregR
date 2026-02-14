test_that("tratar_bd_atual filtra e calcula estatísticas corretamente", {
  df <- tratar_bd_atual(pesquisas_teste, 
                        filtro_inicio = as.Date("2025-01-01"),
                        filtro_fim = as.Date("2025-12-31"),
                        filtro_cargo = "Presidente",
                        filtro_ambito = "Brasil",
                        filtro_cenario = "Cenario 1")

  expect_s3_class(df$dia, "Date")
  expect_true(all(df$percentual_pesquisa <= 1))
  expect_true(all(df$ep > 0))
  expect_equal(nrow(df), 4)
  expect_true("n_efetivo" %in% names(df))
})

test_that("tratar_bd_historico calcula erros corretamente", {
  cfg <- list(
    resultado_eleicao_passada = resultados_teste,
    # direita_eleicao_passada = "Bolsonaro",
    esquerda_eleicao_passada = "Lula"
  )

  res <- tratar_bd_historico(bd = historico_teste,
                             primeiro_turno = "2022-10-02",
                             segundo_turno = "2022-10-30",
                             config_agregador = cfg)

  expect_true("erro_total" %in% names(res))
  expect_true("erro_nao_amostral" %in% names(res))
  expect_equal(res$percentual_pesquisa[1], 0.48)
})
