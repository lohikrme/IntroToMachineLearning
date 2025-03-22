# 13.3.2025
# Päätöspuu esimerkki
# Käyttäkää tätä esimerkkiä R-kurssityössä

# paina f1 jos haluat tutkia jotakin komentoa tarkemmin

options(digits = 10)

install.packages("caret")
library(caret)
library(ggplot2)

data("iris")
names(iris) # petal = terälehti, sepal = verholehti, iris = kurjenmiekka
table(iris$Species)
summary(iris)

# koska data on järjestyksessä, jaetaan data
# training ja testing data setteihin satunnaistetusti
# training käytetään sovittamiseen, testiä käytetään yleistämiseen
# (tällä kertaa ei käytetä validation: sovittamisen arviointia)

# luo ensin satunnaislukugeneraattori
# sitten otetaan 70% training data settiing ja loput test data settiin
set.seed(1111)
intraindex = caret::createDataPartition(y = iris$Species, p=0.7, list= FALSE)
intraindex

# example how to print last 3 specimen
(-length(iris$Species)+3)
iris[-1:-147,]
iris[-1:(-length(iris$Species)+3), ]

# training data is first 105, testing data last 45 rows
training = iris[intraindex, ] # 105 havaintoriviä
testing = iris[-intraindex, ] # 45 havaintoriviä
dim(training)
dim(testing)

qplot(Petal.Width, Petal.Length, colour = Species, data = training)

# tehdään päätöspuumalli
# Species on ennustettava muuttuja, ja matomerkki piste
# tarkoittaa sitä, että kaikkia muita muuttujia käytetään ennustukseen
malli = train(Species ~., method="rpart", data = training)
malli2 = train(Species ~ Petal.Width + Petal.Length, method="rpart", data=training)

install.packages("rattle")
library(rattle)
fancyRpartPlot(malli$finalModel)
fancyRpartPlot(malli2$finalModel)

# kokeillaan minkälaisia tunnuslukuja saadaan aikaiseksi
# tehdään ennustus testing datasetistä
ennuste = predict(malli, newdata = testing)
ennuste2 = predict(malli2, newdata = testing)
# katsotaan virheettömyys (accurasy)
# consufionmatrixissa ennuste on arvot mitä odotetaan, testing$species on todelliset
confusionMatrix(ennuste, testing$Species)
confusionMatrix(ennuste2, testing$Species)

summary(malli$finalModel)