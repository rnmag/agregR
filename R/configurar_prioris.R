#' @encoding UTF-8
#' @title Configuration for Statistical Models
#' @description Defines hyperparameters for the specific Bayesian models.
#' @section Priors Details:
#' These hyperparameters control the strength of assumptions regarding latent
#' state evolution, institute bias, and non-sampling errors.
#'
#' Variable names refer to the model notation described in \url{https://rnmag.github.io/agregR/index.html#conceptual-framework}
#'
#' Recommended reading: \url{https://github.com/stan-dev/stan/wiki/prior-choice-recommendations}
#'
#' \strong{State Model - Level (\eqn{\mu})}
#' \itemize{
#'   \item \code{mu_priori}: Prior mean for the latent vote share at \eqn{t=1}. Can be a vector for multivariate models (ALR space).
#'   \item \code{sd_mu_priori}: Prior uncertainty for the initial latent vote.
#'   \itemize{
#'      \item \emph{Default values}: \eqn{\mu} starts with a flat prior, allowing data to quickly dominate inference.
#'   }
#'   \item \code{omega_eta_priori}: Prior mean for the level volatility (\eqn{\omega_\eta}).
#'   \item \code{sd_omega_eta_priori}: Prior uncertainty for the level volatility.
#'   \itemize{
#'      \item \emph{Default values}: With \code{omega_eta_priori = 0.002} and \code{sd_omega_eta_priori = 0.0001}, the model assumes a **baseline drift** of approx. \eqn{\pm 2} percentage points over a month.
#'   }
#' }
#'
#' \strong{State Model - Trend (\eqn{\nu})}
#' \itemize{
#'   \item \code{nu_priori}: Prior mean for the initial trend (daily growth rate).
#'   \item \code{sd_nu_priori}: Prior uncertainty for the initial trend.
#'   \item \code{omega_zeta_priori}: Prior mean for the trend volatility (\eqn{\omega_\zeta}).
#'   \item \code{sd_omega_zeta_priori}: Prior uncertainty for the trend volatility.
#' }
#' 
#' \strong{Correlation (\eqn{\Sigma})}
#' \itemize{
#'   \item \code{lkj_corr_priori}: Shape parameter for the LKJ prior on the correlation matrix.
#'   \itemize{
#'      \item \emph{Default values}: 50. Higher values favor independence (diagonal matrix), lower values allow for stronger correlations between candidates.
#'   }
#' }
#'
#' \strong{Institute Bias (\eqn{\delta})}
#' \itemize{
#'   \item \code{delta_priori}: Mean expected bias for institutes.
#'   \item \code{sd_delta_priori}: Scale of the bias prior.
#' }
#'
#' \strong{Non-Sampling Error (\eqn{\tau})}
#' \itemize{
#'   \item \code{tau_priori}: Mean expected magnitude of errors not explained by sampling or house effects.
#'   \item \code{sd_tau_priori}: Prior uncertainty for non-sampling error.
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
                                                 mu_priori = 0.0, sd_mu_priori = 1.0, # ALR space needs wider priors
                                                 omega_eta_priori = 0.002, sd_omega_eta_priori = 0.0001,
                                                 nu_priori = 0, sd_nu_priori = 0.001,
                                                 omega_zeta_priori = 0, sd_omega_zeta_priori = 0.00001,
                                                 lkj_corr_priori = 50),
                  vies_relativo_com_pesos = list(delta_priori = 0, sd_delta_priori = 0.02,
                                                 # gamma_priori = 0, sd_gamma_priori = 0.02,
                                                 sd_tau_priori = 0.02,
                                                 mu_priori = 0.0, sd_mu_priori = 1.0, # ALR space needs wider priors
                                                 omega_eta_priori = 0.002, sd_omega_eta_priori = 0.0001,
                                                 nu_priori = 0, sd_nu_priori = 0.001,
                                                 omega_zeta_priori = 0, sd_omega_zeta_priori = 0.00001,
                                                 lkj_corr_priori = 50),
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