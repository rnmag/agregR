# Plot Institute Bias

Generates a plot visualizing the bias of polling institutes.

## Usage

``` r
grafico_vies(
  bd,
  candidaturas,
  salvar = FALSE,
  config_grafico = configurar_grafico(),
  dir_saida = NULL,
  ...
)
```

## Arguments

- bd:

  The results object returned by
  [`rodar_agregador()`](https://rnmag.github.io/agregR/reference/rodar_agregador.md).

- candidaturas:

  A character vector of candidate names to include in the plot.

- salvar:

  Logical. If TRUE, saves the plot to disk.

- config_grafico:

  A list of graphic parameters created by
  [`configurar_grafico()`](https://rnmag.github.io/agregR/reference/configurar_grafico.md).

- dir_saida:

  Output directory for the saved plot if `salvar = TRUE`.

- ...:

  Additional arguments.

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

  # Standard bias plot
  std_plot <- grafico_vies(
    result,
    candidaturas = c("Lula", "Bolsonaro")
  )

  # Altering candidate colors
  custom_plot <- grafico_vies(
    result,
    candidaturas = c("Lula", "Bolsonaro"),
    config_grafico = configurar_grafico(
      cores_candidaturas = c(Lula = "yellow")
    )
  )
}
#> 
#> ── Simulações do Segundo Turno ─────────────────────────────────────────────────
#> ✔ Base carregada e filtrada com sucesso!
#> ℹ Iniciando 4 cadeias de 1000 iterações por candidatura.
#> ℹ Há 30 pesquisas na base entre 01/01/25 e 15/08/26.
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
#> Chain 1 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 4 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 2 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 3 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 2 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 1 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 3 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 2 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 4 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 1 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 3 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 1 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 1 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 2 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 2 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 4 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 3 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 3 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 2 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 1 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 4 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 3 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 2 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 1 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 3 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 4 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 4 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 1 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 2 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 3 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 4 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 2 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 1 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 3 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 4 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 2 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 2 finished in 26.9 seconds.
#> Chain 1 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 1 finished in 27.0 seconds.
#> Chain 3 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 3 finished in 27.1 seconds.
#> Chain 4 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 4 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 4 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 4 finished in 29.5 seconds.
#> 
#> All 4 chains finished successfully.
#> Mean chain execution time: 27.6 seconds.
#> Total execution time: 29.7 seconds.
#> 
#> ── Estimando intenção de votos para: "Lula" ──
#> 
#> Running MCMC with 4 parallel chains...
#> 
#> Chain 1 Iteration:   1 / 1000 [  0%]  (Warmup) 
#> Chain 2 Iteration:   1 / 1000 [  0%]  (Warmup) 
#> Chain 3 Iteration:   1 / 1000 [  0%]  (Warmup) 
#> Chain 4 Iteration:   1 / 1000 [  0%]  (Warmup) 
#> Chain 3 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 4 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 2 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 1 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 3 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 2 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 4 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 1 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 3 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 2 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 1 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 4 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 3 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 2 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 1 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 4 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 2 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 2 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 3 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 3 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 2 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 4 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 4 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 1 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 1 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 3 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 2 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 4 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 3 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 2 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 4 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 1 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 3 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 2 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 4 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 3 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 2 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 2 finished in 24.6 seconds.
#> Chain 4 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 1 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 3 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 3 finished in 25.1 seconds.
#> Chain 4 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 4 finished in 25.8 seconds.
#> Chain 1 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 1 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 1 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 1 finished in 31.5 seconds.
#> 
#> All 4 chains finished successfully.
#> Mean chain execution time: 26.8 seconds.
#> Total execution time: 31.5 seconds.
#> 
```
