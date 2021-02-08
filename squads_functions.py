import requests
from bs4 import BeautifulSoup
import re
import os
import sys
from pymongo import MongoClient
from datetime import datetime
from multiprocessing import Pool
from dotenv import load_dotenv
import logging
import json
load_dotenv()

logging.basicConfig(filename='cartolafc.log', filemode='w', level=logging.ERROR)

def parse_fields(squad):
  meta_file = open('settings/meta.json')
  meta_file = json.load(meta_file)
  meta = meta_file['squads']
  keys = list(squad.keys())

  for key in keys:
    if key in meta.keys():
      if meta[key]=='int':
        squad[key] = int(squad[key]) if squad[key]!='' else None
      elif meta[key]=='float':
        squad[key] = float(squad[key]) if squad[key]!='' else None
      elif squad[key]=='':
        squad[key] = None
    else:
      squad.pop(key,None)

  return squad

def get_squads(comp_id):
  """
    Coleta dados dos clubes da liga.
  """

  rsp = requests.request('GET','https://fbref.com/en/comps/{comp_id}'.format(comp_id=comp_id))
  content = rsp.content
  squads = []

  if rsp.status_code<400:
    logging.info('[+] {logtime} Requisição de squads realizada com sucesso.'.format(logtime=datetime.strftime(datetime.now(),'%c')))
    content = rsp.content
    
    soup = BeautifulSoup(content, 'html.parser')
    comp_info = soup.find(attrs={'id':'info'})
    table_overall = soup.find(attrs={'class':'table_container', 'id': re.compile(r'div_results\d+_overall')})

    # informações da competição
    comp_name = comp_info.find('h1', attrs={'itemprop':'name'}).text
    league = re.subn(r'\n|\t','',comp_name)[0]

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
          'position': position,
          'league_name': league
        }

        squad_info.update(infos)
        squads.append(squad_info)

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

def get_squad_stats(squad, season, year):
  """
    Coleta estatísticas do clube em cada rodada.\n
    Utilize esse função como ponto de partida para coletar estatisticas dos jogadores através do campo href.\n\n

    :param squad: dict correspondente ao objeto squad retornado na função get_squads().
  """
  squad_id=squad['squad_id']
  endpoints = ['schedule','shooting','keeper','misc']
  squad_league = []

  for endpoint in endpoints:
    url = 'https://fbref.com/en/squads/{squad_id}/{year}/matchlogs/{season}/{endpoint}/'.format(squad_id=squad_id, year=year, season=season, endpoint=endpoint)
    rsp = requests.request('GET',url)
    content = rsp.content

    if rsp.status_code<400:
      content = rsp.content
      
      soup = BeautifulSoup(content, 'html.parser')
      table = soup.find(attrs={'class':'stats_table'})

      try:
        tbody = table.find('tbody')
        rows = tbody.find_all('tr')

        for row in rows:
          squad_name = squad['squad']

          th = row.find('th')
          date = th.text

          if 'side-for' in row.attrs['class']:
            stats = {td['data-stat']: re.sub(r'^\s','',td.text) for td in row.find_all('td')}
          elif 'side-against' in row.attrs['class']:
            stats = {'opponent_'+td['data-stat']: re.sub(r'^\s','',td.text) for td in row.find_all('td')}
            stats['round'] = stats['opponent_round']
            stats.pop('opponent_round',None)
          # dicionário contendo as informações do squad
          squad_round = {
            'squad': squad_name,
            'squad_id': squad_id,
            'href': squad['href'],
            'date': date
          }
          squad_round.update(stats)

          if 'date' in squad_round.keys():
            if re.search(r'Matchweek',squad_round['round']):
              squad_round['round_num'] = int(squad_round['round'].split(' ')[1])

            # executa a função que ajusta os datatypes dos campos
            squad_round_parsed = parse_fields(squad_round)

            squad_league.append(squad_round_parsed)

      except Exception as e:
        logging.error('[+] {logtime} Erro ao coletar squads: {error}.'.format(error=e,logtime=datetime.strftime(datetime.now(),'%c')))

  return squad_league


def get_players(squad):
  """
    Coleta informações básicas sobre os jogadores do clube.\n
    Utilize esse função como ponto de partida para coletar estatisticas dos jogadores através do campo href.\n\n

    :param squad: dict correspondente ao objeto squad retornado na função get_squads().
  """
  players_id = []
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
        if body:
          rows = body.find_all('tr')

          for row in rows:
            if row:
              # separa elementos da tabela
              th = row.find('th')
              td = row.find_all('td')
              # define o nome e o link de referencia do jogador
              name = th.text
              href = th.find('a')['href']
              player_id = href.split('/')[3]

              player = {
                'name': name,
                'href': href,
                'player_id': player_id,
                'squad_id': squad['squad_id'],
                'squad': squad['squad']
              }
              # coleta as estatisticas totais do jogador e atualiza dicionário
              player.update({stat.attrs['data-stat']: stat.text for stat in td})
              
              players_id.append(player)

      except Exception as e:
        logging.error('[+] {logtime} Erro ao coletar link dos jogadores: {error}.'.format(error=e,logtime=datetime.strftime(datetime.now(),'%c')))

  return players_id