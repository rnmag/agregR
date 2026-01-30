#' @encoding UTF-8
#' @title Run Poll Aggregator
#' @description Main function to run the state-space model for poll aggregation.
#' @section Model Details:
#' The aggregator supports five types of Bayesian state-space models, each with specific assumptions about institute bias and non-sampling errors:
#'
#' \strong{1. Vi\u00e9s Relativo com Pesos (Default)}
#' \itemize{
#'   \item \strong{Assumption:} Institute biases are relative to the average of all institutes (latent "truth" is anchored to the consensus).
#'   \item \strong{Bias (\eqn{\delta}):} Calculated relative to the mean bias of all institutes.
#'   \item \strong{Weights:} Uses past election performance to weight the non-sampling error (\eqn{\tau}). Institutes with larger historical errors have less influence on the current estimate.
#'   \item \strong{Use case:} Best for general forecasting when historical data is available.
#' }
#'
#' \strong{2. Vi\u00e9s Relativo sem Pesos}
#' \itemize{
#'   \item \strong{Assumption:} Same as above, but treats all institutes as having equal potential quality a priori.
#'   \item \strong{Bias (\eqn{\delta}):} Calculated relative to the mean bias.
#'   \item \strong{Weights:} None. All institutes share the same prior for non-sampling error (\eqn{\tau}).
#'   \item \strong{Use case:} When historical data is unreliable or when a "fresh start" assumption is desired.
#' }
#'
#' \strong{3. Vi\u00e9s Emp\u00edrico}
#' \itemize{
#'   \item \strong{Assumption:} Institute biases are anchored to their specific historical performance.
#'   \item \strong{Bias (\eqn{\delta}):} Prior means are set to the bias observed in the previous election (directional error).
#'   \item \strong{Weights:} Uses past performance for non-sampling error (\eqn{\tau}), similar to the "Com Pesos" model.
#'   \item \strong{Use case:} When institutes are expected to repeat their specific past directional errors (e.g., consistently underestimating a specific wing).
#' }
#'
#' \strong{4. Retrospectivo}
#' \itemize{
#'   \item \strong{Assumption:} The true election result is known and used as the final anchor for the state-space model.
#'   \item \strong{Method:} Runs the model "backwards" or constrained by the final result to estimate the true path of public opinion.
#'   \item \strong{Use case:} Post-election analysis to diagnose institute performance and calculate accurate biases for future calibration.
#' }
#'
#' \strong{5. Naive}
#' \itemize{
#'   \item \strong{Assumption:} Polls have no bias and no non-sampling error.
#'   \item \strong{Method:} A random walk model where the only source of uncertainty is the sampling error (\eqn{\sigma}).
#'   \item \strong{Use case:} Baseline comparison. Assumes "polls are perfect" within their margin of error.
#' }
#'
#' @section Priors Details:
#' The `config_prioris` argument allows customization of the model's hyperparameters. Default values can be found at `configurar_prioris()`.
#'
#' These priors control the strength of assumptions about institute bias, state evolution, and non-sampling errors.
#'
#' \strong{State Model - Level (\eqn{\mu})}
#' \itemize{
#'   \item \code{mu_priori}: The prior mean for the initial latent vote share. Default is 0.5 (50\%).
#'   \item \code{sd_mu_priori}: The standard deviation for the initial latent vote.
#'   \item \code{eta_priori}: The expected volatility (standard deviation) of the daily change in the latent vote share (\eqn{\eta}).
#'   \item \code{sd_eta_priori}: The uncertainty around the level volatility.
#'   \itemize{
#'      \item \emph{Higher values (eta):} The latent vote (\eqn{\mu}) can jump more from one day to the next. The model adapts more quickly to new polls but becomes more "jittery".
#'      \item \emph{Lower values (eta):} The model assumes the public opinion level is more stable over time, resulting in smoother curves.
#'   }
#' }
#'
#' \strong{State Model - Trend (\eqn{\nu})}
#' \itemize{
#'   \item \code{nu_priori}: The prior mean for the initial trend (daily growth rate). Default is 0.
#'   \item \code{sd_nu_priori}: The uncertainty around the initial trend.
#'   \item \code{zeta_priori}: The expected volatility of the trend itself (\eqn{\zeta}). Controls how much the growth rate can change daily.
#'   \item \code{sd_zeta_priori}: The uncertainty around the trend volatility.
#'   \itemize{
#'      \item \emph{Higher values (zeta):} The trend (\eqn{\nu}) can change direction or magnitude rapidly (accelerations/decelerations).
#'      \item \emph{Lower values (zeta):} The trend is assumed to be more constant over time (more linear evolution).
#'   }
#' }
#'
#' \strong{Institute Bias (\eqn{\delta})}
#' \itemize{
#'   \item \code{delta_priori}: The mean expected bias for institutes. Defaults to 0, except on "Vi\u00e9s Emp\u00edrico" (where it is anchored on past election results).
#'   \item \code{sd_delta_priori}: The standard deviation of the bias prior. Controls how much institutes are allowed to deviate from the mean bias.
#'   \itemize{
#'     \item \emph{Higher values:} Allow for larger, more variable biases across institutes.
#'     \item \emph{Lower values:} constrain institutes to have similar biases (shrinkage).
#'   }
#' }
#'
#' \strong{Non-Sampling Error (\eqn{\tau})}
#' \itemize{
#'   \item \code{tau_priori}: The expected magnitude of non-sampling errors (errors not explained by sample size or bias). Default depends on whether the model is weighted.
#'   \item \code{sd_tau_priori}: The uncertainty around the non-sampling error.
#'   \itemize{
#'     \item \emph{Higher values:} The model treats polls as less precise, widening the credible intervals of the final estimate.
#'   }
#' }
#'
#' @param bd Dataframe or path to a CSV file containing poll data.
#' @param data_inicio Start date for the analysis.
#' @param data_fim End date for the analysis.
#' @param cargo The office/position being contested (e.g., "Presidente"). Current data only contains presidential polls, but the package supports expansion for other offices.
#' @param ambito The geographical scope (e.g., "Brasil"). Current data only contains national polls, but the package supports expansion for state races.
#' @param turno The election round (1 or 2).
#' @param cenario The specific electoral scenario. Mandatory for second round.
#' @param modelo The name of the model to run. Options: "Vi\u00e9s Relativo com Pesos" (default), "Vi\u00e9s Relativo sem Pesos", "Vi\u00e9s Emp\u00edrico", "Retrospectivo" and "Naive".
#' @param config_agregador A list of configuration parameters created by `configurar_agregador()`. If NULL, uses defaults.
#' @param config_prioris A list of model hyperparameters created by `configurar_prioris()`. If NULL, uses defaults based on `modelo`.
#' @param salvar Logical. If TRUE, saves the results to disk.
#' @param dir_saida Output directory for saved files if `salvar = TRUE`.
#' @return A list containing the model name, estimated votes, institute bias, and the raw model object.
#' @export
#' @examples
#' # Running the default model for a second round scenario
#' if (instantiate::stan_cmdstan_exists()) {
#'   resultados <- rodar_agregador(
#'     turno = 2,
#'     cenario = "Lula vs Bolsonaro",
#'     salvar = FALSE
#'   )
#' }
#'
#' # Tuning Stan, changing the model and altering specific priors
#' if (instantiate::stan_cmdstan_exists()) {
#'   resultados_custom <- rodar_agregador(
#'     turno = 2,
#'     cenario = "Lula vs Bolsonaro",
#'     modelo = "Vi\u00e9s Relativo sem Pesos",
#'     config_agregador = list(stan_chains = 1, stan_warmup = 200),
#'     config_prioris = list(tau_priori = 0.02),
#'     salvar = FALSE
#'   )
#' }
#' @importFrom cli cli_abort cli_h1 cli_alert_success cli_alert_info
#' @importFrom dplyr filter group_by mutate select n_distinct ungroup
#' @importFrom tidyr nest unnest
#' @importFrom purrr map map2
#' @importFrom readr write_excel_csv2
#' @importFrom instantiate stan_package_model
#' @importFrom utils modifyList
rodar_agregador <- function(bd = NULL,
                            data_inicio = "01/01/2025",
                            data_fim = Sys.Date(),
                            cargo = "Presidente",
                            ambito = "Brasil",
                            cenario = NULL,
                            turno,
                            modelo = "Vi\u00e9s Relativo com Pesos",
                            config_agregador = NULL,
                            config_prioris = NULL,
                            salvar = FALSE,
                            dir_saida = ".") {

  # 1. Configuração do modelo e validação -------------------------------------

  # Verificar se cmdstanr está instalado
  if (!requireNamespace("cmdstanr", quietly = TRUE)) {

    cli_abort(c("O pacote {.pkg cmdstanr} \u00e9 necess\u00e1rio para rodar esta fun\u00e7\u00e3o.",
                "i" = "Instale-o com {.code install.packages('cmdstanr', repos = 'https://mc-stan.org/r-packages/')}.",
                "i" = "Ou consulte {.url https://mc-stan.org/cmdstanr/}."))

  }

  # Configurar agregador (geral)
  # Permite passar:
  # 1. NULL (defaults)
  # 2. Objeto completo (criado com configurar_agregador)
  # 3. Lista de argumentos (que será passada para configurar_agregador)
  if (is.null(config_agregador)) {

    config_agregador <- configurar_agregador()

  } else if (is.list(config_agregador) && !"stan" %in% names(config_agregador)) {

    # Se for lista sem a estrutura final ('stan'), processar como argumentos
    config_agregador <- do.call(configurar_agregador, config_agregador)

  }

  # Carregar dados se bd for NULL
  if (is.null(bd)) {

    bd <- config_agregador$pesquisas

  }

  # Aceitar datas em diferentes formatos
  data_inicio <- data_robusta(data_inicio)
  data_fim <- data_robusta(data_fim)

  # Se turno = 1, definir cenário automaticamente
  if (turno == 1) {

    cenario <- "Primeiro turno"

  } else if (turno == 2) {

    # Validação do cenário para o 2º turno
    cenarios_disp <- cenarios_disponiveis(2, dados = bd)

    if (is.null(cenario) || cenario == "") {

      cli_abort(c("O argumento 'cenario' \u00e9 obrigat\u00f3rio para o 2\u00ba turno.",
                  "i" = "Cen\u00e1rios dispon\u00edveis: {.val {cenarios_disp}}"))

    }

    if (!(cenario %in% cenarios_disp)) {

      cli_abort(c("Cen\u00e1rio inv\u00e1lido para o 2\u00ba turno: {.val {cenario}}.",
                  "i" = "Cen\u00e1rios dispon\u00edveis: {.val {cenarios_disp}}"))

    }

  }

  # Validar nome do modelo
  modelos_validos <- c("Vi\u00e9s Relativo sem Pesos",
                       "Vi\u00e9s Relativo com Pesos",
                       "Vi\u00e9s Emp\u00edrico",
                       "Retrospectivo",
                       "Naive")

  if (!(modelo %in% modelos_validos)) {

    cli_abort(c("Modelo {.val {modelo}} inv\u00e1lido.",
                "i" = "Escolha entre os modelos: {.val {modelos_validos}}"))

  }

  # Configurar prioris personalizadas
  # Lógica paralela à do config_agregador:
  # 1. NULL (padrão do modelo)
  # 2. Lista de argumentos para sobrescrever o padrão
  if (!is.null(config_prioris)) {

    config_prioris <- modifyList(configurar_prioris(modelo), config_prioris)

  } else {

    config_prioris <- configurar_prioris(modelo)

  }

  # Carregar as pesquisas atuais
  pesquisas <- tratar_bd_atual(bd,
                               filtro_inicio = data_inicio,
                               filtro_fim = data_fim,
                               filtro_cargo = cargo,
                               filtro_ambito = ambito,
                               filtro_cenario = cenario)

  # Configurações que dependem do turno
  if (turno == 1) {

    candidaturas <- config_agregador$candidaturas_1t
    arq_bases_tratadas <- "Votos_Estimados_1t.csv"
    arq_modelos_brutos <- "StanMCMC_1t.rds"

    cli_h1("Simula\u00e7\u00f5es do Primeiro Turno")

  } else if (turno == 2) {

    candidaturas <- config_agregador$candidaturas_2t
    sufixo_cenario <- colar_ascii(intersect(pesquisas$candidatura, candidaturas))

    arq_bases_tratadas <- paste0("Votos_Estimados_2t_", sufixo_cenario, ".csv")
    arq_modelos_brutos <- paste0("StanMCMC_2t_", sufixo_cenario, ".rds")

    cli_h1("Simula\u00e7\u00f5es do Segundo Turno")

  } else {

    cli_abort("Obrigat\u00f3rio definir o turno. Use turno = 1 ou turno = 2.")

  }

  # 2. Iniciar simulações -----------------------------------------------------

  cli_alert_success("Base carregada e filtrada com sucesso!")
  cli_alert_info("Iniciando {.val {config_agregador$stan$chains}} cadeia{?s} de {.val {config_agregador$stan$warmup + config_agregador$stan$sampling}} itera\u00e7\u00f5es para cada candidatura.")
  cli_alert_info("H\u00e1 {.val {n_distinct(pesquisas$pesquisa_id)}} pesquisa{?s} na base entre {format(data_inicio, '%d/%m/%y')} e {format(data_fim, '%d/%m/%y')}.")
  cli_alert_info("Se esses n\u00fameros parecerem incorretos, revise os argumentos e configura\u00e7\u00f5es da fun\u00e7\u00e3o.")

  # Nome do arquivo Stan
  nome_stan <- limpar_texto_minusculo(modelo)

  # Compilar o modelo
  stan_compilado <- instantiate::stan_package_model(name = nome_stan,
                                                    package = "agregR")

  # Iterar ajustar_modelo() para cada candidatura
  modelo_ajustado <- pesquisas |>
    filter(turno == !!turno & candidatura %in% candidaturas) |>
    group_by(candidatura) |>
    nest() |>
    mutate(modelos = map2(data, candidatura,
                          ajustar_modelo,
                          turno = !!turno,
                          data_inicio = data_inicio,
                          data_fim = data_fim,
                          modelo = modelo,
                          stan_compilado = stan_compilado,
                          config_agregador = config_agregador,
                          config_prioris = config_prioris),
           votos_estimados = map(modelos, "votos_estimados"),
           vies_institutos = map(modelos, "vies_institutos"),
           # vies_metodologia = map(modelos, "vies_metodologia"),
           modelo_bruto = map(modelos, "modelo_bruto")) |>
    select(candidatura,
           votos_estimados,
           vies_institutos,
           # vies_metodologia,
           modelo_bruto) |>
    ungroup()

  # 3. Extrair resultados -----------------------------------------------------

  # Resultado 1: base de dados com dados de pesquisas + estimativas diárias
  votos_estimados <- modelo_ajustado |>
    select(candidatura, votos_estimados) |>
    unnest(votos_estimados)

  # Resultado 2: viés dos institutos por candidatura
  vies_institutos <- modelo_ajustado |>
    select(candidatura, vies_institutos) |>
    unnest(vies_institutos)

  # Resultado 3: viés das metodologias por candidatura
  # vies_metodologia <- modelo_ajustado |>
  #   select(candidatura, vies_metodologia) |>
  #   unnest(vies_metodologia)

  # Resultado 4: output completo para acesso a distribuições, diagnósticos, etc.
  # Se salvar = FALSE, manter objeto na classe R6 (mais rápido, mas temporário)
  if (salvar) {

    cli_alert_info("Armazenando amostras posteriores...")
    modelo_bruto <- setNames(map(modelo_ajustado$modelo_bruto,
                                 ~ .x$draws(format = "df")),
                             modelo_ajustado$candidatura)

  } else {

    modelo_bruto <- setNames(modelo_ajustado$modelo_bruto,
                             modelo_ajustado$candidatura)

  }

  # Juntar tudo
  resultados <- list(nome_modelo = modelo,
                     votos_estimados = votos_estimados,
                     vies_institutos = vies_institutos,
                     # vies_metodologia = vies_metodologia,
                     modelo_bruto = modelo_bruto)

  # 4. Salvar resultados em disco ---------------------------------------------

  if (salvar) {

    # Modelos brutos, cada candidatura em um arquivo separado
    # walk2(modelo_ajustado$candidatura, modelo_ajustado$modelo_bruto,
    #       function(candidatura, modelo_bruto) {
    #         modelo_bruto$save_object(file = iconv(here(paste0(config_agregador$saida_modelos_brutos,
    #                                                           turno,
    #                                                           "t_CmdStanMCMC_",
    #                                                           candidatura,
    #                                                           ".rds")),
    #                                               to = "ASCII//TRANSLIT"))
    #       })
    # cli_alert_success("Resultados brutos do modelo disponíveis em {.path {here(config_agregador$saida_modelos_brutos)}}")

    # Resultados completos em formato RDS
    saida_rds <- gerar_saida(file.path(dir_saida, config_agregador$saida_modelos_brutos), modelo, arq_modelos_brutos)
    saveRDS(resultados, file = saida_rds)

    # Votos estimados + pesquisas em formato acessível
    saida_csv <- gerar_saida(file.path(dir_saida, config_agregador$saida_bases_tratadas), modelo, arq_bases_tratadas)
    write_excel_csv2(votos_estimados, file = saida_csv)

    cli_alert_success("Base tratada e modelos brutos dispon\u00edveis em {.file {file.path(dir_saida, 'resultados_agregador')}}")

  }

  return(resultados)

}