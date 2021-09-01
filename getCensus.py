import requests, pickle, json
import pandas as pd

def getNodeCensus(latitude, longitude):
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
 
with open('imgPoints.json') as f:
    jsons = json.load(f)
df = pd.DataFrame(jsons)  

for index, row in df.iterrows(): 
    if (index >=250000 and index <300000):     
        lat = row["y"]
        lon = row["x"]
        block_fip_data = getNodeCensus(lat, lon)
        for j in range(len(block_fip_data)):
            geo_data.append({"census": block_fip_data[j]["block_fips"], "lat": lat, "lon": lon})
        if (index%200 == 0):
            print index

with open('la_crime_data/nodes/nodes_census_250000_300000.dat', 'wb') as outfile:
    pickle.dump(geo_data, outfile) 

























