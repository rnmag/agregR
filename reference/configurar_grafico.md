# Configuration for Graphics

Defines configuration parameters for graphics, including colors, fonts,
and dimensions.

## Usage

``` r
configurar_grafico(
  fonte = "Fira Sans",
  cores_candidaturas = NULL,
  simbolos = NULL,
  graf_largura = 2918,
  graf_altura = 1913,
  graf_unidade = "px",
  graf_dpi = 320,
  dir_grafico = "resultados_agregador/graficos"
)
```

## Arguments

- fonte:

  Font family (default: "Fira Sans").

- cores_candidaturas:

  Named vector or list of colors for candidates. Can be a partial
  override.

- simbolos:

  Named vector or list of symbols for methodologies. Can be a partial
  override.

- graf_largura:

  Width of saved plots.

- graf_altura:

  Height of saved plots.

- graf_unidade:

  Unit for dimensions ("px", "in", "cm", "mm").

- graf_dpi:

  DPI for saved plots.

- dir_grafico:

  Directory to save plots.

## Value

A list of graphic configuration parameters.

## Examples

``` r
# Alternative colors for use in the config_grafico argument in a plot
config_custom <- configurar_grafico(
  cores_candidaturas = c(Lula = "darkred")
)
```
