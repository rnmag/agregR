#' @encoding UTF-8
#' @title Configuration function for Poll Aggregator
#' @description Defines configuration parameters for the poll aggregator, including Stan settings, and election details.
#' @param pesquisas Path to a CSV file or URL containing current poll data. Defaults to a GitHub Raw URL.
#' @param resultado_eleicao_passada Path to a CSV file containing results from the previous election. Defaults to a GitHub Raw URL.
#' @param resultado_eleicao_atual Path to a CSV file containing results for the current election (useful for retrospective model). Defaults to a GitHub Raw URL.
#' @param historico_pesquisas Path to a CSV/RDS file containing historical poll data. If NULL (default), uses the package's internal dataset.
#' @param candidaturas_1t Character vector of candidates in the 1st round. If NULL, uses default candidates.
#' @param candidaturas_2t Character vector of candidates in the 2nd round. If NULL, uses default candidates.
#' @param direita_eleicao_atual Character vector of right-wing candidates in the current race. If NULL, uses default candidates. The model can compensate institute errors against right-wing candidates in the last election.
#' @param direita_eleicao_passada Name of the right-wing candidate in the previous election.
#' @param esquerda_eleicao_atual Character vector of left-wing candidates in the current race. If NULL, uses default candidates. The model can compensate institute errors against left-wing candidates in the last election.
#' @param esquerda_eleicao_passada Name of the left-wing candidate in the previous election.
#' @param eleicao_passada_primeiro_turno Date of the previous 1st round (e.g., "2/10/2022").
#' @param eleicao_passada_segundo_turno Date of the previous 2nd round (e.g., "30/10/2022").
#' @param stan_cores Number of CPU cores for Stan to use.
#' @param stan_chains Number of MCMC chains.
#' @param stan_warmup Number of warmup iterations per chain.
#' @param stan_sampling Number of sampling iterations per chain.
#' @param stan_init Initial value for Stan parameters.
#' @param stan_adapt_delta The target acceptance rate for Stan's NUTS algorithm.
#' @param saida_bases_tratadas Directory where treated data will be saved.
#' @param saida_modelos_brutos Directory where raw model objects will be saved.
#' @return A list of configuration parameters.
#' @export
#' @examples
#' # Create custom Stan settings
#' cfg_custom <- configurar_agregador(
#'   stan_warmup = 100,
#'   stan_sampling = 100
#' )
configurar_agregador <- function(pesquisas = NULL,
                                 resultado_eleicao_passada = NULL,
                                 resultado_eleicao_atual = NULL,
                                 historico_pesquisas = NULL,
                                 candidaturas_1t = NULL,
                                 candidaturas_2t = NULL,
                                 direita_eleicao_atual = NULL,
                                 direita_eleicao_passada = "Bolsonaro",
                                 esquerda_eleicao_atual = NULL,
                                 esquerda_eleicao_passada = "Lula",
                                 eleicao_passada_primeiro_turno = "2/10/2022",
                                 eleicao_passada_segundo_turno = "30/10/2022",
                                 stan_cores = pmin(parallel::detectCores(), 4),
                                 stan_chains = 4,
                                 stan_warmup = 500,
                                 stan_sampling = 500,
                                 stan_init = 0.1,
                                 stan_adapt_delta = 0.99,
                                 saida_bases_tratadas = "resultados_agregador/bases_tratadas",
                                 saida_modelos_brutos = "resultados_agregador/modelos_brutos") {

  # Definir URLs padrão se NULL
  if (is.null(pesquisas)) {

    pesquisas <- "https://raw.githubusercontent.com/rnmag/agregR/refs/heads/main/inst/extdata/pesquisas_2026.csv"

  }

  if (is.null(resultado_eleicao_passada)) {

    resultado_eleicao_passada <- "https://raw.githubusercontent.com/rnmag/agregR/refs/heads/main/inst/extdata/resultado_eleicao_passada.csv"

  }

  if (is.null(resultado_eleicao_atual)) {

    resultado_eleicao_atual <- "https://raw.githubusercontent.com/rnmag/agregR/refs/heads/main/inst/extdata/resultado_eleicao_atual.csv"

  }

  # Definir candidaturas sem precisar refazer documentação
  if (is.null(candidaturas_1t)) {
    candidaturas_1t <- c("Lula", "Fl\u00e1vio", "Caiado", "Renan", "Zema")
  }

  if (is.null(candidaturas_2t)) { # Bolsonaro fica só para rodar os exemplos do pacote
    candidaturas_2t <- c("Bolsonaro", "Lula", "Fl\u00e1vio", "Caiado", "Renan", "Zema")
  }

  if (is.null(direita_eleicao_atual)) {
    direita_eleicao_atual <- c("Bolsonaro", "Fl\u00e1vio")
  }

  if (is.null(esquerda_eleicao_atual)) {
    esquerda_eleicao_atual <- c("Lula", "Haddad")
  }

  list(pesquisas = pesquisas,
       historico_pesquisas = historico_pesquisas,
       resultado_eleicao_passada = resultado_eleicao_passada,
       resultado_eleicao_atual = resultado_eleicao_atual,
       candidaturas_1t = candidaturas_1t,
       candidaturas_2t = candidaturas_2t,
       direita_eleicao_atual = direita_eleicao_atual,
       direita_eleicao_passada = direita_eleicao_passada,
       esquerda_eleicao_atual = esquerda_eleicao_atual,
       esquerda_eleicao_passada = esquerda_eleicao_passada,
       data_primeiro_turno = eleicao_passada_primeiro_turno,
       data_segundo_turno = eleicao_passada_segundo_turno,
       stan = list(cores = stan_cores,
                   chains = stan_chains,
                   warmup = stan_warmup,
                   sampling = stan_sampling,
                   init = stan_init, # iniciar sim próximo da média
                   adapt_delta = stan_adapt_delta), # explorar com passos pequanos
       saida_bases_tratadas = saida_bases_tratadas,
       saida_modelos_brutos = saida_modelos_brutos)
}
