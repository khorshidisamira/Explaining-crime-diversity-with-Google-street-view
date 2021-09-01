# -*- coding: utf-8 -*-
"""
Created on Wed May 16 19:29:46 2018

@author: Samira
"""

import urllib, os, json, io
import geopandas as gpd
import numpy as np
key = "&key=" + "AIzaSyDDoD92NPPKxZhKnMVxqQXsoLQxkKEQ9C0"
DownLoc = r"/home/samira/Dropbox/Dr Mohler/Crime discovery/images/la10"
myloc = r"/home/samira/Dropbox/Dr Mohler/Crime discovery/images/la" #replace with your own location
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
"""
DataList = [(40.7036043470179800,-74.0143908501053400,97.00),
            (40.7037139540670900,-74.0143727485309500,97.00),
            (40.7038235569946140,-74.0143546472568100,97.00),
            (40.7039329592712600,-74.0143365794219800,97.00),
            (40.7040422704154500,-74.0143185262956300,97.00),
            (40.7041517813782500,-74.0143004403322000,97.00),
            (40.7042611636045350,-74.0142823755611700,97.00),
            (40.7043707615693800,-74.0142642750708300,97.00)]
"""

heading = 97.00
EdgePoints = []
DataList = []

fp = "nodes.shp"
"""
# Read file using gpd.read_file()
data = gpd.read_file(fp)
for index, row in data.iterrows():
    DataList.append((row['y'], row['x'], heading, row['osmid']))

"""
"""
efp = "edges.shp"
EdgesList = []
EdgesJson = []
osmidPoints = []
imgPoints = []
# Read file using gpd.read_file()
#edges_data = gpd.read_file(efp)
import osmnx as ox
G = ox.graph_from_place('Los Angeles, Los Angeles County, California, USA', network_type='drive')
gdf_nodes, edges_data = ox.graph_to_gdfs(G)
print(type(edges_data))
print(edges_data.head())

for index, row in edges_data.iterrows():
    #EdgesList.append((row['u'], row['v'], row['key'], row['osmid']))
    #EdgesJson.append({'u':row['u'], 'v': row['v'], 'key':row['key'], 'osmid':row['osmid']})
    #EdgePoints.append({'osmid':row['osmid'], 'u_id': row['u'],'v_id':row['v'], 'u': {'y': G.node[row['u']]['y'], 'x': G.node[row['u']]['x']}, 'v':{'y': G.node[row['v']]['y'], 'x': G.node[row['v']]['x']}})
    #osmidPoints.append({'osmid':row['osmid'], 'node': {'y': G.node[row['u']]['y'], 'x': G.node[row['u']]['x']}})

    imgPoints.append({'osmid':row['osmid'], 'node_id': row['u'], 'y': G.node[row['u']]['y'], 'x': G.node[row['u']]['x']})
    imgPoints.append({'osmid':row['osmid'], 'node_id': row['v'], 'y': G.node[row['v']]['y'], 'x': G.node[row['v']]['x']})

edge_attributes = ox.graph_to_gdfs(G, nodes=False).columns
print(edge_attributes)


#with open('EdgePoints.JSON', 'w') as outfile:
#    json.dump(EdgePoints, outfile)

#with open('osmidPoints.JSON', 'w') as outfile:
#    json.dump(osmidPoints, outfile)

#with open('EdgesJson.JSON', 'w') as outfile:
#    json.dump(EdgesJson, outfile)

with open('imgPoints.JSON', 'w') as outfile:
    json.dump(imgPoints, outfile)
"""
"""	
print "EDGES::::"
print(len([i[3] for i in EdgesList]))#[:,3])
print(len(np.unique([i[3] for i in EdgesList if type(i[3])!=list])))


print "NODES:::"
print(len([i[3] for i in DataList]))#[:,3])
print(len(np.unique([i[3] for i in DataList])))
"""
"""
image_list = [] #to stuff the resulting meta-data for images
ct = 0
for i in imgPoints:
    #if ct<100:
    ct += 1
    fi = str(i['osmid']) + "_"  + str(i['node_id']) + "_" + str(i['y']) + "_" + str(i['x'])
    temp = GetStreetLL(Lat=i['y'],Lon=i['x'],Head=97.0,File=fi,SaveLoc=DownLoc)
    if temp[2] is not None:
        image_list.append(temp)

with open('image_list.JSON', 'w') as outfile:
    json.dump(image_list, outfile)


"""

data = []

# Imports the Google Cloud client library
from google.cloud import vision
from google.cloud.vision import types

# Instantiates a client
client = vision.ImageAnnotatorClient()
def set_default(obj):
    if isinstance(obj, set):
        return list(obj)
    raise TypeError

dirName = os.path.join(os.path.dirname(__file__), 'images/la10')

for filename in os.listdir(dirName):
    
    baseFileName = os.path.splitext(filename)[0]
    print "filename is:"
    print filename
    print(baseFileName)
    i = baseFileName.split("_")
    # Loads the image into memory
    with io.open(os.path.join(os.path.dirname(__file__), 'images/la10', filename), 'rb') as image_file:
        content = image_file.read()

    image = types.Image(content=content)

    # Performs label detection on the image file
    response = client.label_detection(image=image)
    labels = response.label_annotations
    #print('Labels:')
    for label in labels:
        data.append({'osmid':i[0], 'node_id': i[1], 'y': i[2], 'x': i[3], 'label_mid': label.mid, 'label_description': label.description, 'label_score': label.score})

    
#print(str(data))
"""
for i in imgPoints: 
    filename = str(i['osmid']) + "_"  + str(i['node_id']) + "_" + str(i['y']) + "_" + str(i['x']) + ".jpg"
    print(os.path.join(os.path.dirname(__file__), 'images/la10', filename))
    with io.open(os.path.join(os.path.dirname(__file__), 'images/la10', filename), 'rb') as image_file:
        content = image_file.read()

    image = types.Image(content=content)

    # Performs label detection on the image file
    response = client.label_detection(image=image)
    labels = response.label_annotations
    #print('Labels:')
    for lable in labels:
        data.append({'osmid':i['osmid'], 'node_id': i['node_id'], 'y': i['y'], 'x': i['x'], 'label_mid': label.mid, 'label_description': label.description, 'label_score': label.score})
"""
with open("la_label_data.json", "w") as write_file:
    json.dump(data, write_file)

"""
with open("la_label_annotations.json", "w") as write_file:
    json.dump(data, default=set_default, write_file)
    

# The name of the image file to annotate
file_name = os.path.join(os.path.dirname(__file__), 'images/hose_dog.jpeg')

# Loads the image into memory
with io.open(file_name, 'rb') as image_file:
    content = image_file.read()

image = types.Image(content=content)

# Performs label detection on the image file
response = client.label_detection(image=image)
labels = response.label_annotations

print('Labels:')
for label in labels:
    print(label.description)
"""
