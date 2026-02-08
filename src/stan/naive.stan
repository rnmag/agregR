// ------------------------------- MODELO NAIVE -------------------------------
//
// O modelo que acredita em todas as pesquisas. Para ele:
//
// - Não existe viés de institutos
// - As pesquisas só erram dentro da margem
// - Os erros são simétricos para todos os campos políticos
//
// Nos dias em que não há pesquisas publicadas, a intenção de votos de cada
// candidatura é modelada como uma variável latente (mu) que evolui diariamente
// com choques aleatórios (eta):
//
// mu[t] ~ N(mu[t-1], eta)
//
// Quando uma pesquisa é publicada, o modelo a trata como uma informação incon-
// troversa sobre o estado real da variável latente. A única fonte de incerteza
// é o erro amostral (sigma):
//
// percentual ~ N(mu[t], sigma)
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
  //
  int<lower=1> total_dias;                          // total de dias analisados
  int<lower=1> n_pesquisas;                         // n de pesquisas
  array[n_pesquisas] int<lower=1> n_dias;           // n de dias desde a primeira pesquisa
  //
  // -------------------------------- Prioris ---------------------------------
  //     https://github.com/stan-dev/stan/wiki/prior-choice-recommendations
  //
  real<lower=0, upper=1> mu_priori;                 // priori para votos latentes
  real<lower=0> sd_mu_priori;                       // desvio padrão da priori para mu
  real<lower=0> omega_eta_priori;                   // priori para a volatilidade do nível
  real<lower=0> sd_omega_eta_priori;                // desvio padrão para a volatilidade do nível
  //
  // ---------------------------- Dados observados ----------------------------
  //
  vector<lower=0, upper=1>[n_pesquisas] percentual; // valores das pesquisas
  vector<lower=0>[n_pesquisas] sigma;               // erro padrão das pesquisas
}

parameters {
  // ----------------- Vars auxiliares para reparametrização ------------------
  vector[total_dias] mu_raw;
  real<lower=0> omega_eta_raw;
}

transformed parameters {
  // ---------------------------- Modelo de estado ----------------------------
  vector[total_dias] mu;
  real<lower=0> eta = omega_eta_priori + omega_eta_raw * sd_omega_eta_priori;

  // Inicialização (t = 1)
  mu[1] = mu_priori + mu_raw[1] * sd_mu_priori;

  // Evolução do estado
  for (t in 2:total_dias) {
    mu[t] = mu[t - 1] + mu_raw[t] * eta;
  }
}

model {
  // ------------------------ Prioris reparametrizadas ------------------------
  mu_raw ~ std_normal();
  omega_eta_raw ~ std_normal();

  // ------------------------- Verossimilhança --------------------------------
  percentual ~ normal(mu[n_dias], sigma);
}

generated quantities {
  // Simulação para *Posterior Predictive Checks*
  // Vetor sem limites pode gerar valores simulados abaixo de 0 ou acima de 1
  vector[n_pesquisas] perc_simulado = to_vector(normal_rng(mu[n_dias], sigma));
}
