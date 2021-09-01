# -*- coding: utf-8 -*-
"""
Created on Fri Sep 28 20:56:28 2018

@author: Samira
"""

#!/usr/bin/env python

import pandas as pd 
 
df = pd.read_csv("la_crime_data/lat_lon_census_grouped.csv", sep=',', dtype={'CRIMECLASSCODE': object, 'census': object})  
v_data = pd.DataFrame(columns=['CRIMECLASSCODE', 'census', 'count'])

unique_censuses = df['census'].unique()
for index, row in df.iterrows(): 
    if (' ' in row["CRIMECLASSCODE"]) == True:
        my_cat = row["CRIMECLASSCODE"].split()
        for i in range(len(my_cat)):
            crime_cat = my_cat[i]
            v_data = v_data.append({'census': row['census'], 'CRIMECLASSCODE': crime_cat, 'count': row['count']}, ignore_index=True)
    else:
        v_data = v_data.append({'census': row['census'], 'CRIMECLASSCODE': row['CRIMECLASSCODE'], 'count': row['count']},ignore_index=True)
print("here") 
v_data.to_csv('la_crime_data/pre_processed/extracted_crime.csv')