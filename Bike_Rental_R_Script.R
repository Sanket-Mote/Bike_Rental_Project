
#clearing environment
rm(list = ls())

#setting working directory
setwd("D:/Learning/Project_1/BikeRental")

#get working directory
getwd()

#importing data
df_day = read.csv("day.csv", header = T, na.strings = c("", " ", "NA"))

#since instant is just index number deleting it from the data
df_day$instant = NULL

#importing all the required libraries
x = c("ggplot2","corrgram","DMWR","caret","randomForest","unbalanced","C50","dummies","e1071","Information",
      "MASS","rpart","gbm","ROSE","sampling","DataCombine","inTrees")

#installing all the reuired libraries
lapply(x, require, character.only = TRUE)

#installing unavailable packages
install.packages(c("caret","DMwR","C50","sampling","inTrees"))

library(caret) #got error
#install.packages("rlang")
#install.packages("rlang","recipes")
library(DMwR)
library(C50) #got error
library(sampling)
library(inTrees)
library(corrgram)


install.packages(c("rlang","dplyr","plyr","reshape","ggplot2","data.table","GGally"))

library(dplyr)
library(reshape)
library(ggplot2)
library(data.table)
library(GGally)
library(DataCombine)
library(rpart)
library(MASS)
library(randomForest)
library(usdm)
library(VIF)

#getting summary of the data
summary(df_day)

#getting structure of the data
str(df_day)

#we can see that season, yr, mnth, holiday, weekday, workingday, weathersit are categorical variables
#therefore changing data types from int to factor

#Converting required Data Types

df_day$season = as.factor(df_day$season)
df_day$yr = as.factor(df_day$yr)
df_day$mnth = as.factor(df_day$mnth)
df_day$holiday = as.factor(df_day$holiday)
df_day$weekday = as.factor(df_day$weekday)
df_day$workingday = as.factor(df_day$workingday)
df_day$weathersit = as.factor(df_day$weathersit)
df_day$dteday=as.Date(df_day$dteday,format="%Y-%m-%d")

#creating a backup copy
df_backup = df_day

#updated structure of the dataset after changing required datatypes.
str(df_day)

# Analyze variables  by visualize

# function to create univariate distribution of numeric  variables
univariate_numeric <- function(num_x) {
  ggplot(df_day)+
    geom_histogram(aes(x=num_x,y=..density..),
                   fill= "blue")+
    geom_density(aes(x=num_x,y=..density..))
}

# analyze the distribution of  target variable 'cnt'
univariate_numeric(df_day$cnt)

# analyse the distrubution of  independence variable 'temp'
univariate_numeric(df_day$temp)

# analyse the distrubution of  independence variable 'atemp'
univariate_numeric(df_day$atemp)

# analyse the distrubution of  independence variable 'hum'
univariate_numeric(df_day$hum)

# analyse the distrubution of  independence variable 'windspeed'
univariate_numeric(df_day$windspeed)

# analyse the distrubution of  independence variable 'casual'
univariate_numeric(df_day$casual)

# analyse the distrubution of  independence variable 'registered'
univariate_numeric(df_day$registered)

## MISSING VALUE ANALYSIS ##

#Checking for missing values in dataset
missing_val  =  data.frame(apply(df_day,2,function(x){sum(is.na(x))}))

#converting row names ito columns
missing_val$columns=row.names(missing_val)
row.names(missing_val) = NULL

#Rename the variable name
names(missing_val)[1] = "Missing_Percent"

#calculating percentage
missing_val$Missing_Percent = (missing_val$Missing_Percent / nrow(df_day)) * 100

#Arranging in descending order
missing_val = missing_val[order(-missing_val$Missing_Percent),]

#Rearranging column names
missing_val = missing_val[,c(2,1)]

#As we can see our data does not have any missing values so we can proceed to check for Outliers

## OUTLIER ANALYSIS ##

#considering only numeric variables

numeric_index = sapply(df_day, is.numeric)

numeric_index

numeric_data = df_day[, numeric_index]

cnames = colnames(numeric_data)

cnames 

for( i in 1:length(cnames))
{
  assign(paste0("gn",i), ggplot(aes_string(y =(cnames[i]), x = "cnt"),data = subset(df_day)) +
           stat_boxplot(geom = "errorbar", width = 0.5) +
           geom_boxplot(outlier.colour = "red", fill = "grey", outlier.shape = 18, 
                        outlier.size = 1, notch = FALSE) +
           theme(legend.position = "bottom") + 
           labs(y = cnames[i], x = "cnt") +
           ggtitle(paste("Boxplot of cnt for ", cnames[i])))
}

#Plotting the graphs

gridExtra::grid.arrange(gn1, gn2, gn3, ncol = 3)
#We can see outliers in hum

gridExtra::grid.arrange(gn4, gn5, gn6, ncol = 3)
#We can see outliers in windspeed and casual

# We have to remove outliers from hum, windspeed and casual

