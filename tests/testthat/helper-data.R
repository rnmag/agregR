# Dados sintéticos com n pequeno para não dar problema com limite de tempo do CRAN

# Pesquisas pré-tratamanto
pesquisas_teste <- data.frame(
  dia = c("01/01/2025", "01/01/2025", "02/01/2025", "02/01/2025"),
  instituto = c("Datafolha", "Datafolha", "Ipec", "Ipec"),
  turno = c(1, 1, 1, 1),
  candidatura = c("Lula", "Bolsonaro", "Lula", "Bolsonaro"),
  percentual_pesquisa = c(45, 40, 46, 39),
  margem_pesquisa = c(2, 2, 2, 2),
  qtd_entrevistas = c(2000, 2000, 2500, 2500),
  metodologia = c("Presencial", "Presencial", "Telefônica", "Telefônica"),
  ambito = c("Brasil", "Brasil", "Brasil", "Brasil"),
  cargo = c("Presidente", "Presidente", "Presidente", "Presidente"),
  cenario = c("Cenario 1", "Cenario 1", "Cenario 1", "Cenario 1"),
  stringsAsFactors = FALSE
)

# Pesquisas após tratamento
pesquisas_minimas <- data.frame(
  dia = as.Date(c("2025-01-01", "2025-01-01", "2025-01-02", "2025-01-02")),
  instituto = c("Datafolha", "Datafolha", "Ipec", "Ipec"),
  candidatura = c("Lula", "Bolsonaro", "Lula", "Bolsonaro"),
  percentual_pesquisa = c(0.45, 0.40, 0.46, 0.39),
  ep = c(0.01, 0.01, 0.01, 0.01),
  n_implicito = c(2000, 2000, 2500, 2500),
  metodologia = c("Presencial", "Presencial", "Telefônica", "Telefônica"),
  stringsAsFactors = FALSE
)

# Pesqisas histórica
historico_teste <- data.frame(
  ano = 2022,
  cargo = "Presidente",
  instituto = "Datafolha",
  nome_candidato = "Lula",
  percentual = 48,
  data = as.Date("2022-10-01"),
  turno = 1,
  sigla_uf = "BR",
  quantidade_entrevistas = 2000,
  margem_mais = 2,
  margem_menos = 2,
  stringsAsFactors = FALSE
)

# Resultado eleitoral
resultados_teste <- data.frame(
  ano = 2022,
  cargo = "Presidente",
  turno = 1,
  nome_candidato = "Lula",
  votos_recebidos = 57259504,
  total_votos = 118229719,
  stringsAsFactors = FALSE
)
