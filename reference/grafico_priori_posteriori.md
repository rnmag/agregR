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
  dir_saida = "."
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
  result <- rodar_agregador(turno = 2, cenario = "Lula vs Bolsonaro", salvar = FALSE)

  # Prior vs Posterior plot for institute bias
  grafico_priori_posteriori(
    result,
    tipo = "Viés",
    candidaturas = c("Lula", "Bolsonaro"),
    salvar = FALSE
  )

  # Altering candidate colors
  grafico_priori_posteriori(
    result,
    candidaturas = c("Lula", "Bolsonaro"),
    salvar = FALSE,
    config_grafico = configurar_grafico(
      cores_candidaturas = c(Lula = "darkred")
    )
  )
}
#> 
#> ── Simulações do Segundo Turno ─────────────────────────────────────────────────
#> ✔ Base carregada e filtrada com sucesso!
#> ℹ Iniciando 4 cadeias de 1000 iterações por candidatura.
#> ℹ Há 30 pesquisas na base entre 01/01/25 e 13/02/26.
#> ℹ Se esses números parecerem incorretos, revise os argumentos e configurações da função.
#> Error in stan_compilado$has_exe(): attempt to apply non-function
```
