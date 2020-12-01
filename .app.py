import requests
import pandas as pd
from bs4 import BeautifulSoup
import re
import os
import sys
from pymongo import MongoClient
from datetime import datetime
from multiprocessing import Pool
from dotenv import load_dotenv
import logging
load_dotenv()

logging.basicConfig(filename='cartolafc.log', filemode='w', level=logging.DEBUG)
# define a conexão com o servidor de mongodb definido no arquivo .env
mongo = MongoClient(os.getenv('MONGO_URL'))

def get_squads():
  """
    Função responsável por recuperar os dados dos clubes da liga.
    Apenas algumas informações são recuperadas: link de referencia, squad_id e posição do time no campeonato. 
  """

  db = mongo.cartola_fc
  rsp = requests.request('GET','https://fbref.com/en/comps/24/Serie-A-Stats')
  content = rsp.content
  squads = []

  if rsp.status_code<400:
    logging.info('[+] {logtime} Requisição de squads realizada com sucesso.'.format(logtime=datetime.strftime(datetime.now(),'%c')))
    content = rsp.content
    
    soup = BeautifulSoup(content, 'html.parser')
    table_overall = soup.find(attrs={'class':'table_container', 'id': re.compile(r'div_results\d+_overall')})
    
    rows = table_overall.find_all('tr')

    for row in rows:
      squad = row.find(attrs={'data-stat':'squad'})
      try:
        squad_link = squad.find('a')['href']
        position = row.find(attrs={'data-stat':'rank'}).text
        infos = {td['data-stat']: re.sub(r'^\s','',td.text) for td in row.find_all('td')}
        # dicionário contendo as informações do squad
        squad_info = {
          'href': squad_link,
          'squad_id': squad_link.split('/')[3],
          'position': position
        }

        squad_info.update(infos)
        squads.append(squad_info)
        logging.info('[+] {logtime} Inserindo registros no banco de dados.'.format(logtime=datetime.strftime(datetime.now(),'%c')))
        db.squads.update_many({'squad_id': squad_info['squad_id']}, {'$set': squad_info}, upsert=True)

      except Exception as e:
        logging.error('[+] {logtime} Erro ao coletar squads: {error}.'.format(error=e,logtime=datetime.strftime(datetime.now(),'%c')))

    if len(squads)<20:
      logging.warning('[+] {logtime} Pode haver squads ausentes.'.format(logtime=datetime.strftime(datetime.now(),'%c')))
    elif len(squads)>20:
      logging.warning('[+] {logtime} Pode haver sujeira nos registros.'.format(logtime=datetime.strftime(datetime.now(),'%c')))
    else:
      logging.info('[+] {logtime} Todos os squads encontrados.'.format(logtime=datetime.strftime(datetime.now(),'%c')))

  else:
    logging.error('[+] {logtime} Erro ao executar requisição: status_code={status_code} reason={reason} '.format(status_code=rsp.status_code,reason=rsp.reason, logtime=datetime.strftime(datetime.now(),'%c')))

  return squads

def get_player_links(squads):
  players_id = []
  for squad in squads:
    link = squad['href']
    rsp = requests.request('GET','https://fbref.com{}'.format(link))
    content = rsp.content

    if rsp.status_code<400:
      logging.info('[+] {logtime} Requisição realizada com sucesso - {squad}.'.format(squad=squad['squad'], logtime=datetime.strftime(datetime.now(),'%c')))
      content = rsp.content

      soup = BeautifulSoup(content, 'html.parser')
      stats_tables = soup.find_all(attrs={'class':'table_wrapper', 'id':re.compile('stats')})

      for table in stats_tables:
        try:
          body = table.find('tbody')
          rows = body.find_all('tr')

          for row in rows:
            if row:
              th = row.find_all('th')
              players_id.append({'player_id': th[0].find('a')['href'].split('/')[3], 'squad_id':squad['squad_id']})
        except Exception as e:
          logging.error('[+] {logtime} Erro ao coletar link dos jogadores: {error}.'.format(error=e,logtime=datetime.strftime(datetime.now(),'%c')))
  return players_id

