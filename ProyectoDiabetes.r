
library(ggplot2)
library(dplyr)
library(plyr)

## Carga los datos del fichero
data <- read.table("diabetes.data", header=T)

## Muestra información (primeras filas, nº de filas y columnas, variables ...)
head(data)
str(data)

# Muestra algunas filas en las que pueden verse algunos valores -9999.00 
print("Antes:")
data[c(18 : 20), 1 : ncol(data)]
dim(data)

# Reemplaza los valores -9999.00 por NA 
data[data == -9999 ] <- NA

# Muestra las filas anteriores después de la modificación
print("Después:")
data[c(18 : 20), 1 : ncol(data)]

# Elimina las filas con valores NA y muestra información del nuevo dataframe resultante
data <- na.omit(data)
print("Dimensiones del nuevo dataframe sin filas con valores NA:")
dim(data)

str(data)

summary(data)
print("Desviación típica:")
apply(data[-2], 2, sd)
print("Varianza:")
apply(data[-2], 2, var)

boxplot(data[-2])

# Calcula la media para cada variable mumérica
datax = data[-2]
for (i in 1:ncol(datax)) {
    print(colnames(datax[i]))
    print(tapply(datax[[i]], data$SEX, mean))
}

correlacionY <- cor(data[-2])[,ncol(data[-2])]
head(correlacionY, ncol(data[-2]))

ggplot(data, aes(x=data$BMI, y=data$Y)) + geom_line()

ggplot(data, aes(x=data$S2, y=data$Y)) + geom_line()

ggplot(data, aes(x=data$Y, y=data$Y)) + geom_line()

# Muestra el valor de la variable SEX antes de la modificación
print("Antes:")
head(data$SEX, 10)
class(data$SEX)

# Modifica los valores de la variable SEX
data$SEX<-as.character(data$SEX)
data$SEX<-replace(data$SEX, data$SEX=="M","1")
data$SEX<-replace(data$SEX, data$SEX=="F","2")
data$SEX <- as.numeric(data$SEX)

# Muestra el valor de la variable SEX después de la modificación
print("Después:")
head(data$SEX, 10)
class(data$SEX)
head(data)

# Creamos una función que reemplace los outlier por NA
quitar_outliers <- function(x) {
  mediana <- median(x)
  desviacion <- mad(x)
  maximo <- mediana + 3 * desviacion
  minimo <- mediana - 3 * desviacion
  y <- x
  y[x < minimo] <- NA
  y[x > maximo] <- NA
  y
}

# Mostramos las dimensiones del dataframe antes de la modificación
print("Numero de filas antes:")
nrow(data)

# Cambiamos los outlier de las variables (excepto sexo y edad) por NA
for (i in 3:ncol(data)) {
  data[[i]] <- quitar_outliers(data[[i]])
}
# Eliminamos las líneas del dataframe con algún valor NA
data <- na.omit(data)

# Mostramos las dimensiones del dataframe después de la modificación
print("Numero de filas después:")
nrow(data)

# Calculamos el número de filas correspondiente al 70%
corte70 <- floor(0.70 * nrow(data))
corte70

# Fijamos la semilla para generación de números aleatorios
set.seed(3)

# Generamos la lista de números aleatorios (70%)
aleatorios <- sample(seq_len(nrow(data)), size=corte70)
str(aleatorios)

# Generamos el dataframe de entrenamiento
entrenamiento <- data[aleatorios,]
str(entrenamiento)

# Generamos el dataframe de test
test <- data[-aleatorios,]
str(test)

# Crea una función para normalzar dataframes
normalizar_dataframe =  function(datos, parametros) {
    as.data.frame(
        Map(function(columna, parametros) {
            (columna - parametros[1]) / parametros[2]
        }, datos, parametros)
    )
}

# Obtiene la media y la desviación típica
media <- numcolwise(mean)(entrenamiento[-2])
desviacion <- numcolwise(sd)(entrenamiento[-2])
media
desviacion

# Normaliza los dataframe
parametros <- rbind(media, desviacion)
entrenamiento_norm <- normalizar_dataframe(entrenamiento[-2], parametros)
test_norm <- normalizar_dataframe(test[-2], parametros)
summary(entrenamiento_norm)
summary(test_norm)

regresion <- lm(Y~ ., data=entrenamiento)
summary(regresion)

vector_predictivo <- predict.lm(regresion, newdata=data)
error_cuadratico_medio <- mean((data$Y - vector_predictivo)^2)
cat("Error cuadrático medio:", error_cuadratico_medio, "\n")
