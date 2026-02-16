# Dados sintéticos com n pequeno para não dar problema com limite de tempo do CRAN

# Pesquisas pré-tratamanto
pesquisas_teste <- data.frame(
  dia = c("01/01/2025", "01/01/2025", "02/01/2025", "02/01/2025", "03/01/2025", "03/01/2025"),
  instituto = c("Datafolha", "Datafolha", "Ipec", "Ipec", "Atlas", "Atlas"),
  turno = c(1, 1, 1, 1, 1, 1),
  candidatura = c("Lula", "Bolsonaro", "Lula", "Bolsonaro", "Lula", "Bolsonaro"),
  percentual_pesquisa = c(45, 40, 46, 39, 44, 41),
  margem_pesquisa = c(2, 2, 2, 2, 2, 2),
  qtd_entrevistas = c(2000, 2000, 2500, 2500, 1500, 1500),
  metodologia = c("Presencial", "Presencial", "Telefônica", "Telefônica", "Online", "Online"),
  ambito = c("Brasil", "Brasil", "Brasil", "Brasil", "Brasil", "Brasil"),
  cargo = c("Presidente", "Presidente", "Presidente", "Presidente", "Presidente", "Presidente"),
  cenario = c("Primeiro turno", "Primeiro turno", "Primeiro turno", "Primeiro turno", "Primeiro turno", "Primeiro turno"),
  stringsAsFactors = FALSE
)

# Pesquisas após tratamento
pesquisas_minimas <- data.frame(
  dia = as.Date(c("2025-01-01", "2025-01-01", "2025-01-02", "2025-01-02", "2025-01-03", "2025-01-03")),
  instituto = c("Datafolha", "Datafolha", "Ipec", "Ipec", "Atlas", "Atlas"),
  candidatura = c("Lula", "Bolsonaro", "Lula", "Bolsonaro", "Lula", "Bolsonaro"),
  percentual_pesquisa = c(0.45, 0.40, 0.46, 0.39, 0.44, 0.41),
  ep = c(0.01, 0.01, 0.01, 0.01, 0.01, 0.01),
  n_implicito = c(2000, 2000, 2500, 2500, 1500, 1500),
  metodologia = c("Presencial", "Presencial", "Telefônica", "Telefônica", "Online", "Online"),
  instituto_num = c(1, 1, 2, 2, 3, 3),
  metodologia_num = c(1, 1, 2, 2, 3, 3),
  stringsAsFactors = FALSE
)

# Pesqisas histórica
historico_teste <- data.frame(
  ano = 2022,
  cargo = "presidente",
  instituto = c("Datafolha", "Ipec", "Datafolha", "Ipec"),
  nome_candidato = c("Lula", "Lula", "Bolsonaro", "Bolsonaro"),
  percentual = c(48, 47, 43, 42),
  data = as.Date("2022-10-01"),
  turno = 1,
  sigla_uf = NA,
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
  nome = c("Lula", "Bolsonaro"),
  votos_recebidos = c(57259504, 51072345),
  total_votos = 118229719,
  stringsAsFactors = FALSE
)
