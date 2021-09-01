# -*- coding: utf-8 -*-
"""
Created on Thu Jul 19 18:34:07 2018

@author: Samira
"""
import urllib, os, json, io, pickle
import numpy as np
import pandas as pd


"""
with open('la_crime_data/nodes/nodes_census_50000.dat', 'rb') as outfile:
    nodes_50000 = pickle.load(outfile) 

with open('la_crime_data/nodes/nodes_census_50000_100000.dat', 'rb') as outfile:
    nodes_100000 = pickle.load(outfile) 

with open('la_crime_data/nodes/nodes_census_100000_150000.dat', 'rb') as outfile:
    nodes_150000 = pickle.load(outfile) 

with open('la_crime_data/nodes/nodes_census_150000_173525.dat', 'rb') as outfile:
    nodes_173525 = pickle.load(outfile) 

with open('la_crime_data/nodes/nodes_census_173525_220000.dat', 'rb') as outfile:
    nodes_220000 = pickle.load(outfile) 

with open('la_crime_data/nodes/nodes_census_200000_250000.dat', 'rb') as outfile:
    nodes_250000 = pickle.load(outfile) 

with open('la_crime_data/nodes/nodes_census_250000_300000.dat', 'rb') as outfile:
    nodes_300000 = pickle.load(outfile) 

frames = nodes_50000 + nodes_100000 + nodes_150000 + nodes_173525 + nodes_220000 + nodes_250000 + nodes_300000

with open('la_crime_data/nodes/nodes_census.dat', 'wb') as outfile:
    pickle.dump(frames, outfile) 
"""    

key = "&key=" + "AIzaSyDDoD92NPPKxZhKnMVxqQXsoLQxkKEQ9C0"
DownLoc = r"la_crime_data/images"
myloc = r"la_crime_data/images" 

# get a verified google account which allows 25,000 image downloads per day.
#You technically could download the historical data if you know the pano id for the image
  
def MetaParse(MetaUrl):# grabs the date (Month and Year) and pano_id from a particular street view image
    response = urllib.urlopen(MetaUrl)
    jsonRaw = response.read()
    jsonData = json.loads(jsonRaw)
    #return jsonData
    if jsonData['status'] == "OK":
        if 'date' in jsonData:
            return (jsonData['date'],jsonData['pano_id']) #sometimes it does not have a date!
        else:
            return (None,jsonData['pano_id'])
    else:
        return (None,None)

PrevImage = [] #Global list that has previous images sampled, memoization kindof        
#if you have already downloaded that image once, the second GetStreetLL function will not download it again, as it checks the PrevImage list.
def GetStreetLL(Lat,Lon,Head,File,SaveLoc):
    base = r"https://maps.googleapis.com/maps/api/streetview"
    size = r"?size=1200x800&fov=60&location="
    end = str(Lat) + "," + str(Lon) + "&heading=" + str(Head) + key
    mid= size
    MyUrl = base + mid + end
    fi = File + ".jpg"
    urllib.urlretrieve(MyUrl, os.path.join(SaveLoc,fi))
    MetaUrl = base + r"/metadata" + size + end
    print MyUrl, MetaUrl #can check out image in browser to adjust size, fov to needs
    met_lis = list(MetaParse(MetaUrl))                           #does not grab image if no date
    if (met_lis[1],Head) not in PrevImage and met_lis[0] is not None:   #PrevImage is global list
        urllib.urlretrieve(MyUrl, os.path.join(SaveLoc,fi))
        met_lis.append(fi)
        PrevImage.append((met_lis[1],Head)) #append new Pano ID to list of images
    else:
        met_lis.append(None)
    return met_lis  


heading = 97.00
EdgePoints = []
DataList = []


with open('la_crime_data/nodes/nodes_census1.dat', 'rb') as outfile:
    nodes = pickle.load(outfile)     
data = pd.DataFrame(nodes)
"""
for index, row in data.iterrows():
    DataList.append((row['lat'], row['lon'], heading, row['census']))
"""
image_list = [] #to stuff the resulting meta-data for images
ct = 0
for index, row in data.iterrows():
    if ct>=0 and ct<25000: #day1
        ct += 1
        fi = str(row['census']) + "_" + str(row['lat']) + "_" + str(row['lon'])
        temp = GetStreetLL(Lat=row['lat'],Lon=row['lon'],Head=heading,File=fi,SaveLoc=DownLoc)
        if temp[2] is not None:
            image_list.append(temp)

with open('la_crime_data/images/image_list_25000.dat', 'wb') as outfile:
    pickle.dump(frames, outfile) 
"""    
with open('la_crime_data/images/image_list_25000.JSON', 'w') as outfile:
    json.dump(image_list, outfile)
"""