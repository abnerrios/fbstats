import requests
from bs4 import BeautifulSoup
from datetime import datetime
from dotenv import load_dotenv
import logging
load_dotenv()

logging.basicConfig(filename='cartolafc.log', filemode='a', level=logging.ERROR)

def get_competitions(url):
  """
    Coleta dados dos clubes da liga.
  """
  rsp = requests.request('GET',url)
  content = rsp.content
  competitions_types = ['comps_1_fa_club_league_senior','comps_2_fa_club_league_senior','comps_3_fa_club_league_senior']
  comps = []

  if rsp.status_code<400:
    logging.info('[+] {logtime} Requisição de competições realizada com sucesso.'.format(logtime=datetime.strftime(datetime.now(),'%c')))

    for type in competitions_types:
    
      soup = BeautifulSoup(content, 'html.parser')
      table_overall = soup.find('table',attrs={'id':type})

      rows = table_overall.find_all('tr', attrs={'class':'gender-m'})

      for row in rows:
        try:
          league_name = row.find(attrs={'data-stat':'league_name'}).find('a').text
          country = row.find(attrs={'data-stat':'country'}).find('a').text
          last_season = row.find(attrs={'data-stat':'maxseason'}).find('a').attrs['href']

          competition = {
            'league_name': league_name,
            'country': country,
            'href': last_season
          }

          comps.append(competition)
        
        except Exception as e:
          logging.error('[+] {logtime} Erro ao coletar squads: {error}.'.format(error=e,logtime=datetime.strftime(datetime.now(),'%c')))

    
  else:
    logging.error('[+] {logtime} Erro ao executar requisição: status_code={status_code} reason={reason} '.format(status_code=rsp.status_code,reason=rsp.reason, logtime=datetime.strftime(datetime.now(),'%c')))

  return comps