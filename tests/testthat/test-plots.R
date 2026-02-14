test_that("grafico_agregador retorna um objeto ggplot", {
  # Resultado sintétoco de rodar_agregador()
  votos_estimados_mock <- pesquisas_minimas
  votos_estimados_mock$li <- votos_estimados_mock$percentual_pesquisa - 0.02
  votos_estimados_mock$mediana <- votos_estimados_mock$percentual_pesquisa
  votos_estimados_mock$ls <- votos_estimados_mock$percentual_pesquisa + 0.02
  votos_estimados_mock$percentual_estimado <- "45%"
  votos_estimados_mock$turno <- 1
  votos_estimados_mock$pesquisa_id <- paste(votos_estimados_mock$instituto, votos_estimados_mock$dia)

  bd_mock <- list(
    nome_modelo = "Naive",
    votos_estimados = votos_estimados_mock,
    vies_institutos = NULL
  )

  p <- grafico_agregador(bd_mock, salvar = FALSE)

  expect_s3_class(p, "ggplot")
})

test_that("grafico_vies retorna um objeto ggplot", {
  vies_mock <- data.frame(
    instituto = c("Datafolha", "Ipec"),
    li = c(-0.02, -0.01),
    mediana = c(0.01, 0.02),
    ls = c(0.04, 0.05),
    candidatura = "Lula"
  )

  bd_mock <- list(
    nome_modelo = "Vi\u00e9s Relativo sem Pesos",
    votos_estimados = pesquisas_minimas,
    vies_institutos = vies_mock,
    # Mock para passar na validação de candidaturas em grafico_vies
    modelo_bruto = list(Lula = list())
  )

  p <- grafico_vies(bd_mock, candidaturas = "Lula", salvar = FALSE)
  expect_s3_class(p, "ggplot")
})
