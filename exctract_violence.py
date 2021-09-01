# -*- coding: utf-8 -*-
"""
Created on Fri Sep 28 20:56:28 2018

@author: Samira
"""

#!/usr/bin/env python

import sys
from collections import defaultdict

def sdi(data):
    """ Given a hash { 'species': count } , returns the SDI
    
    >>> sdi({'a': 10, 'b': 20, 'c': 30,})
    1.0114042647073518"""
    
    from math import log as ln
    
    def p(n, N):
        """ Relative abundance """
        if n is  0:
            return 0
        else:
            return (float(n)/N) * ln(float(n)/N)
            
    N = sum(data.values())
    
    return -sum(p(n, N) for n in data.values() if n is not 0)

import pandas as pd
crim_rows = pd.read_csv("la_crime_data/New_data/Crime_Categories_LA.csv", sep=',')
#################################
crim_rows = crim_rows.loc[crim_rows['Row#'] < 144]
crim_rows = crim_rows.loc[crim_rows['Violence'] < 99]                   
#################################                
crime_row_cat = pd.read_csv("la_crime_data/row_crime_category.csv", sep=',', dtype={'crime_cat': object})

dfs = [crim_rows, crime_row_cat]
crim_cats = reduce(lambda left,right: pd.merge(left,right,on='Row#', how = 'inner'), dfs)
                                             

data = crim_cats.loc[:,['Row#', 'crime_cat', 'Violence', 'P1Prop', 'P2P']]
wanted_category = "Conditional_Violence" 
#data_p1 = data.loc[data['P1Prop'] >0]
#data_p2 = data.loc[data['P2P'] >0]

data_violence = data.loc[data['Violence']>0]# data_p1.append(data_p2)
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

xyz_shannon = []
for entry in xyz:
    xyz_shannon.append({"census": entry["census"], "data": entry["data"], "shannon_index": sdi(entry["data"])})
print("here")

#import pickle
#with open('la_crime_data/census_property_shannon.dat', 'wb') as outfile:
#    pickle.dump(xyz_shannon, outfile) 
#
#
#with open('la_crime_data/census_property_shannon.dat') as f:
#    x = pickle.load(f)
#    
#crime_df = pd.DataFrame(x)
#crime_df.columns = ['census', 'crimes', 'crimes_shannon_index']
#crime_df.to_csv('la_crime_data/pre_processed/census_property_shannon.csv')


#import pickle
#with open('la_crime_data/census_violence_shannon.dat', 'wb') as outfile:
#    pickle.dump(xyz_shannon, outfile) 


#with open('la_crime_data/census_violence_shannon.dat') as f:
#    x = pickle.load(f)
    
crime_df = pd.DataFrame(xyz_shannon)
crime_df.columns = ['census', 'crimes', 'crimes_shannon_index']
crime_df.to_csv('la_crime_data/pre_processed/census_conditional_violence_shannon.csv')