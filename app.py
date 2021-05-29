import os
from pymongo import MongoClient
from dotenv import load_dotenv
import logging
import fbcollect.fbrefstats as fbs
from progress.bar import ChargingBar
load_dotenv()

logging.basicConfig(filename='footstats.log', filemode='w', level=logging.ERROR)

# define a conexão com o servidor de mongodb definido no arquivo .env
mongo = MongoClient(os.getenv('MONGO_CONNECTION_STRING'))
db = mongo.dbfoot

Competitions = fbs.Competitions()
competitions = Competitions.competitions()

for comp in competitions:
  comp_ref = comp['href']
  Squads = fbs.Squads(comp_ref)
  print('Coletando dados de {}'.format(comp['league_name']))


  # coleta estatisticas da equipe a cada rodada
  squads_stats = Squads.squadStats()
  bar = ChargingBar('Inserindo squads no banco de dados: ', max=len(squads_stats))
  for squad in squads_stats:
    squad.update({'governing_country':comp['country']})
    
    db.squads.find_one_and_update({'squad_id':squad['squad_id'],'date': squad['date']},{'$set': squad},upsert=True)
    bar.next()
  bar.finish()