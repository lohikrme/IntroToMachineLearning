# 20.3.2025
# Logistic regression
# Unlike in linear regression, we predict a categoric variable

# Aineisto on muokattu Akin menetelmäblogi: https://tilastoapu.wordpress.com/2014/04/25/logistinen-regressio/

library(readxl)
df = data.frame(read_excel("./logistReg.xlsx"))

# olemme kiinnostuneet muuttujasta "Osto" (1: on ostettu 0: ei ole ostettu)
# Osto on selitettävä muuttuja
# Selittävinä muuttujina tulos, onkoNainen, onkoNaimisissa

ostoaikomus = glm(Osto ~ Tulot + OnkoNainen + OnkoNaimisissa, 
                  data = df, 
                  family = binomial(link = "logit"))

summary(ostoaikomus)
# intercept = vakiotermi, muut muuttujat kertoimia
# muistuttaa siis lineaarista regressiota

# lisää sarake "Yhtalo" dataframeen
df$Yhtalo = -12.033 + 0.0001674 * df$Tulot + 1.365 * df$OnkoNainen + 1.38 * df$OnkoNaimisissa

# muunna luvut luettavammaksi käyttäen akin menetelmäblogin kaavaa
# kaavassa e = neperin luku
# eli lisätään p-arvo omaksi sarakkeeksi dataan

# p = e Prob / (1 + e Prob)
# exp(x) = e^x
# vertaa sarakkeita Osto ja p, joka kertoo, millä todennäköisyydellä osto tapahtuu

df$p_prosentual = round(exp(df$Yhtalo) / (1 + exp(df$Yhtalo)) * 100, 2)
