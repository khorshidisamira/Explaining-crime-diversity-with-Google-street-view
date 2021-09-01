library(raster)
library(rgdal)
library(classInt)

library(latticeExtra)
#install.packages("RColorBrewer")
library("RColorBrewer") 
## Loading required package: lattice
## Loading required package: RColorBrewer


h <- readRDS('./la_crime_data/houses2000.rds')

dim(h) 
names(h)

d1 <- data.frame(h)[, c("nhousingUn", "recHouses", "nMobileHom", "nBadPlumbi",
                        "nBadKitche", "Population", "Males", "Females", "Under5", "White",
                        "Black", "AmericanIn", "Asian", "Hispanic", "PopInHouse", "nHousehold", "Families")]

d1a <- aggregate(d1, list(County=h$County), sum, na.rm=TRUE)


d2 <- data.frame(h)[, c("houseValue", "yearBuilt", "nRooms", "nBedrooms",
                        "medHHinc", "MedianAge", "householdS",  "familySize")]
d2 <- cbind(d2 * h$nHousehold, hh=h$nHousehold)

d2a <- aggregate(d2, list(County=h$County), sum, na.rm=TRUE)
d2a[, 2:ncol(d2a)] <- d2a[, 2:ncol(d2a)] / d2a$hh

grps <- 10
brks <- quantile(h$houseValue, 0:(grps-1)/(grps-1), na.rm=TRUE)


p <- spplot(h, "houseValue", at=brks, col.regions=rev(brewer.pal(grps, "RdBu")), col="transparent" )
p + layer(sp.polygons(hh))
