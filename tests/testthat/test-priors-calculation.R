test_that("calcular_prioris_empiricas atribui erros corretamente", {
  cfg <- configurar_agregador(
    historico_pesquisas = historico_teste,
    resultado_eleicao_passada = resultados_teste,
    direita_eleicao_atual = "Tarc\u00edsio",
    esquerda_eleicao_atual = "Lula",
    eleicao_passada_primeiro_turno = "02/10/2022",
    eleicao_passada_segundo_turno = "30/10/2022"
  )

  # Lula (esquerda) -> deve pegar histórico do Lula na eleição passada
  priors_lula <- calcular_prioris_empiricas("Lula", 1, c("Datafolha", "Novo Instituto"), cfg)

  expect_equal(nrow(priors_lula), 2)
  expect_true("Datafolha" %in% priors_lula$instituto)
  expect_true("Novo Instituto" %in% priors_lula$instituto)

  # Datafolha deve ter o valor do historico_teste
  val_df <- priors_lula$emp_delta_priori[priors_lula$instituto == "Datafolha"]
  expect_false(is.na(val_df))

  # Novo Instituto deve ter a média (que no caso é o próprio valor da Datafolha pois só tem ela)
  val_novo <- priors_lula$emp_delta_priori[priors_lula$instituto == "Novo Instituto"]
  expect_equal(val_df, val_novo)
})
