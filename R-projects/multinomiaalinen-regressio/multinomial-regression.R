# 20.3.2025
# Multinomiaalinen regressio
# Selitettävä muuttuja voi saada useamman kuin  2 arvoa
# Vastaukset ovat todennäköisyyksiä

options(digits=10)

# W = win
# D = draw
# L = loss

library(readxl)
library(nnet) # here is multinom() function

# Seuraavana lauantaina peli Norwich - Blacburn.
# Yritämme ennustaa ottelun lopputulosta
# Näiden joukkoueiden edellisten pelien perusteella.

hometeam = data.frame(read_excel("./Data/Norwich.xlsx"))
guestteam = data.frame(read_excel("./Data/Blackburn.xlsx"))

# datasets mean next:
# Venue = is data's tittle team in Home or Away match
# Result = win of title team
# Rk = opponent ranking
# Pts = opponent points
# Opponent = opponent name

### Tehdään ensin ennuste lopputuloksesta kotijoukkoeen näkökulmasta
# valitse ensin "baseline" lopputulokselle
# relevel as factor tarkoittaa nyt sitä, että draw on ensimmäinen taso,
# sitten voitto, sitten tappio

hometeam$baseline = relevel(as.factor(hometeam$Result), ref= "D")
model_hometeam = multinom(Result ~ Venue + Rk + Pts, data = hometeam)
summary(model_hometeam)

# tehdään mallin avulla ennuste 
# in this data frame, Rk and Pts means Blackburn ranking and points just before match
saturday_homematch_Norwich = data.frame(Venue = "Home", Rk = 15, Pts = 45)
predict(model_hometeam, newdata = saturday_homematch_Norwich, "probs")

# model gave next results:
# Draw 0.140%, Loss 0.065%, Win 0.795%

### Nyt ennustetaan lopputulos vierasjoukkoeen näkökulmasta
# eli valitaan taas baseline, tehdään relevel
guestteam$baseline = relevel(as.factor(guestteam$Result), ref="D")
model_guestteam = multinom(Result ~ Venue + Rk + Pts, data = guestteam)

# in this data frame, Rk and Pts means Norwich ranking and points just before match
saturday_guestmatch_Blackburn = data.frame(Venue = "Away", Rk = 1, Pts = 82)
predict(model_guestteam, newdata = saturday_guestmatch_Blackburn, "probs")ema
