# Configuration for Statistical Models

Defines hyperparameters for the specific Bayesian models.

## Usage

``` r
configurar_prioris(nome = "Viés Relativo com Pesos", ...)
```

## Arguments

- nome:

  Name of the model. Options: "Viés Relativo com Pesos", "Viés Relativo
  sem Pesos", "Viés Empírico", "Retrospectivo" and "Naive".

- ...:

  Named arguments to override default hyperparameters (e.g.,
  `sd_tau_priori = 0.05`).

## Value

A list of model parameters.

## Priors Details

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

  - *Default values*: With `omega_eta_priori = 0.002`, the model assumes
    a **baseline drift** of approx. \\\pm 2\\ percentage points over a
    month (\\1.96 \times \sqrt{30} \times 0.002 \approx 0.02\\).

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

  - *Default values*: With `omega_zeta_priori = 0.00001`, the model
    assumes a linear evolution, allowing the trend to shift rapidly
    (accelerations) only under strong evidence.

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
# Get default parameters for the "Naive" model
naive_params <- configurar_prioris(nome = "Naive")

# Get parameters for "Naive" and override a default value
custom_params <- configurar_prioris(nome = "Naive", sd_mu_priori = 0.2)
```
