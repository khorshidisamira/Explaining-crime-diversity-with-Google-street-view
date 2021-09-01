# -*- coding: utf-8 -*-
"""
Created on Thu Jul 12 23:57:38 2018

@author: Samira
"""
from __future__ import division
import pickle
import json
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt  
from sklearn.metrics import mean_squared_error


with open('la_crime_data/lat_lon_census_population.json') as f:
    jsons = json.load(f)
population_df = pd.DataFrame(jsons)  

unique_population_df = population_df.groupby('census').first()
unique_population_df.to_csv('la_crime_data/census_population.csv')
population_df = unique_population_df.reset_index()#pd.read_csv('la_crime_data/census_population.csv')
population_df.columns = ['census', 'population']

pop_df = pd.read_csv("la_crime_data/total_population/ACS_16_5YR_B01003_with_ann.csv", sep=',') 
sc = ["census"] + ["HD01_VD%02d" % i for i in range(1,2)]

pop_df = pop_df.loc[1:,sc] 
pop_df.columns = ['census', 'population']
pop_df.census = np.int64(pop_df.census)

pop_census = pop_df[pop_df.columns[0]]
population_census = population_df[population_df.columns[0]]
#??????????????????????
common = pd.Series(list(set(pop_census) & set(population_census)))
unique_population_census = population_census.unique()
unique_pop_census = pop_census.unique()
#?????????????????????????

# Creating the dataset
dfs = [population_df, pop_df]
dataset = reduce(lambda left,right: pd.merge(left,right,on='census', how = 'inner'), dfs)


merged = population_df.merge(pop_df,on='census', how = 'inner')
pop_m = pop_df.merge(population_df,on='census', how = 'inner')