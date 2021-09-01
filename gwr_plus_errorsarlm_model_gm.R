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

crimes_df <-  subset(read.csv("la_crime_data/pre_processed/extracted_census_crimes_shannon.csv"), select=c('census', 'crimes_shannon_index'))
#crimes_df <- subset(read.csv("la_crime_data/pre_processed/census_violence_shannon.csv"), select=c('census', 'crimes_shannon_index'))
#crimes_df <- subset(read.csv("la_crime_data/pre_processed/census_property_shannon.csv"), select=c('census', 'crimes_shannon_index'))
#crimes_df <- subset(read.csv("la_crime_data/pre_processed/census_conditional_violence_shannon.csv"), select=c('census', 'crimes_shannon_index'))

#destination = "F:/Dropbox/Dr Mohler/Crime discovery/la_crime_data/result/results_all_crimes_plus_3_cats_crimes/all"
#destination = "F:/Dropbox/Dr Mohler/Crime discovery/la_crime_data/result/results_all_crimes_plus_3_cats_crimes/violence"
#destination = "F:/Dropbox/Dr Mohler/Crime discovery/la_crime_data/result/results_all_crimes_plus_3_cats_crimes/property"
destination="~/Downloads/"
land_df <-  subset(read.csv("la_crime_data/la_aland.csv"), select=c('census', 'ALAND')) 
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

#B02001
B02001 <- read.csv("la_crime_data/new_data/ACS_16_5YR_B02001_with_ann.csv", header = T, na.strings=c("","NA"))
B02001 = B02001[-1, c("census", "HD01_VD02", "HD01_VD03", "HD01_VD04", "HD01_VD05", "HD01_VD06", "HD01_VD07", "HD01_VD08")]
colnames(B02001) <- paste("B02001", colnames(B02001), sep = "_")
names(B02001)[names(B02001) == 'B02001_census'] <- 'census'
attach(B02001)

#B03003
B03003 <- read.csv("la_crime_data/new_data/ACS_16_5YR_B03003_with_ann.csv", header = T, na.strings=c("","NA"))
B03003 = B03003[-1, c("census", "HD01_VD03")]
colnames(B03003) <- paste("B03003", colnames(B03003), sep = "_")
names(B03003)[names(B03003) == 'B03003_census'] <- 'census'
attach(B03003)

#B01001
B01001 <- read.csv("la_crime_data/new_data/ACS_16_5YR_B01001_with_ann.csv", header = T, na.strings=c("","NA"))
B01001 = B01001[-1, c("census", "HD01_VD02", "HD01_VD26")]
colnames(B01001) <- paste("B01001", colnames(B01001), sep = "_")
names(B01001)[names(B01001) == 'B01001_census'] <- 'census'
attach(B01001)

#B17021
B17021 <- read.csv("la_crime_data/new_data/ACS_16_5YR_B17021_with_ann.csv", header = T, na.strings=c("","NA"))
B17021 = B17021[-1, c("census", "HD01_VD01")]
colnames(B17021) <- paste("B17021", colnames(B17021), sep = "_")
names(B17021)[names(B17021) == 'B17021_census'] <- 'census'
attach(B17021)

#B01002
B01002 <- read.csv("la_crime_data/new_data/ACS_16_5YR_B01002_with_ann.csv", header = T, na.strings=c("","NA"))
B01002 = B01002[-1, c("census", "HD01_VD02")]
colnames(B01002) <- paste("B01002", colnames(B01002), sep = "_")
names(B01002)[names(B01002) == 'B01002_census'] <- 'census'
attach(B01002)

#B01003
B01003 <- read.csv("la_crime_data/new_data/ACS_16_5YR_B01003_with_ann.csv", header = T, na.strings=c("","NA"))
B01003 = B01003[-1, c("census", "HD01_VD01")]
colnames(B01003) <- paste("B01003", colnames(B01003), sep = "_")
names(B01003)[names(B01003) == 'B01003_census'] <- 'census'
attach(B01003)

