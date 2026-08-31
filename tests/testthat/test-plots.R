test_that("grafico_agregador retorna um objeto ggplot e lida com diferentes modelos e turnos", {
  # Mock de votos_estimados para 1º turno e múltiplos anos (para testar labels do eixo X)
  votos_mock_1t <- tibble::tibble(
    final_coleta = as.Date(c("2024-12-31", "2025-01-01")),
    turno = 1,
    candidatura = "Lula",
    mediana = 0.45,
    li = 0.43,
    ls = 0.47,
    percentual_pesquisa = 0.45,
    percentual_estimado = "45%",
    metodologia = "Presencial",
    instituto = "Datafolha",
    pesquisa_id = "1"
  )

  # 1. Teste modelo Naive e 1º turno
  bd_naive <- list(nome_modelo = "Naive", votos_estimados = votos_mock_1t)
  p1 <- grafico_agregador(bd_naive, salvar = FALSE)
  expect_s3_class(p1, "ggplot")
  expect_match(p1$labels$title, "1\u00ba Turno")

  # 2. Teste modelo Viés Empírico e 2º turno
  votos_mock_2t <- votos_mock_1t |> dplyr::mutate(turno = 2)
  bd_emp <- list(nome_modelo = "Vi\u00e9s Emp\u00edrico", votos_estimados = votos_mock_2t)
  p2 <- grafico_agregador(bd_emp, salvar = FALSE)
  expect_match(p2$labels$title, "2\u00ba Turno")
  # expect_match(p2$labels$subtitle, "compensada pelo erro")

  # 3. Teste modelo Viés Relativo com Pesos
  bd_pesos <- list(nome_modelo = "Vi\u00e9s Relativo com Pesos", votos_estimados = votos_mock_1t)
  p3 <- grafico_agregador(bd_pesos, salvar = FALSE)
 #  expect_match(p3$labels$subtitle, "ponderada pelo erro")

  # 4. Teste modelo Retrospectivo
  bd_retro <- list(nome_modelo = "Retrospectivo", votos_estimados = votos_mock_1t)
  p4 <- grafico_agregador(bd_retro, salvar = FALSE)
  # expect_match(p4$labels$subtitle, "Recomposi\u00e7\u00e3o")

  # 5. Teste salvamento
  tmp <- tempdir()
  expect_message(suppressWarnings(grafico_agregador(bd_naive, salvar = TRUE, dir_saida = tmp)), "Gr\u00e1fico salvo")
})
test_that("grafico_agregador falha sem turno (linha 64)", {
  bd_erro <- list(votos_estimados = tibble::tibble(turno = 3))
  expect_error(grafico_agregador(bd_erro), "definir o turno")
})

test_that("grafico_agregador atribui cores padrão do ggplot para candidatos sem cor", {
  votos_mock_novo <- tibble::tibble(
    final_coleta = as.Date(c("2024-12-31", "2025-01-01")),
    turno = 1,
    candidatura = "CandidatoX",
    mediana = 0.45,
    li = 0.43,
    ls = 0.47,
    percentual_pesquisa = 0.45,
    percentual_estimado = "45%",
    metodologia = "Presencial",
    instituto = "Datafolha",
    pesquisa_id = "1"
  )

  bd_naive <- list(nome_modelo = "Naive", votos_estimados = votos_mock_novo)
  p <- grafico_agregador(bd_naive, salvar = FALSE)
  expect_s3_class(p, "ggplot")
  
  cor_scale <- p$scales$get_scales("colour")
  expect_true("CandidatoX" %in% names(cor_scale$palette(1)))
})


test_that("grafico_vies retorna um objeto ggplot e valida entradas", {
  vies_mock <- data.frame(
    instituto = c("Datafolha", "Ipec"),
    li = c(-0.02, -0.01),
    mediana = c(0.01, 0.02),
    ls = c(0.04, 0.05),
    candidatura = "Lula",
    instituto_num = 1:2
  )

  votos_mock <- tibble::tibble(
    final_coleta = as.Date("2025-01-01"),
    pesquisa_id = "1",
    instituto = "Datafolha"
  )

  # 1. Erro para modelo Naive
  bd_naive <- list(nome_modelo = "Naive")
  expect_error(grafico_vies(bd_naive, candidaturas = "Lula"), "n\u00e3o \u00e9 aplic\u00e1vel")

  # 2. Erro para candidatura inexistente
  bd_erro <- list(nome_modelo = "Vi\u00e9s Emp\u00edrico", modelo_bruto = list(Bolsonaro = 1))
  expect_error(grafico_vies(bd_erro, candidaturas = "Lula"), "n\u00e3o encontrada")

  # Mock de dados comum para os sucessos
  bd_base <- list(
    votos_estimados = votos_mock,
    vies_institutos = vies_mock,
    modelo_bruto = list(Lula = data.frame(`delta[1]` = rnorm(10), `delta[2]` = rnorm(10), check.names = FALSE))
  )

  # 3. Teste Viés Empírico
  bd_emp <- bd_base
  bd_emp$nome_modelo <- "Vi\u00e9s Emp\u00edrico"
  p_emp <- grafico_vies(bd_emp, candidaturas = "Lula")
  expect_match(p_emp$labels$subtitle, "ancorado no desempenho")

  # 4. Teste Retrospectivo
  bd_retro <- bd_base
  bd_retro$nome_modelo <- "Retrospectivo"
  p_retro <- grafico_vies(bd_retro, candidaturas = "Lula")
  expect_match(p_retro$labels$subtitle, "resultado final")

  # 5. Teste salvamento
  tmp <- tempdir()
  expect_message(suppressWarnings(grafico_vies(bd_emp, candidaturas = "Lula", salvar = TRUE, dir_saida = tmp)), "Gr\u00e1fico salvo")
})

test_that("grafico_vies atribui cores padrão do ggplot para candidatos sem cor", {
  vies_mock <- data.frame(
    instituto = c("Datafolha", "Ipec"),
    li = c(-0.02, -0.01),
    mediana = c(0.01, 0.02),
    ls = c(0.04, 0.05),
    candidatura = "CandidatoX",
    instituto_num = 1:2
  )

  votos_mock <- tibble::tibble(
    final_coleta = as.Date("2025-01-01"),
    pesquisa_id = "1",
    instituto = "Datafolha"
  )

  bd_base <- list(
    nome_modelo = "Vi\u00e9s Emp\u00edrico",
    votos_estimados = votos_mock,
    vies_institutos = vies_mock,
    modelo_bruto = list(CandidatoX = data.frame(`delta[1]` = rnorm(10), `delta[2]` = rnorm(10), check.names = FALSE))
  )

  p <- grafico_vies(bd_base, candidaturas = "CandidatoX")
  expect_s3_class(p, "ggplot")

  cor_scale <- p$scales$get_scales("fill")
  expect_true("CandidatoX" %in% names(cor_scale$palette(1)))
})

