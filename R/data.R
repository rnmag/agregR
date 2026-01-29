#' Historical Polls by Poder360
#'
#' A dataset containing historical electoral polls compiled by Poder360.
#' This dataset is used to calculate empirical priors for the models.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{ano}{Election year}
#'   \item{cargo}{Office being contested}
#'   \item{condicao}{Condition (e.g., stimulated)}
#'   \item{contratante}{Entity that paid for the poll}
#'   \item{data}{Date of the poll}
#'   \item{data_referencia}{Reference date for the poll}
#'   \item{descricao_cenario}{Description of the electoral scenario}
#'   \item{id_candidato_poder360}{Unique ID for the candidate}
#'   \item{id_cenario}{Unique ID for the scenario}
#'   \item{id_pesquisa}{Unique ID for the poll}
#'   \item{instituto}{Name of the polling institute}
#'   \item{margem_mais}{Upper margin of error}
#'   \item{margem_menos}{Lower margin of error}
#'   \item{nome_candidato}{Candidate name}
#'   \item{nome_municipio}{City name (if applicable)}
#'   \item{numero_registro}{Official registration number}
#'   \item{orgao_registro}{Entity where the poll was registered}
#'   \item{percentual}{Voting intention percentage}
#'   \item{quantidade_entrevistas}{Sample size}
#'   \item{sigla_partido}{Political party abbreviation}
#'   \item{sigla_uf}{State abbreviation}
#'   \item{tipo}{Poll type}
#'   \item{tipo_voto}{Vote type (Total, Valid, etc.)}
#'   \item{turno}{Election round (1 or 2)}
#' }
#' @source Poder360
"historico_pesquisas_poder360"