
heading = 97.00
DataList = []
import geopandas as gpd
fp = "nodes.shp"

# Read file using gpd.read_file()
data = gpd.read_file(fp)
for index, row in data.iterrows():
    #DataList.append((row['y'], row['x']))
    DataList.append({'y': row['y'], 'x': row['x']})
	
print(DataList)

import json
with open('data.JSON', 'w') as outfile:
    json.dump(DataList, outfile)
