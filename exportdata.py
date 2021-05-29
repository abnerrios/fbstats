import os
import pandas as pd
from pymongo import MongoClient
from dotenv import load_dotenv
import json
load_dotenv()

mongo = MongoClient(os.getenv('MONGO_CONNECTION_STRING'))

db = mongo.footstats

# squads

cursor = db.squads.find()
squads = []

for squad in cursor:
  squads.append(squad)

df = pd.DataFrame(squads)

df.to_csv('squads.csv',header=True, sep=';', encoding='utf-8',index=False)