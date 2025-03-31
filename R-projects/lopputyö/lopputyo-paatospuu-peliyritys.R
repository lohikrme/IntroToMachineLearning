# Koneoppiminen, pelifirman päätöspuumalli
# Machine learning, game company decision tree model and data analysis
# 30.3.2025

# The assingment is to find out, what kind of players 
# are the most likely to buy expensive products (price > 5 euros),
# and to make 3 suggestions to a marketing team, how to use these finds

options(digits=10)

#install.packages("caret") 
#install.packages("corrplot") 
#install.packages("dplyr") 
# needed for selecting training and testing data
library(caret) 
# needed for more complex decision tree visualisations
library(ggplot2) 
# needed to read excel and csv files
library(readxl) 
# needed to visualize correlations simply
library(corrplot) 
# needed to select only unique user ids effectively
library(dplyr) 

### step 1: read data from csv and filter out useless data
### split players to those who buy expensive (price > 5 euros) or cheap items

# read and rename data
data = read.csv("Data/peli_data.csv")
names(data) = c(
  "userId", 
  "sessionId", 
  "teamRank", 
  "deviceType", 
  "clicks_inside_game", 
  "hits_in_enemies", 
  "bought_item_count", 
  "avrg_price")
summary(data)

# save original data into a new df
df = subset(data)

# find out if there is a correlation between bought item count and price
correlation_item_price = cor(df[, c("bought_item_count", "avrg_price")])
correlation_item_price
plot(df$bought_item_count, data$avrg_price)

# as the plot shows, there is no linear correlation
# it seems to be normally distributed that avrg person buys 2-4, leaning towards 4
# therefore, i can drop the item_count variable
df = subset(df, select = -bought_item_count)

# sessionId also seems to be unimportant based on simple observation of df
df = subset(df, select = -sessionId)


# next step is to examine how well numeric variables correlate each other
correlations = cor(df[, c("teamRank", "clicks_inside_game", "hits_in_enemies", "avrg_price" )])
# correlation matrix
correlations
# correlation graph
corrplot(correlations, method="circle")
# because correlation between clicks and hits is close to 100%, 
# draw a linear regression plot of them
lm_clicks_shots = lm(hits_in_enemies ~ clicks_inside_game, data = df)
plot(df$clicks_inside_game, df$hits_in_enemies, main = "clicks vs hits", xlab = "clicks", ylab = "hits")
abline(lm_clicks_shots, col="darkgreen", lwd = 5)
# as the graph shows, these 2 variables have almost perfect correlation
# therefore, we can drop out one of them
df = subset(df, select = -clicks_inside_game)
# now make another correlation analysis
correlations = cor(df[, c("teamRank", "hits_in_enemies", "avrg_price" )])
# correlation matrix
correlations
# correlation graph
corrplot(correlations, method="circle")
# there seems to be moderate correlation between avrg price and teamRank
# make a plot out of it
plot(df$avrg_price, df$teamRank)
# the plots shows that the correlation is not following any specific pattern

# one last correlation to check for is correlation between same user_id and price
# but because userId is nominal (not numeric data), i have difficulties to
# make any kind of meaningful statistical findings based on userId
# therefore, i will simply remove the userID column
# i checked manually that some users have e.g 7 rows, some just 1
# but it should not cause an issue for the analysis
# i did find for example user id 1369, who has 
# teamRank c(4,5,6), deviceType mobile, hits c(9,31,31) and avrg price c(0,0,10)
# therefore, based on manual observations, user have variety within themselftoo
# it could for example mean that higher rank of team encourages to buy more expensive
# therefore, i will just delete the column userId and observe how other variables
df = subset(df, select = -userId)



# step 2: split data into training data 70% and testing data 30%
# i will use seed 123 as help. i will also make sure
# i get about same relationship spenders and cheap customers to both
set.seed(123)
training_data = 

