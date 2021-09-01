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


#functions
# centering with 'scale()'
center_scale <- function(x) {
  scale(x, scale = FALSE)
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

crimes_df <-  subset(read.csv("la_crime_data/pre_processed/extracted_census_crimes_shannon.csv"), select=c('census', 'crimes_shannon_index'))
#crimes_df <- subset(read.csv("la_crime_data/pre_processed/census_violence_shannon.csv"), select=c('census', 'crimes_shannon_index'))
#crimes_df <- subset(read.csv("la_crime_data/pre_processed/census_property_shannon.csv"), select=c('census', 'crimes_shannon_index'))
#crimes_df <- subset(read.csv("la_crime_data/pre_processed/census_conditional_violence_shannon.csv"), select=c('census', 'crimes_shannon_index'))

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
processed_data = join_all(list(object_df, household_df, language_df, race_df, income_df, population_df), by = "census")
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

subset_dataset <- dataset[, !(colnames(dataset) %in% c("census", "lat", "lon", "crimes_shannon_index", "freq", "B01003_HD01_VD01", "C17002_HD01_VD08", "B02001_HD01_VD08"))]#subset(dataset, select=c('labels_shannon_index', 'population', 'income', 'household_shannon_index', 'language_shannon_index', 'race_shannon_index'))

# list rows of data that have missing values
subset_dataset[!complete.cases(subset_dataset),] 

scaled_data <- data.frame(center_scale(subset_dataset))

columns_str = paste(colnames(scaled_data), collapse="+")
scaled_data$crimes_shannon_index<-dataset$crimes_shannon_index

attach(scaled_data)

crime_diversity_max <- apply(scaled_data["crimes_shannon_index"], 2, max)
crime_diversity_min <- apply(scaled_data["crimes_shannon_index"], 2, min)
#max_row = scaled_data[which.max(scaled_data$crimes_shannon_index),]

#n <- nrow(scaled_data)
#sorted_crimes = sort(scaled_data$crimes_shannon_index,partial=n-1)
#second_max = sort(scaled_data$crimes_shannon_index,partial=n-1)[n-1]
#second_max_row = scaled_data[which.max(scaled_data$crimes_shannon_index!=max(scaled_data$crimes_shannon_index)),]
#ss = max( scaled_data$crimes_shannon_index[scaled_data$crimes_shannon_index!=max(scaled_data$crimes_shannon_index)] )

co <- dataset[, c('census', 'lon', 'lat')] 
 
scaled_data$lat <- co$lat
scaled_data$lon <- co$lon
scaled_data$census <- co$census
sorted_data = scaled_data[order(scaled_data$crimes_shannon_index),]


a <- unique(scaled_data$crimes_shannon_index)
two_max_c_d = tail(sort(a),2)
two_min_c_d = head(sort(a),2)

min1_crime = 0.6931472

bottom = scaled_data[which(scaled_data$crimes_shannon_index<0.8),]
bottom = bottom[which(bottom$labels_shannon_index>0),]
two_bottom_sample = bottom[sample(nrow(bottom), 2), ]
bottom1 = two_bottom_sample[1,]
bottom2 = two_bottom_sample[2,]

top = scaled_data[which(scaled_data$crimes_shannon_index>1.8),]
top = top[which(top$labels_shannon_index>0.7),]
two_top_sample = top[sample(nrow(top), 2), ]
top1 = two_top_sample[1,]
top2 = two_top_sample[2,]

#top_first = scaled_data[which(scaled_data$crimes_shannon_index == two_max_c_d[1]), ] 
#top_second = scaled_data[which(scaled_data$crimes_shannon_index == two_max_c_d[2]), ] 

#bottom_first = scaled_data[which(scaled_data$crimes_shannon_index == two_min_c_d[1]), ] 
#bottom_second = scaled_data[which(scaled_data$crimes_shannon_index == two_min_c_d[2]), ] 


top_first_nodes = subset(nodes_df, nodes_df$census == top1$census)
top_second_nodes = subset(nodes_df, nodes_df$census == top2$census)

bottom_first_nodes = subset(nodes_df, nodes_df$census == bottom1$census)
bottom_second_nodes = subset(nodes_df, nodes_df$census == bottom2$census)

#- crime diversity index
#- object diversity index
top_first_crim_diversity = top1$crimes_shannon_index
top_second_crim_diversity = top2$crimes_shannon_index
top_first_object_diversity = top1$labels_shannon_index
top_second_object_diversity = top2$labels_shannon_index

bottom_first_crim_diversity = bottom1$crimes_shannon_index
bottom_second_crim_diversity = bottom2$crimes_shannon_index
bottom_first_object_diversity = bottom1$labels_shannon_index
bottom_second_object_diversity = bottom2$labels_shannon_index

#str(row['census'])[1:] + "_" + str(row['lat']) + "_" + str(row['lon'])





ggplot(top_first, aes(x=lon,y=lat))+geom_point(aes(colour=top_first$crimes_shannon_index))+scale_colour_gradient2(low = "red", mid = "black", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="range"))
ggsave("C:/Users/Samira/Dropbox/Dr Mohler/Crime discovery/la_crime_data/result/top_first_crime_diversity.png")

ggplot(top_first, aes(x=lon,y=lat))+geom_point(aes(colour=top_first$crimes_shannon_index))+scale_colour_gradient2(low = "red", mid = "black", high = "blue", midpoint = 0, space = "rgb", na.value = "grey50", guide = "colourbar", guide_legend(title="range"))
ggsave("C:/Users/Samira/Dropbox/Dr Mohler/Crime discovery/la_crime_data/result/top_first_crime_diversity.png")

  
my_d <- subset(scaled_data, crimes_shannon_index == two_max_c_d[1])


# loading the required packages
library(ggplot2)
library(ggmap)




qmplot(lon, lat, data = my_d, colour = I('red'), size = I(3), darken = .3, zoom=13)
# getting the map
mapgilbert <- get_map(location = c(lon = mean(scaled_data$lon), lat = mean(scaled_data$lat)), zoom = 4,
                      maptype = "satellite", scale = 2)

# plotting the map with some points on it
ggmap(mapgilbert) +
  geom_point(data = df, aes(x = lon, y = lat, fill = "red", alpha = 0.8), size = 5, shape = 21) +
  guides(fill=FALSE, alpha=FALSE, size=FALSE)