import osmnx as ox
G = ox.graph_from_place('Los Angeles, Los Angeles County, California, USA', network_type='drive')
import networkx as nx

#gdf_nodes, gdf_edges = ox.graph_to_gdfs(G)
#print(type(gdf_edges))
#print(gdf_edges.head())


edge_attributes = ox.graph_to_gdfs(G, nodes=False).columns
print(edge_attributes)


nodes_attributes = ox.graph_to_gdfs(G, edges=False).columns
print(nodes_attributes)
"""
print(type(gdf_edges))
print(gdf_edges.head().osmid.count())
print(gdf_edges.head().osmid.nunique())
"""
# Create a output path for the data
#out = r"edges.shp"

# Write those rows into a new Shapefile (the default output file format is Shapefile)
#gdf_edges.to_file(out)
print("done")


