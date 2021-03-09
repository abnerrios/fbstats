import os
import json
from pymongo import MongoClient
from dotenv import load_dotenv
import logging
import fbcollect.fbstats as fbs
from progress.bar import ChargingBar
load_dotenv()

logging.basicConfig(filename='cartolafc.log', filemode='w', level=logging.ERROR)

json_comps = open('./settings/competitions.json','r')
comps = json.load(json_comps)
competitions = comps['competitions']

# define a conexão com o servidor de mongodb definido no arquivo .env
mongo = MongoClient(os.getenv('MONGO_CONNECTION_STRING'))
db = mongo.footstats


for comp in competitions:
  Players = fbs.Players(comp)
  Squads = fbs.Squads(comp)
  print('Coletando dados de {}'.format(comp['title']))

  # coleta estatisticas da equipe a cada rodada
  squads_stats = Squads.squadStats()
  bar = ChargingBar('Inserindo squads no banco de dados: ', max=len(squads_stats))
  for squad in squads_stats:
    if 'date' in squad.keys() and squad['date']!='':
      squad.update({'competition':comp['title'], 'governing_country':comp['country']})
      
      db.squads.find_one_and_update({'squad_id':squad['squad_id'],'date': squad['date']},{'$set': squad},upsert=True)
      bar.next()
  bar.finish()

  # coleta estatisticas dos jogadores para cada rodada
  squads = Squads.squads()
  for squad in squads:
    logging.info('[+] Inserindo registros do clube: {}'.format(squad['squad']))
    players = Players.playersStats(squad)
    bar = ChargingBar('Inserindo jogadores de {} no banco de dados: '.format(squad['squad']), max=len(players))
    for player in players:
      if 'date' in player.keys() and player['date']!='':

        db.players.find_one_and_update({'player_id': player['player_id'], 'date': player['date']},{'$set':player}, upsert=True)
        bar.next()
    bar.finish()