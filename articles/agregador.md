# Agregador Eleições 2026

**Última pesquisa**: Nexus com campo entre 04/09 e 07/09

## Introdução

Como interpretar pesquisas eleitorais com resultados divergentes? O
`agregR` é um pacote para o R que filtra a enxurrada de dados divulgados
no período eleitoral e estima o nível subjacente de apoio para cada
candidato.

Trata-se de um conjunto de modelos estatísticos que consideram:

- Resultados dos institutos na última eleição
- Desvios dos institutos em relação ao consenso
- Vieses de acordo com o alinhamento político dos candidatos
- Margens de erro incoerentes com o tamanho das amostras
- Erros não-amostrais (para além da margem de erro)

São 3[^1] modelos que se diferenciam pela importância atribuída ao
desempenho dos institutos na última eleição. Eles são apresentados
abaixo em ordem do menos dependente dos dados históricos para o mais
dependente. Cada modelo contém uma breve nota introdutória, e
interessados em mais detalhes podem consultar a [metodologia
completa](https://rnmag.github.io/agregR/index.html#methodology).

## Pesquisas incluídas

O banco de dados se baseia nas pesquisas registradas no TSE e divulgadas
na imprensa. Ele contém **139 pesquisas** abrangendo os seguintes
institutos:

- Alfa
- Atlas
- Datafolha
- Futura
- Gerp
- Ideia
- Ipsos-Ipec
- MDA
- Nexus
- Palver
- Paraná Pesquisas
- PoderData
- Quaest
- Realtime Bigdata
- Vox Brasil

Esta página apresenta apenas os cenários eleitorais mais prováveis, mas
o pacote inclui os dados completos de cada pesquisa. [Instale-o
gratuitamente](https://rnmag.github.io/agregR/index.html#installation)
para explorar os mais de 10 cenários disponíveis.

## Modelo 1: Viés Relativo sem Pesos

Este modelo não usa qualquer informação sobre o desempenho dos
institutos na última eleição, calculando vieses puramente em relação às
pesquisas deste ciclo eleitoral. Todos os institutos têm o mesmo peso.

![\[Clique para ver em tela
cheia\](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/grafico-vies-relativo-sem-pesos-1t-1.png)](agregador_files/figure-html/grafico-vies-relativo-sem-pesos-1t-1.png)

[Clique para ver em tela
cheia](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/grafico-vies-relativo-sem-pesos-1t-1.png)

------------------------------------------------------------------------

![\[Clique para ver em tela
cheia\](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/grafico-vies-relativo-sem-pesos-2t-1.png)](agregador_files/figure-html/grafico-vies-relativo-sem-pesos-2t-1.png)

[Clique para ver em tela
cheia](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/grafico-vies-relativo-sem-pesos-2t-1.png)

------------------------------------------------------------------------

![\[Clique para ver em tela
cheia\](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/institutos-vies-relativo-sem-pesos-1.png)](agregador_files/figure-html/institutos-vies-relativo-sem-pesos-1.png)

[Clique para ver em tela
cheia](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/institutos-vies-relativo-sem-pesos-1.png)

## Modelo 2: Viés Relativo com Pesos

Este modelo equilibra o uso de dados históricos e do ciclo atual.
Atribui pesos aos institutos de acordo com o desempenho na última
eleição, considerando o alinhamento político dos candidatos. O viés é
estimado em relação ao consenso das pesquisas.

![\[Clique para ver em tela
cheia\](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/grafico-vies-relativo-com-pesos-1t-1.png)](agregador_files/figure-html/grafico-vies-relativo-com-pesos-1t-1.png)

[Clique para ver em tela
cheia](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/grafico-vies-relativo-com-pesos-1t-1.png)

------------------------------------------------------------------------

![\[Clique para ver em tela
cheia\](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/grafico-vies-relativo-com-pesos-2t-1.png)](agregador_files/figure-html/grafico-vies-relativo-com-pesos-2t-1.png)

[Clique para ver em tela
cheia](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/grafico-vies-relativo-com-pesos-2t-1.png)

------------------------------------------------------------------------

![\[Clique para ver em tela
cheia\](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/institutos-vies-relativo-com-pesos-1.png)](agregador_files/figure-html/institutos-vies-relativo-com-pesos-1.png)

[Clique para ver em tela
cheia](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/institutos-vies-relativo-com-pesos-1.png)

## Modelo 3: Viés Empírico

Este é o modelo mais vinculado ao passado. Além de atribuir pesos aos
institutos de acordo com o desempenho na última eleição, também compensa
(ou desconta) os candidatos com alinhamentos políticos mais prejudicados
(ou beneficiados) por cada instituto.

![\[Clique para ver em tela
cheia\](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/grafico-vies-empirico-1t-1.png)](agregador_files/figure-html/grafico-vies-empirico-1t-1.png)

[Clique para ver em tela
cheia](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/grafico-vies-empirico-1t-1.png)

------------------------------------------------------------------------

![\[Clique para ver em tela
cheia\](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/grafico-vies-empirico-2t-1.png)](agregador_files/figure-html/grafico-vies-empirico-2t-1.png)

[Clique para ver em tela
cheia](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/grafico-vies-empirico-2t-1.png)

------------------------------------------------------------------------

![\[Clique para ver em tela
cheia\](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/institutos-vies-empirico-1.png)](agregador_files/figure-html/institutos-vies-empirico-1.png)

[Clique para ver em tela
cheia](https://rnmag.github.io/agregR/articles/agregador_files/figure-html/institutos-vies-empirico-1.png)

## Agradecimentos

Agradecimentos a Ricardo Ribeiro, que gentilmente compartilhou sua
planilha de pesquisas para a eleição de 2026, e ao Poder360, que
publicou sua [base
histórica](https://basedosdados.org/dataset/fb38dbe8-03ce-46b4-a6b7-638ade03999c?table=b6df9e1c-cbcb-4dbd-893b-8645a51773e6).

[^1]: O pacote inclui outros 2 modelos com menor utilidade durante a
    campanha: o modelo **Retrospectivo** usa o resultado real da eleição
    para calcular retrospectivamente vieses e trajetórias para cada
    candidato, enquanto o modelo **Naive** é disponibilizado como uma
    curiosidade, pois não modela nenhum viés e é equivalente a calcular
    uma média simples das pesquisas.
