test_that("grafico_priori_posteriori valida argumentos e modelos", {
  # Mock base
  bd_naive <- list(
    nome_modelo = "Naive",
    votos_estimados = tibble::tibble(turno = 1, dia = as.Date("2025-01-01"), pesquisa_id = "1")
  )

  # 1. Erro tipo inválido
  expect_error(grafico_priori_posteriori(bd_naive, tipo = "Inexistente"), "deve ser 'Percentual' ou 'Vi\u00e9s'")

  # 2. Erro Viés no modelo Naive
  expect_error(grafico_priori_posteriori(bd_naive, tipo = "Vi\u00e9s"), "modelo 'Naive' n\u00e3o existe vi\u00e9s")

  # 3. Erro candidatura não encontrada
  bd_erro_cand <- list(
    nome_modelo = "Vi\u00e9s Relativo sem Pesos",
    votos_estimados = tibble::tibble(turno = 1, dia = as.Date("2025-01-01"), pesquisa_id = "1"),
    modelo_bruto = list(Bolsonaro = 1)
  )
  expect_error(grafico_priori_posteriori(bd_erro_cand, candidaturas = "Lula", tipo = "Percentual"), "n\u00e3o encontrada")
})

test_that("grafico_priori_posteriori gera graficos de Percentual e Vi\u00e9s", {
  # Mock de dados para sucesso
  # Criar amostras com nomes de colunas que extrair_amostras_post espera
  amostras <- data.frame(`mu[1]` = rnorm(10), `delta[1]` = rnorm(10), check.names = FALSE)
  bd_base <- list(
    nome_modelo = "Vi\u00e9s Relativo sem Pesos",
    votos_estimados = tibble::tibble(turno = 1, dia = as.Date("2025-01-01"), pesquisa_id = "1", instituto = "Datafolha"),
    vies_institutos = tibble::tibble(instituto = "Datafolha", candidatura = "Lula", instituto_num = 1),
    modelo_bruto = list(Lula = amostras)
  )

  # 1. Teste Percentual (mu)
  p_perc <- grafico_priori_posteriori(bd_base, candidaturas = "Lula", tipo = "Percentual")
  expect_s3_class(p_perc, "ggplot")
  expect_match(p_perc$labels$title, "Inten\u00e7\u00e3o de Votos")

  # 2. Teste Vi\u00e9s (delta) - Modelo padrão
  p_vies <- grafico_priori_posteriori(bd_base, candidaturas = "Lula", tipo = "Vi\u00e9s")
  expect_s3_class(p_vies, "ggplot")
  expect_match(p_vies$labels$title, "Vi\u00e9s dos Institutos")

  # 3. Teste Vi\u00e9s - Modelo Empírico
  # Fornecer config com dados mock para evitar rede em calcular_prioris_empiricas
  cfg_emp <- configurar_agregador(
    historico_pesquisas = historico_teste,
    resultado_eleicao_passada = resultados_teste,
    direita_eleicao_passada = "Bolsonaro",
    esquerda_eleicao_passada = "Lula"
  )
  bd_emp <- bd_base
  bd_emp$nome_modelo <- "Vi\u00e9s Emp\u00edrico"

  p_emp <- grafico_priori_posteriori(bd_emp, candidaturas = "Lula", tipo = "Vi\u00e9s", config_agregador = cfg_emp)
  expect_s3_class(p_emp, "ggplot")
})

test_that("grafico_priori_posteriori salva arquivos corretamente", {
  amostras <- data.frame(`mu[1]` = rnorm(10), check.names = FALSE)
  bd_naive <- list(
    nome_modelo = "Naive",
    votos_estimados = tibble::tibble(turno = 1, dia = as.Date("2025-01-01"), pesquisa_id = "1", instituto = "Datafolha"),
    modelo_bruto = list(Lula = amostras)
  )

  tmp <- tempdir()
  # Registrar fonte para evitar warnings no ggsave se a fonte não for encontrada
  # registrar_fonte() # Já é chamado dentro da função

  expect_message(
    suppressWarnings(grafico_priori_posteriori(bd_naive, candidaturas = "Lula", tipo = "Percentual", salvar = TRUE, dir_saida = tmp)),
    "Gr\u00e1fico salvo"
  )
})
