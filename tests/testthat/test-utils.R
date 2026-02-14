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