#B15003
B15003 <- read.csv("la_crime_data/new_data/ACS_16_5YR_B15003_with_ann.csv", header = T, na.strings=c("","NA"))
B15003 = B15003[-1, c("census", "HD01_VD02", "HD01_VD17", "HD01_VD18", "HD01_VD19", "HD01_VD20", "HD01_VD21", "HD01_VD22", "HD01_VD23", "HD01_VD24")]
colnames(B15003) <- paste("B15003", colnames(B15003), sep = "_")
names(B15003)[names(B15003) == 'B15003_census'] <- 'census'
attach(B15003)

#B23025
B23025 <- read.csv("la_crime_data/new_data/ACS_16_5YR_B23025_with_ann.csv", header = T, na.strings=c("","NA"))
B23025 = B23025[-1, c("census", "HD01_VD05")]
colnames(B23025) <- paste("B23025", colnames(B23025), sep = "_")
names(B23025)[names(B23025) == 'B23025_census'] <- 'census'
attach(B23025)

#B19013
B19013 <- read.csv("la_crime_data/new_data/ACS_16_5YR_B19013_with_ann.csv", header = T, na.strings=c("","NA"))
B19013 = B19013[-1, c("census", "HD01_VD01")]
colnames(B19013) <- paste("B19013", colnames(B19013), sep = "_")
names(B19013)[names(B19013) == 'B19013_census'] <- 'census'
attach(B19013)

#B25004
B25004 <- read.csv("la_crime_data/new_data/ACS_16_5YR_B25004_with_ann.csv", header = T, na.strings=c("","NA"))
B25004 = B25004[-1, c("census", "HD01_VD01")]
colnames(B25004) <- paste("B25004", colnames(B25004), sep = "_")
names(B25004)[names(B25004) == 'B25004_census'] <- 'census'
attach(B25004)

#C17002
C17002 <- read.csv("la_crime_data/new_data/ACS_16_5YR_C17002_with_ann.csv", header = T, na.strings=c("","NA"))
C17002 = C17002[-1, c("census", "HD01_VD02","HD01_VD03","HD01_VD04", "HD01_VD05", "HD01_VD06", "HD01_VD07", "HD01_VD08")]
colnames(C17002) <- paste("C17002", colnames(C17002), sep = "_")
names(C17002)[names(C17002) == 'C17002_census'] <- 'census'
attach(C17002)

#crime data
crimes_df <- unique( crimes_df[ , 1:2] )
attach(crimes_df)

object_df <-  subset(read.csv('la_crime_data/pre_processed/label_df.csv'), select=c('census', 'labels_shannon_index'))
object_df <- unique( object_df[ , 1:2] )

household_df <-  subset(read.csv('la_crime_data/pre_processed/household_indexed.csv'), select=c('census', 'household_shannon_index'))
household_df <- unique( household_df[ , 1:2] )

language_df <-  subset(read.csv('la_crime_data/pre_processed/language_indexed.csv'), select=c('census', 'language_shannon_index'))
language_df <- unique( language_df[ , 1:2] )

race_df <-  subset(read.csv('la_crime_data/pre_processed/race_indexed.csv'), select=c('census', 'race_shannon_index'))
race_df <- unique( race_df[ , 1:2] )

income_df <- subset(read.csv('la_crime_data/pre_processed/ACS_16_5YR_B19301_with_ann.csv'), select=c('census', 'income'), na.strings=c("","NA"))
population_df = subset(read.csv('la_crime_data/pre_processed/census_population.csv'), select=c('census', 'population'), na.strings=c("","NA"))


#pre process data
index_data <- merge(x = nodes_df, y = crimes_df, by = "census")
processed_data = join_all(list(object_df, household_df, language_df, race_df, income_df, population_df,land_df), by = "census")
raw_data <- join_all(list(B01001, B01002, B01003, B03003, B17021, B19013, B23025, B25004,C17002, B15003, B02001), by = "census")

