# Configuration function for Poll Aggregator

Defines configuration parameters for the poll aggregator, including Stan
settings, and election details.

## Usage

``` r
configurar_agregador(
  pesquisas = NULL,
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
  saida_modelos_brutos = "resultados_agregador/modelos_brutos"
)
```

## Arguments

- pesquisas:

  Path to a CSV file or URL containing current poll data. Defaults to a
  GitHub Raw URL.

- resultado_eleicao_passada:

  Path to a CSV file containing results from the previous election.
  Defaults to a GitHub Raw URL.

- resultado_eleicao_atual:

  Path to a CSV file containing results for the current election (useful
  for retrospective model). Defaults to a GitHub Raw URL.

- historico_pesquisas:

  Path to a CSV/RDS file containing historical poll data. If NULL
  (default), uses the package's internal dataset.

- candidaturas_1t:

  Character vector of candidates in the 1st round. If NULL, uses default
  candidates.

- candidaturas_2t:

  Character vector of candidates in the 2nd round. If NULL, uses default
  candidates.

- direita_eleicao_atual:

  Character vector of right-wing candidates in the current race. If
  NULL, uses default candidates. The model can compensate institute
  errors against right-wing candidates in the last election.

- direita_eleicao_passada:

  Name of the right-wing candidate in the previous election.

- esquerda_eleicao_atual:

  Character vector of left-wing candidates in the current race. If NULL,
  uses default candidates. The model can compensate institute errors
  against left-wing candidates in the last election.

- esquerda_eleicao_passada:

  Name of the left-wing candidate in the previous election.

- eleicao_passada_primeiro_turno:

  Date of the previous 1st round (e.g., "2/10/2022").

- eleicao_passada_segundo_turno:

  Date of the previous 2nd round (e.g., "30/10/2022").

- stan_cores:

  Number of CPU cores for Stan to use.

- stan_chains:

  Number of MCMC chains.

- stan_warmup:

  Number of warmup iterations per chain.

- stan_sampling:

  Number of sampling iterations per chain.

- stan_init:

  Initial value for Stan parameters.

- stan_adapt_delta:

  The target acceptance rate for Stan's NUTS algorithm.

- saida_bases_tratadas:

  Directory where treated data will be saved.

- saida_modelos_brutos:

  Directory where raw model objects will be saved.

## Value

A list of configuration parameters.

## Examples

``` r
# Create custom Stan settings
cfg_custom <- configurar_agregador(
  stan_warmup = 100,
  stan_sampling = 100
)
```
