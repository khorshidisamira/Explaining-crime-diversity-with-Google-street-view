# -*- coding: utf-8 -*-
"""
Created on Mon Jun 25 08:24:21 2018

@author: Samira
"""

#!/usr/bin/env python

# Simpson Diversity Index
# http://en.wikipedia.org/wiki/Diversity_index

# modified from Shannon Diversity Index implementation by audy
# https://gist.github.com/audy/783125
# https://gist.github.com/audy

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
    import numpy as np
#doctest.testmod()
#grouped_df = sdi({'a': 10, 'b': 20, 'c': 30})
df = pd.read_csv("grouped.csv", sep=',') 

from collections import defaultdict

      
dic = defaultdict(list)
unique_osmids = df['osmid'].unique()

for index, row in df.iterrows():
#    if index<3700:
    for mygroup in unique_osmids: 
        if row["osmid"] == mygroup:
            dic[mygroup].append({row["label_description"]: row["count"]})
xyz = []
print "line 64"
for entry,data in dic.iteritems():
    result = {}
    for d in data:
        result.update(d)
    xyz.append({"osmid": entry, "data": result})

xyz_simpson = []
print "line 72"
for entry in xyz:
    xyz_simpson.append({"osmid": entry["osmid"], "data": entry["data"], "simpson_index": simpson_di(entry["data"])})

import json,pickle
with open('simpson.dat', 'w') as outfile:
    pickle.dump(xyz_simpson, outfile) 
with open('simpson.dat') as f:
    x = pickle.load(f)

#np.savetxt('simpson_di.txt', str(xyz_simpson))