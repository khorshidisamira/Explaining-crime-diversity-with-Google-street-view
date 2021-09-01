# -*- coding: utf-8 -*-
"""
Created on Fri Jun 29 17:02:57 2018

@author: Samira
"""
import pickle
import json
import pandas as pd

def correlation_matrix(df):
    from matplotlib import pyplot as plt
    from matplotlib import cm as cm

    fig = plt.figure()
    ax1 = fig.add_subplot(111)
    cmap = cm.get_cmap('jet', 30)
    cax = ax1.imshow(df.corr(), interpolation="nearest", cmap=cmap)
    ax1.grid(True)
    plt.title('Object diversity-Crime diversity Correlation')
    labels=['labels_shannon_index','crimes_shannon_index']
    ax1.set_xticklabels(labels,fontsize=6)
    ax1.set_yticklabels(labels,fontsize=6)
    # Add colorbar, make sure to specify tick locations to match desired ticklabels
    fig.colorbar(cax, ticks=[.05,.065,.080,.095,.1,0.15,030])
    plt.show()
    
with open('la_crime_data/census_label_shannon.dat', "rb") as f:
    x = pickle.load(f)
label_df = pd.DataFrame(x)
label_df.columns = ['census', 'labels', 'labels_shannon_index']

with open('la_crime_data/census_crime_shannon.dat') as f:
    x = pickle.load(f)
crime_df = pd.DataFrame(x)
crime_df.columns = ['census', 'crimes', 'crimes_shannon_index']

with open('la_crime_data/lat_lon_census_population.json') as f:
    jsons = json.load(f)
population_df = pd.DataFrame(jsons)  
population_df.columns = ['census', 'population']
"""
population_census = population_df[population_df.columns[0]]
crime_census = crime_df[crime_df.columns[0]]
common = pd.Series(list(set(population_census) & set(crime_census)))
"""

df_crime_population = crime_df.merge(population_df, on="census", how = 'inner')
df_crime_population = df_crime_population[['crimes_shannon_index', 'population']]
df_crime_population.corr()

df_label_population = label_df.merge(population_df, on="census", how = 'inner')
df_label_population = df_label_population[['labels_shannon_index', 'population']]
df_label_population.corr()

dfs = [label_df, crime_df, population_df]
df_crime_label_population = reduce(lambda left,right: pd.merge(left,right,on='census', how = 'inner'), dfs)
df_crime_label_population = df_crime_label_population[['labels_shannon_index','crimes_shannon_index', 'population']]
df_crime_label_population.corr()

#import matplotlib.pyplot as plt
#df.corr(method='pearson').style.format("{:.2}").background_gradient(cmap=plt.get_cmap('coolwarm'), axis=1)
#correlation_matrix(df)
