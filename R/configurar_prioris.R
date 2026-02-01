#' @encoding UTF-8
#' @title Configuration for Statistical Models
#' @description Defines hyperparameters for the specific Bayesian models.
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
                                                 eta_priori = 0.002, sd_eta_priori = 0.0001,
                                                 nu_priori = 0, sd_nu_priori = 0.001,
                                                 zeta_priori = 0, sd_zeta_priori = 0.00001),
                  vies_relativo_com_pesos = list(delta_priori = 0, sd_delta_priori = 0.02,
                                                 # gamma_priori = 0, sd_gamma_priori = 0.02,
                                                 sd_tau_priori = 0.02,
                                                 mu_priori = 0.5, sd_mu_priori = 0.5,
                                                 eta_priori = 0.002, sd_eta_priori = 0.0001,
                                                 nu_priori = 0, sd_nu_priori = 0.001,
                                                 zeta_priori = 0, sd_zeta_priori = 0.00001),
                  vies_empirico = list(sd_delta_priori = 0.02,
                                       # gamma_priori = 0, sd_gamma_priori = 0.02,
                                       sd_tau_priori = 0.02,
                                       mu_priori = 0.5, sd_mu_priori = 0.5,
                                       eta_priori = 0.002, sd_eta_priori = 0.0001,
                                       nu_priori = 0, sd_nu_priori = 0.001,
                                       zeta_priori = 0, sd_zeta_priori = 0.00001),
                  retrospectivo = list(delta_priori = 0, sd_delta_priori = 0.02,
                                       # gamma_priori = 0, sd_gamma_priori = 0.02,
                                       tau_priori = 0.02, sd_tau_priori = 0.02,
                                       mu_priori = 0.5, sd_mu_priori = 0.5,
                                       eta_priori = 0.002, sd_eta_priori = 0.0001,
                                       nu_priori = 0, sd_nu_priori = 0.001,
                                       zeta_priori = 0, sd_zeta_priori = 0.00001),
                  naive = list(mu_priori = 0.5, sd_mu_priori = 0.5,
                               eta_priori = 0.002, sd_eta_priori = 0.0001))

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