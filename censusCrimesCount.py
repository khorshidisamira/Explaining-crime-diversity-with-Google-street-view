# -*- coding: utf-8 -*-
"""
Created on Fri Sep 28 20:56:28 2018

@author: Samira
"""
#!/usr/bin/env python
from collections import defaultdict

import pandas as pd
from functools import reduce
crim_rows = pd.read_csv("la_crime_data/New_data/Crime_Categories_LA.csv", sep=',')
#################################
#crim_rows = crim_rows.loc[crim_rows['Row#'] < 144]
#crim_rows = crim_rows.loc[crim_rows['Violence'] < 99]                   
#################################                
crime_row_cat = pd.read_csv("la_crime_data/row_crime_category.csv", sep=',', dtype={'crime_cat': object})

dfs = [crim_rows, crime_row_cat]
crim_cats = reduce(lambda left,right: pd.merge(left,right,on='Row#', how = 'inner'), dfs)
                                             

data = crim_cats.loc[:,['Row#', 'crime_cat', 'Violence', 'P1Prop', 'P2P']]
wanted_category = "Violence" 
data_violence = data.loc[data['Violence']>0]

#########################for property
#wanted_category = "Property" 
#data_p1 = data.loc[data['P1Prop'] >0]
#data_p2 = data.loc[data['P2P'] >0]
#data_violence = data_p1.append(data_p2)
##############################################
target_cats = data_violence["crime_cat"]
 
df = pd.read_csv("la_crime_data/pre_processed/extracted_crime.csv", sep=',', dtype={'CRIMECLASSCODE': object, 'census': object})
target_df = df.loc[df['CRIMECLASSCODE'].isin(target_cats)]#.loc[:, lambda df: df['CRIMECLASSCODE'] in target_cats] #df.loc[(df['CRIMECLASSCODE'] in target_cats)]

#df = pd.read_csv("la_crime_data/lat_lon_census_grouped.csv", sep=',', dtype={'CRIMECLASSCODE': object})
v_data = pd.DataFrame()#columns=['CRIMECLASSCODE', 'census', 'count']

dic = defaultdict(list)
unique_censuses = df['census'].unique()
for index, row in target_df.iterrows(): 
    for mygroup in unique_censuses:  
        if row["census"] == mygroup: 
            dic[mygroup].append({row["CRIMECLASSCODE"]: row["count"]})
xyz = []
for entry,data in dic.iteritems():
    result = {}
    for d in data:
        result.update(d)
    xyz.append({"census": entry, "data": result})

xyz_counts = []
for entry in xyz:
    data = entry["data"]
    xyz_counts.append({"census": entry["census"], "data": entry["data"], "crimes": sum(data.values())})
print("here")

crime_df = pd.DataFrame(xyz_counts)
crime_df.columns = ['census', 'crimes', 'crimes']
crime_df.to_csv('la_crime_data/pre_processed/census_violence_counts.csv')