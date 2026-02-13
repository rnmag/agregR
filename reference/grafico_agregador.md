# Plot Aggregator Results

Generates a plot of the aggregated poll results over time.

## Usage

``` r
grafico_agregador(
  bd,
  salvar = FALSE,
  config_grafico = configurar_grafico(),
  dir_saida = ".",
  ...
)
```

## Arguments

- bd:

  The results object returned by \[rodar_agregador()\].

- salvar:

  Logical. If TRUE, saves the plot to disk.

- config_grafico:

  A list of graphic parameters created by \[configurar_grafico()\].

- dir_saida:

  Output directory for the saved plot if \`salvar = TRUE\`.

- ...:

  Additional arguments.

## Value

A ggplot2 object.

## Examples

``` r
if (instantiate::stan_cmdstan_exists()) {
  # Generate results
  result <- rodar_agregador(turno = 2, cenario = "Lula vs Bolsonaro", salvar = FALSE)

  # Standard plot
  grafico_agregador(result, salvar = FALSE)

  # Altering candidate colors
  grafico_agregador(
    result,
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
#> 
#> ── Estimando intenção de votos para: "Bolsonaro" ──
#> 
#> Error in mutate(nest(group_by(filter(pesquisas, turno == !!turno & candidatura %in%     candidaturas), candidatura)), modelos = map2(data, candidatura,     ajustar_modelo, turno = !!turno, data_inicio = data_inicio,     data_fim = data_fim, modelo = modelo, stan_compilado = stan_compilado,     config_agregador = config_agregador, config_prioris = config_prioris),     votos_estimados = map(modelos, "votos_estimados"), vies_institutos = map(modelos,         "vies_institutos"), modelo_bruto = map(modelos, "modelo_bruto")): ℹ In argument: `modelos = map2(...)`.
#> ℹ In group 1: `candidatura = "Bolsonaro"`.
#> Caused by error in `map2()`:
#> ℹ In index: 1.
#> Caused by error:
#> ! Model not compiled. Try running the compile() method first.
```
