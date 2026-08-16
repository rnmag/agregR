# Agregador Eleições 2026

**Última atualização: 16/08/2026**

## Introdução

À medida que as eleições presidenciais se aproximam, aumenta o número de
pesquisas eleitorais divulgadas por diferentes institutos com resultados
divergentes. `agregR` emprega uma
[metodologia](https://rnmag.github.io/agregR/index.html#methodology)
rigorosa para tratar esses números e estimar o nível de apoio subjacente
a cada candidato. O pacote modela:

- Vieses dos institutos em relação ao consenso
- Vieses de acordo com o alinhamento político dos candidatos
- Desempenhos no 1º e 2º turnos de 2022
- Margens de erro incoerentes com o tamanho da amostra
- Erros não-amostrais (para além da margem de erro)

Esta página apresenta os resultados para os cenários eleitorais mais
prováveis, mas `agregR` é um pacote de [código
aberto](https://github.com/rnmag/agregR) para o R que pode ser
[instalado](https://rnmag.github.io/agregR/index.html#installation)
gratuitamente. Fique à vontade para explorar os 10+ cenários disponíveis
no banco de dados.

## Visão Geral dos Modelos

`agregR` oferece 3[^1] modelos que se diferenciam pela importância
atribuída ao desempenho dos institutos na última eleição (a documentação
do pacote oferece uma [exposição técnica
detalhada](https://rnmag.github.io/agregR/index.html#methodology)):

- **Viés Relativo com Pesos**: o modelo mais equilibrado. Atribui pesos
  aos institutos de acordo com o desempenho na última eleição, mas não
  dá nenhuma compensação aos candidatos.
- **Viés Relativo sem Pesos**: o modelo tábula rasa. Não usa qualquer
  informação sobre o desempenho dos institutos na última eleição,
  calculando vieses puramente com base nas pesquisas deste ciclo
  eleitoral.
- **Viés Empírico**: o modelo mais vinculado ao passado. Além de
  atribuir pesos aos institutos de acordo com o desempenho na última
  eleição, também compensa (ou desconta) os candidatos com alinhamentos
  políticos mais prejudicados (ou beneficiados) por cada instituto.

Embora os modelos com dados históricos pareçam preferíveis, é importante
lembrar que desempenhos passados podem não se repetir, e institutos
podem adaptar suas metodologias entre uma eleição e outra. Os modelos se
complementam.

## Viés Relativo com Pesos

![](agregador_files/figure-html/grafico-vies-relativo-com-pesos-1t-1.png)

![](agregador_files/figure-html/grafico-vies-relativo-com-pesos-2t-1.png)

![](agregador_files/figure-html/institutos-vies-relativo-com-pesos-1.png)

## Viés Relativo sem Pesos

![](agregador_files/figure-html/grafico-vies-relativo-sem-pesos-1t-1.png)

![](agregador_files/figure-html/grafico-vies-relativo-sem-pesos-2t-1.png)

![](agregador_files/figure-html/institutos-vies-relativo-sem-pesos-1.png)

## Viés Empírico

![](agregador_files/figure-html/grafico-vies-empirico-1t-1.png)

![](agregador_files/figure-html/grafico-vies-empirico-2t-1.png)

![](agregador_files/figure-html/institutos-vies-empirico-1.png)

[^1]: O pacote contém mais 2 modelos com menor utilidade durante a
    campanha: o modelo **Retrospectivo** usa o resultado real da eleição
    para calcular retrospectivamente vieses e trajetórias para cada
    candidato, enquanto o modelo **Naive** é oferecido como uma
    curiosidade, pois não modela nenhum viés e é equivalente a tirar uma
    média simples das pesquisas.
