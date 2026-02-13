# Historical Polls by Poder360

A dataset containing historical electoral polls compiled by Poder360.
This dataset is used to calculate empirical priors for the models.

## Usage

``` r
historico_pesquisas_poder360
```

## Format

A data frame with columns:

- ano:

  Election year

- cargo:

  Office being contested

- condicao:

  Condition (e.g., stimulated)

- contratante:

  Entity that paid for the poll

- data:

  Date of the poll

- data_referencia:

  Reference date for the poll

- descricao_cenario:

  Description of the electoral scenario

- id_candidato_poder360:

  Unique ID for the candidate

- id_cenario:

  Unique ID for the scenario

- id_pesquisa:

  Unique ID for the poll

- instituto:

  Name of the polling institute

- margem_mais:

  Upper margin of error

- margem_menos:

  Lower margin of error

- nome_candidato:

  Candidate name

- nome_municipio:

  City name (if applicable)

- numero_registro:

  Official registration number

- orgao_registro:

  Entity where the poll was registered

- percentual:

  Voting intention percentage

- quantidade_entrevistas:

  Sample size

- sigla_partido:

  Political party abbreviation

- sigla_uf:

  State abbreviation

- tipo:

  Poll type

- tipo_voto:

  Vote type (Total, Valid, etc.)

- turno:

  Election round (1 or 2)

## Source

Poder360
