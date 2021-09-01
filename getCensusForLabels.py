# -*- coding: utf-8 -*-
"""
Created on Wed Jun 27 16:59:48 2018

@author: Samira
"""

import requests, json
import pandas as pd

def getCensusId(latitude, longitude):
    # api-endpoint
    URL = "https://geo.fcc.gov/api/census/area?format=json"
      
    PARAMS = {'lat':latitude,'lon': longitude}
     
    # sending get request and saving the response as response object
    r = requests.get(url = URL, params = PARAMS)
     
    # extracting data in json format
    data = r.json()
    block_fips = data['results'][0]['block_fips']
  
    return block_fips


fileName = "lasp_la_label_data.json"
labelData = []
geo_data = []

with open(fileName) as f:
    labelData = json.load(f)
for i in range(len(labelData)):
    label_description = labelData[i]['label_description']     
    if(i%100)==0:
          print(i)
    lat = labelData[i]["y"]
    lon = labelData[i]["x"]
    block_fips = getCensusId(lat, lon)
    geo_data.append({"lat": lat, "lon": lon, "census": block_fips, "label_description":labelData[i]['label_description'],'label_mid': labelData[i]['label_mid'], 'label_score': labelData[i]['label_score']})

with open('la_crime_data/lasp_lat_lon_label_census.json', 'w') as outfile:
    json.dump(geo_data, outfile)
        