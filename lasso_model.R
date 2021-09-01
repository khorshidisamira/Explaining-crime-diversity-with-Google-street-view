#packages
#library(doMC)
#registerDoMC(cores = 4)
library(spgwr)
library(ggplot2)
library(ggpubr)
library(maptools)
library(plyr)
library(rgdal)
require(plyr)
require(Matrix)
library(spdep)
library(bigmemory)
#library(biganalytics)
#library(bigtabulate)
library(data.table)

# centering with 'scale()'
center_scale <- function(x) {
  scale(x, scale = FALSE)
}

#######################################DATA############################################
#load data
nodes_url = "la_crime_data/nodes/nodes.csv"
objects_url = "la_crime_data/pre_processed/reformed_for_lasso.csv"

crimes_url = "la_crime_data/pre_processed/census_violence.csv"
#crimes_url = "la_crime_data/pre_processed/census_property.csv"
#crimes_url = "la_crime_data/pre_processed/extracted_crime.csv"

nodes_df <- subset(read.csv(nodes_url), select=c('census', 'lat', 'lon'))
nodes_df <- unique( nodes_df[ , 1:3 ] )
attach(nodes_df)

objects_df <- subset(read.csv(objects_url))
objects_df <- objects_df[, !(colnames(objects_df) %in% c("X"))]
objects_df <- unique( objects_df[ , 1:421 ] )

crimes_df <- subset(read.csv(crimes_url), select=c('census', 'count'))
crimes_df <- unique( crimes_df[ , 1:2 ] )

names(crimes_df)[names(crimes_df) == "count"] <- "crimes_count"

data = join_all(list(nodes_df, objects_df, crimes_df), by = "census") 
dataset <- count(data, vars = colnames(data)) ##### ALL DATA####


for(i in 1:ncol(dataset)){
  dataset[is.na(dataset[,i]), i] <- mean(dataset[,i], na.rm = TRUE)
}

subset_dataset <- dataset[, !(colnames(dataset) %in% c("X", "census", "lat", "lon", "crimes_count", "freq"))]
# list rows of data that have missing values
subset_dataset[!complete.cases(subset_dataset),]

scaled_data <- data.frame(center_scale(subset_dataset))

columns_str = paste(colnames(scaled_data), collapse="+")
scaled_data$crimes_count<-dataset$crimes_count

attach(scaled_data)

#######################################DATA############################################

library(glmnet)
#library(MASS)
#attach(Boston)
#library(plotmo)

set.seed(489)
grid <- 10^seq(10,-2,length=100)

#we have chosen to implement the function over a grid of values ranging from ?? = 1010 to ?? = 10???2, 
#essentially covering the full range of scenarios from the null model containing only the intercept, to the least squares fit.

#head(Boston)
#head(scaled_data)

#dim(Boston)
#dim(scaled_data)
#Boston <- na.omit(Boston) 
scaled_data <- na.omit(scaled_data) 
#x <- model.matrix(medv~.,Boston)
x <- model.matrix(crimes_count~.,scaled_data)
#str(x)

#y <-Boston$medv
y <- scaled_data$crimes_count
#str(y)

train <- sample(1:nrow(x), nrow(x)*.7)
test <- (-train)
y.test <- y[test]

#OLS
crimelm <- lm(crimes_count~., data = scaled_data)
coef(crimelm)

#ridge
ridge.mod <- glmnet(x, y, alpha = 0, lambda = grid)
#predict(ridge.mod, s = 0, exact = T, type = 'coefficients')[1:6,]

#crimelm <- lm(crimes_count~., data = scaled_data, subset = train)
#ridge.mod <- glmnet(x[train,], y[train], alpha = 0, lambda = grid)
#find the best lambda from our list via cross-validation
#cv.out <- cv.glmnet(x[train,], y[train], alpha = 0)
cv.out <- cv.glmnet(x, y, alpha = 0)

bestlam <- cv.out$lambda.min

#make predictions 
#ridge.pred <- predict(ridge.mod, s = bestlam, newx = x[test,])
#s.pred <- predict(crimelm, newdata = scaled_data[test,])
#check MSE
#mean((s.pred-ytest)^2)

#a look at the coefficients
#out = glmnet(x[train,],y[train],alpha = 0)
ridge.coef <- predict(ridge.mod, type = "coefficients", s = bestlam)#[1:6,]

#lasso.mod <- glmnet(x[train,], y[train], alpha = 1, lambda = grid)
lasso.mod <- glmnet(x, y, alpha = 1, lambda = grid)
#find the best lambda from our list via cross-validation
#cv.out <- cv.glmnet(x[train,], y[train], alpha = 1)

#lasso.pred <- predict(lasso.mod, s = bestlam, newx = x[test,])
#mean((lasso.pred-ytest)^2)
lasso.coef <- predict(lasso.mod, type = 'coefficients', s = bestlam)#[1:6,]


library(MASS)
write.matrix(lasso.coef, file = "la_crime_data/new_data/Lasso/coef_lasso_mod_violence.txt")
lasso_coef_df <- as.data.frame(as.matrix(lasso.coef))

#write.matrix(ridge.coef, file = "la_crime_data/new_data/Lasso/coef_ridge_mod_violence.csv")
ridge_coef_df <- as.data.frame(as.matrix(ridge.coef))


#write.csv(lasso_coef_df, file = "la_crime_data/new_data/Lasso/coef_lasso_mod_violence.csv")
#write.csv(ridge_coef_df, file = "la_crime_data/new_data/Lasso/coef_ridge_mod_violence.csv")
#write.csv(lasso_coef_df, file = "la_crime_data/new_data/Lasso/coef_lasso_mod_property.csv")
#write.csv(ridge_coef_df, file = "la_crime_data/new_data/Lasso/coef_ridge_mod_property.csv")
#write.csv(lasso_coef_df, file = "la_crime_data/new_data/Lasso/coef_lasso_mod_all.csv")
#write.csv(ridge_coef_df, file = "la_crime_data/new_data/Lasso/coef_ridge_mod_all.csv")
