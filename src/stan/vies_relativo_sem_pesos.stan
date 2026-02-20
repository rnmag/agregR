// ------------------------- VIÉS RELATIVO SEM PESOS --------------------------
//
// Versão Multivariada (ALR + Multinomial)
//
// Similar ao "com pesos", mas assume uma priori comum (tau_priori) para o erro
// não-amostral de todos os institutos, sem usar histórico.
//
// ----------------------------------------------------------------------------

data {
  // -------------------------------- Índices ---------------------------------
  int<lower=1> total_dias;                          
  int<lower=1> n_pesquisas;                         
  int<lower=1> n_institutos;                        
  int<lower=1> n_candidatos;                        
  
  array[n_pesquisas] int<lower=1> n_dias;           
  array[n_pesquisas] int<lower=1> instituto;        
  
  // -------------------------------- Prioris ---------------------------------
  
  real<lower=0> lkj_corr_priori;                    
  
  real delta_priori;                                
  real<lower=0> sd_delta_priori;                    
  
  // --- Erro não-amostral (Escalar comum) ---
  real<lower=0> tau_priori;
  real<lower=0> sd_tau_priori;                      
  
  // --- Modelo de estado ---
  vector[n_candidatos-1] mu_priori;                 
  vector<lower=0>[n_candidatos-1] sd_mu_priori;     
  
  real<lower=0> omega_eta_priori;                   
  real<lower=0> sd_omega_eta_priori;                
  
  vector[n_candidatos-1] nu_priori;                 
  vector<lower=0>[n_candidatos-1] sd_nu_priori;     
  
  real<lower=0> omega_zeta_priori;                  
  real<lower=0> sd_omega_zeta_priori;               
  
  // ---------------------------- Dados observados ----------------------------
  array[n_pesquisas, n_candidatos] int votos; 
}

parameters {
  matrix[total_dias, n_candidatos-1] alpha_raw;
  matrix[total_dias, n_candidatos-1] nu_raw;
  
  vector<lower=0>[n_candidatos-1] sigma_alpha_raw;
  vector<lower=0>[n_candidatos-1] sigma_nu_raw;
  
  cholesky_factor_corr[n_candidatos-1] L_corr;
  
  matrix[n_institutos, n_candidatos-1] delta_raw;
  matrix<lower=0>[n_institutos, n_candidatos-1] tau_raw;
}

transformed parameters {
  vector[n_candidatos-1] sigma_alpha;
  vector[n_candidatos-1] sigma_nu;
  
  sigma_alpha = omega_eta_priori + sigma_alpha_raw * sd_omega_eta_priori;
  sigma_nu    = omega_zeta_priori + sigma_nu_raw * sd_omega_zeta_priori;
  
  matrix[n_institutos, n_candidatos-1] delta;
  delta = delta_priori + delta_raw * sd_delta_priori;
  
  matrix[n_institutos, n_candidatos-1] tau;
  // Tau uniforme base + variação
  tau = tau_priori + tau_raw * sd_tau_priori;

  matrix[total_dias, n_candidatos-1] alpha; 
  matrix[total_dias, n_candidatos-1] nu;    
  
  for(p in 1:(n_candidatos-1)) {
    alpha[1, p] = mu_priori[p] + alpha_raw[1, p] * sd_mu_priori[p];
    nu[1, p]    = nu_priori[p] + nu_raw[1, p] * sd_nu_priori[p];
  }

  matrix[n_candidatos-1, n_candidatos-1] L_Sigma_alpha = diag_pre_multiply(sigma_alpha, L_corr);
  matrix[n_candidatos-1, n_candidatos-1] L_Sigma_nu    = diag_pre_multiply(sigma_nu, L_corr);

  for (t in 2:total_dias) {
    vector[n_candidatos-1] innovation_nu = L_Sigma_nu * to_vector(nu_raw[t, ]);
    nu[t, ] = to_row_vector(to_vector(nu[t-1, ]) + innovation_nu);
    
    vector[n_candidatos-1] innovation_alpha = L_Sigma_alpha * to_vector(alpha_raw[t, ]);
    alpha[t, ] = to_row_vector(to_vector(alpha[t-1, ]) + to_vector(nu[t-1, ]) + innovation_alpha);
  }
  
  array[total_dias] simplex[n_candidatos] mu;
  
  for(t in 1:total_dias) {
    vector[n_candidatos] temp;
    temp[1:(n_candidatos-1)] = to_vector(alpha[t, ]);
    temp[n_candidatos] = 0; 
    mu[t] = softmax(temp);
  }
}

model {
  L_corr ~ lkj_corr_cholesky(lkj_corr_priori);
  
  to_vector(alpha_raw) ~ std_normal();
  to_vector(nu_raw)    ~ std_normal();
  sigma_alpha_raw      ~ std_normal();
  sigma_nu_raw         ~ std_normal();
  
  to_vector(delta_raw) ~ std_normal();
  to_vector(tau_raw)   ~ std_normal();
  
  for(i in 1:n_pesquisas) {
    int d = n_dias[i];
    int inst = instituto[i];
    
    vector[n_candidatos-1] pred_alr = to_vector(alpha[d, ]) + to_vector(delta[inst, ]);
    
    vector[n_candidatos] theta;
    theta[1:(n_candidatos-1)] = pred_alr;
    theta[n_candidatos] = 0;
    
    votos[i] ~ multinomial(softmax(theta));
  }
}

generated quantities {
  array[n_pesquisas, n_candidatos] int votos_simulados;
  
  for(i in 1:n_pesquisas) {
    int d = n_dias[i];
    int inst = instituto[i];
    int N_total = sum(votos[i]);
    
    vector[n_candidatos] theta;
    theta[1:(n_candidatos-1)] = to_vector(alpha[d, ]) + to_vector(delta[inst, ]);
    theta[n_candidatos] = 0;
    
    votos_simulados[i] = multinomial_rng(softmax(theta), N_total);
  }
}