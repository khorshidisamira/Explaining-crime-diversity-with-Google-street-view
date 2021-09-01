library(tigris)
library(leaflet)
opdata=read.csv("~/Desktop/opioid_hotspot/indy_opioid-geo.csv")
opdata=opdata[(is.element(opdata$QualityInjury,c("ExactParcelCentroidPoint",
                                                 "AddressRangeInterpolation"))&opdata$MCity=="Indianapolis"),]

opdata$Latitude=opdata$LatitudeInjury
opdata$Longitude=opdata$LongitudeInjury
opdata$TYPE="Any_Opioid_Death"
opdata$YEAR=year(mdy(opdata$DOD))
all_opioid=opdata[c("Latitude","Longitude","TYPE","YEAR")]

indy <- block_groups(state = "IN", county = "Marion")

library(totalcensus)

set_path_to_census("~/Desktop/my_census_data")

codes=read.csv("~/Desktop/opioid_hotspot/codes.csv")
acsdata <- read_acs5year(
  year = 2015,
  states = "IN",
  table_contents=as.character(codes$codes),
  summary_level = "block group"
) 


geoids=cSplit(as.data.table(acsdata), "GEOID", "US")


geoids=geoids[is.element(geoids$GEOID_2,indy$GEOID),]
geoids$GEOID=geoids$GEOID_2

all_opioid$x=all_opioid$Longitude
all_opioid$y=all_opioid$Latitude


coordinates(all_opioid)<-~x+y
proj4string(all_opioid) <- CRS("+proj=longlat +ellps=WGS84") 
poly.proj <- proj4string(indy) 
all_opioid <- spTransform(all_opioid,CRS(poly.proj)) 

temp=over(all_opioid,indy)
all_opioid=as.data.frame(all_opioid)
temp=as.data.frame(temp)
all_opioid=cbind(all_opioid,temp)

all_opioid=merge(all_opioid,geoids,by="GEOID")