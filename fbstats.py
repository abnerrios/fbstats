import players_functions as pf
import squads_functions as sf
from multiprocessing import Pool

class Players():
  def __init__(self):
    pass
  def squadStats(self, squad):
    players_id = sf.get_players(squad)
    players = []

    with Pool(5) as p:
      players_stats = p.map(pf.get_player_stats, players_id)

    for player in players_stats:
      for stats in player:
        players.append(stats)
    
    return players

class Squads():
  def __init__(self):
    pass
  def squads(self, comp):
    squads = sf.get_squads(comp)

    return squads
    
  def players(self, squad):
    players = sf.get_players(squad)

    return players


