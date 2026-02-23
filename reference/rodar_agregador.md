# Run Poll Aggregator

Main function to run the state-space model for poll aggregation.

## Usage

``` r
rodar_agregador(
  bd = NULL,
  data_inicio = NULL,
  data_fim = Sys.Date(),
  cargo = "Presidente",
  ambito = "Brasil",
  cenario = NULL,
  turno,
  modelo = "Viés Relativo com Pesos",
  config_agregador = NULL,
  config_prioris = NULL,
  salvar = FALSE,
  dir_saida = "."
)
```

## Arguments

- bd:

  Dataframe or path to a CSV file containing poll data.

- data_inicio:

  Start date for the analysis (mandatory).

- data_fim:

  End date for the analysis.

- cargo:

  The office/position being contested (e.g., "Presidente"). Current data
  only contains presidential polls, but the package supports expansion
  for other offices.

- ambito:

  The geographical scope (e.g., "Brasil"). Current data only contains
  national polls, but the package supports expansion for state races.

- cenario:

  The specific electoral scenario. Mandatory for second round.

- turno:

  The election round (1 or 2).

- modelo:

  The name of the model to run. Options: "Viés Relativo com Pesos"
  (default), "Viés Relativo sem Pesos", "Viés Empírico", "Retrospectivo"
  and "Naive".

