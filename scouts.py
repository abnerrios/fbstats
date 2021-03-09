import requests
import os
import sys
from pymongo import MongoClient
from datetime import datetime
from dotenv import load_dotenv
from multiprocessing import Pool
import logging
import json
import fbcollect.fbstats as fbs
load_dotenv()

logging.basicConfig(filename='cartolafc.log', filemode='w', level=logging.ERROR)
# define a conexão com o servidor de mongodb definido no arquivo .env
mongo = MongoClient(os.getenv('MONGO_CONNECTION_STRING'))
db = mongo.footstats
cartoladb = mongo.scoutsdb

# metadados de score para cada scout
scouts = open('scouts_score.json')
scouts = json.load(scouts)

def get_score(player):
  # separa os campos necessários
  player_score = {
    'player_id': player['player_id'],
    'name': player['name'],
    'squad': player['squad'],
    'squad_id': player['squad_id'],
    'field_area': player['field_area'],
    'round': player['round'],
    'date': player['date'],
    'venue': player['venue']
  }

  player_scouts = {}
  # se o jogador for defensor, atribui o scout de clean sheat
  if player['field_area']=='DF':
    squad_cursor = db.squads.find({'squad_id':player['squad_id'], 'round':player['round']})
    for squad in squad_cursor:
      player['clean_sheets']=squad['clean_sheets']

  # aplica o peso de cada scout com base no metadado
  for key in player.keys():
    if key in scouts.keys():
      field = 'score_'+key
      player_scouts[field] = round(player[key]*scouts[key],2) if player[key] else 0.0

  # numero da rodada
  round_num = int(player_score['round'].split(' ')[1])
  
  # atribui um valor negativo padrão, baseado em passes errados
  negative_default = 0.3 if player['field_area']=='GK' else 0.7
  # define o score estimado
  estimated_score = round(sum(player_scouts.values())-negative_default,2)

  # atualiza os dados nos dicionários
  player_scouts.update({'estimated_score':estimated_score, 'round_num':round_num})
  player.update({'estimated_score':estimated_score, 'round_num':round_num})

  player_score.update(player_scouts)

  # atualiza os dados no banco de dados
  db.players.find_one_and_update({'player_id': player['player_id'], 'round': player['round']},{'$set':player}, upsert=True)
  cartoladb.players.find_one_and_update({'player_id':player_score['player_id'], 'round': player_score['round']},{'$set':player_score},upsert=True)


if __name__ == "__main__":
  # traz os resultados do banco e a iteração sobre eles
  cursor = db.players.find({})

  with Pool(4) as p:
    p.map(get_score, cursor)