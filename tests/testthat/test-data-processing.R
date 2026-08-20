test_that("tratar_bd_atual filtra e calcula estatísticas corretamente", {
  # Adicionar um caso com metodologia ausente para testar imputação
  bd_imput <- pesquisas_teste
  bd_imput$metodologia[1] <- NA
  bd_imput$instituto[1] <- "Datafolha" # Deve ser imputado como Presencial

  df <- tratar_bd_atual(bd_imput, 
                        filtro_inicio = as.Date("2025-01-01"),
                        filtro_fim = as.Date("2025-12-31"),
                        filtro_cargo = "Presidente",
                        filtro_ambito = "Brasil",
                        filtro_cenario = "Primeiro turno")

  expect_s3_class(df$final_coleta, "Date")
  expect_true(all(df$percentual_pesquisa <= 1))
  expect_true(all(df$ep > 0))
  expect_equal(nrow(df), 6)
  expect_true("n_efetivo" %in% names(df))

  # Verificar imputação de metodologia
  expect_equal(df$metodologia[df$instituto == "Datafolha"][1], "Presencial")

  # Testar filtro de data
  df_filtered <- tratar_bd_atual(pesquisas_teste, 
                                 filtro_inicio = as.Date("2025-01-02"),
                                 filtro_fim = as.Date("2025-01-03"),
                                 filtro_cargo = "Presidente",
                                 filtro_ambito = "Brasil",
                                 filtro_cenario = "Primeiro turno")
  expect_equal(nrow(df_filtered), 4)
})

test_that("tratar_bd_historico calcula erros corretamente e aceita diferentes inputs", {
  cfg <- list(
    resultado_eleicao_passada = resultados_teste,
    direita_eleicao_passada = "Bolsonaro",
    esquerda_eleicao_passada = "Lula"
  )

  # 1. Caso bd = dataframe (já existente)
  res_df <- tratar_bd_historico(bd = historico_teste,
                                primeiro_turno = "2022-10-02",
                                segundo_turno = "2022-10-30",
                                config_agregador = cfg)
  expect_equal(res_df$percentual_pesquisa[1], 0.48)
  expect_true("erro_total" %in% names(res_df))

  # 2. Caso bd = NULL (usa historico_pesquisas_poder360 do pacote)
  # Como não podemos garantir o conteúdo exato sem rodar, verificamos se retorna um DF
  res_null <- tratar_bd_historico(bd = NULL,
                                  primeiro_turno = "2022-10-02",
                                  segundo_turno = "2022-10-30",
                                  config_agregador = cfg)
  expect_s3_class(res_null, "data.frame")

  # 3. Caso bd = caminho RDS
  tmp_rds <- tempfile(fileext = ".rds")
  saveRDS(historico_teste, tmp_rds)
  res_rds <- tratar_bd_historico(bd = tmp_rds,
                                 primeiro_turno = "2022-10-02",
                                 segundo_turno = "2022-10-30",
                                 config_agregador = cfg)
  expect_equal(nrow(res_rds), 4)

  # 4. Caso bd = caminho CSV
  tmp_csv <- tempfile(fileext = ".csv")
  readr::write_csv(historico_teste, tmp_csv)
  res_csv <- tratar_bd_historico(bd = tmp_csv,
                                 primeiro_turno = "2022-10-02",
                                 segundo_turno = "2022-10-30",
                                 config_agregador = cfg)
  expect_equal(nrow(res_csv), 4)
})
