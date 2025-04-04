# 3.4.2025

## Esimerkki on kirjasta: Machine Learning with R, Brett Lantz
# "Yksinkertainen neuroverkko" tarkoittaa kevyttä neuralnet-kirjaston avulla
# tehtäviä neuroverkkoratkaisuja
# Tuotantokäyttöön kannattaa käyttää keras-kirjastoa

# Esimerkissä tutkitaan mahdollisuutta ennustaa betonin lujuutta (strenght)
# Sen tekemiseen tarvittavien ainesosien avulla

### Step 1: Ladataan data, tutkitaan datan rakennetta ja valmistellaan data

betoni = read.csv("Data/concrete.csv")

str(betoni)  #superplastic means silica, coarseagg means small pebble rocks?
summary(betoni)  # Eri ainesosien arvot vaihtelevat nollasta yli tuhanteen


# Neuroverkko toimii parhaiten, kun data on skaalattu lähelle nollaa
# tyypillisesti käytetään jompaa kumpaa seuraavista keinoista:
#     1. standardisointi
#     2. normalisointi

# Normalisoinnissa arvot muutetaan siten, että ne ovat 0 ja 1 välissä
# Jos data noudattaa tasajakaumaa tai on epänormaalia,
# kannattaa tehdä normalisointi
# Muista, jos olet normalisoinut arvot, 
# niitä ei voi verrata alkuperäisiin arvoihin,
# silloin pitäisi tehdä "denormalisointi"

# Standardoinnissa arvot keskitetään keskiarvon "0" ympärille hajonnan avulla.
# Arvojen keskiarvo tulee siis saada nollaksi, ja hajonta nollan ympärille
# Jos data on normaalisti jakautunut (eli gaussin käyrän muotoinen)
# Silloin on järkevä käyttää R:N scale() - funktiota

# Koska meidän tutkimamme data on nyt varsin vaihtelevaa, 
# teemme funktion joka normalisoi datan
normalize = function(x){
  return ((x-min(x)) / (max(x)-min(x)))
}

# ja nyt applylla normalisoidaan koko data ja laitetaan data frameen
betoni_norm = as.data.frame(lapply(betoni, normalize))
summary(betoni_norm)

### Step 2: training ja testing data setit
# varmistetaan, että alkuperäinen data ei ole missään järjestyksessä
# meidän tapauksessamme, data ei ole järjestyksessä
# nyt kun ei ole järjestystä, voidaan vain ottaa rivejä alusta alkaen
betoni_train = betoni_norm[1:773, ] # noin 75%
betoni_test = betoni_norm[774:1030, ] # noin 25%

### Step 3: rakennetaan neuroverkko
# ANN neuroverkko, ei takaisinkytkentää tai monimutkaisuutta
# tehdään 1 piilotettu neuroni (= aktivaatiofunktio)
# aktivaatiofunktio määrittää, miten syötearvo lasketaan ulospäin
# aktivaatiofunktio mahdollistaa neuroverkon oppia
# niitä voi olla eri määrä tai eri kerroksissa
install.packages("neuralnet")
library(neuralnet)

set.seed(12345)
betoni_malli1 = neuralnet::neuralnet(formula = strength ~., data = betoni_train)
# visualisoidaan malli1 topologia
plot(betoni_malli1)
# kuvassa näkyy 2x vakiokerrointa
# sekä 8x painokerrointa (kullekin muuttujan arvolle)
# käytännössä msaadut tulokset muistuttavat hyvin paljon regressiota
# Error = 5.077438, Steps: 4882
# Error tarkoittaa SSE:tä, joka tarkoittaa Sum of Squared Error
# Eli todellisten arvojen ja ennustettujen arvojen erotusten neliöiden summa
# Mitataan sitä ,kuinka hyvin malli sopii dataan (yleensä regression yhteydessä)

### Step 4: arvioidaan malli1 soveltuvuus
# Lasketaan malli1:n avulla testing datan lujuudet
str(betoni_test)
malli1_tulokset = neuralnet::compute(betoni_malli1, betoni_test[1:8])
# Tämän jälkeen pääsemme vertaamaan ennustettuja arvoja todellisiin
# haetaan ennustetut lujuusarvot
ennustetut1_strength = malli1_tulokset$net.result

# Tutkitaan korrelaatioita oikeiden ja ennustettujen arvojen välillä (huom ovat normalisoituja)
cor(ennustetut1_strength, betoni_test$strength)
# Korrelaatio 0.8064656

# Tässä voisi käyttää myös MAE-arvoa, tämä vaatii kuitenkin, että normalisoidut
# arvot pitäisi kääntää alkuperäiseen skaalaan (denormalize)

### Step 5: Yritetään parannella mallia, lisätään neuroverkkoon neuroneita (=aktivaatiofunktioita)
# kokeillaan 5 neuronia
betoni_malli2 = neuralnet::neuralnet(
  formula = strength ~.,
  data = betoni_train,
  hidden = 5)

plot(betoni_malli2)
# Error 1.67, Steps 10376
malli2_tulokset = neuralnet::compute(betoni_malli2, betoni_test[1:8])
ennustetut2_strength = malli2_tulokset$net.result
cor(ennustetut2_strength, betoni_test$strength)
# Korrelaatio 0.93425

### Step 6: Yritetään vielä parannella mallia
# Lisätään tällä kertaa 1 kerros ja kustomoitu aktivaatiofunktio
softplus = function(x) {log(1+exp(x))}

set.seed(12345)
betoni_malli3 = neuralnet::neuralnet(
  formula=strength ~., 
  data = betoni_train, 
  hidden = c(5, 5),
  act.fct = softplus)

plot(betoni_malli3)
# Error 1.666068, Steps 88240
malli3_tulokset = neuralnet::compute(betoni_malli3, betoni_test[1:8])
ennustetut3_strength = malli3_tulokset$net.result
cor(ennustetut3_strength, betoni_test$strength)
# Korrelaatio 0.9348395


### Step 7: Koitetaan ilman aktivaatiofunktiota
set.seed(12345)
betoni_malli4 = neuralnet::neuralnet(
  formula=strength ~., 
  data = betoni_train, 
  hidden = c(5, 5))
plot(betoni_malli4)
# Error 1.26161, Steps 9322
malli4_tulokset = neuralnet::compute(betoni_malli4, betoni_test[1:8])
ennustetut4_strength = malli4_tulokset$net.result
cor(ennustetut4_strength, betoni_test$strength)
# Korrelaatio 0.9323314