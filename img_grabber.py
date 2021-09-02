# -*- coding: utf-8 -*-
"""
Created on Wed May 16 19:29:46 2018

@author: Samira
"""

import urllib, os, json
key = "&key=" + "YourAPI KEY"
DownLoc = r".\images"
myloc = r".images" #replace with your own location
"""
def GetStreet(Add,SaveLoc):
  base = "https://maps.googleapis.com/maps/api/streetview?size=1200x800&location="
  MyUrl = base + urllib.quote_plus(Add) + key #added url encoding
  fi = Add + ".jpg"
  urllib.urlretrieve(MyUrl, os.path.join(SaveLoc,fi))

Tests = ["457 West Robinwood Street, Detroit, Michigan 48203",
         "1520 West Philadelphia, Detroit, Michigan 48206",
         "2292 Grand, Detroit, Michigan 48238",
         "15414 Wabash Street, Detroit, Michigan 48238",
         "15867 Log Cabin, Detroit, Michigan 48238",
         "3317 Cody Street, Detroit, Michigan 48212",
         "14214 Arlington Street, Detroit, Michigan 48212"]

for i in Tests:
  GetStreet(Add=i,SaveLoc=myloc)
""" 
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

DataList = [(40.7036043470179800,-74.0143908501053400,97.00),
            (40.7037139540670900,-74.0143727485309500,97.00),
            (40.7038235569946140,-74.0143546472568100,97.00),
            (40.7039329592712600,-74.0143365794219800,97.00),
            (40.7040422704154500,-74.0143185262956300,97.00),
            (40.7041517813782500,-74.0143004403322000,97.00),
            (40.7042611636045350,-74.0142823755611700,97.00),
            (40.7043707615693800,-74.0142642750708300,97.00)]

    
image_list = [] #to stuff the resulting meta-data for images
ct = 0
for i in DataList:
    ct += 1
    fi = "Image_" + str(ct)
    temp = GetStreetLL(Lat=i[0],Lon=i[1],Head=i[2],File=fi,SaveLoc=DownLoc)
    if temp[2] is not None:
        image_list.append(temp)
