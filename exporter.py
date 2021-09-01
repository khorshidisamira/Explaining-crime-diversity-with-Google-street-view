# -*- coding: utf-8 -*-
"""
Created on Sat Jul 28 22:56:48 2018

@author: Samira
"""
import urllib, os, json, io, pickle
import numpy as np
import pandas as pd
"""
with open('la_crime_data/nodes/nodes_census1.dat', 'rb') as outfile:
    nodes = pickle.load(outfile)     
data = pd.DataFrame(nodes)
data.to_csv('la_crime_data/nodes/nodes.csv')
"""


df = pd.read_csv("la_crime_data/nodes/nodes.csv")
from shapely.geometry import Point

# combine lat and lon column to a shapely Point() object
df['geometry'] = df.apply(lambda x: Point((float(x.lon), float(x.lat))), axis=1)

import geopandas
df = geopandas.GeoDataFrame(df, geometry='geometry')
df.to_file('la_crime_data/laGeometries.shp', driver='ESRI Shapefile')