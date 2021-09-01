#packages
library(spgwr)
library(ggplot2)
library(ggpubr)
library(maptools)
library(plyr)
library(rgdal)
require(plyr)

#functions
plot_density<- function(data, variable_name, y_axis, x_label){
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
}

plot_histogram<- function(data, variable_name, x_label){
  a <- ggplot(data, aes(x = variable_name)) +  labs(x=x_label)
  
  a + geom_histogram(bins = 30, color = "black", fill = "gray") +
    geom_vline(aes(xintercept = mean(variable_name)), 
               linetype = "dashed", size = 0.6)
  
}

# centering with 'scale()'
center_scale <- function(x) {
  scale(x, scale = FALSE)
}

#load data
nodes_df <- subset(read.csv("la_crime_data/nodes/nodes.csv"), select=c('census', 'lat', 'lon'))
attach(nodes_df)

index_df <-  subset(read.csv("la_crime_data/dataset.csv"), select=c('census', 'labels_shannon_index', 'population', 'income', 'household_shannon_index', 'language_shannon_index', 'race_shannon_index', 'crimes_shannon_index'))
attach(index_df)

household <- read.csv("la_crime_data/household_type_by_relationship/DEC_10_SF1_P29_with_ann.csv", header = T)
household = household[-1, c("census", "D003", "D018", "D026")]#[-1 ,!(colnames(household) %in% c("GEO.id", "GEO.id2", "X", "GEO.display.label"))]
colnames(household) <- paste("household", colnames(household), sep = "_")
names(household)[names(household) == 'household_census'] <- 'census'
attach(household)

language <- read.csv("la_crime_data/language/ACS_16_5YR_C16002_with_ann.csv", header = T)
language = language[-1, c("census", "HD01_VD02", "HD01_VD03", "HD01_VD06", "HD01_VD09", "HD01_VD12")]#[-1 ,!(colnames(language) %in% c("GEO.id", "GEO.id2", "X", "GEO.display.label", "block.group"))]
attach(language)


race <- read.csv("la_crime_data/race_la/race_census_data.csv", header = T)
race = race[-1, c("census", "D002", "D009", "D026", "D047", "D063", "D070")]#[-1 ,!(colnames(race) %in% c("GEO.id", "GEO.id2", "X", "GEO.display.label", "block.group"))]
colnames(race) <- paste("race", colnames(race), sep = "_")
names(race)[names(race) == 'race_census'] <- 'census'
attach(race)

raw_data <- join_all(list(household,language,race), by = "census")
#we need numeric type for scale function
raw_data[] <- lapply(raw_data, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x})
#pre process data
index_data <- merge(x = nodes_df, y = index_df, by = "census")

#####################################################################################
index_data = index_data[which(population >50), ] 
#####################################################################################

data <- merge(x= raw_data, y = index_data, by = "census")
#dataset <- count(data, vars = colnames(data)) ##### ALL DATA####
dataset <- count(index_data, vars = colnames(index_data)) ###ONLY INDEXED DATA#########
dataset$income = ifelse(is.na(dataset$income), 
                        ave(dataset$income, FUN= function(x) mean(x, na.rm = TRUE)), 
                        dataset$income)

subset_dataset <- dataset[, !(colnames(dataset) %in% c("census", "lat", "lon", "crimes_shannon_index", "freq"))]#subset(dataset, select=c('labels_shannon_index', 'population', 'income', 'household_shannon_index', 'language_shannon_index', 'race_shannon_index'))

# list rows of data that have missing values
subset_dataset[!complete.cases(subset_dataset),]
scaled_data <- data.frame(center_scale(subset_dataset))

scaled_data$crimes_shannon_index<-dataset$crimes_shannon_index
# check that we get mean of 0 and sd of 1
colMeans(scaled_data) 
attach(scaled_data)

#Plot density of crime diversity
plot_density(scaled_data, scaled_data$crimes_shannon_index, "density", "crimes diversity index")
plot_density(scaled_data, scaled_data$crimes_shannon_index, "count", "crimes diversity index")

#Plot histogram of crime diversity
plot_histogram(scaled_data, scaled_data$crimes_shannon_index, "crimes diversity index")

#check the correlation of the data
cor(scaled_data)

#flm<-as.formula("crimes_shannon_index ~ race_shannon_index+language_shannon_index+household_shannon_index+income+population+labels_shannon_index+HD01_VD12+HD01_VD09+HD01_VD06+HD01_VD03+HD01_VD02+race_D070+race_D063+race_D047+race_D026+race_D009+race_D002+household_D026+household_D018")#+household_D003")
flm<-as.formula("crimes_shannon_index ~ race_shannon_index+language_shannon_index+household_shannon_index+income+population+labels_shannon_index")
#Linear regression
model1 <- lm(formula=flm, data=scaled_data)#, na.action=na.exclude)
#lm(formula=crimes_shannon_index ~ labels_shannon_index+population+income+household_shannon_index+language_shannon_index+race_shannon_index, data=scaled_data)#,na.action=na.exclude)#labels_shannon_index+population+income+household_shannon_index+language_shannon_index+race_shannon_index)
summary(model1)

linear_pred <- predict(model1)


#Plot density of predicted crime diversity
plot_density(scaled_data, linear_pred, "density", "predicted crimes diversity index with linear regression")
plot_density(scaled_data, linear_pred, "count", "predicted crimes diversity index with linear regression")

