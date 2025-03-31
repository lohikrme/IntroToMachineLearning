# 27.3.2025
# KMeans Klusterointi
# ohjaamaton oppiminen

options(digits=10)

library(plyr)
library(ggplot2)
library(cluster)
library(grid)
library(gridExtra)

pisteet = as.data.frame(read.csv("Data/pääsykoepisteet.csv"))
summary(pisteet)

# kaikki rivit, sarakkeet 2-4
koepisteet = pisteet[ ,2:4]


# valitaan tunnusluvuksi wss = withing sum of squares
# tämän avulla voidaan evaluoida klustereiden määrää
# jos k+1 klusteria ei juurikaan vähennä sen wss-tunnusluvun arvoa,
# voi olla, että k+1 klusteria on parempi määrä
# alustetaan wss arvoksi vektori jossa 15 nollaa
# sitten käydään loopilla läpi mitä tarkottaisi 1-15 klusteria wss arvoina
wss = numeric(15)
for (k in 1:15) wss[k]= sum(kmeans(koepisteet, centers = k, nstart = 25)$withinss)

print(wss)
plot(1:15, wss, type= "b", xlab="Klustereiden määrä", ylab="wss arvo")
# elbow 3 tai 4 voisi olla sopiva klustereiden määrä plotin perusteella

# Nyt tiedetään sopiva klustereiden määrä, seuraavaksi muodostetaan kmeans malli
malli = kmeans(koepisteet, 3, nstart=25)
summary(malli)

# Jotta päästään paremmin tutkimaan klustereita, on hyvä visualisoida lopputulosta
# käytetään factor tietotyyppiä, koska klusterit ovat tasaarvoisia luokkia keskenään
koepisteet$klusteri = factor(malli$cluster)
centers = as.data.frame(malli$centers)

g1 = ggplot(data = koepisteet, aes(x = English, y = Matematiikka, color = klusteri)) +
  geom_point() +
  theme(legend.position = "right") +
  geom_point(data = centers, aes(x = English, y = Matematiikka, color = as.factor(c(1,2,3))),
             size = 10, alpha = .3)
print(g1)

g2 = ggplot(data = koepisteet, aes(x = Fysiikka, y = Matematiikka, color = klusteri)) +
  geom_point() +
  theme(legend.position = "right") +
  geom_point(data = centers, aes(x = Fysiikka, y = Matematiikka, color = as.factor(c(1,2,3))),
             size = 10, alpha = .3)
print(g2)

# TODO: make 3d model using https://r-graph-gallery.com/