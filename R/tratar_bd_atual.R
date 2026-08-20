#' @noRd
#' @importFrom readr read_csv2 locale
#' @importFrom lubridate dmy
#' @importFrom dplyr mutate case_when filter select arrange
tratar_bd_atual <- function(bd,
                            filtro_inicio,
                            filtro_fim,
                            filtro_cargo,
                            filtro_ambito,
                            filtro_cenario) {

  pesquisas <- ler_csv(bd) |>
    mutate(final_coleta = dmy(final_coleta),
           pesquisa_id = paste(instituto, "-", final_coleta),
           percentual_pesquisa = as.numeric(percentual_pesquisa) / 100,
           # Tamanho da amostra implícito a partir da margem de erro
           n_implicito = round(1.96^2 * 0.5 * 0.5 / ((margem_pesquisa / 100)^2)),
           # Usar n implicito em pesquisas com n declarado muito alto
           n_efetivo = case_when(qtd_entrevistas > n_implicito ~ n_implicito,
                                 TRUE ~ qtd_entrevistas),
           ep = round(sqrt(percentual_pesquisa * (1 - percentual_pesquisa) / n_efetivo), 4),
           # Preencher metodologia quando ausente
           metodologia = case_when(!is.na(metodologia) ~ metodologia,
                                   instituto %in% c("FSB",
                                                    "Ponteio",
                                                    "Ideia Big Data",
                                                    "PoderData",
                                                    "Ipespe",
                                                    "Futura",
                                                    "Ranking",
                                                    "Gerp") ~ "Telef\u00f4nica",
                                   instituto %in% c("Sensus",
                                                    "MDA",
                                                    "Quaest",
                                                    "Ipec",
                                                    "Paran\u00e1 Pesquisas",
                                                    "Vox Populi",
                                                    "Datafolha",
                                                    "Datatempo") ~ "Presencial",
                                   instituto %in% c("Atlas") ~ "Online",
                                   TRUE ~ "Desconhecida")) |>
    filter(final_coleta >= filtro_inicio & final_coleta <= filtro_fim,
           cargo == filtro_cargo,
           ambito == filtro_ambito,
           cenario == filtro_cenario,
           percentual_pesquisa > 0) |>
    select(pesquisa_id,
           final_coleta,
           instituto,
           turno,
           candidatura,
           percentual_pesquisa,
           margem_pesquisa,
           qtd_entrevistas,
           n_efetivo,
           ep,
           metodologia,
           cargo,
           ambito,
           cenario) |>
    arrange(final_coleta, turno)

  return(pesquisas)

}