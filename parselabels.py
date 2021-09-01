import json
"""

data = []
with open('la_label_data.json') as f:
    data = json.load(f)
 
"""
#result = json_normalize(data,'osmid', ['y', 'x', 'node_id', 'label_mid', 'label_score', 'label_description'])
import pandas as pd
import numpy as np
jsons = []

with open('la_label_data.json') as f:
    jsons = json.load(f)
np.random.seed(2015)
df = pd.DataFrame([])
for i in range(len(jsons)):
#for i in range(5):
    data = jsons[i]
    myosmid = data['osmid']
    #data = dict(zip(np.random.choice(10, replace=False, size=5), np.random.randint(10, size=5)))
    data = pd.DataFrame(data.items())
    data = data.transpose()
    data.columns = data.iloc[0]
    data = data.drop(data.index[[0]])
    df = df.append(data)
print("Here")   
spjsons = []
with open('lasp_la_label_data.json') as f:
    spjsons = json.load(f)
    
for i in range(len(spjsons)):
#for i in range(5):
    data = spjsons[i]
    x = json.loads(data['osmid'])
    for j in range(len(x)):
        datadict = {'osmid': x[j],'y': data['y'], 'x': data['x'], 'node_id': data['node_id'], 'label_mid': data['label_mid'], 'label_score': data['label_score'], 'label_description': data['label_description']}
        datadict = pd.DataFrame(datadict.items())
        datadict = datadict.transpose()
        datadict.columns = datadict.iloc[0]
        datadict = datadict.drop(datadict.index[[0]])
        df = df.append(datadict)  
        
file_name = "la.csv"        
#df.to_csv(file_name, sep='\t')

df = pd.read_csv(file_name, sep='\t')

text_df = df.loc[(df['label_description'] == 'text')]
#grouped = pd.DataFrame({'count' : df.groupby( [ "osmid", "label_description"] ).size()}).reset_index()
grouped = pd.DataFrame({'count' : df.groupby( [ "osmid", "label_description"] ).size()}).reset_index()
grouped.to_csv("grouped.csv", sep=',')
text_grouped = pd.DataFrame({'count' : text_df.groupby( [ "osmid", "label_description", "x", "y"] ).size()}).reset_index()
text_grouped.to_csv("text_grouped_latlong.csv", sep=',')

import numpy as np
import matplotlib.pyplot as plt

# Fixing random state for reproducibility
np.random.seed(19680801)


N = 50
x = text_df['x'] #np.random.rand(N)
y = text_df['y'] #np.random.rand(N)
colors = np.random.rand(N)
 
plt.title("Text Nodes")
plt.figure(figsize=(12,16))
plt.scatter(x, y, alpha=0.5)
plt.show()

unique_labels = df['label_description'].unique()
np.savetxt('unique_labels.txt', unique_labels, delimiter=',', fmt='%s')