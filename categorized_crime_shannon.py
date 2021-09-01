# -*- coding: utf-8 -*-
"""
Created on Fri Sep 28 20:56:28 2018

@author: Samira
"""

#!/usr/bin/env python

# Shannon Diversity Index
# http://en.wikipedia.org/wiki/Shannon_index

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

def simpson_di(data):

    """ Given a hash { 'species': count } , returns the Simpson Diversity Index
    
    >>> simpson_di({'a': 10, 'b': 20, 'c': 30,})
    0.3888888888888889
    """

    def p(n, N):
        """ Relative abundance """
        if n is  0:
            return 0
        else:
            return float(n)/N

    N = sum(data.values())
    
    return sum(p(n, N)**2 for n in data.values() if n is not 0)


def inverse_simpson_di(data):
    """ Given a hash { 'species': count } , returns the inverse Simpson Diversity Index
    
    >>> inverse_simpson_di({'a': 10, 'b': 20, 'c': 30,})
    2.571428571428571
    """
    return float(1)/simpson_di(data)

if __name__ == '__main__':
    import pandas as pd
#doctest.testmod()
#grouped_df = sdi({'a': 10, 'b': 20, 'c': 30})
#df = pd.read_csv("la_crime_data/label_census_grouped.csv", sep=',')  
crim_cats = pd.read_csv("la_crime_data/New_data/Crime_Categories_LA.csv", sep=',')  
data = crim_cats.loc[:,['Row#','Violence', 'P1Prop', 'P2P']]
wanted_category = "violence"
data_violence = data.loc[data['Violence'] >0]
target_cats = data_violence["Row#"]
                           
df = pd.read_csv("la_crime_data/lat_lon_census_grouped.csv", sep=',')  
 
dic = defaultdict(list)
unique_osmids = df['census'].unique()

for index, row in df.iterrows():
    for mygroup in unique_osmids: 
        if row["census"] == mygroup:
            #Check whether this row is wanted or not
            my_cat = row["CRIMECLASSCODE"].split()
            #target = False
            for i in range(len(my_cat)):
            #    if my_cat[i] in target_cats:
            #        target = True
            #if target:
                dic[mygroup].append({my_cat[i]: row["count"]})
xyz = []
print("Line 92")

for entry,data in dic.iteritems():
    result = {}
    for d in data:
        result.update(d)
    xyz.append({"census": entry, "data": result})

xyz_shannon = []
for entry in xyz:
    xyz_shannon.append({"census": entry["census"], "data": entry["data"], "shannon_index": sdi(entry["data"])})
print("here")

import pickle
with open('la_crime_data/census_violent_shannon.dat', 'wb') as outfile:
    pickle.dump(xyz_shannon, outfile) 
with open('shannon.dat') as f:
    x = pickle.load(f)
   