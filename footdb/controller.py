from service import squad_service 

class squad_controller():
  def __main__(self):
    # TODO
    pass
  
  def insert_squad(self,squad):
    squad_service.insert_squad(squad)
  
  def insert_squad_round(self,squad):
    squad_service.insert_squad_round(squad)

  def insert_squad_ofensive_stats(self,squad):
    squad_service.insert_squad_ofensive_stats(squad)
  
  def insert_squad_defensive_stats(self,squad):
    squad_service.insert_squad_defensive_stats(squad)
  
  def insert_squad_gk_stats(self,squad):
    squad_service.insert_squad_gk_stats(squad)
  
  def insert_squad_pass_stats(self,squad):
    squad_service.insert_squad_pass_stats(squad)