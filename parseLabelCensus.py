import json
import pandas as pd
import numpy as np
jsons = []

#with open('la_crime_data/lasp_lat_lon_label_census.json') as f:
with open('la_crime_data/lasp_lat_lon_label_census.json') as f:
    jsons = json.load(f)
np.random.seed(2018)
df = pd.DataFrame([])
for i in range(len(jsons)):
#for i in range(5):
    data = jsons[i]  
    data = pd.DataFrame(data.items())
    data = data.transpose()
    data.columns = data.iloc[0]
    data = data.drop(data.index[[0]])
    df = df.append(data)
print("Here")  
with open('la_crime_data/la_lat_lon_label_census.json') as f:
    jsons = json.load(f)

for i in range(len(jsons)):
#for i in range(5):
    data = jsons[i]  
    data = pd.DataFrame(data.items())
    data = data.transpose()
    data.columns = data.iloc[0]
    data = data.drop(data.index[[0]])
    df = df.append(data)
#grouped = pd.DataFrame({'count' : df.groupby( [ "osmid", "label_description"] ).size()}).reset_index()
#grouped = pd.DataFrame({'count' : df.groupby( [ "census", "label_description"] ).size()}).reset_index()
print("Here") 
grouped = pd.DataFrame({'count' : df.groupby( [ "census", "label_description"] ).size()}).reset_index()
grouped.to_csv("la_crime_data/label_census_grouped.csv", sep=',') 