- config_agregador:

  A list of configuration parameters created by
  [`configurar_agregador()`](https://rnmag.github.io/agregR/reference/configurar_agregador.md).
  If NULL, uses defaults.

- config_prioris:

  A list of model hyperparameters created by
  [`configurar_prioris()`](https://rnmag.github.io/agregR/reference/configurar_prioris.md).
  If NULL, uses defaults based on `modelo`.

- salvar:

  Logical. If TRUE, saves the results to disk.

- dir_saida:

  Output directory for saved files if `salvar = TRUE`.

## Value

A list containing the model name, estimated votes, institute bias, and
the raw model object.

## Model Details

The aggregator supports five types of Bayesian state-space models, each
with specific assumptions about institute bias and non-sampling errors:

**1. Viés Relativo com Pesos (Default)**

- **Assumption:** Institute biases are relative to the average of all
  institutes (latent "truth" is anchored to the consensus).

- **Bias (\\\delta\\):** Calculated relative to the mean bias of all
  institutes.

- **Weights (\\\tau\\):** Uses past election performance to weight the
  non-sampling error. Institutes with larger historical errors have less
  influence on the current estimate.

- **Use case:** Best for general forecasting when historical data is
  available.

**2. Viés Relativo sem Pesos**

- **Assumption:** Same as above, but treats all institutes as having
  equal potential quality a priori.

- **Bias (\\\delta\\):** Calculated relative to the mean bias.

- **Weights (\\\tau\\):** None. All institutes share the same prior for
  non-sampling error.

- **Use case:** When historical data is unreliable or when a "fresh
  start" assumption is desired.

**3. Viés Empírico**

- **Assumption:** Institute biases are anchored to their specific
  historical performance.

- **Bias (\\\delta\\):** Prior means are set to the bias observed in the
  previous election (directional error).

- **Weights (\\\tau\\):** Uses past performance for non-sampling error,
  similar to the "Com Pesos" model.

- **Use case:** When institutes are expected to repeat their specific
  past directional errors (e.g., consistently underestimating a specific
  wing).

**4. Retrospectivo**

- **Assumption:** The true election result is known and used as the
  final anchor for the state-space model.

- **Method:** Runs the model "backwards" or constrained by the final
  result to estimate the true path of public opinion.

- **Use case:** Post-election analysis to diagnose institute performance
  and calculate accurate biases for future calibration.

**5. Naive**

- **Assumption:** Polls have no bias and no non-sampling error.

- **Method:** A random walk model where the only source of uncertainty
  is the sampling error (\\\sigma\\).

- **Use case:** Baseline comparison. Assumes "polls are perfect" within
  their margin of error.

## Priors Details

The `config_prioris` argument allows customization of the model's
hyperparameters with the
[`configurar_prioris()`](https://rnmag.github.io/agregR/reference/configurar_prioris.md)
function.

These hyperparameters control the strength of assumptions regarding
latent state evolution, institute bias, and non-sampling errors.

Variable names refer to the model notation described in
<https://rnmag.github.io/agregR/index.html#conceptual-framework>

Recommended reading:
<https://github.com/stan-dev/stan/wiki/prior-choice-recommendations>

**State Model - Level (\\\mu\\)**

- `mu_priori`: Prior mean for the latent vote share at \\t=1\\.

- `sd_mu_priori`: Prior uncertainty for the initial latent vote.

  - *Default values*: \\\mu\\ starts with a flat prior of N(0.5, 0.5),
    allowing data to quickly dominate inference.

- `omega_eta_priori`: Prior mean for the level volatility
  (\\\omega\_\eta\\).

- `sd_omega_eta_priori`: Prior uncertainty for the level volatility.

  - *Default values*: With `omega_eta_priori = 0.002` and
    `sd_omega_eta_priori = 0.0001`, the model assumes a **baseline
    drift** of approx. \\\pm 2\\ percentage points over a month (\\1.96
    \times \sqrt{30} \times 0.002 \approx 0.02\\).

  - *Higher values*: The latent vote (\\\mu\\) can jump more from one
    day to the next. The model adapts more quickly to new polls but
    becomes more "jittery".

  - *Lower values*: The model assumes the public opinion level is more
    stable over time, resulting in smoother curves.

**State Model - Trend (\\\nu\\)**

- `nu_priori`: Prior mean for the initial trend (daily growth rate).

- `sd_nu_priori`: Prior uncertainty for the initial trend.

  - *Default values*: With `nu_priori = 0` and `sd_nu_priori = 0.001`,
    the model expects an initial trend within \\\pm 0.2\\ percentage
    points per day (\\1.96 \times 0.001 \approx 0.002\\).

- `omega_zeta_priori`: Prior mean for the trend volatility
  (\\\omega\_\zeta\\).

- `sd_omega_zeta_priori`: Prior uncertainty for the trend volatility.

  - *Default values*: With `omega_zeta_priori = 0` and
    `sd_omega_zeta_priori = 0.00001`, the model assumes a linear
    evolution, allowing the trend to shift rapidly (accelerations) only
    under strong evidence.

  - *Higher values:* The trend (\\\nu\\) can change direction or
    magnitude rapidly.

  - *Lower values:* The trend is assumed to be more constant over time
    (more linear evolution).

**Institute Bias (\\\delta\\)**

- `delta_priori`: Mean expected bias for institutes. Default is 0,
  except in "Viés Empírico" where it is anchored on past performance.

- `sd_delta_priori`: Scale of the bias prior.

  - *Default values*: With `delta_priori = 0` and
    `sd_delta_priori = 0.02`, the model assumes that 95% of institutes
    have a bias within \\\pm 4\\ percentage points (\\1.96 \times 0.02
    \approx 0.04\\).

  - *Higher values:* Allow for larger, more variable biases across
    institutes.

  - *Lower values:* Constrain institutes to have similar biases
    (shrinkage toward the anchor).

**Non-Sampling Error (\\\tau\\)**

- `tau_priori`: Mean expected magnitude of errors not explained by
  sampling or house effects. In weighted models, this is replaced by the
  empirical RMSE from past elections.

- `sd_tau_priori`: Prior uncertainty for non-sampling error.

  - *Default values*: With `tau_priori = 0.02` and
    `sd_tau_priori = 0.02`, the model assumes a **baseline** of \\\pm
    4\\ percentage points of "noise" in each poll, allowing it to spread
    closer to \\\pm 7\\ percentage points.

  - *Higher values:* The model treats polls as less precise, widening
    the credible intervals of the latent state.

  - *Lower values:* The model trusts polling precision more, leading to
    tighter intervals and potentially more sensitivity to outliers.

## Examples

``` r
# Running the default model for a second round scenario
if (instantiate::stan_cmdstan_exists()) {
  result <- rodar_agregador(
    data_inicio = "01/01/2025",
    turno = 2,
    cenario = "Lula vs Bolsonaro"
  )

# Tuning Stan, changing the model and altering specific priors
  custom_result <- rodar_agregador(
    data_inicio = "01/01/2025",
    turno = 2,
    cenario = "Lula vs Bolsonaro",
    modelo = "Viés Relativo sem Pesos",
    config_agregador = list(stan_chains = 1, stan_warmup = 200),
    config_prioris = list(tau_priori = 0.01)
  )
}
#> 
#> ── Simulações do Segundo Turno ─────────────────────────────────────────────────
#> ✔ Base carregada e filtrada com sucesso!
#> ℹ Iniciando 4 cadeias de 1000 iterações por candidatura.
#> ℹ Há 30 pesquisas na base entre 01/01/25 e 23/02/26.
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
#> Chain 2 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 1 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 3 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 4 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 1 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 3 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 2 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 1 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 4 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 1 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 2 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 4 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 1 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 1 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 2 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 3 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 4 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 1 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 2 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 2 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 3 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 4 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 4 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 1 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 2 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 4 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 3 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 3 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 1 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 2 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 4 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 3 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 1 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 2 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 4 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 3 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 1 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 1 finished in 14.4 seconds.
#> Chain 2 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 3 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 4 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 3 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 2 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 2 finished in 15.6 seconds.
#> Chain 4 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 4 finished in 15.7 seconds.
#> Chain 3 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 3 finished in 16.0 seconds.
#> 
#> All 4 chains finished successfully.
#> Mean chain execution time: 15.4 seconds.
#> Total execution time: 16.2 seconds.
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
#> Chain 2 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 4 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 1 Iteration: 100 / 1000 [ 10%]  (Warmup) 
#> Chain 3 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 3 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 2 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 4 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 1 Iteration: 200 / 1000 [ 20%]  (Warmup) 
#> Chain 3 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 1 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 3 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 3 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 2 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 4 Iteration: 300 / 1000 [ 30%]  (Warmup) 
#> Chain 4 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 1 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 2 Iteration: 400 / 1000 [ 40%]  (Warmup) 
#> Chain 3 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 2 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 2 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 4 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 4 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 1 Iteration: 500 / 1000 [ 50%]  (Warmup) 
#> Chain 1 Iteration: 501 / 1000 [ 50%]  (Sampling) 
#> Chain 3 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 1 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 2 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 4 Iteration: 600 / 1000 [ 60%]  (Sampling) 
#> Chain 3 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 2 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 4 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 1 Iteration: 700 / 1000 [ 70%]  (Sampling) 
#> Chain 3 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 2 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 4 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 1 Iteration: 800 / 1000 [ 80%]  (Sampling) 
#> Chain 3 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 3 finished in 12.9 seconds.
#> Chain 2 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 1 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 4 Iteration: 900 / 1000 [ 90%]  (Sampling) 
#> Chain 2 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 2 finished in 14.0 seconds.
#> Chain 4 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 4 finished in 14.4 seconds.
#> Chain 1 Iteration: 1000 / 1000 [100%]  (Sampling) 
#> Chain 1 finished in 14.5 seconds.
#> 
#> All 4 chains finished successfully.
#> Mean chain execution time: 14.0 seconds.
#> Total execution time: 14.6 seconds.
#> 
#> ── Simulações do Segundo Turno ─────────────────────────────────────────────────
#> ✔ Base carregada e filtrada com sucesso!
#> ℹ Iniciando 1 cadeia de 700 iterações por candidatura.
#> ℹ Há 30 pesquisas na base entre 01/01/25 e 23/02/26.
#> ℹ Se esses números parecerem incorretos, revise os argumentos e configurações da função.
#> 
#> ── Estimando intenção de votos para: "Bolsonaro" ──
#> 
#> Running MCMC with 1 chain...
#> 
#> Chain 1 Iteration:   1 / 700 [  0%]  (Warmup) 
#> Chain 1 Iteration: 100 / 700 [ 14%]  (Warmup) 
#> Chain 1 Iteration: 200 / 700 [ 28%]  (Warmup) 
#> Chain 1 Iteration: 201 / 700 [ 28%]  (Sampling) 
#> Chain 1 Iteration: 300 / 700 [ 42%]  (Sampling) 
#> Chain 1 Iteration: 400 / 700 [ 57%]  (Sampling) 
#> Chain 1 Iteration: 500 / 700 [ 71%]  (Sampling) 
#> Chain 1 Iteration: 600 / 700 [ 85%]  (Sampling) 
#> Chain 1 Iteration: 700 / 700 [100%]  (Sampling) 
#> Chain 1 finished in 6.8 seconds.
#> ── Estimando intenção de votos para: "Lula" ──
#> 
#> Running MCMC with 1 chain...
#> 
#> Chain 1 Iteration:   1 / 700 [  0%]  (Warmup) 
#> Chain 1 Iteration: 100 / 700 [ 14%]  (Warmup) 
#> Chain 1 Iteration: 200 / 700 [ 28%]  (Warmup) 
#> Chain 1 Iteration: 201 / 700 [ 28%]  (Sampling) 
#> Chain 1 Iteration: 300 / 700 [ 42%]  (Sampling) 
#> Chain 1 Iteration: 400 / 700 [ 57%]  (Sampling) 
#> Chain 1 Iteration: 500 / 700 [ 71%]  (Sampling) 
#> Chain 1 Iteration: 600 / 700 [ 85%]  (Sampling) 
#> Chain 1 Iteration: 700 / 700 [100%]  (Sampling) 
#> Chain 1 finished in 6.2 seconds.
```
