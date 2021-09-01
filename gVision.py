# -*- coding: utf-8 -*-
"""
Created on Sun May 20 13:13:25 2018

@author: Samira
"""

import io,json
import os
data = []

# Imports the Google Cloud client library
from google.cloud import vision
from google.cloud.vision import types

# Instantiates a client
client = vision.ImageAnnotatorClient()
def set_default(obj):
    if isinstance(obj, set):
        return list(obj)
    raise TypeError

dirName = os.path.join(os.path.dirname(__file__), 'images/la10')
for filename in os.listdir(dirName):
    print(filename)
    # Loads the image into memory
    with io.open(os.path.join(os.path.dirname(__file__), 'images/la10', filename), 'rb') as image_file:
        content = image_file.read()

    image = types.Image(content=content)

    # Performs label detection on the image file
    response = client.label_detection(image=image)
    labels = response.label_annotations
    print('Labels:')
    data.append({"image_name": filename, "label_annotations": labels})
print(str(data))


"""
with open("la_label_annotations.json", "w") as write_file:
    json.dump(data, default=set_default, write_file)
    

# The name of the image file to annotate
file_name = os.path.join(os.path.dirname(__file__), 'images/hose_dog.jpeg')

# Loads the image into memory
with io.open(file_name, 'rb') as image_file:
    content = image_file.read()

image = types.Image(content=content)

# Performs label detection on the image file
response = client.label_detection(image=image)
labels = response.label_annotations

print('Labels:')
for label in labels:
    print(label.description)
"""