#index_df$census = as.character(index_df$census)
#raw_data$census = as.character(raw_data$census)
#raw_census = raw_data$census
#index_census = index_df$census
#missed = raw_census[!(raw_census %in% index_census)]

#we need numeric type for scale function
raw_data[] <- lapply(raw_data, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x})

processed_data[] <- lapply(processed_data, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x})

#####################################################################################
#index_data = index_data[which(population >50), ] 
#####################################################################################
indexed <- merge(x= processed_data, y = index_data, by = "census")
data <- merge(x= indexed, y = raw_data, by = "census")
dataset <- count(data, vars = colnames(data)) ##### ALL DATA####

for(i in 1:ncol(dataset)){
  dataset[is.na(dataset[,i]), i] <- mean(dataset[,i], na.rm = TRUE)
}

subset_dataset <- dataset[, !(colnames(dataset) %in% c("census", "","lat", "lon", "crimes_shannon_index", "freq", "B01003_HD01_VD01", "C17002_HD01_VD08", "B02001_HD01_VD08"))]#subset(dataset, select=c('labels_shannon_index', 'population', 'income', 'household_shannon_index', 'language_shannon_index', 'race_shannon_index'))

# list rows of data that have missing values
subset_dataset[!complete.cases(subset_dataset),]

#Error in colMeans(x, na.rm = TRUE) : 'x' must be numeric 
#subset_dataset[] <- lapply(subset_dataset, function(x) {
#  if(is.factor(x)) as.numeric(as.character(x)) else x})

#scaled_data <- data.frame(center_scale(subset_dataset))
scaled_data <- data.frame(subset_dataset)

columns_str = paste(colnames(scaled_data), collapse="+")
scaled_data$crimes_shannon_index<-dataset$crimes_shannon_index
scaled_data <- data.frame(center_scale(scaled_data))

# co <- dataset[, c('lon', 'lat')]
# GWRbandwidth <- gwr.sel(crimes_shannon_index~., data=scaled_data, coords=as.matrix(co),adapt=T) 
# 
# #run the gwr model
# gwr.model = gwr(crimes_shannon_index~., data=scaled_data, coords=as.matrix(co), adapt=GWRbandwidth, hatmatrix=TRUE, se.fit=TRUE) 
# #print the results of the model
# gwr.model
# 
# results<-as.data.frame(gwr.model$SDF)
# #predicted value of GWR
# gwr_pred<- results$pred


attach(scaled_data)


#Plot density of crime diversity
plot_density(scaled_data, scaled_data$crimes_shannon_index, "density", "crimes diversity index", "Density of crimes diversity index in data")
#plot_density(scaled_data, scaled_data$crimes_shannon_index, "count", "crimes diversity index", "Density of crimes diversity index data")

#Plot histogram of crime diversity
plot_histogram(scaled_data, scaled_data$crimes_shannon_index, "crimes diversity index", "Histogram of crimes diversity index")


#run pairwise correlation analysis on variables######################
res <- cor(scaled_data)
# Write CSV in R
round(res, 2)
write.csv(res, file = paste(destination, "pairwise_all_correlation.csv", sep="/"))




flm<-as.formula(paste("crimes_shannon_index ~ " , columns_str, sep=""))
#Linear regression
model1 <- lm(formula=flm, data=scaled_data,na.action=na.exclude)
summary(model1)
AIC(model1)

linear_pred <- predict(model1)

#Plot density of predicted crime diversity
plot_density(scaled_data, linear_pred, "density", "predicted crimes diversity index with linear regression", "Density of predicted crimes diversity index with linear regression")
#plot_density(scaled_data, linear_pred, "count", "predicted crimes diversity index with linear regression", "Density of predicted crimes diversity index with linear regression")

#Plot histogram of crime diversity
plot_histogram(scaled_data, linear_pred, "predicted crimes diversity index with linear regression", "Histogram of predicted crimes diversity index with linear regression")

#Plot the predicted value against the actual value

