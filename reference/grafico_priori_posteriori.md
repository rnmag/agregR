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
#> ℹ Há 30 pesquisas na base entre 01/01/25 e 15/02/26.
#> ℹ Se esses números parecerem incorretos, revise os argumentos e configurações da função.
#> 
#> ── Estimando intenção de votos para: "Bolsonaro" ──
#> 
#> Running MCMC with 4 parallel chains...
#> 
#> Chain 1 Iteration:   1 / 1000 [  0%]  (Warmup) 
#> Chain 2 Iteration:   1 / 1000 [  0%]  (Warmup) 
#> Chain 3 Iteration:   1 / 1000 [  0%]  (Warmup) 
#> Chain 4 Iteration:   1 / 1000 [  0%]  (Warmup) 
#> Chain 1 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 3 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 2 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 4 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 1 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 2 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 1 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 3 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 1 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 3 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 4 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 2 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 1 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 1 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 3 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 2 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 1 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 3 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 3 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 4 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 3 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 1 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 2 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 2 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 4 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 3 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 3 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 1 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 2 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 4 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 4 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 3 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 3 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 3 finished in 12.8 seconds.
#> Chain 1 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 2 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 4 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 2 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 1 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 1 finished in 13.9 seconds.
#> Chain 4 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 2 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 4 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 2 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 2 finished in 14.7 seconds.
#> Chain 4 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 4 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 4 finished in 15.6 seconds.
#> 
#> All 4 chains finished successfully.
#> Mean chain execution time: 14.3 seconds.
#> Total execution time: 15.7 seconds.
#> 
#> ── Estimando intenção de votos para: "Lula" ──
#> 
#> Running MCMC with 4 parallel chains...
#> 
#> Chain 1 Iteration:   1 / 1000 [  0%]  (Warmup) 
#> Chain 2 Iteration:   1 / 1000 [  0%]  (Warmup) 
#> Chain 3 Iteration:   1 / 1000 [  0%]  (Warmup) 
#> Chain 4 Iteration:   1 / 1000 [  0%]  (Warmup) 
#> Chain 1 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 2 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 3 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 4 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 3 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 1 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 2 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 4 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 1 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 3 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 2 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 1 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 3 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 2 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 4 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 1 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 1 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 4 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 1 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 3 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 3 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 4 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 4 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 1 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 2 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 2 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 4 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 1 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 3 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 4 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 1 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 2 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 4 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 1 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 3 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 1 finished in 10.8 seconds.
#> Chain 4 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 2 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 3 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 4 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 4 finished in 11.5 seconds.
#> Chain 2 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 3 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 2 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 3 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 3 finished in 12.4 seconds.
#> Chain 2 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 2 finished in 13.0 seconds.
#> 
#> All 4 chains finished successfully.
#> Mean chain execution time: 11.9 seconds.
#> Total execution time: 13.1 seconds.
#> 
```
