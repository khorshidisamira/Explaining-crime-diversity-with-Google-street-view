# Packages
#install.packages("gpclib_1.5-5.tar.gz", repos = NULL, type="source")
library(stringr)
library(ggplot2)
library(mapdata)
library(maptools)
library("gpclib")
library(rgeos)
library(raster)
library(sp)
library(rgdal)

MyData <-read.csv("la_crime_data/nodes/nodes.csv",header=TRUE)
WGScoor <- MyData
coordinates(WGScoor)=~lon+lat
proj4string(WGScoor)<- CRS("+proj=longlat +datum=WGS84")
raster::shapefile(WGScoor, "la_crime_data/la.shp", overwrite=TRUE)

#investigate the result
#ogrinfo -so -al la_crime_data/la.shp #in commandline

