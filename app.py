import requests
import os
import sys
from pymongo import MongoClient
from datetime import datetime
from dotenv import load_dotenv
import logging
import fbstats as fbs
load_dotenv()

logging.basicConfig(filename='cartolafc.log', filemode='w', level=logging.DEBUG)
# define a conexão com o servidor de mongodb definido no arquivo .env
mongo = MongoClient(os.getenv('MONGO_URL'))

Players = fbs.Players()
Squads = fbs.Squads()

squad = {
    'href':'/en/squads/422bb734/Atletico-Mineiro-Stats', 
    'squad': 'Atlético Mineiro',
    'squad_id': '422bb734'
}

squad_players = Squads.players(squad)

print(squad_players)