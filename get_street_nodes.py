# -*- coding: utf-8 -*-
"""
Created on Tue May 22 14:26:57 2018

@author: Samira
"""

import osmnx as ox
import matplotlib
import numpy as np
import matplotlib.pyplot as plt
#matplotlib inline  
city = ox.gdf_from_place('Los Angeles, California')
ox.plot_shape(ox.project_gdf(city))
place_name = "Kamppi, Helsinki, Finland"
graph = ox.graph_from_place(place_name)

type(graph)
