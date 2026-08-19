# Agregador Eleições 2026

**Última atualização**: 19/08/2026

## Introdução

Como interpretar tantas pesquisas eleitorais com resultados divergentes?
O `agregR` emprega um conjunto de modelos estatísticos para filtrar a
enxurrada de dados divulgados no período eleitoral e estimar o nível
subjacente de apoio para cada candidato.

São 3[^1] modelos que se diferenciam pela importância que cada um
atribui ao desempenho dos institutos na última eleição. Eles são
apresentados abaixo em ordem do menos dependente dos dados históricos
para o mais dependente. Cada modelo contém uma breve nota introdutória,
e interessados em mais detalhes podem consultar a [metodologia
completa](https://rnmag.github.io/agregR/index.html#methodology).

Os modelos contemplam:

- Desempenho dos institutos na última eleição
- Vieses de acordo com o alinhamento político dos candidatos
- Vieses dos institutos em relação ao consenso
- Margens de erro incoerentes com o tamanho da amostra
- Erros não-amostrais (para além da margem de erro)

Esta página apresenta os cenários eleitorais mais prováveis, mas
`agregR` é um pacote para o R que pode ser
[instalado](https://rnmag.github.io/agregR/index.html#installation)
gratuitamente. Fique à vontade para explorar os mais de 10 cenários
disponíveis no banco de dados.

## Modelo 1: Viés Relativo sem Pesos

Este modelo não usa qualquer informação sobre o desempenho dos
institutos na última eleição, calculando vieses puramente com base nas
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
estimado em torno do consenso das pesquisas.

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

## Pesquisas incluídas

O [banco de
dados](https://github.com/rnmag/agregR/blob/main/inst/extdata/pesquisas_2026.csv)
se baseia nas pesquisas registradas no TSE e divulgadas na imprensa. Ele
contém **132 pesquisas** para a eleição de 2026, abrangendo os seguintes
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

**Última pesquisa**: Nexus finalizada em 16/08/2026

Agradecimentos a Ricardo Ribeiro, que gentilmente compartilhou sua
planilha de pesquisas para o ciclo atual, e ao Poder360, que publicou
sua [base histórica de
pesquisas](https://basedosdados.org/dataset/fb38dbe8-03ce-46b4-a6b7-638ade03999c?table=b6df9e1c-cbcb-4dbd-893b-8645a51773e6).

[^1]: O pacote contém outros 2 modelos com menor utilidade durante a
    campanha: o modelo **Retrospectivo** usa o resultado real da eleição
    para calcular retrospectivamente vieses e trajetórias para cada
    candidato, enquanto o modelo **Naive** é disponibilizado como uma
    curiosidade, pois não modela nenhum viés e é equivalente a calcular
    uma média simples das pesquisas.
