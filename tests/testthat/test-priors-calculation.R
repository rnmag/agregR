test_that("calcular_prioris_empiricas atribui erros corretamente", {
  # Configurar agregador com dados de teste
  cfg <- configurar_agregador(
    historico_pesquisas = historico_teste,
    resultado_eleicao_passada = resultados_teste,
    direita_eleicao_atual = "Bolsonaro",
    esquerda_eleicao_atual = "Lula",
    direita_eleicao_passada = "Bolsonaro",
    esquerda_eleicao_passada = "Lula",
    eleicao_passada_primeiro_turno = "02/10/2022",
    eleicao_passada_segundo_turno = "30/10/2022"
  )

  # 1. Caso Esquerda
  priors_lula <- calcular_prioris_empiricas("Lula", 1, c("Datafolha", "Novo Instituto"), cfg)
  expect_equal(nrow(priors_lula), 2)
  expect_false(is.na(priors_lula$emp_delta_priori[priors_lula$instituto == "Datafolha"]))
  # Novo Instituto deve ter a média dos outros (que é a do Datafolha já que só tem ele)
  expect_equal(priors_lula$emp_delta_priori[priors_lula$instituto == "Datafolha"],
               priors_lula$emp_delta_priori[priors_lula$instituto == "Novo Instituto"])

  # 2. Caso Direita
  priors_bolsonaro <- calcular_prioris_empiricas("Bolsonaro", 1, c("Datafolha"), cfg)
  expect_equal(nrow(priors_bolsonaro), 1)
})

test_that("calcular_prioris_empiricas lida com candidatos sem histórico", {
  cfg <- configurar_agregador(
    historico_pesquisas = historico_teste,
    resultado_eleicao_passada = resultados_teste
  )

  # Candidato que não é nem direita nem esquerda na config
  priors_outro <- calcular_prioris_empiricas("Candidato Gen\u00e9rico", 1, c("Datafolha"), cfg)
  expect_equal(nrow(priors_outro), 1)
})
