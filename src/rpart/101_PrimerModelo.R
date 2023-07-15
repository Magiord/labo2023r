# Arbol elemental con libreria  rpart
# Debe tener instaladas las librerias  data.table  ,  rpart  y  rpart.plot

# cargo las librerias que necesito
require("data.table")
require("rpart")
require("rpart.plot")
#require("StabPerf")
require ("caret")

# Aqui se debe poner la carpeta de la materia de SU computadora local
setwd("c:/Austral/Labo1/") # Establezco el Working Directory

# cargo el dataset
dataset <- fread("./dataset/dataset_pequeno.csv")

#dataset <- dataset[dataset$clase_ternaria!="BAJA+1",]
#dataset <- dataset[dataset$cliente_vip==1,]


#varelim <- c("numero_de_cliente","cliente_vip","ccheques_emitidos_rechazados","mcheques_emitidos_rechazados","thomebanking","Master_delinquency",
#             "Master_Finiciomora","Master_madelantopesos","Master_madelantodolares","Master_cadelantosefectivo","Visa_delinquency","Visa_Finiciomora","Visa_madelantodolares")

#dataset <- subset(dataset, select = -varelim)
dataset <- dataset[, -c("cliente_vip","ccheques_emitidos_rechazados","mcheques_emitidos_rechazados","thomebanking","Master_delinquency",
                      "Master_Finiciomora","Master_madelantopesos","Master_madelantodolares","Master_cadelantosefectivo","Visa_delinquency","Visa_Finiciomora",
                      "Visa_madelantodolares")
]

dtrain <- dataset[foto_mes == 202107] # defino donde voy a entrenar
dapply <- dataset[foto_mes == 202109] # defino donde voy a aplicar el modelo

dataset <- dataset[,-c("foto_mes")]


#summary(dataset)

#modelo <- train(clase_ternaria ~ ., data=na.omit(dtrain), method="rpart")


# genero el modelo,  aqui se construye el arbol
modelo <- rpart(
  formula = "clase_ternaria ~ .", # quiero predecir clase_ternaria a partir de el resto de las variables
  data = dtrain, # los datos donde voy a entrenar
  xval = 0,
  cp = -0.3, # esto significa no limitar la complejidad de los splits
  minsplit = 20, # minima cantidad de registros para que se haga el split
  minbucket = 6, # tamaño minimo de una hoja
  maxdepth = 5
) # profundidad maxima del arbol


# grafico el arbol
prp(modelo, extra = 101, digits = -5, branch = 1, type = 4, varlen = 0, faclen = 0)


# aplico el modelo a los datos nuevos
prediccion <- predict(
  object = modelo,
  newdata = dapply,
  type = "prob"
)

# prediccion es una matriz con TRES columnas, llamadas "BAJA+1", "BAJA+2"  y "CONTINUA"
# cada columna es el vector de probabilidades

# agrego a dapply una columna nueva que es la probabilidad de BAJA+2
dapply[, prob_baja2 := prediccion[, "BAJA+2"]]

# solo le envio estimulo a los registros con probabilidad de BAJA+2 mayor  a  1/40
dapply[, Predicted := as.numeric(prob_baja2 > 1 / 40)]

# genero el archivo para Kaggle
# primero creo la carpeta donde va el experimento
dir.create("./exp/")
dir.create("./exp/KA2001")

fwrite(dapply[, list(numero_de_cliente, Predicted)], # solo los campos para Kaggle
       file = "./exp/KA2001/K101_001.csv",
       sep = ","
)