jpeg(file = paste(destination, "Linear predicted crimes diversity vs actual.jpeg", sep="/"))
plot(linear_pred,scaled_data$crimes_shannon_index, xlab="predicted crimes diversity using linear regression",ylab="actual crimes diversity")
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



#threshold <- 0.05
#signif_form <-
#  as.formula(paste("metric ~ ",
#                   paste(names(which((summary(linear_model)$coefficients[
#                     2:(nrow(summary(linear_model)$coefficients)), 4] < threshold) == TRUE)),
#                     collapse = "+")))
#linear_model <- lm(signif_form, data = data)
#summary(linear_model)



#plot the residuals to see if there is any obvious spatial patterning
resids<-data.frame(residuals(model1))
colours <- c("dark blue", "blue", "red", "dark red") 
co <- dataset[, c('lon', 'lat')]

#here it is assumed that your eastings and northings coordinates are stored in columns called x and y in your dataframe
map.resids <- SpatialPointsDataFrame(data=resids, coords=co)#cbind(dataset$lon,dataset$lat)) 

alias(model1)

#for speed we are just going to use the quick sp plot function, but you could alternatively store your residuals back in your dataset dataframe and plot using geom_point in ggplot2
jpeg(file = paste(destination, "resids.jpeg", sep="/"))
spplot(map.resids, cuts=quantile(resids$residuals.model1.), col.regions=colours, cex=0.5) 
dev.off()

scaled_data$lat <- co$lat
scaled_data$lon <- co$lon

#calculate kernel bandwidth
#flm<-as.formula("crimes_shannon_index ~ race_shannon_index+language_shannon_index+household_shannon_index+income+population+labels_shannon_index+HD01_VD12+HD01_VD09+HD01_VD06+HD01_VD03+HD01_VD02+household_D026+household_D018+household_D003")#+race_D070+race_D063+race_D047+race_D026+race_D009+race_D002")
GWRbandwidth <- gwr.sel(formula=flm, data=scaled_data, coords=as.matrix(co),adapt=T) 

#run the gwr model
gwr.model = gwr(formula=flm, data=scaled_data, coords=as.matrix(co), adapt=GWRbandwidth, hatmatrix=TRUE, se.fit=TRUE) 
#print the results of the model
gwr.model

results<-as.data.frame(gwr.model$SDF)
#predicted value of GWR
gwr_pred<- results$pred


plot_df = data.frame(census = dataset$census,
                     crimes_shannon_index= scaled_data$crimes_shannon_index,
                     linear_prediction = linear_pred,
                     gwr_prediction = gwr_pred)

jpeg(file = paste(destination, "histogram of actual with density of linear.jpeg", sep="/"))

par(mfrow=c(1,1))
hist(plot_df$crimes_shannon_index, # histogram
     col="gray", # column color
     border="black",
     prob = TRUE, # show densities instead of frequencies
     xlab = "crime density index",
     cex.axis=0.5, font.main=1
     ,main = "Histogram of actual crime diversity along with density of predicted crime diversity using Linear Regression"
)
lines(density(plot_df$linear_prediction), # density plot
      lwd = 2, # thickness of line
      cex.axis=0.5,
      col = "chocolate3")
dev.off()


jpeg(file = paste(destination, "histogram of actual with density of gwr.jpeg", sep="/"))
par(mfrow=c(1,1))
hist(plot_df$crimes_shannon_index, # histogram
     col="gray", # column color
     border="black",
     prob = TRUE, # show densities instead of frequencies
     xlab = "crime density index",
     cex.axis=0.5, font.main=1
     ,main = "Histogram of actual crime diversity along with density of predicted crime diversity using GWR"
)
lines(density(plot_df$gwr_prediction), # density plot
      lwd = 2, # thickness of line
      cex.axis=0.5,
      col = "chocolate3"
)

dev.off()

# Create an object with the value of Quasi-global R2
globalR2 <- (1 - (gwr.model$results$rss/gwr.model$gTSS))