for (i in cnames){
  print(i)
  val = df_day[,i][df_day[,i] %in% boxplot.stats(df_day[,i]) $out]
  df_day = df_day[which(!df_day[,i] %in% val),]
}

#After removing outliers we are left with 676 observations

## FEATURE SELECTION ##

corrgram(df_day[,numeric_index], order = F, upper.panel = panel.pie, text.panel = panel.txt,
         main = "Correlation Plot")

#from correlation plot we can see that independent variables temp and atemp has similar data so we delete atemp

df_day_sel_feature = subset(df_day, select = -c(atemp,casual,registered))

## FEATURE SCALING ##

#Normality check 

qqnorm(df_day$temp)

qqnorm(df_day$hum)

qqnorm(df_day$windspeed)

qqnorm(df_day$casual)

qqnorm(df_day$registered)

qqnorm(df_day$cnt)

#As seen in normality plots we can see normalization is required in hum, windspeed and casual variables

#creating one more backup copy just for safety
df_backup = df_day

#Normalization

norm_names = c('hum', 'windspeed')

for (i in norm_names){
  print(i)
  df_day_sel_feature[,i] = (df_day_sel_feature[,i] - min(df_day_sel_feature[,i])) / 
    (max(df_day_sel_feature[,i] - min(df_day_sel_feature[,i])))  
}

hum_max = max(df_day_sel_feature[,'hum'])
hum_min = min(df_day_sel_feature[,'hum'])

windspeed_max = max(df_day_sel_feature[,'windspeed'])
windspeed_min = min(df_day_sel_feature[,'windspeed'])

#verify range after normalization
print(hum_max)
print(hum_min)
print(windspeed_max)
print(windspeed_min)

#Now we have normalized data so we can proceed with model developments

#Rechecking if outliers present again to be sure

str(df_day_sel_feature)
# 652 observations after removing outliers from Casual

## MODEL DEVELOPMENT ##

#Dividing data into train and test

train_index = sample(1:nrow(df_day_sel_feature), 0.8 * nrow(df_day_sel_feature))

train = df_day_sel_feature[train_index,]

test = df_day_sel_feature[-train_index,]

#Regression using Decision Tree
Dt_fit = rpart(cnt~., data = train, method = "anova", parms = 'gini')

#Predict for new test cases
Dt_predictions = predict(Dt_fit, test[,-12])

#Calculate MAPE
mape = function(y, yhat){
  mean(abs((y-yhat)/y)) * 100
}

mape(test[,12], Dt_predictions)
# 23.37

#Calculate RMSE

RMSE = function(y, yhat){
  diff = y - yhat
  diff_sqrt = sqrt(mean(diff ** 2))
  return(diff_sqrt)
}

RMSE(test[,12], Dt_predictions)
# 436.411

## RANDOM FOREST ##

#Implementing Random Forest algorithm
RF_model = randomForest(cnt~., data = train)

#Prediting data
RF_predictions = predict(RF_model, test[,-12])

mape(test[,12], RF_predictions)
# 18.74

RMSE(test[,12], RF_predictions)
# 612.64

# Round 2

#Adding few parameters to RF
RF_model_v2 = randomForest(cnt~., data = train, mtry = 5, ntree = 500, nodesize = 5, importance = TRUE)

RF_predictions_v2 = predict(RF_model_v2, test[,-12])

mape(test[,12], RF_predictions_v2)
# 17.32

RMSE(test[,12], RF_predictions_v2)
# 580.56

# Round 3

#Adding few parameters to RF
RF_model_v3 = randomForest(cnt~., data = train, mtry = 10, ntree = 700, nodesize = 10, importance = TRUE)

RF_predictions_v3 = predict(RF_model_v3, test[,-12])

mape(test[,12], RF_predictions_v3)
# 17.40

RMSE(test[,12], RF_predictions_v3)
# 594.43

## LINEAR REGRESSION ##

vif(df_day_sel_feature[,9:11])

#running regression model
LM_model = lm(cnt~., data = train)

#summary of the model
summary(LM_model)

#Prediction of LR
LM_prediction = predict(LM_model, test[,1:11])

mape(test[,12], LM_prediction)
# 14.11

RMSE(test[,12], LM_prediction)
# 605.26

### Writing output file for predicted models in respective files

#Linear Regression Output
LM_prediction_df = data.frame(LM_prediction)

row.names(LM_prediction_df) <- NULL

write.csv(LM_prediction_df, "LR_Output_R.csv")

#Decision Tree Output
Dt_predictions_df = data.frame(Dt_predictions)

row.names(Dt_predictions_df) <- NULL

write.csv(Dt_predictions_df, "DT_Output_R.csv")

#Random Forest Output
RF_predictions_df = data.frame(RF_predictions_v4)

row.names(RF_predictions_df) <- NULL

write.csv(RF_predictions_df, "RF_Output_R.csv")

## CONCLUSION ##

##### After seeing the results of all the 3 models we found that Linear Regression is the       #####
#     best model to predict the data in our case as compared to Decision Tree and Random Forest     #
#     We got an accuracy of around more than 85.89% using Linear Regression                         #
