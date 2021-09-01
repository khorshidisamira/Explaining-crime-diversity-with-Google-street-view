#packages
library(spgwr)
library(ggplot2)
library(ggpubr)
library(maptools)
library(plyr)
library(rgdal)
require(plyr)
require(Matrix)
library(spdep)

crimes_df <- subset(read.csv("la_crime_data/pre_processed/reformed_for_lasso_sum_violence.csv"), select=c('census', 'sum'))
destination = "F:/Dropbox/Dr Mohler/Crime discovery/la_crime_data/result/results_all_crimes_plus_3_cats_crimes/objects_crime_regression/violence"

#crimes_df <- subset(read.csv("la_crime_data/pre_processed/reformed_for_lasso_sum_property.csv"), select=c('census', 'sum'))
#destination = "F:/Dropbox/Dr Mohler/Crime discovery/la_crime_data/result/results_all_crimes_plus_3_cats_crimes/objects_crime_regression/property"

#functions
plot_density<- function(data, variable_name, y_axis, x_label, filename){
  a <- ggplot(data, aes(x = variable_name)) +  labs(x=x_label)
  
  if(y_axis == "count"){
    
    # Change y axis to count instead of density
    a + geom_density(aes(y = ..count..), fill = "lightgray") +
      geom_vline(aes(xintercept = mean(variable_name)), 
                 linetype = "dashed", size = 0.6,
                 color = "#FC4E07")
    
  } else{
    # y axis scale = ..density.. (default behaviour)
    a + geom_density() +
      geom_vline(aes(xintercept = mean(variable_name)), 
                 linetype = "dashed", size = 0.6)
  }
  ggsave(file = paste(destination, paste(filename, "png", sep = "."), sep="/"))
}

plot_histogram<- function(data, variable_name, x_label, filename){
  a <- ggplot(data, aes(x = variable_name)) +  labs(x=x_label)
  
  a + geom_histogram(bins = 30, color = "black", fill = "gray") +
    geom_vline(aes(xintercept = mean(variable_name)), 
               linetype = "dashed", size = 0.6)
  
  ggsave(file = paste(destination, paste(filename, "png", sep = "."), sep="/"))
}

# centering with 'scale()'
center_scale <- function(x) {
  scale(x)
}

#load data
nodes_df <- subset(read.csv("la_crime_data/nodes/nodes.csv"), select=c('census', 'lat', 'lon'))
nodes_df <- unique( nodes_df[ , 1:3 ])
attach(nodes_df)

#crime data
crimes_df <- unique( crimes_df[ , 1:2] )
attach(crimes_df)

object_df <-  read.csv('la_crime_data/pre_processed/reformed_for_lasso.csv')

#pre process data
index_data <- merge(x = nodes_df, y = crimes_df, by = "census")
processed_data = object_df#join_all(list(object_df, household_df, language_df, race_df, income_df, population_df,land_df), by = "census")

#we need numeric type for scale function
processed_data[] <- lapply(processed_data, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x})

#####################################################################################
#index_data = index_data[which(population >50), ] 
#####################################################################################
indexed <- merge(x= processed_data, y = index_data, by = "census")
#data <- merge(x= indexed, y = raw_data, by = "census")
#dataset <- count(indexed, vars = colnames(indexed)) ##### ALL DATA####
dataset = indexed
dataset %>% count_(names(.))
for(i in 1:ncol(dataset)){
  dataset[is.na(dataset[,i]), i] <- mean(dataset[,i], na.rm = TRUE)
}

subset_dataset <- dataset[, !(colnames(dataset) %in% c("census", "","lat", "lon", "sum", "freq", "NA"))]#subset(dataset, select=c('labels_shannon_index', 'population', 'income', 'household_shannon_index', 'language_shannon_index', 'race_shannon_index'))

# list rows of data that have missing values
subset_dataset[!complete.cases(subset_dataset),]

#Error in colMeans(x, na.rm = TRUE) : 'x' must be numeric 
#subset_dataset[] <- lapply(subset_dataset, function(x) {
#  if(is.factor(x)) as.numeric(as.character(x)) else x})

#scaled_data <- data.frame(center_scale(subset_dataset))
scaled_data <- data.frame(subset_dataset)

columns_str = paste(colnames(scaled_data), collapse="+")
scaled_data$sum<-dataset$sum
scaled_data <- data.frame(center_scale(scaled_data))
attach(scaled_data)


#Plot density of crime diversity
plot_density(scaled_data, scaled_data$sum, "density", "crimes", "Density of crimes in data")
#plot_density(scaled_data, scaled_data$sum, "count", "crimes diversity index", "Density of crimes diversity index data")

#Plot histogram of crime diversity
plot_histogram(scaled_data, scaled_data$sum, "crimes", "Histogram of crimes index")


#run pairwise correlation analysis on variables######################
res <- cor(scaled_data)
# Write CSV in R
round(res, 2)
write.csv(res, file = paste(destination, "pairwise_all_correlation.csv", sep="/"))

scaled_data[is.na(scaled_data)] <- 0

flm<-as.formula(paste("sum ~ " , columns_str, sep=""))
#Linear regression
model1 <- lm(formula=flm, data=scaled_data)#,na.action=na.omit)#na.exclude)
#summary(model1)
sink(paste(destination, "lm.txt", sep="/"))
print(summary(model1))
sink()  #
AIC(model1)

linear_pred <- predict(model1)

#Plot density of predicted crime diversity
#plot_density(scaled_data, linear_pred, "density", "predicted crimes diversity index with linear regression", "Density of predicted crimes diversity index with linear regression")
#plot_density(scaled_data, linear_pred, "count", "predicted crimes diversity index with linear regression", "Density of predicted crimes diversity index with linear regression")

#Plot histogram of crime diversity
#plot_histogram(scaled_data, linear_pred, "predicted crimes diversity index with linear regression", "Histogram of predicted crimes diversity index with linear regression")

#Plot the predicted value against the actual value

jpeg(file = paste(destination, "Linear predicted crimes vs actual.jpeg", sep="/"))
plot(linear_pred,scaled_data$sum, xlab="predicted crimes  using linear regression",ylab="actual crimes")
dev.off()

#abline(a=0,b=1)
jpeg(file = paste(destination, "1.jpeg", sep="/"))
plot(model1, which=1) # residuals against fitted values
dev.off()

jpeg(file = paste(destination, "2.jpeg", sep="/"))
plot(model1, which=2) # Normal Q-Q
dev.off()

jpeg(file = paste(destination, "3.jpeg", sep="/"))
plot(model1, which=3) # a Scale-Location plot of sqrt(| residuals |) against fitted values
dev.off()

jpeg(file = paste(destination, "4.jpeg", sep="/"))
plot(model1, which=4) # Cook's distance
dev.off()

jpeg(file = paste(destination, "5.jpeg", sep="/"))
plot(model1, which=5) # residuals against leverage
dev.off()

jpeg(file = paste(destination, "6.jpeg", sep="/"))
plot(model1, which=6) # Cook's distance vs leverage
dev.off()