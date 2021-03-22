import requests
from bs4 import BeautifulSoup
import re
from datetime import datetime
from dotenv import load_dotenv
import logging
import json
load_dotenv()

logging.basicConfig(filename='cartolafc.log', filemode='a', level=logging.ERROR)

def parse_fields(player):
  meta_file = open('./settings/meta.json')
  meta_file = json.load(meta_file)
  meta = meta_file['players']

  for key in player.keys():
    if key in meta.keys():
      if meta[key]=='int':
        player[key] = int(player[key]) if player[key]!='' else None
      elif meta[key]=='float':
        player[key] = float(player[key]) if player[key]!='' else None
    elif player[key]=='':
      player[key] = None

  return player


def get_keeper_stats(player, season):
  player_id=player['player_id']
  url = 'https://fbref.com/en/players/{player_id}/matchlogs/{season}/keeper/'.format(player_id=player_id, season=season)
  rsp = requests.request('GET',url)
  content = rsp.content
  player_league = [] # array que armazenará todas as rodas do jogador e será retornada na função

  if rsp.status_code<400:
    
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
        stats_round = player.copy()

        td = row.find_all('td')
        th = row.find('th')
        date = th.text
        stats_round.update({'date':date})
        stats_round.update({stat.attrs['data-stat']: stat.text for stat in td})
        
        # executa a função que ajusta os datatypes dos campos
        stats_round_parsed = parse_fields(stats_round)
        
        player_league.append(stats_round_parsed)

    except Exception as e:
      logging.error('[+] {logtime} Erro ao coletar estatisticas do goleiro {player_id}: {error}.'.format(player_id=player_id, error=e,logtime=datetime.strftime(datetime.now(),'%c')))
  
  return player_league

def get_player_stats(player, season):
  player_id=player['player_id']
  url = 'https://fbref.com/en/players/{player_id}/matchlogs/{season}/summary/'.format(player_id=player_id, season=season)
  rsp = requests.request('GET',url)
  content = rsp.content
  player_league = []

  if rsp.status_code<400:
    
    soup = BeautifulSoup(content, 'html.parser')
    table = soup.find(attrs={'class':'stats_table'})
    info = soup.find('div',attrs={'itemtype':'https://schema.org/Person'})

    try:
      born = info.find('span',attrs={'itemprop':'birthDate'})['data-birth'] if info.find('span',attrs={'itemprop':'birthDate'}) else None
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

      # se for goleiro, executa a função específica 
      if field_area=='GK':
        keeper = {'player_id':player['player_id'], 'squad_id':player['squad_id']}
        player_league = get_keeper_stats(keeper, season)
        return player_league

      tbody = table.find('tbody')
      rows = tbody.find_all('tr')

      for row in rows:
        stats_round = player.copy()

        td = row.find_all('td')
        th = row.find('th')
        date = th.text
        stats_round.update({'date':date})
        stats_round.update({stat.attrs['data-stat']: stat.text for stat in td})

        # executa a função que ajusta os datatypes dos campos
        stats_round_parsed = parse_fields(stats_round)

        # armazena estatisticas da rodada no array
        player_league.append(stats_round_parsed)

    except Exception as e:
      logging.error('[+] {logtime} Erro ao coletar estatisticas do jogador {player_id}: {error}.'.format(player_id=player_id, error=e,logtime=datetime.strftime(datetime.now(),'%c')))

  return player_league