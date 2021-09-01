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
 
with open('la_crime_data/census_label_shannon.dat', "rb") as f:
    x = pickle.load(f)
label_df = pd.DataFrame(x)
label_df.columns = ['census', 'labels', 'labels_shannon_index']
label_df.census = np.int64(label_df.census)
label_df.to_csv('la_crime_data/pre_processed/label_df.csv')

with open('la_crime_data/census_crime_shannon.dat') as f:
    x = pickle.load(f)
crime_df = pd.DataFrame(x)
crime_df.columns = ['census', 'crimes', 'crimes_shannon_index']
crime_df.to_csv('la_crime_data/pre_processed/crime_df.csv')
crime_df.census = np.int64(crime_df.census)

population_df = pd.read_csv('la_crime_data/census_population.csv')
population_df.columns = ['census', 'population']
population_df.census = np.int64(population_df.census)

"""
population_df = pd.read_csv("la_crime_data/total_population/ACS_16_5YR_B01003_with_ann.csv", sep=',') 
sc = ["census"] + ["HD01_VD%02d" % i for i in range(1,2)]#income without estimated error
population_df = population_df.loc[1:,sc] 
population_df.columns = ['census', 'population']
population_df.census = np.int64(population_df.census)
"""
with open('la_crime_data/census_household_shannon.dat') as f:
    x = pickle.load(f)
household_df = pd.DataFrame(x)
household_df.columns = ['census', 'household', 'household_shannon_index']
household_df.census = np.int64(household_df.census)

with open('la_crime_data/census_language_shannon.dat') as f:
    x = pickle.load(f)
language_df = pd.DataFrame(x)
language_df.columns = ['census', 'language', 'language_shannon_index']
language_df.census = np.int64(language_df.census)

with open('la_crime_data/census_race_shannon.dat') as f:
    x = pickle.load(f)
race_df = pd.DataFrame(x)
race_df.columns = ['census', 'race', 'race_shannon_index']
race_df.census = np.int64(race_df.census)

with open('la_crime_data/nodes/nodes_census1.dat', 'rb') as outfile:
    nodes = pickle.load(outfile)     
nodes_df = pd.DataFrame(nodes)
nodes_df.to_csv('la_crime_data/pre_processed/nodes_df.csv')
nodes_df.census = np.int64(nodes_df.census)

income_df = pd.read_csv("la_crime_data/per_capita_income/ACS_16_5YR_B19301_with_ann.csv", sep=',') 
sc = ["census"] + ["HD01_VD%02d" % i for i in range(1,2)]#income without estimated error
income_df = income_df.loc[1:,sc] 
income_df.columns = ['census', 'income']
income_df.census = np.int64(income_df.census)

"""
remove block group part of census id START

label_df[label_df.columns[0]] = label_df[label_df.columns[0]].astype(str).str[:-3].astype(np.int64)
population_df[population_df.columns[0]] = population_df[population_df.columns[0]].astype(str).str[:-3].astype(np.int64)
household_df[household_df.columns[0]] = household_df[household_df.columns[0]].astype(str).str[:-3].astype(np.int64)
language_df[language_df.columns[0]] = language_df[language_df.columns[0]].astype(str).str[:-3].astype(np.int64)
race_df[race_df.columns[0]] = race_df[race_df.columns[0]].astype(str).str[:-3].astype(np.int64)
income_df[income_df.columns[0]] = income_df[income_df.columns[0]].astype(str).str[:-3].astype(np.int64)
crime_df[crime_df.columns[0]] = crime_df[crime_df.columns[0]].astype(str).str[:-3].astype(np.int64)

remove block group part of census id END
"""

household_census = household_df[household_df.columns[0]]
language_census = language_df[language_df.columns[0]]
race_census = race_df[race_df.columns[0]]
income_census = income_df[income_df.columns[0]]
population_census = population_df[population_df.columns[0]]
crime_census = crime_df[crime_df.columns[0]]
label_census = label_df[label_df.columns[0]]
nodes_census = nodes_df[nodes_df.columns[0]]

#??????????????????????
commoncrime_label = pd.Series(list(set(crime_census) & set(nodes_census) ))
common = pd.Series(list(set(household_census) & set(language_census) & set(race_census) & set(income_census) & set(nodes_census)))
#?????????????????????????


# Creating the dataset
dfs = [label_df, population_df, household_df, language_df, race_df, income_df, crime_df]
dataset = reduce(lambda left,right: pd.merge(left,right,on='census', how = 'inner'), dfs)

dataset.set_index('census')
dataset.to_csv('la_crime_data/dataset.csv')
"""
with open('la_crime_data/dataset_with_unique_rows.dat', 'wb') as outfile:
    pickle.dump(dataset, outfile) 
"""
"""
X = dataset.iloc[:, [2, 3, 5, 7, 9, 10]].values
y = dataset.iloc[:, 12].values
y[y < 0.0000001] = 0


# Taking care of missing data
from sklearn.preprocessing import Imputer
imputer = Imputer(missing_values = 'NaN', strategy = 'mean', axis = 0)
imputer = imputer.fit(X[:, 0:6])
X[:, 0:6] = imputer.transform(X[:, 0:6])


# Splitting the dataset into the Training set and Test set
from sklearn.cross_validation import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 0)
"""
"""
# Feature Scaling
from sklearn.preprocessing import StandardScaler
sc_X = StandardScaler()
X_train = sc_X.fit_transform(X_train)
X_test = sc_X.transform(X_test)
sc_y = StandardScaler()
y_train = sc_y.fit_transform(y_train)
"""
"""
# Fitting Multiple Linear Regression to the Training set
from sklearn.linear_model import LinearRegression
regressor = LinearRegression()

regressor.fit(X_train, y_train)

# Predicting the Test set results
y_pred = regressor.predict(X_test)

mse =  mean_squared_error(y_test, y_pred) 
score = regressor.score(X_train,y_train)
coef = regressor.coef_ 

from sklearn.feature_selection import f_regression

f_val, p_val = f_regression(X, y, center=True)
"""