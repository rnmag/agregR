# agregR <a href='https://github.com/rnmag/agregR/'><img src='man/figures/logo.png' align="right" height="150" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/rnmag/agregR/workflows/CmdStan-R-CMD-check/badge.svg)](https://github.com/rnmag/agregR/actions)

<!-- badges: end -->

**An R package to estimate true voting intentions from disparate polling
sources**

As elections approach, Brazilian voters are confronted with a growing
volume of conflicting polling data from various institutes, each
employing distinct methodologies and sampling designs. `agregR` provides
the public with a rigorous statistical framework to filter the surfeit
of data and estimate the underlying level of support for each candidate.

`agregR` implements a set of Bayesian state-space models in
[Stan](https://mc-stan.org/) to aggregate and normalize high-frequency
polling data, extracting a stable latent signal from noisy,
heterogeneous, and often biased data sources. It features specialized
methods to account for:

- House effects relative to the consensus
- House effects based on past election performance
- Asymmetric errors based on candidates’ political alignment
- Non-sampling errors, such as design effects and non-ignorable
  non-response bias

## Installation

You can install the development version of `agregR` with:

``` r
if (!require(pak)) install.packages("pak")
pak("rnmag/agregR")
```

### Dependencies

`agregR` is built on [CmdStan](https://mc-stan.org/docs/cmdstan-guide/),
the state-of-the-art backend for Stan. Since CmdStan is not available on
CRAN [(and will likely never
be)](https://discourse.mc-stan.org/t/what-is-the-difference-between-rstan-cmdstanr-and-bridgestan/39226/3),
it needs to be installed separately. This one-time setup yields
substantial gains in compilation speed and sampling performance.

**Windows users** must first install
[RTools](https://cran.r-project.org/bin/windows/Rtools/) to compile C++
code.

After that, the most convenient way to install CmdStan is via the
`cmdstanr` interface. The following code guides you through installing
and checking the toolchain.

``` r
# Install cmdstanr interface
install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))

# Install CmdStan
cmdstanr::install_cmdstan()

# Check if toolchain is complete
cmdstanr::check_cmdstan_toolchain()
```

## Basic Usage

The main function `rodar_agregador()` acts as the controller,
orchestrating data preparation, model compilation, and sampling.

``` r
library(agregR)

# Execute the aggregation pipeline for a 2nd round scenario
results <- rodar_agregador(
  turno = 2,
  cenario = "Lula vs Tarcísio",
  modelo = "Viés Empírico"
)
```

### Visualization

The package includes a suite of plots designed for public communication.

#### 1. Voting Intentions

Visualizes the posterior distribution of the true voting intention
overlaying the raw polling data.

``` r
grafico_agregador(results)
```

![](man/figures/README-agregador-plot.png)

#### 2. House Effects

Visualizes the systematic bias for each institute, identifying outliers
and consistent directional skews.

``` r
grafico_vies(results, candidaturas = c("Lula", "Tarcísio"))
```

![](man/figures/README-vies-plot.png)

#### 3. Bayesian Updating Check

Visualizes how the data has informed the model by comparing Prior
vs. Posterior distributions for selected parameters.

``` r
grafico_priori_posteriori(results, tipo = "Viés", candidaturas = c("Lula", "Tarcísio"))
```

![](man/figures/README-prior-posterior-plot.png)

### Advanced Configuration

The package offers configuration functions for fine-grained control over
the models, including Stan settings and prior hyperparameters.

``` r
# Example: longer run with tighter priors for non-sampling error
results_custom <- rodar_agregador(
  turno = 2,
  cenario = "Lula vs Bolsonaro",
  config_agregador = list(
    stan_chains = 4,
    stan_iter = 2000,
    stan_warmup = 2000
  ),
  config_prioris = list(sd_tau_priori = 0.01)
)
```

## Methodology

The latent voting intention for each candidate evolves daily according
to a local linear trend (Jackman, 2009, Chapter 9.4). Electoral polls
are treated as noisy and potentially biased observations of this latent
state.

The likelihood function decomposes uncertainty into sampling error
($\sigma$), house effects ($\delta$), and an additional non-sampling
error term ($\tau$) inspired by Heidemanns, Gelman & Morris (2020).

Parameter distributions are standardized using Non-Centered
Parametrization (McElreath, 2020, Chapters 13–14; Stan Development Team,
2025, Section: Efficiency Tuning). Flattening the posterior geometry
addresses the “funnel” problem common in hierarchical models,
significantly improving sampling efficiency and convergence stability.

### Data

Data collection is deliberately *unselective*. Instead of subjectively
deciding which institutes produce high quality polls, we trust the
models to separate the wheat from the chaff.

Polls enter the model with adjustments to their sample size in order to
avoid undue influence from polls with large nominal $n$. We calculate
an *implicit* $n$ based on the published margin of error and compare it
to the nominal $n$. We use the most conservative figure to compute
candidate-specific standard errors as a function of their support level,
improving efficiency in lopsided races.

Historical data is sourced from Poder360’s polling database, [available
here](https://basedosdados.org/dataset/fb38dbe8-03ce-46b4-a6b7-638ade03999c?table=b6df9e1c-cbcb-4dbd-893b-8645a51773e6).

### Latent State

The evolution of the latent state is governed by two variables: a level
component $\mu_t$ and a trend component $\nu_t$.

1.  **Level Dynamics:** The state at time $t$ is the previous state plus
    the trend, subject to stochastic level innovations with standard
    deviation $\eta$.

```math
\mu_t \sim N(\mu_{t-1} + \nu_{t-1}, \eta)
```

2.  **Trend Dynamics:** The trend itself evolves as a random walk,
    allowing the momentum of a campaign to shift over time, controlled
    by trend volatility $\zeta$.

```math    
\nu_t \sim N(\nu_{t-1}, \zeta)
```

### Likelihood

In the days in which polling data $i$ is published, the observed result
$y_i$ from institute $j$ at time $t$ is modeled as:

```math
y_{i} = \begin{bmatrix}1 & 0\end{bmatrix} \begin{bmatrix}\mu_{t(i)} \\ \nu_{t(i)}\end{bmatrix} + \delta_{j(i), k(i), p(i)} + \varepsilon_{i}
```

where

```math
\varepsilon_{i} \sim N\left(0, \sqrt{\sigma_{i}^2 + \tau_{j(i), k(i), p(i)}^2}\right) 
```

and the latent state update is defined as:

```math
\begin{bmatrix}\mu_{t} \\ \nu_{t}\end{bmatrix} = \begin{bmatrix}1 & 1 \\ 0 & 1\end{bmatrix} +
\begin{bmatrix}\mu_{t - 1} \\ \nu_{t - 1}\end{bmatrix}
\begin{bmatrix}\omega_{\mu, t} \\ \omega_{\nu, t}\end{bmatrix}
```

where the volatility parameters follow hierarchical priors:

```math
\begin{aligned}
\omega_{\mu, t} &\sim N(0, \eta), \quad \eta \sim N^+(\eta_{0}, \sigma_{\eta}) \\
\omega_{\nu, t} &\sim N(0, \zeta), \quad \zeta \sim N^+(\zeta_{0}, \sigma_{\zeta})
\end{aligned}
```

with subscripts mapping poll $i$ to its metadata:

- $t(i)$: **Date** of publication.
- $j(i)$: **Polling institute** ($j \in \{1, \dots, J\}$).
- $k(i)$: **Election round** ($k \in \{1, 2\}$).
- $p(i)$: Candidate’s **political alignment**
  ($p \in \{\text{left, right, center}\}$).

The measurement model thus decomposes uncertainty into three distinct
sources:

1.  **Sampling Error ($\sigma_{i}$):** The inherent uncertainty derived
    from the effective sample size of the poll $i$.
2.  **House Effects ($\delta_{j,k,p}$):** A systematic deviation
    specific to institute $j$, conditional on the election round $k$ and
    the candidate’s political alignment $p$.
3.  **Non-Sampling Error ($\tau_{j,k,p}$):** An additional variance term
    capturing errors extrinsic to sampling theory (e.g., design effects,
    non-ignorable non-response bias), also localized by institute $j$,
    round $k$, and alignment $p$.

### Hierarchical Priors & Regularization

`agregR` features partial pooling by employing regularizing priors for
bias and precision parameters. Specific values for priors can be
accessed (and modified) by the `configurar_prioris()` function.

1.  **Bias Shrinkage:** House effects $\delta_{j,k,p}$ follow a
    structured prior centered on a consensus anchor (sum-to-zero) or
    historical alignment. This prevents individual polls from
    disproportionately pulling the latent trend unless supported by
    cumulative evidence.
2.  **Historical Precision:** Non-sampling errors $\tau_{j,k,p}$ use
    past election performance as prior means. This “weighted” approach
    allows the model to automatically down-weight institutes with
    historically poor accuracy while maintaining the flexibility to
    update these estimates based on current-cycle data.
3.  **Automated Regularization:** The hierarchical priors on $\eta$
    (level volatility) and $\zeta$ (trend volatility) govern the
    “stiffness” of the aggregator. This approach prevents over-fitting
    to high-frequency noise while allowing the model to adapt when
    consistent evidence of a shift in public opinion emerges.

### Models Overview

Based on the methods described above, `agregR` offers a set of
specialized models that differ in their assumptions regarding house
effects ($\delta$) and non-sampling error ($\tau$) estimation:

- **Anchoring:** Since $\mu$ and $\delta$ are not jointly identified,
  the models use either the collective consensus of institutes or
  historical/actual electoral results as a fixed reference point.
- **Weighting:** Models using institute-specific $\tau$ effectively
  perform **automated weighting**. Institutes with higher Root Mean
  Square Error (RMSE) in the last election have their polls discounted
  in the posterior latent trend.

| Model                                                    | House Effects Anchor ($\delta$)                               | Non-Sampling Error Prior ($\tau$)                                |
|:---------------------------------------------------------|:--------------------------------------------------------------|:-----------------------------------------------------------------|
| **Viés Relativo com Pesos** (*Weighted Relative Bias*)   | Consensus-based $(\sum \delta_j = 0)$                         | Institute-specific $\tau_{j,k,p}$ (prior $\leftarrow$ past RMSE) |
| **Viés Relativo sem Pesos** (*Unweighted Relative Bias*) | Consensus-based $(\sum \delta_j = 0)$                         | Global scalar $\tau$                                             |
| **Viés Empírico** (*Empirical Bias*)                     | Last election $\delta_{j,k,p}$ (prior $\leftarrow$ past bias) | Institute-specific $\tau_{j,k,p}$ (prior $\leftarrow$ past RMSE) |
| **Retrospectivo** (*Retrospective*)                      | Actual election result ($\mu_T$)                              | Global scalar $\tau$                                             |
| **Naive**                                                | None (assumed zero)                                           | None (assumed zero)                                              |

### References

- Heidemanns, H., Gelman, A., & Morris, G. (2020). *An Updated Dynamic
  Bayesian Forecasting Model for the 2020 Election*. Harvard Data
  Science Review.
- Jackman, S. (2009). *Bayesian Analysis for the Social Sciences*.
  Wiley.
- McElreath, R. (2020). *Statistical Rethinking: A Bayesian Course with
  Examples in R and Stan*. CRC Press.
- Stan Development Team. (2025). *Stan User’s Guide, Version 2.38
  (Section: Efficiency Tuning)*. Retrieved from
  <https://mc-stan.org/docs/stan-users-guide/efficiency-tuning.html>