jpeg(file = paste(destination, "gwr value against the actual value.jpeg", sep="/"))
#Plot the predicted value against the actual value
plot(gwr_pred, scaled_data$crimes_shannon_index, xlab="GWR predicted crimes diversity", ylab="actual crimes diversity")
abline(a=0,b=1)
dev.off()

jpeg(file = paste(destination, "GWR residuals against gwr value.jpeg", sep="/"))
#Plot the residuals against predicted value
plot(results$gwr.e, gwr_pred, xlab="GWR residuals", ylab="GWR predicted crimes diversity")
abline(a=0,b=1)
dev.off()

#jpeg(file = paste(destination, "density of predicted gwr.jpeg", sep="/"))
#Plot density of predicted crime diversity
plot_density(scaled_data, gwr_pred, "density", "predicted crimes diversity index with GWR", "Density of predicted crimes diversity index with GWR")
#dev.off()

#jpeg(file = paste(destination, "count density of predicted gwr.jpeg", sep="/"))
#plot_density(scaled_data, gwr_pred, "count", "predicted crimes diversity index with GWR")
#dev.off()

#Plot histogram of crime diversity
#jpeg(file = paste(destination, "histogram of predicted gwr.jpeg", sep="/"))
plot_histogram(scaled_data, gwr_pred, "predicted crimes diversity index with GWR", "Histogram of predicted crimes diversity index with GWR")
#dev.off()




#attach coefficients to original dataframe
scaled_data$coelabels_shannon_index<-results$labels_shannon_index
scaled_data$coepopulation<-results$population
scaled_data$coeincome<-results$income
scaled_data$coehousehold_shannon_index<-results$household_shannon_index
scaled_data$coelanguage_shannon_index<-results$language_shannon_index
scaled_data$coerace_shannon_index<-results$race_shannon_index
 
# for shapefiles, first argument of the read/write/info functions is the
# directory location, and the second is the file name without suffix

# optionally report shapefile details
ogrInfo(".", "laGeometries")
ogrDrivers()
laGeometries <- readOGR(".", "laGeometries")
str(laGeometries)
#writeSpatialShape(laGeometries, "laPolygons")

mapdata <- data.frame(laGeometries)

# now create the map
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$crimes_shannon_index))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="range"))
ggsave(file = paste(destination, "actual crimes in space.png", sep="/"))

ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=linear_pred))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="range"))
ggsave(file = paste(destination, "linear crimes in space.png", sep="/"))

ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=gwr_pred))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="range"))
ggsave(file = paste(destination, "gwr crimes in space.png", sep="/"))

# Create the loop.vector (all the columns)
loop.vector <- 1:35
target_names = strsplit(columns_str, "\\+")[[1]]

for (i in loop.vector) { # Loop over loop.vector
  #print(target_names[i])
  col = target_names[i]
  # store data in column.i as x
  new_name = paste("coe",col, sep="")
  scaled_data[new_name]<- results[col]
  # Plot of x
  #print(new_name)
  ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data[new_name]))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="range"))
  url = paste(destination, paste(new_name, "png", sep = "."), sep="/")
  ggsave(url)
  #print(url)
  #break
} 

summary(laGeometries)


####################################################
#Define neighbourhood here max is 1km
nn<-dnearneigh(sapply(co, as.numeric),0,1,longlat = TRUE)
#get inverse distances
dsts <- nbdists(nn, sapply(co, as.numeric))
idw <- lapply(dsts, function(x) 1/(x))
#Spatial weights
nnweights<-nb2listw(nn, glist=idw, style='S', zero.policy =TRUE)
errorsarlm_m1<-errorsarlm(formula(model1), listw=nnweights,na.action=na.omit, method='LU', tol.solve=1e-16, control=list(returnHcov=FALSE), zero.policy =TRUE)
summary(errorsarlm_m1)

#errorsarlm_m2<-errorsarlm(formula(model1), listw=nnweights,na.action=na.omit, method='Matrix', tol.solve=1e-16, control=list(returnHcov=FALSE), zero.policy =TRUE)
#summary(errorsarlm_m2)
#####################################################
