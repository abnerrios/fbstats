import fbcollect.players as pf
import fbcollect.squads as sf
import fbcollect.competitions as cf
from multiprocessing import Pool
from functools import partial
from urllib.parse import urljoin

class Competitions():
  def __init__(self):
    self.urlbase = 'https://fbref.com/'
    self.path = 'en/comps/'

  def competitions(self):
    url = urljoin(self.urlbase, self.path)
    competitions = cf.get_competitions(url)

    return competitions

class Players():
  def __init__(self, comp):
    self.comp_id = comp['comp_id']
    self.governing_country = comp['country']
    self.season = comp['season']
    self.comp_title = comp['title']

  def players_stats(self, squad):
    players_id = sf.get_players(squad)
    players = []

    get_stats = partial(pf.get_player_stats,season=self.season)

    with Pool(3) as p:
      players_stats = p.map(get_stats, players_id)

    for player in players_stats:
      for stats in player:
        players.append(stats)
    
    return players

class Squads():
  def __init__(self, comp):
    self.urlbase = 'https://fbref.com/'
    self.path = comp
    self.url = urljoin(self.urlbase, self.path)

  def squads(self):
    squads = sf.get_squads(self.url)
    return squads


  def squad_stats(self):
    """Get statics of squad on all match of competition."""
    squads = sf.get_squads(self.url)
    squads_stats = []
    
    get_stats = partial(sf.get_squad_comps, urlbase=self.urlbase)

    with Pool(3) as p:
      result_list = p.map(get_stats, squads)
    
    for squad in result_list:
      for stats in squad:
        for stat in stats:
          squads_stats.append(stat)

    return squads_stats
    
  def players(self, squad):
    """Get players info from related squad."""
    players = sf.get_players(squad)

    return players