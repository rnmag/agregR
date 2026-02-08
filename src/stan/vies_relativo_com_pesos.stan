// ------------------------- VIÉS RELATIVO COM PESOS --------------------------
//
// Este arquivo implementa um modelo *state-space* bayesiano com o objetivo de
// capturar a preferência real dos eleitores em meio à abundância de pesquisas
// publicadas com diferentes metodologias. A intenção de votos de cada candida-
// tura é modelada como uma variável latente (mu) que evolui diariamente segun-
// do uma tendência linear local (Jackman, 2009).
//
// As pesquisas eleitorais são tratadas como observações ruidosas e potencial-
// mente enviesadas desse estado latente. A função de verossimilhança decompõe
// a incerteza em erro amostral (sigma), viés de institutos (delta) e um termo
// adicional de erro não-amostral (tau) semelhante ao utilizado por Heidemanns,
// Gelman & Morris (2020).
//
// --- Por que viés relativo? ---
//
// Os parâmetros do modelo não são identificados: há múltiplas combinações de
// mu e delta que geram soluções válidas. Como o ajuste do modelo não é único,
// os coeficientes de delta não podem ser interpretados diretamente como valo- 
// res reais do viés de cada instituto. Assim, precisamos escolher uma "âncora"
// que servirá como ponto de referência para os coeficientes.
//
// Neste modelo, essa âncora é a média do viés de todos os institutos. Ela é o
// ponto fixo em torno do qual são solucionados os parâmetros. Portanto, o viés
// é relativo porque mede como cada instituto desvia do conjunto dos demais.
//
// --- Pesos ---
//
// Este modelo utiliza dados da eleição anterior para atribuir pesos aos insti-
// tutos. Os pesos são incorporados como prioris para o parâmetro de erro não-
// amostral (tau). Quanto maior o erro passado, menor influência na estimativa
// do voto latente.
//
// Os desempenhos de cada instituto são avaliados por turno e por campo ideoló-
// gico da candidatura. Assim, além de considerar o fato de que as pesquisas
// erram mais no primeiro turno do que no segundo, o modelo penaliza institutos
// que erram assimetricamente para candidaturas de direita e/ou esquerda.
//
// --- Modelo de estado ---
//
// Nos dias em que não há pesquisas publicadas, a estimativa evolui por meio de
// um *state model* com 2 componentes:
//
// Dinámica de nível:     mu[t] ~ N(mu[t-1] + nu[t-1], eta)
// Dinâmica de tendência: nu[t] ~ N(nu[t-1], zeta)
//
// Em outras palavras, o estado latente da intenção de votos segue o nível do
// dia anterior acrescido da tendência capturada pelo modelo.
//
// --- Verossimilhança ---
//
// Quando uma pesquisa é publicada, o modelo a trata como uma informação útil,
// porém imperfeita, sobre o estado real da variável latente:
//
// percentual ~ N(mu[t] + delta[instituto], sqrt(square(sigma) + square(tau)))
// 
// O modelo inclui 3 fontes de incerteza:
// 
// 1. Erro amostral (sigma): representa a incerteza inerente ao tamanho efetivo
//    da amostra da pesquisa
//
// 2. Erro de nível (delta): estima vieses específicos para cada instituto. Po-
//    tenciais fontes de viés incluem tipo de coleta, pós-estratificação, etc.
//  
// 3. Imprecisão (tau): representa o erro não-amostral, reconhecendo que há ou-
//    tras fontes de erro além daqueles intrínsecos ao tamanho da amostra e ao
//    viés dos institutos. Por exemplo, as amostras raramente são aleatórias,
//    há viés de não resposta não ignorável, etc.
//
// --- Reparametrização ---
//
// Este modelo padroniza as distribuições dos parâmetros em N(0, 1), que é uma
// distribuição com propriedades conhecidas e que o Stan consegue explorar com
// eficiência. Com isso, as simulações rodam mais rápido e sofrem menos com di-
// vergências. 
//
// Para assegurar que as amostras posteriores reflitam as distribuições origi-
// nais, os parâmetros são reconstruídos no bloco *transformed parameters*. As
// estimativas da verossimilhança são calculadas com base nesses parâmetros re-
// constituídos, assim como os valores simulados para os *posterior predictive
// checks*.
//
// Os capítulos 13 e 14 de McElreath (2020) oferecem uma explicação intuitiva a
// respeito de *Non-Centered Parametrization* no contexto de modelos hierárqui-
// cos, enquanto o capítulo sobre Eficiência do Stan Users Guide (link abaixo)
// serve como referência para a implementação da técnica.
//
// --- Referências ---
//
// Heidemanns, Gelman & Morris (2020): https://sites.stat.columbia.edu/gelman/research/published/Harvard_Data_Science_Review.pdf
// Jackman (2009): https://onlinelibrary.wiley.com/doi/book/10.1002/9780470686621
// McElreath (2020): https://www.routledge.com/Statistical-Rethinking-A-Bayesian-Course-with-Examples-in-R-and-STAN/McElreath/p/book/9780367139919
// Stan Users Guide: https://mc-stan.org/docs/stan-users-guide/efficiency-tuning.html#non-centered-parameterization
//
// ----------------------------------------------------------------------------

// ------------------------------- CONFIGURAÇÃO -------------------------------
//
// Este arquivo importa todas as prioris como variáveis no bloco de dados. Isso
// permite experimentar diferentes inicializações sem a necessidade de recompi-
// lar o código, facilitando a calibração dos hiperparâmetros.
//
// As prioris podem ser alteradas no arquivo de configuração do agregador.
//
// ----------------------------------------------------------------------------

