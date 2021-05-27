import requests
from bs4 import BeautifulSoup
import re
from urllib.parse import urljoin
from datetime import datetime
from dotenv import load_dotenv
import logging
import json
load_dotenv()

logging.basicConfig(filename='cartolafc.log', filemode='a', level=logging.ERROR)

def parse_fields(squad):
  meta_file = open('./settings/meta.json')
  meta_file = json.load(meta_file)
  meta = meta_file['squads']
  keys = list(squad.keys())

  for key in keys:
    if key in meta.keys():
      if meta[key]=='int':
        squad[key] = int(squad[key].split(' ')[0]) if squad[key]!='' else None
      elif meta[key]=='float':
        squad[key] = float(squad[key]) if squad[key]!='' else None
      elif squad[key]=='':
        squad[key] = None
    else:
      squad.pop(key,None)

  return squad

def get_squads(url):
  """
    Coleta dados dos clubes da liga.
  """
  rsp = requests.request('GET',url)
  content = rsp.content
  squads = []

  if rsp.status_code<400:
    logging.info('[+] {logtime} Requisição de squads realizada com sucesso.'.format(logtime=datetime.strftime(datetime.now(),'%c')))
    
    soup = BeautifulSoup(content, 'html.parser')
    comp_info = soup.find(attrs={'id':'info'})
    table_overall = soup.find(attrs={'class':'table_container', 'id': re.compile(r'.+_overall')})

    if table_overall:
      # informações da competição
      comp_name = comp_info.find('h1', attrs={'itemprop':'name'}).text
      league = re.subn(r'\n|\t','',comp_name)[0]
      
      rows = table_overall.find_all('tr')

      for row in rows:
        squad = row.find(attrs={'data-stat':'squad'})
        if not squad.name=='th' and squad.find('a'):
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
  else:
    logging.error('[+] {logtime} Erro ao executar requisição: status_code={status_code} reason={reason} '.format(status_code=rsp.status_code,reason=rsp.reason, logtime=datetime.strftime(datetime.now(),'%c')))

  return squads


def get_squad_stats(squad_id, squad_name, urlbase, comp_ref, competition):
  """
    Coleta estatísticas do clube em cada rodada.\n
    Utilize esse função como ponto de partida para coletar estatisticas dos jogadores através do campo href.\n\n

    :param squad: dict correspondente ao objeto squad retornado na função get_squads().
  """
  endpoints = ['schedule','shooting','keeper','misc','passing','passing_types','gca','defense','possession']
  squad_league = []

  for endpoint in endpoints:

    url = urljoin(urlbase, comp_ref)
    url = urljoin(url,'matchlogs/all_comps/')
    endpoint_url = urljoin(url, endpoint) 
    rsp = requests.request('GET',endpoint_url)
    content = rsp.content
    tips = {}

    if rsp.status_code<400:
      content = rsp.content
      
      soup = BeautifulSoup(content, 'html.parser')
      tables = soup.find_all(attrs={'class':'stats_table'})

      for table in tables:
        table_id = table.attrs['id']
        thead = table.find('thead')

        if thead:
          for th in thead.find_all('th'):
            try:
              data_stat = th['data-stat']
              data_tip = th['data-tip']
              tips.update({data_stat: data_tip})
            except KeyError:
              pass

          #logging.info(str(tips))

        try:
          tbody = table.find('tbody')
          if tbody:
            rows = tbody.find_all('tr')

            for row in rows:
              th = row.find('th')
              date = th.text

              # executa apenas se o formato de data estiver correto
              date_pattern = r'\d+-\d+-\d+'
              if re.match(date_pattern, date):
                
                if table_id=='matchlogs_against':
                  stats = {'opponent_'+td['data-stat']: re.sub(r'^\s','',td.text) for td in row.find_all('td')}
                else:
                  stats = {td['data-stat']: re.sub(r'^\s','',td.text) for td in row.find_all('td')}

                # dicionário contendo as informações do squad
                squad_round = {
                  'squad_id': squad_id,
                  'squad': squad_name,
                  'date': date,
                  'competition': competition
                }
                squad_round.update(stats)

                if 'date' in squad_round.keys():
                  # executa a função que ajusta os datatypes dos campos
                  squad_round_parsed = parse_fields(squad_round)
                  squad_league.append(squad_round_parsed)

        except Exception as e:
          logging.error('[+] {logtime} Erro ao coletar squads: {error}.'.format(error=e,logtime=datetime.strftime(datetime.now(),'%c')))

  return squad_league


def get_squad_comps(squad, urlbase):
  squad_ref = squad['href']
  url = urljoin(urlbase, squad_ref)
  rsp = requests.request('GET',url)
  content = rsp.content
  squad_id = squad['squad_id']
  squad_stats = []
  comps = []

  if rsp.status_code<400:
    content = rsp.content
    
    soup = BeautifulSoup(content, 'html.parser')
    filters = soup.find('div',attrs={'class':'filter'})

    if filters:
      if re.search(r'Competitions',filters.text): 
        options = filters.find_all('div')

        for option in options:
          if 'current' not in option.attrs['class']:
            comp_ref = option.find('a').attrs['href']
            comp_title = option.find('a').text

            comp = {'competition': comp_title, 'href': comp_ref}
            comps.append(comp)
  
        for comp in comps:
          squad_name = squad['squad']
          squad_id = squad['squad_id']
          competition = comp['competition']
          comp_ref = comp['href'].split('/')
          href = '/'.join(comp_ref[:-2])+'/'
          comp_stats = get_squad_stats(squad_id, squad_name, urlbase, href, competition)
          
          squad_stats.append(comp_stats)

  return squad_stats


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