#Plot histogram of crime diversity
plot_histogram(scaled_data, linear_pred, "predicted crimes diversity index with linear regression")

#Plot the predicted value against the actual value
plot(linear_pred,scaled_data$crimes_shannon_index, xlab="predicted crimes diversity using linear regression",ylab="actual crimes diversity")
abline(a=0,b=1)

plot(model1, which=1) # residuals against fitted values
plot(model1, which=2) # Normal Q-Q
plot(model1, which=3) # a Scale-Location plot of sqrt(| residuals |) against fitted values
plot(model1, which=4) # Cook's distance
plot(model1, which=5) # residuals against leverage
plot(model1, which=6) # Cook's distance vs leverage

#plot the residuals to see if there is any obvious spatial patterning
resids<-data.frame(residuals(model1))
colours <- c("dark blue", "blue", "red", "dark red") 
co <- dataset[, c('lon', 'lat')]
#resids$lat <- co$lat
#resids$lon <- co$lon

#here it is assumed that your eastings and northings coordinates are stored in columns called x and y in your dataframe
map.resids <- SpatialPointsDataFrame(data=resids, coords=co)#cbind(dataset$lon,dataset$lat)) 

alias(model1)

#for speed we are just going to use the quick sp plot function, but you could alternatively store your residuals back in your dataset dataframe and plot using geom_point in ggplot2
spplot(map.resids, cuts=quantile(resids$residuals.model1.), col.regions=colours, cex=0.5) 
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
head(results)

#predicted value of GWR
gwr_pred<- results$pred


plot_df = data.frame(census = dataset$census,
                     crimes_shannon_index= scaled_data$crimes_shannon_index,
                     linear_prediction = linear_pred,
                     gwr_prediction = gwr_pred)

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


# Create an object with the value of Quasi-global R2
globalR2 <- (1 - (gwr.model$results$rss/gwr.model$gTSS))

#Plot the predicted value against the actual value
plot(gwr_pred, scaled_data$crimes_shannon_index, xlab="GWR predicted crimes diversity", ylab="actual crimes diversity")
abline(a=0,b=1)

#Plot the residuals against predicted value
plot(results$gwr.e, gwr_pred, xlab="GWR residuals", ylab="GWR predicted crimes diversity")
abline(a=0,b=1)

#Plot density of predicted crime diversity
plot_density(scaled_data, gwr_pred, "density", "predicted crimes diversity index with GWR")
plot_density(scaled_data, gwr_pred, "count", "predicted crimes diversity index with GWR")

#Plot histogram of crime diversity
plot_histogram(scaled_data, gwr_pred, "predicted crimes diversity index with GWR")

#attach coefficients to original dataframe
scaled_data$coelabels_shannon_index<-results$labels_shannon_index
scaled_data$coepopulation<-results$population
scaled_data$coeincome<-results$income
scaled_data$coehousehold_shannon_index<-results$household_shannon_index
scaled_data$coelanguage_shannon_index<-results$language_shannon_index
scaled_data$coerace_shannon_index<-results$race_shannon_index

scaled_data$coHD01_VD12 <-results$HD01_VD12
scaled_data$coHD01_VD09 <-results$HD01_VD09
scaled_data$coHD01_VD06 <-results$HD01_VD06
scaled_data$coHD01_VD03 <-results$HD01_VD03
scaled_data$coHD01_VD02 <-results$HD01_VD02
scaled_data$corace_D070 <-results$race_D070
scaled_data$corace_D063 <-results$race_D063
scaled_data$corace_D047 <-results$race_D047
scaled_data$corace_D026 <-results$race_D026
scaled_data$corace_D009 <-results$race_D009
scaled_data$corace_D002 <-results$race_D002
scaled_data$cohousehold_D026 <-results$household_D026
scaled_data$cohousehold_D018 <-results$household_D018



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
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=linear_pred))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="range"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=gwr_pred))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="range"))

ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$coelabels_shannon_index))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$coepopulation))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$coeincome))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$coehousehold_shannon_index))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$coelanguage_shannon_index))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$coerace_shannon_index))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))

ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$coHD01_VD12))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$coHD01_VD09))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$coHD01_VD06))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$coHD01_VD03))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$coHD01_VD02))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$corace_D070))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$corace_D063))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$corace_D047))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$corace_D026))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$corace_D009))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$corace_D002))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$cohousehold_D026))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
ggplot(scaled_data, aes(x=lon,y=lat))+geom_point(aes(colour=scaled_data$cohousehold_D018))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))

#ggplot() +  geom_point( data= mapdata, aes(x=lon, y=lat), color="red")

summary(laGeometries)

#read in the shapefile using the maptools function readShapePoly
#la_sp <- readShapePoly("la_crime_data/co06_d00_shp/co06_d00.shp")
#fortify for use in ggpplot2
#california_outline <- fortify(la_sp, region="AREA")
#now plot the various GWR coefficients                       
#gwr.point1<-ggplot(data.frame(scaled_data), aes(x=co$lon,y=co$lat))+geom_point(aes(colour=labels_shannon_index))+scale_colour_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="Coefs"))
#gwr.point1+geom_path(data=california_outline,aes(long, lat, group=id), colour="grey")+coord_equal()
