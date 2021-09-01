#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue Jul  3 13:26:30 2018

@author: samira
"""

import requests, json
import pandas as pd
import time

def getCensusPopulation(latitude, longitude):
    # api-endpoint
    URL = "https://geo.fcc.gov/api/census/area?format=json"
      
    PARAMS = {'lat':latitude,'lon': longitude}
     
    # sending get request and saving the response as response object
    r = requests.get(url = URL, params = PARAMS)
     
    # extracting data in json format
    data = r.json()
    block_fips_data = data['results']
    return block_fips_data

 
geo_data = []
 
fileName = "la_crime_data/LACRIME-DIVERSITY-13-V8-LatLng.csv"
df = pd.read_csv(fileName, sep=',')

for index, row in df.iterrows(): 
#    if (index >= 160000 and index < 1680000):     
    lat = row["lat"]
    lon = row["lng"]
    block_fip_population_data = getCensusPopulation(lat, lon)
    for j in range(len(block_fip_population_data)):
        geo_data.append({"census": block_fip_population_data[j]["block_fips"], "population":block_fip_population_data[j]["block_pop_2015"]})
    if (index%200 == 0):
        print(index)
    if (index%10000 == 0):
        time.sleep(900)#wait 15 mins

#with open('la_crime_data/lat_lon_census_area_160000_180000.json', 'w') as outfile:
#    json.dump(geo_data, outfile)
