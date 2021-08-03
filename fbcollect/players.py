from urllib.parse import urljoin
import requests
from bs4 import BeautifulSoup
import re
from time import sleep
from dotenv import load_dotenv
import logging
import json
load_dotenv()

logging.basicConfig(filename='footstats.log', filemode='a', level=logging.ERROR, format='%(asctime)s %(message)s', datefmt='%Y/%m/%d %I:%M:%S %p')
html_parser = 'html.parser'

class Player:
  def __init__(self) -> None:  
    self.name = str
    self.id = str
    self.name = str
    self.full_name = str
    self.field_area = str
    self.position = str
    self.footed = str
    self.height = str
    self.weight = str
    self.born = str
    self.associated_club = str
    self.stats = []

def parse_fields(entity, type) -> dict:
  meta_file = open('./settings/meta.json')
  meta_file = json.load(meta_file)
  meta = meta_file.get(type)
  pattern = r'^[-|+|\d]\d*\.'

  for key in list(entity.keys()):
    try:
      to_parse = entity.get(key)
      # verify if the field has on metadata and if need a transformation
      if meta.get(key):
        if to_parse=='':
          entity[key] = None
        else:
          if re.match(pattern, to_parse):
            entity[key] = float(to_parse) 
          else:
            entity[key] = int(re.subn(r'\,','',to_parse.split(' ')[0])[0])
    except Exception as error:
      logging.error(f'Erro ao converter campo: {error}')

  return entity

def get_player_matchs_stats(url):
  sleep(3)
  rsp = requests.request('GET',url)
  content = rsp.content
  player_matchs_stats = [] # array que armazenará todas as rodas do jogador e será retornada na função

  if rsp.status_code<400:
    try:
      soup = BeautifulSoup(content, html_parser)
      table = soup.find(attrs={'class':'stats_table'})
      tbody = table.find('tbody')
      rows = tbody.find_all('tr')

      for row in rows:
        td = row.find_all('td')
        th = row.find('th')
        date = th.text or None
        
        if date:
          stats_round = {'date': date}
          stats_round.update({stat.attrs['data-stat']: stat.text for stat in td})
          # executa a função que ajusta os datatypes dos campos
          stats_round_parsed = parse_fields(stats_round, 'players')
          
          player_matchs_stats.append(stats_round_parsed)

    except Exception as error:
      logging.error(f'[+] Erro ao coletar estatisticas do jogador: {error}.')
  
  return player_matchs_stats


def get_player_log_types(urlbase, season_ref) -> list:
  sleep(3)
  url = urljoin(urlbase, season_ref)
  rsp = requests.request('GET',url)
  log_types = []
  log_types_stats = []

  if rsp.status_code<400:
    try:
      content = rsp.content
      
      soup = BeautifulSoup(content, html_parser)
      filters = soup.find_all('div',attrs={'class':'filter'})

      for filter in filters:
        if re.search(r'Log Types',filter.text): 
          options = filter.find_all('div')

          for option in options:
            if 'disabled' not in option.attrs.get('class'):
              if 'current' not in option.attrs['class']:
                log_ref = option.find('a').attrs['href']
                log_name = re.subn(r'\n','',option.text)[0]
                log_type = {'href': log_ref, 'name': log_name}

                log_types.append(log_type)
              else:
                log_name = re.subn(r'\n','',option.text)[0]
                log_type = {'href': url, 'name': log_name}
                log_types.append(log_type)
          
          for log_type in log_types:
            log_type_url = urljoin(urlbase, log_type.get('href')) 
            attr_stats = get_player_matchs_stats(log_type_url)
            for stat in attr_stats:
              stat['stats_type'] = log_type.get('name')
              log_types_stats.append(stat)
    except Exception as error:
      logging.error(f'Erro ao coletar log types: {error}')

  return log_types_stats  

def get_player_infos(urlbase, player) -> Player:
  href = player.get('href')
  url = urljoin(urlbase, href)
  rsp = requests.request('GET',url)
  content = rsp.content

  player_obj = Player()
  player_obj.id = player.get('player_id')
  player_obj.name = player.get('name')
  player_obj.position = player.get('position')

  if rsp.status_code<400:
    try:
      soup = BeautifulSoup(content, html_parser)
      info = soup.find('div',attrs={'itemtype':'https://schema.org/Person'})
      match_logs_summary = soup.find('p', attrs={'class':'listhead'}, string='Match Logs (Summary)')
      last_season = match_logs_summary.find_next('a', string='2021')

      player_obj.born = info.find('span',attrs={'itemprop':'birthDate'})['data-birth'] if info.find('span',attrs={'itemprop':'birthDate'}) else None
      player_obj.full_name = info.find('h1',attrs={'itemprop':'name'}).find('span').text
      player_obj.field_area = re.findall(r'Position: ([GK|DF|MF|FW|-]+)|$',info.text)[0]
      player_obj.footed = re.findall(r'Footed:[\d|%|\s]+([Right|Left|Both]+)|$',info.text)[0]
      player_obj.height = re.findall(r'(\d+)cm|$',info.text)[0]
      player_obj.weight = re.findall(r'(\d+)kg|$',info.text)[0]
      player_obj.associated_club = re.findall(r'Club:\s(.+)\n|$',info.text)[0]

      if not last_season:
        last_season = match_logs_summary.find_next('a', string='2020-2021')

      last_season_ref = last_season.attrs.get('href') if last_season else None

      if re.search(r'Match-Logs',last_season_ref):
        player_obj.stats = get_player_log_types(urlbase, last_season_ref)

    except Exception as error:
      logging.error(f'Erro ao coletar infos do jogador: {error}')
  
  return player_obj