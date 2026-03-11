# Plot Prior vs Posterior

Generates a plot comparing prior and posterior distributions for
candidates or bias.

## Usage

``` r
grafico_priori_posteriori(
  bd,
  candidaturas,
  tipo = "Viés",
  salvar = FALSE,
  config_agregador = configurar_agregador(),
  config_grafico = configurar_grafico(),
  config_prioris = configurar_prioris(bd$nome_modelo),
  dir_saida = NULL
)
```

## Arguments

- bd:

  The results object returned by
  [`rodar_agregador()`](https://rnmag.github.io/agregR/reference/rodar_agregador.md).

- candidaturas:

  A character vector of candidate names to include in the plot.

- tipo:

  The type of da to plot: "Viés" (for institute bias) or "Percentual"
  (for candidate voting share).

- salvar:

  Logical. If TRUE, saves the plot to disk.

- config_agregador:

  A list of configuration parameters created by
  [`configurar_agregador()`](https://rnmag.github.io/agregR/reference/configurar_agregador.md).

- config_grafico:

  A list of graphic parameters created by
  [`configurar_grafico()`](https://rnmag.github.io/agregR/reference/configurar_grafico.md).

- config_prioris:

  A list of model hyperparameters created by
  [`configurar_prioris()`](https://rnmag.github.io/agregR/reference/configurar_prioris.md).

- dir_saida:

  Output directory for the saved plot if `salvar = TRUE`.

## Value

A ggplot2 object.

## Examples

``` r
if (instantiate::stan_cmdstan_exists()) {
  result <- rodar_agregador(
    data_inicio = "01/01/2025",
    turno = 2,
    cenario = "Lula vs Bolsonaro"
  )

  # Prior vs Posterior plot for institute bias
  std_plot <- grafico_priori_posteriori(
    result,
    tipo = "Viés",
    candidaturas = c("Lula", "Bolsonaro")
  )

  # Altering candidate colors
  custom_plot <- grafico_priori_posteriori(
    result,
    candidaturas = c("Lula", "Bolsonaro"),
    config_grafico = configurar_grafico(
      cores_candidaturas = c(Lula = "yelow")
    )
  )
}
#> Warning: One or more parsing issues, call `problems()` on your data frame for details,
#> e.g.:
#>   dat <- vroom(...)
#>   problems(dat)
#> Warning: One or more parsing issues, call `problems()` on your data frame for details,
#> e.g.:
#>   dat <- vroom(...)
#>   problems(dat)
#> Error in mutate(ler_csv(bd), dia = dmy(dia), pesquisa_id = paste(instituto,     "-", dia), percentual_pesquisa = as.numeric(percentual_pesquisa)/100,     n_implicito = round(1.96^2 * 0.5 * 0.5/((margem_pesquisa/100)^2)),     n_efetivo = case_when(qtd_entrevistas > n_implicito ~ n_implicito,         TRUE ~ qtd_entrevistas), ep = round(sqrt(percentual_pesquisa *         (1 - percentual_pesquisa)/n_efetivo), 4), metodologia = case_when(!is.na(metodologia) ~         metodologia, instituto %in% c("FSB", "Ponteio", "Ideia Big Data",         "PoderData", "Ipespe", "Futura", "Ranking", "Gerp") ~         "Telefônica", instituto %in% c("Sensus", "MDA", "Quaest",         "Ipec", "Paraná Pesquisas", "Vox Populi", "Datafolha",         "Datatempo") ~ "Presencial", instituto %in% c("Atlas") ~         "Online", TRUE ~ "Desconhecida")): ℹ In argument: `n_efetivo = case_when(...)`.
#> Caused by error in `case_when()`:
#> ! Can't combine `..1 (right)` <double> and `..2 (right)` <character>.
```
