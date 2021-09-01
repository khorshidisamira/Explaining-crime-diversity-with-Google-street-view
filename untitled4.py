# -*- coding: utf-8 -*-
"""
Created on Thu Aug 30 12:17:44 2018

@author: Samira
"""

import pandas as pd
df = pd.read_csv("la_crime_data/LACRIME-DIVERSITY-13-V8-LatLng.csv", sep=',')  
 
crimes_class_codes = df['CRIMECLASSCODES'].unique()
pd.DataFrame(crimes_class_codes).to_csv("la_crime_data/unique_crimes_code.csv")