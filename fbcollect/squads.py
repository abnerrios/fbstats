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

class Squad:
  def __init__(self) -> None:  
    self.name = str
    self.id = str
    self.governing_country = str
    self.manager = str
    self.stats = []
    self.players = []

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


def get_squads(url) -> list:
  """
    Coleta dados dos clubes da liga.
  """
  rsp = requests.request('GET',url)
  content = rsp.content
  squads = []

  if rsp.status_code<400:
    try:      
      soup = BeautifulSoup(content, html_parser)
      table_overall = soup.find(attrs={'class':'table_container', 'id': re.compile(r'.+_overall')})

      if table_overall:
        rows = table_overall.find_all('tr')

        for row in rows:
          squad = row.find(attrs={'data-stat':'squad'})
          if not squad.name=='th' and squad.find('a'):
              squad_link = squad.find('a')['href']
              infos = {td['data-stat']: re.sub(r'^\s','',td.text) for td in row.find_all('td')}
              # dicionário contendo as informações do squad
              squad_info = {
                'href': squad_link,
                'squad_id': squad_link.split('/')[3]
              }
              squad_info.update(infos)
  
              squads.append(squad_info)
    except Exception as error:
      logging.error(f'[+] Erro ao coletar squads: {error}.')
  else:
    logging.error(f'[+] Erro ao executar requisição: status_code={rsp.status_code} reason={rsp.reason}')

  return squads

def get_squad_matchs_stats(url):
  sleep(3)
  rsp = requests.request('GET',url)
  content = rsp.content
  squad_matchs_stats = [] # array que armazenará todas as rodas do jogador e será retornada na função

  if rsp.status_code<400:
    try:
      soup = BeautifulSoup(content, html_parser)
      table = soup.find(attrs={'class':'stats_table'})
      table_id = table.attrs['id']
      tbody = table.find('tbody')
      rows = tbody.find_all('tr')

      for row in rows:
        th = row.find('th')
        date = th.text or None
        
        # executa apenas se o formato de data estiver correto
        date_pattern = r'\d+-\d+-\d+'
        if re.match(date_pattern, date):
          match_stats = {'date': date}
          
          if table_id=='matchlogs_against':
            match_stats.update({'opponent_'+td['data-stat']: re.sub(r'^\s','',td.text) for td in row.find_all('td')})
          else:
            match_stats.update({td['data-stat']: re.sub(r'^\s','',td.text) for td in row.find_all('td')})
          # executa a função que ajusta os datatypes dos campos
          stats_round_parsed = parse_fields(match_stats, 'squads')
          
          squad_matchs_stats.append(stats_round_parsed)

    except Exception as error:
      logging.error(f'[+] Erro ao coletar estatisticas do squad: {error}.')
  
  return squad_matchs_stats


def get_squad_log_types(urlbase, current_url, filters) -> list:
  log_types_stats = []
  log_types = []

  try:
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
              log_type = {'href': current_url, 'name': log_name}
              log_types.append(log_type)
        
        for log_type in log_types:
          log_type_url = urljoin(urlbase, log_type.get('href')) 
          attr_stats = get_squad_matchs_stats(log_type_url)
          for stat in attr_stats:
            stat['stats_type'] = log_type.get('name')
            log_types_stats.append(stat)
  except Exception as error:
    logging.error(f'Erro ao coletar log types: {error}')

  return log_types_stats  

def get_squad_infos(squad, urlbase) -> Squad:
  href = squad.get('href')
  url = urljoin(urlbase, href)
  rsp = requests.request('GET',url)
  content = rsp.content

  squad_obj = Squad()
  squad_obj.id = squad.get('squad_id')
  squad_obj.name = squad.get('squad')

  if rsp.status_code<400:
    try:
      soup = BeautifulSoup(content, html_parser)
      info_section = soup.find('div',attrs={'id':'info'})
      filters = soup.find_all('div',attrs={'class':'filter'}) # TODO adicionar string log types
      players_tables = soup.find_all(attrs={'class':'table_wrapper', 'id':re.compile('stats')})

      infos = [p.text for p in info_section.find_all('p')]
      governing_country = list(filter(lambda x: re.search(r'Governing Country', x), infos))
      manager = list(filter(lambda x: re.search(r'Manager', x), infos))
      squad_obj.governing_country = re.findall('Governing Country:\s(.+)|$',governing_country[0])[0] if len(governing_country)>0 else None 
      squad_obj.manager = re.findall('Manager:\s(.+)|$',manager[0])[0] if len(manager)>0 else None
      squad_obj.stats = get_squad_log_types(urlbase, url, filters)
      squad_obj.players = get_squad_players(players_tables)

    except Exception as error:
      logging.error(f'Erro ao coletar infos do jogador: {error}')
  
  return squad_obj

def get_squad_players(players_tables) -> list:
  """
    Coleta informações básicas sobre os jogadores do clube.\n
    Utilize esse função como ponto de partida para coletar estatisticas dos jogadores através do campo href.\n\n

    :param squad: dict correspondente ao objeto squad retornado na função get_squads().
  """
  squad_players = []

  for table in players_tables:
    try:
      body = table.find('tbody')
      if body:
        rows = body.find_all('tr')

        for row in rows:
          if row:
            # separa elementos da tabela
            th = row.find('th')
            # define o nome e o link de referencia do jogador
            name = th.text
            href = th.find('a').get('href')
            player_id = href.split('/')[3]

            player = {
              'name': name,
              'href': href,
              'player_id': player_id
            }
            squad_players.append(player)

    except Exception as e:
      logging.error(f'[+] Erro ao coletar link dos jogadores: {e}.')

  return squad_players