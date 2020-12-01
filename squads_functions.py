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
load_dotenv()

logging.basicConfig(filename='cartolafc.log', filemode='w', level=logging.DEBUG)

def get_squads(comp_link):
  """
    Coleta dados dos clubes da liga.
  """

  rsp = requests.request('GET','https://fbref.com/{comp_link}'.format(comp_link=comp_link))
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
              player = {
                'name': name,
                'href': href,
                'squad_id': squad['squad_id'],
                'squad': squad['squad']
              }
              # coleta as estatisticas totais do jogador e atualiza dicionário
              player.update({stat.attrs['data-stat']: stat.text for stat in td})
              
              players_id.append(player)

      except Exception as e:
        logging.error('[+] {logtime} Erro ao coletar link dos jogadores: {error}.'.format(error=e,logtime=datetime.strftime(datetime.now(),'%c')))

  return players_id