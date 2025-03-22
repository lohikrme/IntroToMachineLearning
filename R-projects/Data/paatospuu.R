# 13.3.2025
# Päätöspuu esimerkki.
# Käyttäkää tätä esimerkkiä R-kurssityössä.

options(digits = 10)

library(caret)
library(ggplot2)

data("iris")
names(iris)   # petal = terälehti, sepal = verholehti
table(iris$Species)
summary(iris)


# Koska data on järjestyksessä, on jako datasetteihin tehtävä satunnaistetusti.
# Jaetaan data kahteen eri datasettiin: training (sovittamiseen) ja testing (yleistämiseen)
# (validation: sovittamisen arviointi)

set.seed(1234)
intrain <- createDataPartition(y = iris$Species, p = 0.7, list = FALSE)
training <- iris[intrain, ]  # 105 havaintoriviä
testing  <- iris[-intrain, ] # 45 havaintoriviä
dim(training)
dim(testing)

qplot(Petal.Width, Petal.Length, colour = Species, data = training)

# Tehdään päätöspuumalli
malli <- train(Species ~., method = "rpart", data = training)

library(rattle)
fancyRpartPlot(malli$finalModel)
malli

# Tehdään ennustus testing datasetillä
ennuste <- predict(malli, newdata = testing)
confusionMatrix(ennuste, testing$Species)

summary(malli$finalModel)