def get_keeper_stats(player):
  db = mongo.cartola_fc
  player_id=player['player_id']
  url = 'https://fbref.com/en/players/{player_id}/matchlogs/s10072/keeper/'.format(player_id=player_id)
  rsp = requests.request('GET',url)
  content = rsp.content

  if rsp.status_code==200:
    content = rsp.content
    
    soup = BeautifulSoup(content, 'html.parser')
    table = soup.find(attrs={'class':'stats_table'})
    info = soup.find('div',attrs={'itemtype':'https://schema.org/Person'})

    try:
      born = info.find('span',attrs={'itemprop':'birthDate'})['data-birth']
      full_name = info.find('h1',attrs={'itemprop':'name'}).find('span').text
      field_area = re.findall(r'Position: ([GK|DF|MF|FW|-]+)|$',info.text)[0]
      position = re.findall(r'Position: [GK|DF|MF|FW|-]+\s(.+)|$',info.text)[0]
      footed = re.findall(r'Footed:[\d|%|\s]+([Right|Left|Both]+)|$',info.text)[0]
      height = re.findall(r'(\d+)cm|$',info.text)[0]
      weight = re.findall(r'(\d+)kg|$',info.text)[0]
      associated_club = re.findall(r'Club:\s(.+)\n|$',info.text)[0]
      
      player.update({
        'name': full_name,
        'field_area': field_area,
        'player_position': re.sub(r'\(|\)','',position) if not re.search(r'Footed',position) else field_area,
        'footed': footed,
        'height': height,
        'weight': weight,
        'born': born,
        'associated_club': associated_club
      })

      tbody = table.find('tbody')
      rows = tbody.find_all('tr')

      for row in rows:
        td = row.find_all('td')
        th = row.find('th')
        date = th.text
        player.update({'date':date})
        player.update({stat.attrs['data-stat']: stat.text for stat in td})
        print(player['name'],player['round'])
        db.players.update_one({'player_id':player['player_id'], 'round':player['round']},{'$set':player},upsert=True)
    except Exception as e:
      logging.error('[+] {logtime} Erro ao coletar estatisticas do goleiro {player_id}: {error}.'.format(player_id=player_id, error=e,logtime=datetime.strftime(datetime.now(),'%c')))
      

def get_player_stats(player):
  player_id=player['player_id']
  db = mongo.cartola_fc
  url = 'https://fbref.com/en/players/{player_id}/matchlogs/s10072/summary/'.format(player_id=player_id)
  rsp = requests.request('GET',url)
  content = rsp.content

  if rsp.status_code==200:
    content = rsp.content
    
    soup = BeautifulSoup(content, 'html.parser')
    table = soup.find(attrs={'class':'stats_table'})
    info = soup.find('div',attrs={'itemtype':'https://schema.org/Person'})

    try:
      born = info.find('span',attrs={'itemprop':'birthDate'})['data-birth']
      full_name = info.find('h1',attrs={'itemprop':'name'}).find('span').text
      field_area = re.findall(r'Position: ([GK|DF|MF|FW|-]+)|$',info.text)[0]
      position = re.findall(r'Position: [GK|DF|MF|FW|-]+\s(.+)|$',info.text)[0]
      footed = re.findall(r'Footed:[\d|%|\s]+([Right|Left|Both]+)|$',info.text)[0]
      height = re.findall(r'(\d+)cm|$',info.text)[0]
      weight = re.findall(r'(\d+)kg|$',info.text)[0]
      associated_club = re.findall(r'Club:\s(.+)\n|$',info.text)[0]
      
      player.update({
        'name': full_name,
        'field_area': field_area,
        'player_position': re.sub(r'\(|\)','',position) if not re.search(r'Footed',position) else field_area,
        'footed': footed,
        'height': height,
        'weight': weight,
        'born': born,
        'associated_club': associated_club
      })
      
      if field_area=='GK':
        get_keeper_stats({'player_id':player['player_id'], 'squad_id':player['squad_id']})
        next

      tbody = table.find('tbody')
      rows = tbody.find_all('tr')

      for row in rows:
        td = row.find_all('td')
        th = row.find('th')
        date = th.text
        player.update({'date':date})
        player.update({stat.attrs['data-stat']: stat.text for stat in td})
        print(player['name'],player['round'])
        db.players.update_one({'player_id':player['player_id'], 'round':player['round']},{'$set':player},upsert=True)
    except Exception as e:
      logging.error('[+] {logtime} Erro ao coletar estatisticas do jogador {player_id}: {error}.'.format(player_id=player_id, error=e,logtime=datetime.strftime(datetime.now(),'%c')))

if __name__=='__main__':
  squads_link = get_squads()
  players_id = get_player_links(squads_link)

  with Pool(5) as p:
    p.map(get_player_stats, players_id)