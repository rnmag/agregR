#' @noRd
#' @importFrom readr read_csv
#' @importFrom dplyr filter group_by ungroup left_join mutate select arrange join_by recode
#' @importFrom lubridate ymd days
tratar_bd_historico <- function(bd,
                                primeiro_turno,
                                segundo_turno,
                                config_agregador) {

  # Resultados da última eleição
  caminho <- if (is.null(config_agregador$resultado_eleicao_passada)) "resultado_eleicao_passada.csv" else config_agregador$resultado_eleicao_passada
  resultado_eleicao_passada <- ler_csv(caminho)

  # Selecionar pesquisas do banco histórico e calcular erros
  # Se bd for NULL (padrão), usar dados do pacote
  if (is.null(bd)) {

    bd_historico <- historico_pesquisas_poder360

  } else if (is.character(bd)) {

    # Fallback para desenvolvimento. Na prática, dados sempre vão estar no pacote
    if (grepl("\\.rds$", bd, ignore.case = TRUE)) {

      bd_historico <- readRDS(bd)

    } else {

      bd_historico <- ler_csv(bd)

    }

  } else {

    bd_historico <- bd

  }

  bd_historico <- bd_historico |>
    filter((turno == 1 &
              data >= ymd(primeiro_turno) - days(5) &
              data <= ymd(primeiro_turno)) |
             (turno == 2 &
                data >= ymd(segundo_turno) - days(5) &
                data <= ymd(segundo_turno)),
           # is.na(sigla_uf) para excluir pesquisas estaduais para presidente
           cargo == "presidente" & is.na(sigla_uf),
           # Selecionar candidaturas representativas da direita/esquerda
           nome_candidato %in% c(config_agregador$direita_eleicao_passada, config_agregador$esquerda_eleicao_passada)) |>
    # Última pesquisa de cada instituto antes do 1 e 2 turnos
    group_by(instituto, turno, nome_candidato) |>
    filter(data == max(data)) |>
    ungroup() |>
    # Incorporar resultados da última eleição
    left_join(resultado_eleicao_passada, by = join_by(nome_candidato == nome, turno)) |>
    mutate(instituto = recode(instituto, "AtlasIntel/Internet" = "Atlas"),
           percentual_pesquisa = as.numeric(percentual) / 100,
           # Tamanho da amostra implícito a partir da margem de erro
           n_implicito = round(1.96^2 * 0.5 * 0.5 / ((margem_mais / 100)^2)),
           # Usar n implicito em pesquisas com n declarado muito alto
           n_efetivo = case_when(quantidade_entrevistas > n_implicito ~ n_implicito,
                                 TRUE ~ quantidade_entrevistas),
           ep = round(sqrt(percentual_pesquisa * (1 - percentual_pesquisa) / n_efetivo), 4),
           resultado = round(votos_recebidos / total_votos, 4),
           erro_total = percentual_pesquisa - resultado,
           # Se o erro total é maior que o erro padrão, somar variâncias. Supõe
           # que erro amostral e erro não-amostral não são correlacionados, que
           # é o cálculo mais conservador para a incerteza
           erro_nao_amostral = if_else(abs(erro_total) > ep, sqrt(erro_total^2 - ep^2), 0)) |>
    select(data,
           turno,
           instituto,
           nome_candidato,
           percentual_pesquisa,
           ep,
           resultado,
           erro_total,
           erro_nao_amostral,
           quantidade_entrevistas,
           n_efetivo,
           margem_mais) |>
    arrange(data, instituto, turno)

  return(bd_historico)

}