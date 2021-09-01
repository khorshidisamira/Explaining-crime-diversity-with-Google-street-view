
data = []

# Imports the Google Cloud client library
import os,io,json
from google.cloud import vision
from google.cloud.vision import types

# Instantiates a client
client = vision.ImageAnnotatorClient()
def set_default(obj):
    if isinstance(obj, set):
        return list(obj)
    raise TypeError

dirName = os.path.join(os.path.dirname(__file__), 'images/lasp')

for filename in os.listdir(dirName):
    
    baseFileName = os.path.splitext(filename)[0]
    print "filename is:"
    print filename
    print(baseFileName)
    i = baseFileName.split("_")
    # Loads the image into memory
    with io.open(os.path.join(os.path.dirname(__file__), 'images/lasp', filename), 'rb') as image_file:
        content = image_file.read()

    image = types.Image(content=content)

    # Performs label detection on the image file
    response = client.label_detection(image=image)
    labels = response.label_annotations
    #print('Labels:')
    for label in labels:
        data.append({'osmid':i[0], 'node_id': i[1], 'y': i[2], 'x': i[3], 'label_mid': label.mid, 'label_description': label.description, 'label_score': label.score})

    
with open("lasp_label_data.json", "w") as write_file:
    json.dump(data, write_file)
