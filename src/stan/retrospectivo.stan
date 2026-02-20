// -------------------------------- IMPORTANTE --------------------------------
//
// Este modelo usa o resultado da eleição como ponto de partida e reconstroi a
// trajetória da opinião pública de trás para frente. Não é um modelo útil du-
// rante a campanha, mas depois da eleição ele pode calcular vieses precisos e
// ajudar no diagnóstico dos outros modelos.
//
// Para rodá-lo corretamente, é necessário fornecer um arquivo com o resultado
// das urnas. O pacote será atualizado assim que os dados estiverem disponíveis,
// e é possível usar um arquivo próprio por meio da função config_agregador().
// Nesta caso, é recomendado que o resultado percentual utilize a soma de votos
// válidos + brancos/nulos no denominador, para manter a consistência com as
// pesquisas.
//
// ----------------------------------------------------------------------------

// --------------------------- MODELO RETROSPECTIVO ---------------------------
//
// Versão Multivariada (ALR + Multinomial)
//
// Ancora o estado final (dia da eleição) ao resultado real das urnas.
// O estado latente evolui até a véspera, e no dia T é fixado.
//
// alpha[t] ~ MultiNormal(alpha[t-1], ...) para t < T
// alpha[T] = ALR(resultado_final)
//
// ----------------------------------------------------------------------------

data {
  int<lower=1> total_dias;                          
  int<lower=1> n_pesquisas;                         
  int<lower=1> n_institutos;                        
  int<lower=1> n_candidatos;                        
  
  array[n_pesquisas] int<lower=1> n_dias;           
  array[n_pesquisas] int<lower=1> instituto;        
  
  // Resultado Final (Simplex)
  vector<lower=0, upper=1>[n_candidatos] resultado_final;

  // Prioris
  real<lower=0> lkj_corr_priori;                    
  
  real delta_priori;
  real<lower=0> sd_delta_priori;
  
  real<lower=0> sd_tau_priori;                      
  
  vector[n_candidatos-1] mu_priori;                 
  vector<lower=0>[n_candidatos-1] sd_mu_priori;     
  
  real<lower=0> omega_eta_priori;                   
  real<lower=0> sd_omega_eta_priori;                
  
  vector[n_candidatos-1] nu_priori;                 
  vector<lower=0>[n_candidatos-1] sd_nu_priori;     
  
  real<lower=0> omega_zeta_priori;                  
  real<lower=0> sd_omega_zeta_priori;               
  
  array[n_pesquisas, n_candidatos] int votos; 
}

parameters {
  // Vars latentes (t vai até T-1 na prática para evolução estocástica livre, mas definimos T)
  // Mas para facilitar, declaramos T e restringimos no loop
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
  // Tau uniforme (escalar expandido na priori via dados ou aqui)
  // Aqui assumimos que não temos emp_tau_priori no retrospectivo (conforme arquivo original)
  // Usamos um tau base constante 0 se não fornecido, mas data pede sd_tau_priori.
  // Vamos assumir tau médio zero + raw.
  // Original: tau = tau_priori + ...
  // Vamos usar sd_tau_priori apenas.
  tau = tau_raw * sd_tau_priori;

  matrix[total_dias, n_candidatos-1] alpha; 
  matrix[total_dias, n_candidatos-1] nu;    
  
  for(p in 1:(n_candidatos-1)) {
    alpha[1, p] = mu_priori[p] + alpha_raw[1, p] * sd_mu_priori[p];
    nu[1, p]    = nu_priori[p] + nu_raw[1, p] * sd_nu_priori[p];
  }

  matrix[n_candidatos-1, n_candidatos-1] L_Sigma_alpha = diag_pre_multiply(sigma_alpha, L_corr);
  matrix[n_candidatos-1, n_candidatos-1] L_Sigma_nu    = diag_pre_multiply(sigma_nu, L_corr);

  // Evolução até T-1
  for (t in 2:(total_dias-1)) {
    vector[n_candidatos-1] innovation_nu = L_Sigma_nu * to_vector(nu_raw[t, ]);
    nu[t, ] = to_row_vector(to_vector(nu[t-1, ]) + innovation_nu);
    
    vector[n_candidatos-1] innovation_alpha = L_Sigma_alpha * to_vector(alpha_raw[t, ]);
    alpha[t, ] = to_row_vector(to_vector(alpha[t-1, ]) + to_vector(nu[t-1, ]) + innovation_alpha);
  }

  // Definir Estado Final (T)
  // ALR do resultado: log(p_i / p_ref)
  // Ref = ultimo candidato
  nu[total_dias] = nu[total_dias-1]; // Tendência constante no último dia (ou evolui, tanto faz, não afeta alpha[T])
  
  for(p in 1:(n_candidatos-1)) {
     alpha[total_dias, p] = log(resultado_final[p] / resultado_final[n_candidatos]);
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
