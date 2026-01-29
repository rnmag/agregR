libs <- file.path(R_PACKAGE_DIR, "libs", R_ARCH)
dir.create(libs, recursive = TRUE, showWarnings = FALSE)
for (file in c("symbols.rds", Sys.glob(paste0("*", SHLIB_EXT)))) {
  if (file.exists(file)) {
    file.copy(file, file.path(libs, file))
  }
}
inst_stan <- file.path("..", "inst", "stan")
if (dir.exists(inst_stan)) {
  warning(
    "Stan models in inst/stan/ are deprecated in {instantiate} ",
    ">= 0.0.4.9001 (2024-01-03). Please put them in src/stan/ instead."
  )
  if (file.exists("stan")) {
    warning("src/stan/ already exists. Not copying models from inst/stan/.")
  } else {
    message("Copying inst/stan/ to src/stan/.")
    file.copy(from = inst_stan, to = "stan", recursive = TRUE)
  }
}
bin <- file.path(R_PACKAGE_DIR, "bin")
if (!file.exists(bin)) {
  dir.create(bin, recursive = TRUE, showWarnings = FALSE)
}
bin_stan <- file.path(bin, "stan")
# Copiar diretório stan para bin_stan
# file.copy com recursive=TRUE copia o diretório 'stan' PARA DENTRO de 'bin', criando 'bin/stan'
# Se 'bin/stan' não existir, ele cria.
# Importante: file.copy recursive behavior can be tricky.
# Se bin_stan (".../bin/stan") não existe, file.copy("stan", bin, recursive=TRUE) cria ".../bin/stan".
# Vamos garantir que bin existe (já feito acima) e copiar o CONTEÚDO ou a PASTA.
# fs::dir_copy("stan", bin_stan) copia "stan" para "bin_stan".
# file.copy("stan", bin, recursive=TRUE) deve funcionar.
file.copy("stan", bin, recursive = TRUE)

# Executar compilação diretamente
instantiate::stan_package_compile(
  models = instantiate::stan_package_model_files(path = bin_stan),
  quiet = TRUE
)
