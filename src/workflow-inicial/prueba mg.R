# data drift descriptiva

# limpio la memoria
rm(list = ls(all.names = TRUE)) # remove all objects
gc(full = TRUE) # garbage collection

require("data.table")
require("yaml")
require("ggplot2")

# Parametros del script
PARAM <- list()
PARAM$experimento <- "DR6210"

PARAM$exp_input <- "CA6110"

PARAM$home <- "~/buckets/b1/"


setwd(PARAM$home)

# cargo el dataset donde voy a entrenar
# esta en la carpeta del exp_input y siempre se llama  dataset.csv.gz
dataset_input <- paste0("./exp/", PARAM$exp_input, "/dataset.csv.gz")
dataset <- fread(dataset_input)

# Calcula la densidad de sueldo para cada mes
#density_data <- dataset[, list(Density = density(mpayroll)), by = foto_mes]
# Gráfica la densidad de sueldo para cada mes
#ggplot(density_data, aes(x = x, y = y, color = foto_mes)) +
#  geom_line() +
#  labs(x = "Sueldo", y = "Densidad", title = "Densidad de Sueldo por Mes") +
#  theme_minimal()



dataset$foto_mes <- as.factor(dataset$foto_mes)

ggplot(dataset, aes(x=mpayroll, color=foto_mes)) + 
  geom_density() + 
  labs(x = "Sueldo", y = "Density", color = "Mes", title = "Distribucion de salario por mes") +
  theme_minimal()

