from types import new_class
import fbcollect.players as pf
import fbcollect.squads as sf
import fbcollect.competitions as cf
from multiprocessing import Pool
from functools import partial
from urllib.parse import urljoin

urlbase = 'https://fbref.com/'

class Competitions():
  def __init__(self):
    self.urlbase = urlbase
    self.path = 'en/comps/'

  def competitions(self):
    url = urljoin(self.urlbase, self.path)
    competitions = cf.get_competitions(url)

    return competitions

class Players():
  def __init__(self):
    self.urlbase = urlbase

  def players_stats(self, players):

    get_stats = partial(pf.get_player_infos, self.urlbase)

    with Pool(3) as p:
      players_stats = p.map(get_stats, players)
    
    return players_stats

class Squads():
  def __init__(self, comp):
    self.urlbase = urlbase
    self.path = comp
    self.url = urljoin(self.urlbase, self.path)

  def squads(self):
    """Get statics of squad on all match of competition."""
    squads = sf.get_squads(self.url)
    get_stats = partial(sf.get_squad_comps, urlbase=self.urlbase)

    with Pool(3) as p:
      result_list = p.map(get_stats, squads)

    return result_list
    
  def players(self, squad):
    """Get players info from related squad."""
    players = sf.get_players(squad)

    return players