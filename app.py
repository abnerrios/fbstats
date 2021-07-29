import os
from pymongo import MongoClient
from dotenv import load_dotenv
import logging
import fbcollect.fbrefstats as fbs
from progress.bar import ChargingBar
load_dotenv()

logging.basicConfig(filename='footstats.log', filemode='w', level=logging.ERROR)

# define a conexão com o servidor de mongodb definido no arquivo .env

def main():
  mongohost = os.getenv('MONGODB_HOST')
  mongoport = int(os.getenv('MONGODB_PORT'))
  mongo = MongoClient(host=mongohost, port=mongoport)
  db = mongo.fbstats

  competitions = fbs.Competitions().competitions()
  players_list = []

  for comp in competitions:
    comp_ref = comp.get('href')
    squads = fbs.Squads(comp_ref)
    print('Coletando dados de {}'.format(comp.get('league_name')))
    
    # coleta estatisticas da equipe a cada rodada
    squads_stats = squads.squads()
    bar = ChargingBar('Inserindo squads no banco de dados: ', max=len(squads_stats))
    for s in squads_stats:
      db.squads.find_one_and_update(
        {'squad_id':s.id}, 
        {'$set': {'squad_id': s.id, 'name': s.name,'country': s.governing_country, 'manager': s.manager}}, 
        upsert=True
      )

      for stats in s.stats:
        db.squad_stats.find_one_and_update(
          {'squad_id':s.id,'date': stats.get('date'), 'stats_type':stats.get('stats_type')},
          {'$set': stats},
          upsert=True
        )

      for player in s.players:
        players_list.append(player)

      bar.next()
    bar.finish()

  # coleta estatisticas dos jogadores
  players = fbs.Players().players_stats(players_list)

  for p in players:
    db.players.find_one_and_update(
      {'player_id':p.id}, 
      {'$set': {'player_id': p.id, 'name': p.name, 'full_name': p.full_name, 'position': p.position, 'field_area': p.field_area, 'footed':p.footed, 'height': p.height, 'weight': p.weight, 'born': p.born, 'associated_club': p.associated_club }}, 
      upsert=True
    )

    for stats in p.stats:
      db.player_stats.find_one_and_update(
        {'player_id':p.id, 'date': stats.get('date'), 'stats_type':stats.get('stats_type')},
        {'$set': stats},
        upsert=True
      )

if __name__=='__main__':
  main()