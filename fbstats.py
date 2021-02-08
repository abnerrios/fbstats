import players_functions as pf
import squads_functions as sf
from multiprocessing import Pool
from functools import partial

class Players():
  def __init__(self, comp):
    self.comp_id = comp['comp_id']
    self.governing_country = comp['country']
    self.season = comp['season']
    self.comp_title = comp['title']

  def playersStats(self, squad):
    players_id = sf.get_players(squad)
    players = []

    get_stats = partial(pf.get_player_stats,season=self.season)

    with Pool(5) as p:
      players_stats = p.map(get_stats, players_id)

    for player in players_stats:
      for stats in player:
        players.append(stats)
    
    return players

class Squads():
  def __init__(self, comp):
    self.comp_id = comp['comp_id']
    self.governing_country = comp['country']
    self.season = comp['season']
    self.comp_title = comp['title']
    self.year = comp['year']

  def squads(self):
    squads = sf.get_squads(self.comp_id)

    for squad in squads:
      squad.update({'country':self.governing_country})

    return squads


  def squadStats(self):
    squads = sf.get_squads(self.comp_id)
    squads_stats = []
    
    get_stats = partial(sf.get_squad_stats, year=self.year, season=self.season)

    with Pool(5) as p:
      result_list = p.map(get_stats, squads)
    
    for squad in result_list:
      for stats in squad:
        squads_stats.append(stats)

    return squads_stats
    
  def players(self, squad):
    players = sf.get_players(squad)

    return players


