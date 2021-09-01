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
library(data.table)
library(dplyr)

# centering with 'scale()'
center_scale <- function(x) {
  scale(x, scale = FALSE)
}

#label_df <- subset(read.csv("la_crime_data/pre_processed/census_violence.csv"),stringsAsFactors=FALSE, select=c('census', 'CRIMECLASSCODE', 'count'))
#label_df <- subset(read.csv("la_crime_data/pre_processed/census_property.csv"),stringsAsFactors=FALSE, select=c('census', 'CRIMECLASSCODE', 'count'))
label_df <- subset(read.csv("la_crime_data/pre_processed/extracted_crime.csv"),stringsAsFactors=FALSE, select=c('census', 'CRIMECLASSCODE', 'count'))
unique_labels = unique(label_df$CRIMECLASSCODE)
unique_census = unique(label_df$census)
attach(label_df)

columns <- list("census")
for(l in unique_labels){
  label = substr(l, 1, 20)
  columns = append(columns, label)
}

reformed_df <- data.frame(matrix(ncol = (length(unique_labels)+2), nrow = length(unique_census)))
selected_part <- data.frame(matrix(ncol = 3))
colnames(reformed_df) <- columns
i=1
for(current_census in unique_census){
  reformed_df$census[i] <- current_census
  
  filtered_df <- filter(label_df, census == current_census)
  selected_part <- group_by(filtered_df, CRIMECLASSCODE)
  (label_counts<- summarise(selected_part, counts = sum(count)))
  
  print(nrow(label_counts))
  for(index_label in 1:nrow(label_counts)) {
    row <- label_counts[index_label,]
    l = substr(row$CRIMECLASSCODE, 1, 20)
    
    if(is.na(reformed_df[i, l])){
      reformed_df[i, l] = 0
    }
    reformed_df[i, l] <-  reformed_df[i, l] + row$counts
  }
  
  #print( reformed_df[i,])
  i = i+1
  print(i)
  #if(i == 5)
  #  break
}

reformed_df[is.na(reformed_df)] <- 0
#write.csv(reformed_df, file ="la_crime_data/pre_processed/reformed_for_lasso_violence.csv")
#write.csv(reformed_df, file ="la_crime_data/pre_processed/reformed_for_lasso_property.csv")
write.csv(reformed_df, file ="la_crime_data/pre_processed/reformed_for_lasso_all.csv")