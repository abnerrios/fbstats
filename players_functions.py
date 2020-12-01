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

def get_keeper_stats(player):
  player_id=player['player_id']
  url = 'https://fbref.com/en/players/{player_id}/matchlogs/s10072/keeper/'.format(player_id=player_id)
  rsp = requests.request('GET',url)
  content = rsp.content
  player_league = [] # array que armazenará todas as rodas do jogador e será retornada na função

  if rsp.status_code<400:
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
        
        player_league.append(player)

    except Exception as e:
      logging.error('[+] {logtime} Erro ao coletar estatisticas do goleiro {player_id}: {error}.'.format(player_id=player_id, error=e,logtime=datetime.strftime(datetime.now(),'%c')))
  
  return player_league

def get_player_stats(player):
  player_id=player['player_id']
  url = 'https://fbref.com/en/players/{player_id}/matchlogs/s10072/summary/'.format(player_id=player_id)
  rsp = requests.request('GET',url)
  content = rsp.content
  player_league = []

  if rsp.status_code<400:
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

      # se for goleiro, executa a função específica 
      if field_area=='GK':
        player_league = get_keeper_stats({'player_id':player['player_id'], 'squad_id':player['squad_id']})
        return player_league

      tbody = table.find('tbody')
      rows = tbody.find_all('tr')

      for row in rows:
        td = row.find_all('td')
        th = row.find('th')
        date = th.text
        player.update({'date':date})
        player.update({stat.attrs['data-stat']: stat.text for stat in td})
        # armazena estatisticas da rodada no array
        player_league.append(player)

    except Exception as e:
      logging.error('[+] {logtime} Erro ao coletar estatisticas do jogador {player_id}: {error}.'.format(player_id=player_id, error=e,logtime=datetime.strftime(datetime.now(),'%c')))

  return player_league