data {
  // -------------------------------- Índices ---------------------------------
  int<lower=1> total_dias;                          // total de dias analisados
  int<lower=1> n_pesquisas;                         // n de pesquisas
  int<lower=1> n_institutos;                        // n de institutos
  // int<lower=1> n_metodologias;                   // n de metodologias
  array[n_pesquisas] int<lower=1> n_dias;           // n de dias desde a primeira pesquisa
  array[n_pesquisas] int<lower=1> instituto;        // índice para instituto
  // array[n_pesquisas] int<lower=1> metodologia;   // índice para metodologia
  //
  // -------------------------------- Prioris ---------------------------------
  //     https://github.com/stan-dev/stan/wiki/prior-choice-recommendations
  //
  // --- Viés dos institutos ---
  real delta_priori;                                // erro direcional dos institutos
  real<lower=0> sd_delta_priori;                    // desvio padrão da priori para delta
  //
  // --- Viés das metodologias ---
  // real gamma_priori;                             // erro direcional por metodologia
  // real<lower=0> sd_gamma_priori;                 // desvio padrão da priori para gamma
  //
  // --- Erro não-amostral ---
  vector<lower=0>[n_institutos] emp_tau_priori;     // erro não-amostral empírico por instituto
  real<lower=0> sd_tau_priori;                      // desvio padrão da priori para tau
  // 
  // --- Modelo de estado: dinâmica de nível ---
  real<lower=0, upper=1> mu_priori;                 // priori para votos latentes
  real<lower=0> sd_mu_priori;                       // desvio padrão da priori para mu
  real<lower=0> omega_eta_priori;                   // priori para a volatilidade do nível
  real<lower=0> sd_omega_eta_priori;                // desvio padrão para a volatilidade do nível
  //
  // --- Modelo de estado: dinâmica de tendência ---
  real<lower=0> nu_priori;                          // priori para a tendência inicial
  real<lower=0> sd_nu_priori;                       // desvio padrão da priori para nu
  real<lower=0> omega_zeta_priori;                  // priori para volatilidade da tendência
  real<lower=0> sd_omega_zeta_priori;               // desvio padrão para a volatilidade da tendência
  //
  // ---------------------------- Dados observados ----------------------------
  vector<lower=0, upper=1>[n_pesquisas] percentual; // valores das pesquisas
  vector<lower=0>[n_pesquisas] sigma;               // erro padrão das pesquisas
}

parameters {
  // ----------------- Vars auxiliares para reparametrização ------------------
  // Viés dos institutos
  vector[n_institutos] vies_instituto_raw;

  // Viés das metodologias
  // vector[n_metodologias] vies_metodologia_raw;
  
  // Erro não-amostral
  real<lower=0> tau_raw;

  // Dinâmica de nível
  vector[total_dias] mu_raw;
  real<lower=0> omega_eta_raw;

  // Dinâmica de tendência
  vector[total_dias] nu_raw;
  real<lower=0> omega_zeta_raw;
}

transformed parameters {
  // ----------------------- Parâmetros reconstruídos -----------------------
  // Viés dos institutos
  vector[n_institutos] vies_instituto;
  vies_instituto = delta_priori + vies_instituto_raw * sd_delta_priori;

  // Vieses somam a zero
  vector[n_institutos] delta;
  delta = vies_instituto - mean(vies_instituto);

  // Viés das metodologias
  // vector[n_institutos] vies_metodologia;
  // vies_instituto = gamma_priori + vies_metodologia_raw * sd_gamma_priori;
  
  // Vieses somam a zero
  // vector[n_metodologias] gamma;
  // gamma = vies_metodologia - mean(vies_metodologia);

  // Erro não-amostral
  vector<lower=0>[n_institutos] tau = emp_tau_priori + tau_raw * sd_tau_priori;

  // ---------------------------- Modelo de estado ----------------------------
  // Reconstrução da dinâmica de nível
  vector[total_dias] mu;
  real<lower=0> eta = omega_eta_priori + omega_eta_raw * sd_omega_eta_priori;

  // Reconstrução da dinâmica de tendência
  vector[total_dias] nu;
  real<lower=0> zeta = omega_zeta_priori + omega_zeta_raw * sd_omega_zeta_priori;

  // Inicialização (t = 1)
  nu[1] = nu_priori + nu_raw[1] * sd_nu_priori;
  mu[1] = mu_priori + mu_raw[1] * sd_mu_priori;

  // Evolução do estado
  for (t in 2:total_dias) {
    nu[t] = nu[t - 1] + nu_raw[t] * zeta;
    mu[t] = mu[t - 1] + nu[t - 1] + mu_raw[t] * eta;
  }
}

model {
  // ------------------------ Prioris reparametrizadas ------------------------
  // Viés dos institutos
  vies_instituto_raw ~ std_normal();

  // Viés das metodologias
  // vies_metodologia ~ std_normal();

  // Erro não-amostral
  tau_raw ~ std_normal();

  // Dinâmica de nível
  mu_raw ~ std_normal();
  omega_eta_raw ~ std_normal();

  // Dinâmica de tendência
  nu_raw ~ std_normal();
  omega_zeta_raw ~ std_normal();

  // ------------------------- Verossimilhança --------------------------------
  // Combina erro amostral (sigma) com erro não-amostral (tau) por instituto
  percentual ~ normal(mu[n_dias] + delta[instituto], sqrt(square(sigma) + square(tau[instituto])));
}

generated quantities {
  // Simulação para *Posterior Predictive Checks*
  // Vetor sem limites pode gerar valores simulados abaixo de 0 ou acima de 1
  vector[n_pesquisas] perc_simulado = to_vector(normal_rng(mu[n_dias] + delta[instituto], sqrt(square(sigma) + square(tau[instituto]))));
}
