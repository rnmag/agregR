test_that("nome_robusto padroniza nomes corretamente", {
  expect_equal(nome_robusto("lula"), "Lula")
  expect_equal(nome_robusto("luiz inacio lula da silva"), "Lula")
  expect_equal(nome_robusto("jair messias bolsonaro"), "Bolsonaro")
  expect_equal(nome_robusto("tarcisio de freitas"), "Tarc\u00edsio")
  expect_equal(nome_robusto("Candidato Inexistente"), "Candidato Inexistente")
})

test_that("data_robusta lida com diferentes formatos e tipos", {
  expect_equal(data_robusta("2025-01-01"), as.Date("2025-01-01"))
  expect_equal(data_robusta("01/01/2025"), as.Date("2025-01-01"))
  expect_equal(data_robusta(as.Date("2025-01-01")), as.Date("2025-01-01"))
  expect_null(data_robusta(NULL))
})

test_that("formatar_lista funciona para diferentes tamanhos", {
  expect_equal(formatar_lista(c("A", "B", "C")), "A, B e C")
  expect_equal(formatar_lista(c("A", "B")), "A e B")
  expect_equal(formatar_lista("A"), "A")
  expect_equal(formatar_lista(character(0)), "")
})

test_that("limpar_texto funciona", {
  expect_equal(limpar_texto("Lula da Silva"), "Lula_da_Silva")
  expect_equal(limpar_texto("Tarc\u00edsio"), "Tarcisio")
})

test_that("gerar_saida cria diretorios e retorna caminhos corretos (linhas 79-94)", {
  tmp_base <- file.path(tempdir(), "test_outputs")

  # Caso 1: sem nome de arquivo
  path1 <- gerar_saida(tmp_base, "Meu Modelo")
  expect_true(dir.exists(path1))
  expect_match(path1, "meu_modelo$")

  # Caso 2: com nome de arquivo
  path2 <- gerar_saida(tmp_base, "Meu Modelo", "teste.csv")
  expect_match(path2, "teste.csv$")

  unlink(tmp_base, recursive = TRUE)
})

test_that("cenarios_disponiveis filtra cenarios corretamente (linhas 99-106)", {
  bd_cenarios <- data.frame(
    turno = c(1, 2, 2),
    cenario = c("T1", "Cenário A", "Cenário B"),
    stringsAsFactors = FALSE
  )

  res <- cenarios_disponiveis(2, bd_cenarios)
  expect_equal(length(res), 2)
  expect_true(all(c("Cenário A", "Cenário B") %in% res))
})

test_that("ler_csv lida com diversos inputs e formatos (linhas 125-186)", {
  # 1. Dataframe
  df <- data.frame(a = 1)
  expect_equal(ler_csv(df), df)

  # 2. NULL
  expect_null(ler_csv(NULL))

  # 3. ler_robusto (separadores)
  tmp_semi <- tempfile(fileext = ".csv")
  writeLines("col1;col2\n1,5;2,0", tmp_semi)
  res_semi <- ler_csv(tmp_semi)
  expect_equal(ncol(res_semi), 2)
  expect_equal(res_semi$col1[1], 1.5)

  tmp_comma <- tempfile(fileext = ".csv")
  writeLines("col1,col2\n1.5,2.0", tmp_comma)
  res_comma <- ler_csv(tmp_comma)
  expect_equal(ncol(res_comma), 2)
  expect_equal(res_comma$col1[1], 1.5)

  # Simulando URL que falha
  expect_message(ler_csv("https://url_inexistente_12345.csv", arquivo_local_fallback = tmp_comma), "internet")

  # pesquisas_2026.csv deve existir no inst/extdata
  res_pkg <- ler_csv("pesquisas_2026.csv")
  expect_s3_class(res_pkg, "data.frame")

  # 6. Erro fatal (linha 186)
  expect_error(ler_csv("arquivo_que_nao_existe_mesmo.csv"), "configura\u00e7\u00e3o")
})

test_that("registrar_fonte lida com fontes ausentes (linha 206)", {
  # Simular cenário onde fonte_regular não existe
  # Como a função usa system.file(), se não passarmos nada que exista ela deve retornar invisible()
  # Nota: registrar_fonte não tem parâmetros para forçar erro, mas o código
  # interno lida com o retorno de "" do system.file()
  expect_silent(registrar_fonte())
})
