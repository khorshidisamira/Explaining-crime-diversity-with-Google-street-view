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

attach(scaled_data)

#flm<-as.formula("crimes_shannon_index ~ race_shannon_index+language_shannon_index+household_shannon_index+income+population+labels_shannon_index+HD01_VD12+HD01_VD09+HD01_VD06+HD01_VD03+HD01_VD02+race_D070+race_D063+race_D047+race_D026+race_D009+race_D002+household_D026+household_D018")#+household_D003")
flm<-as.formula("crimes_shannon_index ~ race_shannon_index+language_shannon_index+household_shannon_index+income+population+labels_shannon_index")
#Linear regression
model1 <- lm(formula=flm, data=scaled_data)#, na.action=na.exclude)
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
nnweights<-nb2listw(nn, glist=idw, style='S')
errorsarlm_m1<-errorsarlm(formula(model1), listw=nnweights,na.action=na.omit, method='LU', tol.solve=1e-16, control=list(returnHcov=FALSE))
summary(errorsarlm_m1)

errorsarlm_m2<-errorsarlm(formula(model1), listw=nnweights,na.action=na.omit, method='Matrix', tol.solve=1e-16, control=list(returnHcov=FALSE))
summary(errorsarlm_m2)
###################################################
#https://stat.ethz.ch/pipermail/r-sig-geo/2013-December/020100.html
###################################################
#errW.eig <- errorsarlm(formula=flm, data=scaled_data, nb2listw(nb, style="W"), method="eigen", quiet=FALSE)
#COL.errB.eig <- errorsarlm(CRIME ~ INC + HOVAL, data=COL.OLD, nb2listw(COL.nb, style="B"), method="eigen", quiet=FALSE)
#COL.errW.sp <- errorsarlm(CRIME ~ INC + HOVAL, data=COL.OLD, nb2listw(COL.nb, style="W"), method="sparse", quiet=FALSE)
#summary(errW.eig)
#summary(COL.errB.eig)
#summary(COL.errW.sp)
#NA.COL.OLD <- COL.OLD
#NA.COL.OLD$CRIME[20:25] <- NA
#COL.err.NA <- errorsarlm(CRIME ~ INC + HOVAL, data=NA.COL.OLD,
#                         nb2listw(COL.nb), na.action=na.exclude)
#COL.err.NA$na.action
#COL.err.NA
#resid(COL.err.NA)