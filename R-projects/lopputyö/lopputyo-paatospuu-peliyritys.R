# Koneoppiminen, pelifirman päätöspuumalli
# Machine learning, game company decision tree model and data analysis
# 1.4.2025

# The assingment is to find out, what kind of players 
# are the most likely to buy expensive products (price > 5 euros),
# and to make 3 suggestions to a marketing team, how to use these finds

options(digits=10)

#install.packages("caret") 
#install.packages("corrplot") 
#install.packages("rattle")
# needed for selecting training and testing data
library(caret) 
# needed for more complex decision tree visualisations
library(ggplot2) 
# needed to read excel and csv files
library(readxl) 
# needed to visualize correlations simply
library(corrplot) 
# needed to draw decision tree
library(rattle)

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

# remove unneeded sessionId column
df = subset(df, select = -sessionId)

# find out if there is a correlation between bought item count and price
correlation_item_price = cor(df[, c("bought_item_count", "avrg_price")])
correlation_item_price
plot(df$bought_item_count, df$avrg_price)
hist(df$bought_item_count)
hist(df$avrg_price)

# drop rows with no bought items, and see again if there is correlation
df = subset(df, bought_item_count > 0)
correlation_item_price = cor(df[, c("bought_item_count", "avrg_price")])
correlation_item_price
plot(
  x = df$bought_item_count, 
  y = df$avrg_price, 
  type="p", 
  xlab="bought item count", 
  ylab="average price",
  col="darkgreen",
  lwd=2
  )

# because no correlation, remove bought_item_count from df
df = subset(df, select = -bought_item_count)


# next step is to examine how well numeric variables correlate each other
correlations = cor(df[, c("clicks_inside_game", "hits_in_enemies", "avrg_price" )])
# correlation matrix
correlations
# correlation graph
corrplot(correlations, method="circle")
# because correlation between clicks and hits is close to 100%, 
# draw a linear regression plot of them
lm_clicks_shots = lm(hits_in_enemies ~ clicks_inside_game, data = df)
plot(
  x=df$clicks_inside_game, 
  y=df$hits_in_enemies, 
  main = "clicks vs hits", 
  xlab = "clicks", 
  ylab = "hits",
  col="lightgreen",
  lwd=2)
abline(lm_clicks_shots, col="#34f", lwd = 5)

constant = paste("vakiotermi:", sprintf("%.3f", coef(lm_clicks_shots)[1]))
regression_coef = paste("regressiokerroin:", sprintf("%.3f", coef(lm_clicks_shots)[2]))
coef_of_determination = paste("selitysaste:", sprintf("%.4f", summary(lm_clicks_shots)$r.squared))

constant
regression_coef
coef_of_determination

# as the graph and numbers shows, these 2 variables have almost perfect correlation
# therefore, we can drop out one of them to avoid multicollinearity
df = subset(df, select = -clicks_inside_game)

# drop userId column, and replace avrg_price with squanderer,
# which is defined as a person in moment, who buys items with
# over 5 euros average price
df = subset(df, select = -userId)
df$squanderer = ifelse(df$avrg_price >5, T, F)
df = subset(df, select = -avrg_price)

# as last thing, make sure datas are proper type for analysis
# teamRank is meant to be ordinal data with order
# deviceType 
class(df$teamRank)
class(df$deviceType)
class(df$hits_in_enemies)
class(df$squanderer)

df$squanderer = as.factor(df$squanderer)
df$deviceType = as.factor(df$deviceType)
df$teamRank = factor(df$teamRank, levels=1:7, ordered=TRUE)

class(df$squanderer)
class(df$deviceType)
class(df$teamRank)


### step 2: split data into training data 70% and testing data 30%, seed 123
### predicted variable is squanderer, and predictors are other variables
### also create the decision tree
set.seed(123)
# list=F means datapartition is returned as vector
intraindex = caret::createDataPartition(y=df$squanderer, p=0.7, list=FALSE)
intraindex
length(intraindex)
length(df$squanderer)

# split data into training 70% and testing 30% datasets
training = df[intraindex, ] # 989 rows
testing = df[-intraindex, ] # 422 rows
dim(training)
dim(testing)


# create the decision tree model
tree_model = train(
  squanderer ~ .,
  method="rpart", 
  data=training)

# visualize tree model
rattle::fancyRpartPlot(
  tree_model$finalModel,
  main="Decision Tree - will player be a squanderer?")

# Because the tree does not look as expected, i will create bar graphs to see further
# how different variables have distributed
ggplot(training, aes(x = deviceType)) +
  geom_bar(fill = "lightgreen") +
  labs(title = "Distribution of Device Type", x = "Device Type", y = "Count") +
  theme_minimal()

ggplot(training, aes(x = teamRank)) +
  geom_bar(fill = "lightgreen") +
  labs(title = "Distribution of TeamRank", x = "Team Rank", y = "Count") +
  theme_minimal()

ggplot(training, aes(x = hits_in_enemies)) +
  geom_bar(fill = "lightgreen") +
  labs(title = "Distribution of Hits In Enemies", x = "Hits In Enemies", y = "Count") +
  theme_minimal()

