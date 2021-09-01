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

# centering with 'scale()'
center_scale <- function(x) {
  scale(x, scale = FALSE)
}

#load data
nodes_df <- subset(read.csv("la_crime_data/nodes/nodes.csv"), select=c('census', 'lat', 'lon'))
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

#index_df <-  subset(read.csv("la_crime_data/pre_processed/extracted_census_crimes_shannon.csv"), select=c('census', 'crimes_shannon_index'))
#index_df <- subset(read.csv("la_crime_data/pre_processed/census_violence_shannon.csv"), select=c('census', 'crimes_shannon_index'))
index_df <- subset(read.csv("la_crime_data/pre_processed/census_property_shannon.csv"), select=c('census', 'crimes_shannon_index'))
attach(index_df)

#pre process data
index_data <- merge(x = nodes_df, y = index_df, by = "census")

raw_data <- join_all(list(B01001, B01002, B01003, B03003, B17021, B19013, B23025, B25004,C17002, B15003, B02001), by = "census")

index_df$census = as.character(index_df$census)
raw_data$census = as.character(raw_data$census)
raw_census = raw_data$census
index_census = index_df$census
missed = raw_census[!(raw_census %in% index_census)]

#we need numeric type for scale function
raw_data[] <- lapply(raw_data, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x})

#####################################################################################
#index_data = index_data[which(population >50), ] 
#####################################################################################

data <- merge(x= index_data, y = raw_data, by = "census")
dataset <- count(data, vars = colnames(data)) ##### ALL DATA####

for(i in 1:ncol(dataset)){
  dataset[is.na(dataset[,i]), i] <- mean(dataset[,i], na.rm = TRUE)
}

subset_dataset <- dataset[, !(colnames(dataset) %in% c("census", "lat", "lon", "crimes_shannon_index", "freq", "B01003_HD01_VD01", "C17002_HD01_VD08", "B02001_HD01_VD08"))]#subset(dataset, select=c('labels_shannon_index', 'population', 'income', 'household_shannon_index', 'language_shannon_index', 'race_shannon_index'))

# list rows of data that have missing values
subset_dataset[!complete.cases(subset_dataset),]

#Error in colMeans(x, na.rm = TRUE) : 'x' must be numeric 
#subset_dataset[] <- lapply(subset_dataset, function(x) {
#  if(is.factor(x)) as.numeric(as.character(x)) else x})

scaled_data <- data.frame(center_scale(subset_dataset))

clmns_df = scaled_data[, -which(names(scaled_data) %in% c())]
columns_str = paste(colnames(scaled_data), collapse="+")
scaled_data$crimes_shannon_index<-dataset$crimes_shannon_index

attach(scaled_data)

#run pairwise correlation analysis on variables######################
res <- cor(scaled_data)
# Write CSV in R
write.csv(res, file = "la_crime_data/new_data/pairwise_property_correlation.csv")

round(res, 2)


flm<-as.formula(paste("crimes_shannon_index ~ " , columns_str, sep=""))
#Linear regression
model1 <- lm(formula=flm, data=scaled_data,na.action=na.exclude)
#lm(formula=crimes_shannon_index ~ labels_shannon_index+population+income+household_shannon_index+language_shannon_index+race_shannon_index, data=scaled_data)#,na.action=na.exclude)#labels_shannon_index+population+income+household_shannon_index+language_shannon_index+race_shannon_index)
summary(model1)

linear_pred <- predict(model1)

#plot the residuals to see if there is any obvious spatial patterning
resids<-data.frame(residuals(model1))
colours <- c("dark blue", "blue", "red", "dark red") 
co <- dataset[, c('lon', 'lat')]

#here it is assumed that your eastings and northings coordinates are stored in columns called x and y in your dataframe
map.resids <- SpatialPointsDataFrame(data=resids, coords=co)#cbind(dataset$lon,dataset$lat)) 

alias(model1)

#for speed we are just going to use the quick sp plot function, but you could alternatively store your residuals back in your dataset dataframe and plot using geom_point in ggplot2
spplot(map.resids, cuts=quantile(resids$residuals.model1.), col.regions=colours, cex=0.5) 
scaled_data$lat <- co$lat
scaled_data$lon <- co$lon

#Define neighbourhood here max is 1km
nn<-dnearneigh(sapply(co, as.numeric),0,1,longlat = TRUE)
#get inverse distances
dsts <- nbdists(nn, sapply(co, as.numeric))
idw <- lapply(dsts, function(x) 1/(x))
#Spatial weights
nnweights<-nb2listw(nn, glist=idw, style='S', zero.policy =TRUE)
errorsarlm_m1<-errorsarlm(formula(model1), listw=nnweights,na.action=na.omit, method='LU', tol.solve=1e-16, control=list(returnHcov=FALSE), zero.policy =TRUE)
summary(errorsarlm_m1)

errorsarlm_m2<-errorsarlm(formula(model1), listw=nnweights,na.action=na.omit, method='Matrix', tol.solve=1e-16, control=list(returnHcov=FALSE))
summary(errorsarlm_m2)