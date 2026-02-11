#' @encoding UTF-8
#' @title Configuration for Statistical Models
#' @description Defines hyperparameters for the specific Bayesian models.
#' @section Priors Details:
#' These hyperparameters control the strength of assumptions regarding latent
#' state evolution, institute bias, and non-sampling errors.
#'
#' \strong{State Model - Level (\eqn{\mu})}
#' \itemize{
#'   \item \code{mu_priori}: Prior mean for the latent vote share at \eqn{t=1}.
#'   \item \code{sd_mu_priori}: Prior uncertainty for the initial latent vote.
#'   \itemize{
#'      \item \emph{Default values}: \eqn{\mu} starts with a flat prior of N(.5, .5), allowing data to quickly dominate inference.
#'   }
#'   \item \code{omega_eta_priori}: Prior mean for the level volatility (\eqn{\omega_\eta}).
#'   \item \code{sd_omega_eta_priori}: Prior uncertainty for the level volatility.
#'   \itemize{
#'      \item \emph{Default values}: With \code{omega_eta_priori = 0.002}, the model allows the latent vote to drift by approx. \eqn{\pm 2} percentage points over a month (\eqn{1.96 \times \sqrt{30} \times 0.002 \approx 0.02}).
#'      \item \emph{Higher values (eta)}: The latent vote (\eqn{\mu}) can jump more from one day to the next. The model adapts more quickly to new polls but becomes more "jittery".
#'      \item \emph{Lower values (eta)}: The model assumes the public opinion level is more stable over time, resulting in smoother curves.
#'   }
#' }
#'
#' \strong{State Model - Trend (\eqn{\nu})}
#' \itemize{
#'   \item \code{nu_priori}: Prior mean for the initial trend (daily growth rate).
#'   \item \code{sd_nu_priori}: Prior uncertainty for the initial trend.
#'   \itemize{
#'      \item \emph{Default values}: Centered at 0 and with \code{sd_nu_priori = 0.001}, the model expects an initial trend within \eqn{\pm 0.2} percentage points per day (\eqn{1.96 \times 0.001 \approx 0.002}).
#'   }
#'   \item \code{omega_zeta_priori}: Prior mean for the trend volatility (\eqn{\omega_\zeta}).
#'   \item \code{sd_omega_zeta_priori}: Prior uncertainty for the trend volatility.
#'   \itemize{
#'      \item \emph{Default values}: \code{omega_zeta_priori = 0} assumes a stable trend that only shifts rapidly under strong evidence.
#'      \item \emph{Higher values (zeta):} The trend (\eqn{\nu}) can change direction or magnitude rapidly (accelerations/decelerations).
#'      \item \emph{Lower values (zeta):} The trend is assumed to be more constant over time (more linear evolution).
#'   }
#' }
#'
#' \strong{Institute Bias (\eqn{\delta})}
#' \itemize{
#'   \item \code{delta_priori}: Mean expected bias for institutes. Default is 0, except in "Vi\u00e9s Emp\u00edrico" where it is anchored on past performance.
#'   \item \code{sd_delta_priori}: Scale of the bias prior.
#'   \itemize{
#'     \item \emph{Default values}: With \code{sd_delta_priori = 0.02}, the model assumes that 95\% of institutes have a bias within \eqn{\pm 4} percentage points (\eqn{1.96 \times 0.02 \approx 0.04}).
#'     \item \emph{Higher values:} Allow for larger, more variable biases across institutes.
#'     \item \emph{Lower values:} Constrain institutes to have similar biases (shrinkage toward the anchor).
#'   }
#' }
#'
#' \strong{Non-Sampling Error (\eqn{\tau})}
#' \itemize{
#'   \item \code{tau_priori}: Mean expected magnitude of errors not explained by sampling or house effects. In weighted models, this is replaced by the empirical RMSE from past elections.
#'   \item \code{sd_tau_priori}: Prior uncertainty for non-sampling error.
#'   \itemize{
#'     \item \emph{Default values}: \code{sd_tau_priori = 0.02} implies an extra \eqn{\pm 4} percentage points of "noise" or uncertainty in each poll, effectively increasing the margin of error.
#'     \item \emph{Higher values:} The model treats polls as less precise, widening the credible intervals of the latent state.
#'     \item \emph{Lower values:} The model trusts polling precision more, leading to tighter intervals and potentially more sensitivity to outliers.
#'   }
#' }
#' @param nome Name of the model. Options: "Vi\u00e9s Relativo com Pesos", "Vi\u00e9s Relativo sem Pesos", "Vi\u00e9s Emp\u00edrico", "Retrospectivo" and "Naive".
#' @param ... Named arguments to override default hyperparameters (e.g., `sd_tau_priori = 0.05`).
#' @return A list of model parameters.
#' @export
#' @importFrom utils modifyList
#' @importFrom cli cli_abort
#' @examples
#' # Get default parameters for the "Naive" model
#' naive_params <- configurar_prioris(nome = "Naive")
#'
#' # Get parameters for "Naive" and override a default value
#' custom_params <- configurar_prioris(nome = "Naive", sd_mu_priori = 0.2)
configurar_prioris <- function(nome = "Vi\u00e9s Relativo com Pesos", ...) {

  # Padronizar nome do modelo
  nome_convertido <- limpar_texto_minusculo(nome)

  valores <- list(vies_relativo_sem_pesos = list(delta_priori = 0, sd_delta_priori = 0.02,
                                                 # gamma_priori = 0, sd_gamma_priori = 0.02,
                                                 tau_priori = 0.02, sd_tau_priori = 0.02,
                                                 mu_priori = 0.5, sd_mu_priori = 0.5,
                                                 omega_eta_priori = 0.002, sd_omega_eta_priori = 0.0001,
                                                 nu_priori = 0, sd_nu_priori = 0.001,
                                                 omega_zeta_priori = 0, sd_omega_zeta_priori = 0.00001),
                  vies_relativo_com_pesos = list(delta_priori = 0, sd_delta_priori = 0.02,
                                                 # gamma_priori = 0, sd_gamma_priori = 0.02,
                                                 sd_tau_priori = 0.02,
                                                 mu_priori = 0.5, sd_mu_priori = 0.5,
                                                 omega_eta_priori = 0.002, sd_omega_eta_priori = 0.0001,
                                                 nu_priori = 0, sd_nu_priori = 0.001,
                                                 omega_zeta_priori = 0, sd_omega_zeta_priori = 0.00001),
                  vies_empirico = list(sd_delta_priori = 0.02,
                                       # gamma_priori = 0, sd_gamma_priori = 0.02,
                                       sd_tau_priori = 0.02,
                                       mu_priori = 0.5, sd_mu_priori = 0.5,
                                       omega_eta_priori = 0.002, sd_omega_eta_priori = 0.0001,
                                       nu_priori = 0, sd_nu_priori = 0.001,
                                       omega_zeta_priori = 0, sd_omega_zeta_priori = 0.00001),
                  retrospectivo = list(delta_priori = 0, sd_delta_priori = 0.02,
                                       # gamma_priori = 0, sd_gamma_priori = 0.02,
                                       tau_priori = 0.02, sd_tau_priori = 0.02,
                                       mu_priori = 0.5, sd_mu_priori = 0.5,
                                       omega_eta_priori = 0.002, sd_omega_eta_priori = 0.0001,
                                       nu_priori = 0, sd_nu_priori = 0.001,
                                       omega_zeta_priori = 0, sd_omega_zeta_priori = 0.00001),
                  naive = list(mu_priori = 0.5, sd_mu_priori = 0.5,
                               omega_eta_priori = 0.002, sd_omega_eta_priori = 0.0001))

  if (!nome_convertido %in% names(valores)) {

    cli_abort("Modelo n\u00e3o encontrado: {.val {nome}}")

  }

  # Configuração padrão
  config <- valores[[nome_convertido]]

  # Substituir com valores do usuário
  substituir <- list(...)

  if (length(substituir) > 0) {

    config <- modifyList(config, substituir)

  }

  return(config)

}