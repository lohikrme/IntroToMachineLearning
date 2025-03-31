# 27.3.2025
# Assosiaatioanalyysi
# Esimerkki kirjasta: Machine Learning with R, Brett Lantz, Packt Publishing

library(arules)
# not use read csv but read transactions
# a bit comparable to time series that has own data type
groceries = read.transactions("Data/groceries.csv", sep=",")
class(groceries)
summary(groceries)

# katsotaan 3 ensimmäistä kuittia
inspect(groceries[1:5])

# all rows, 1-10 columns
itemFrequency(groceries[ ,1:10])
itemFrequencyPlot(groceries, support = 0.1)
itemFrequencyPlot(groceries, topN = 20)
# värikäs vaihtoehto
library(RColorBrewer)
itemFrequencyPlot(groceries,topN=20,col=brewer.pal(8,'Pastel2'),
                  main='Relative Item Frequency Plot',
                  type="relative",ylab="Item Frequency (Relative)")

# testaa ensin pelkkä apriori, mutta se tarvitsee parametrejä löytääkseen sääntöjä
apriori(groceries)
# seuraavat parametrit tekevät seuraavaa: 
groceryrules = apriori(groceries, parameter = list(
  support=0.006, 
  confidence = 0.25, minlen = 2))
print(groceryrules)
summary(groceryrules)

# lhs = left hand side, rhs = right hand side
inspect(groceryrules[300:400])
inspect(groceryrules[1:5])
inspect(sort(groceryrules, by = "support")[400:405])
inspect(sort(groceryrules, by = "lift")[1:20])

# kuvitellaan että kiinnostaa nimenomaan marjat analyysissa
marjasaannot = subset(groceryrules, items %in% "berries")
summary(marjasaannot)
inspect(marjasaannot)

# ota löydetyt säännöt talteen csv-tiedostoon jatkokäsittelyä varten
write(marjasaannot, file="Data/marjasaannot.csv", sep = ",", quote = T, row.names = F)

# kananttaa myös R:ssä muuttaa dataframeksi, paljon helpompi käsitellä
marjasaannot_df = as(marjasaannot, "data.frame")
