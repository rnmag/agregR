// ------------------------------- MODELO NAIVE -------------------------------
//
// Versão Multivariada (ALR + Multinomial)
//
// O modelo que acredita em todas as pesquisas. Para ele:
// - Não existe viés de institutos (delta = 0)
// - Não existe erro não-amostral extra (tau = 0)
//
// O estado latente (alpha) evolui no espaço ALR como um Random Walk multivariado.
//
// alpha[t] ~ MultiNormal(alpha[t-1], Sigma_evo)
// mu[t] = softmax([alpha[t], 0])
// votos ~ Multinomial(mu[t], N)
//
// ----------------------------------------------------------------------------

data {
  // -------------------------------- Índices ---------------------------------
  int<lower=1> total_dias;                          
  int<lower=1> n_pesquisas;                         
  int<lower=1> n_candidatos;                        
  
  array[n_pesquisas] int<lower=1> n_dias;           
  
  // -------------------------------- Prioris ---------------------------------
  
  // --- Correlação (LKJ) ---
  real<lower=0> lkj_corr_priori;                    
  
  // --- Modelo de estado: dinâmica de nível (ALR) ---
  vector[n_candidatos-1] mu_priori;                 
  vector<lower=0>[n_candidatos-1] sd_mu_priori;     
  
  real<lower=0> omega_eta_priori;                   
  real<lower=0> sd_omega_eta_priori;                

  // ---------------------------- Dados observados ----------------------------
  array[n_pesquisas, n_candidatos] int votos; 
}

parameters {
  // ----------------- Vars latentes no espaço ALR (P-1) ----------------------
  
  // Dinâmica de nível (alpha) - Random Walk simples (sem tendência nu)
  matrix[total_dias, n_candidatos-1] alpha_raw;
  
  // Escalas de volatilidade 
  vector<lower=0>[n_candidatos-1] sigma_alpha_raw;
  
  // Matriz de Correlação
  cholesky_factor_corr[n_candidatos-1] L_corr;
}

transformed parameters {
  // ----------------------- Reconstrução de Parâmetros -----------------------
  
  // 1. Escalas de volatilidade
  vector[n_candidatos-1] sigma_alpha;
  sigma_alpha = omega_eta_priori + sigma_alpha_raw * sd_omega_eta_priori;
  
  // 2. Modelo de Estado (Evolução Temporal)
  matrix[total_dias, n_candidatos-1] alpha; 
  
  // Inicialização (t=1)
  for(p in 1:(n_candidatos-1)) {
    alpha[1, p] = mu_priori[p] + alpha_raw[1, p] * sd_mu_priori[p];
  }

  // Matriz de covariância
  matrix[n_candidatos-1, n_candidatos-1] L_Sigma_alpha = diag_pre_multiply(sigma_alpha, L_corr);

  // Evolução (t=2...T)
  for (t in 2:total_dias) {
    vector[n_candidatos-1] innovation = L_Sigma_alpha * to_vector(alpha_raw[t, ]);
    alpha[t, ] = to_row_vector(to_vector(alpha[t-1, ]) + innovation);
  }
  
  // 3. Transformação para Simplex (mu)
  array[total_dias] simplex[n_candidatos] mu;
  
  for(t in 1:total_dias) {
    vector[n_candidatos] temp;
    temp[1:(n_candidatos-1)] = to_vector(alpha[t, ]);
    temp[n_candidatos] = 0; 
    mu[t] = softmax(temp);
  }
}

model {
  // ----------------------------- Prioris ------------------------------------
  
  L_corr ~ lkj_corr_cholesky(lkj_corr_priori);
  
  to_vector(alpha_raw) ~ std_normal();
  sigma_alpha_raw      ~ std_normal();
  
  // ------------------------- Verossimilhança --------------------------------
  
  for(i in 1:n_pesquisas) {
    int d = n_dias[i];
    votos[i] ~ multinomial(mu[d]);
  }
}

generated quantities {
  array[n_pesquisas, n_candidatos] int votos_simulados;
  
  for(i in 1:n_pesquisas) {
    int d = n_dias[i];
    int N_total = sum(votos[i]);
    votos_simulados[i] = multinomial_rng(mu[d], N_total);
  }
}
