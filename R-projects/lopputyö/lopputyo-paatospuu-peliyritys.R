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
#install.packages("dplyr)
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
# rpart needed for visualization tree model
library(rpart)
library(rpart.plot)
library(dplyr)

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# STEP 1: READ DATA AND FILTER USELESS DATA
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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

# make sure no missing values
missing_values <- sapply(df, function(x) sum(is.na(x)))
missing_values

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
df = subset(df, select = -userId)


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# STEP 2: MAKE DATA INTO SUITABLE FORM FOR MODEL
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


# check out unique values
unique(df$teamRank)
unique(df$deviceType) 
unique(df$hits_in_enemies) 
unique(df$avrg_price) 

# check out data types
class(df$teamRank)
class(df$deviceType)
class(df$hits_in_enemies)
class(df$avrg_price)

# REPLACE average price with categorical values
# and factorize data as needed
    #df$squanderer = ifelse(df$avrg_price >5, T, F)
df$squanderer = ifelse(df$avrg_price >5, "squanderer", "cheap")
df = subset(df, select = -avrg_price)
df$squanderer = as.factor(df$squanderer)
df$deviceType = as.factor(df$deviceType)
df$teamRank = factor(df$teamRank, levels=1:7, ordered=TRUE)

# confirm data is in suitable form
class(df$teamRank)
class(df$deviceType)
class(df$hits_in_enemies)
class(df$squanderer)

# find out device type distribution
ggplot(df, aes(x= deviceType)) +
  geom_bar(fill="lightgreen") +
  theme_minimal()

### create a df2, with one hot encoding device type
df2 = df
# add replace squanderer with binary version
df2$squanderer_binary = ifelse(df2$squanderer == 'squanderer', 1, 0)
df2 = subset(df2, select = -squanderer)
names(df2)[names(df2) == "squanderer_binary"] = "squanderer"
# one hot encode the values of device type and replace original deviceType col
deviceType_encoded <- model.matrix(~ deviceType - 1, data = df)
df2 = cbind(df2, deviceType_encoded)
df2 = subset(df2, select=-deviceType)
#reorder df2
df2 = df2[, c("teamRank", 
              "hits_in_enemies", 
              "deviceTypedesktop", 
              "deviceTypelaptop",
              "deviceTypemobile",
              "deviceTypeother_device",
              "deviceTypepeliluola",
              "squanderer")]
# rename one hot encoded columns
names(df2)[names(df2) == "deviceTypedesktop"] = "pc"
names(df2)[names(df2) == "deviceTypelaptop"] = "laptop"
names(df2)[names(df2) == "deviceTypemobile"] = "mobile"
names(df2)[names(df2) == "deviceTypeother_device"] = "other"
names(df2)[names(df2) == "deviceTypepeliluola"] = "peliluola"

# use logistic regression to find out
# whether teamRank, deviceType or hits_in_enemy are collerated to squanderer:
log_reg = glm(squanderer ~., data = df2[, -1], family=binomial)
summary(log_reg)

# make a new dataframe, where are fewer categories
# join laptop and desktop together, and peliluola and other device togehter
df3 = df
df3 <- df3 %>%
  mutate(deviceType = case_when(
    deviceType == "mobile" ~ "mobile",
    deviceType %in% c("desktop", "laptop") ~ "pc",
    deviceType %in% c("peliluola", "other_device") ~ "other",
    TRUE ~ deviceType
))
unique(df3$deviceType)

class(df3$squanderer)
class(df3$deviceType)
class(df3$teamRank)

# create one hot encoding matrix manually
deviceType_encoded <- model.matrix(~ deviceType - 1, data = df3)
df3 = cbind(df, deviceType_encoded)
df3 = subset(df3, select = -deviceType)
names(df3)[names(df3) == "deviceTypepc"] = "pc"
names(df3)[names(df3) == "deviceTypemobile"] = "mobile"
names(df3)[names(df3) == "other"] = "otherDevice"

df3 = df3[, c("teamRank", 
              "hits_in_enemies", 
              "pc", 
              "mobile",
              "deviceTypeother",
              "squanderer")]
df3$squanderer = ifelse(df3$squanderer == "squanderer", 1, 0)

log_reg2 = glm(squanderer ~., data = df3[, -1], family=binomial)
summary(log_reg2)

# because logistic regression still not as expected, 
# therefore, find out all the rows with "peliluola"
df_peliluola = data[data$deviceType=="peliluola", ]
df_peliluola = df_peliluola[df_peliluola$bought_item_count > 0, ]
summary(df_peliluola)

# filter all rows where deviceType == "peliluola"
df4 = df
df4 = df4[df4$deviceType != "peliluola", ]
unique(df4$deviceType)
df4$deviceType = as.factor(df4$deviceType)
unique(df4$deviceType)
sum(df4$deviceType == "peliluola")
df4$deviceType = droplevels(df4$deviceType)
unique(df4$deviceType)

# define "squanderer as the positive class for the tree model:
df4$squanderer = relevel(as.factor(df4$squanderer), ref = "squanderer")
class(df4$squanderer)


# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# TRAIN THE MODEL
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

### step 2: split data into training data 70% and testing data 30%, seed 123
### predicted variable is squanderer, and predictors are other variables
### also create the decision tree
set.seed(123)
# list=F means datapartition is returned as vector
intraindex = caret::createDataPartition(y=df4$squanderer, p=0.7, list=FALSE)
intraindex
length(intraindex)
length(df4$squanderer)

# split data into training 70% and testing 30% datasets
training = df4[intraindex, ] 
testing = df4[-intraindex, ] 
dim(training)
dim(testing)

# create the decision tree model
tree_model = caret::train(
  squanderer ~ .,
  method="rpart", 
  data=training)

# visualize tree model
rattle::fancyRpartPlot(
  tree_model$finalModel,
  main="Decision Tree - will player be a squanderer?")

# Visualisoi päätöspuumalli
rpart.plot(
  tree_model$finalModel,
  main = "Decision Tree - will player be a squanderer?",
  type = 5,  
  extra = 108,
  shadow.col = "darkgrey"
)

# give test data to predict function
# predict funtion wont use other columns than those
# it was trained to use previously
# therefore, it is ok testing data contains column "squanderer"
ennuste = predict(tree_model, newdata = testing)
confusionMatrix(ennuste, as.factor(testing$squanderer))


# in the end i want to run a khii square test to see,
# if there is any correlation between teamRank and squanderer
head(df4)
df5 = df4
table_data = table(df5$teamRank, df5$squanderer)
chi_square_test = chisq.test(table_data)
print(chi_square_test)

unique(df5$teamRank)
count(df5[df5$teamRank == 1, ])
count(df5[df5$teamRank == 2, ])
count(df5[df5$teamRank == 3, ])
count(df5[df5$teamRank == 4, ])
count(df5[df5$teamRank == 5, ])
count(df5[df5$teamRank == 6, ])
count(df5[df5$teamRank == 7, ])

# there was correlation in khii square test,
# therefore run logistic model considering only different team ranks
# make first team ranks dummy-variables with contr.treatment, '
# so it is easier to interpret e.g logistic model summary
contrasts(df5$teamRank) = contr.treatment(7)
logistic_model3 = glm(squanderer ~ teamRank, data = df5, family = binomial)
summary(logistic_model3)


