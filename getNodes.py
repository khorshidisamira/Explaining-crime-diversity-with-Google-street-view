
"""
nodes = ox.graph_to_gdfs(G, edges=False)

print(nodes)

nodes.to_csv('nodes.txt', sep='\t', encoding='utf-8')

G = ox.graph_from_place('Piedmont, California', network_type='drive')
print(G.edges(keys=True, data=True))

#Or you could use OSMnx to convert the edges to a GeoDataFrame and inspect its columns:

edge_attributes = ox.graph_to_gdfs(G, nodes=False).columns
print(edge_attributes)

import osmnx as ox, networkx as nx
ox.config(log_console=True, use_cache=True)
G = ox.graph_from_place('Los Angeles, California, USA', network_type='drive_service')
city = ox.gdf_from_place('Los Angeles, California')
#print(len(G))
"""

import osmnx as ox
#G = ox.graph_from_place('Los Angeles California USA', network_type='drive')
#city = ox.gdf_from_place('Los Angeles California USA')
		
#G = ox.core.graph_from_bbox(34.1440342, 34.1437138, -118.7610031, -118.7614668)

#ox.plot_graph(G)
#city.to_csv('city.txt', sep='\t', encoding='utf-8')

G = ox.graph_from_place('Los Angeles, Los Angeles County, California, USA', network_type='drive')
#ox.plot_graph(G)
import networkx as nx

gdf_nodes, gdf_edges = ox.graph_to_gdfs(G)
# Create a output path for the data
out = r"nodes.shp"

# Write those rows into a new Shapefile (the default output file format is Shapefile)
gdf_nodes.to_file(out)
"""
print(type(gdf_nodes))
gdf_nodes.head()
gdf_nodes['geometry'].head()

# Iterate rows one at the time
for index, row in gdf_nodes.iterrows():
    print('latitude: ')
    print(row['x'])
#print(gdf_nodes.x.name)
"""
"""
path = nx.shortest_path(G, G.nodes()[0], G.nodes()[1])
gdf_nodes.loc[path]

nodes = ox.graph_to_gdfs(G, edges=False)
for i in range(len(G.node)):
    print(G.node[i])
#G.node[38862848]
#print(nodes)
"""

#nodes.to_csv('nodes.txt', sep='\t', encoding='utf-8')
print("done")
"""
import csv
with open("nodes.txt") as f:
    reader = csv.reader(f,delimiter='\t')
    next(reader) # skip header
    data = [r for r in reader]
    print(data)
"""
