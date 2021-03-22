import os
import pandas as pd
import numpy as np
from pymongo import MongoClient
from dotenv import load_dotenv
import json
load_dotenv()

mongo = MongoClient(os.getenv('MONGO_CONNECTION_STRING'))

db = mongo.fbref

# squads

cursor = db.squads.find()
squads = []

for squad in cursor:
  squads.append(squad)

df = pd.DataFrame(squads)

df.to_csv('squads.csv',header=True, sep=';', encoding='utf-8',index=False)


# players 
cursor = db.players.find()
players = []

for player in cursor:
  players.append(player)

df = pd.DataFrame(players)

df.to_csv('players.csv',header=True, sep=';', encoding='utf-8',index=False)

