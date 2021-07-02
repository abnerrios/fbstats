from service import squad_service 

class squad_controller():
  def __main__(self):
    # TODO
    pass
  def __insert_squad__(self,squad):
    keys = ['squad_id','squad']
    squad_fields = [squad.get(k) for k in keys]

    squad_service.insert_squad(squad_fields)
  
  def __insert_round__(self,squad):
    keys = ['round','captain','dayofweek','date','formation','opponent','referee','result','venue','possession','goals_for','goals_against','comp']
    squad_fields = [squad.get(k) for k in keys]

    squad_service.insert_round(squad_fields)

  def __insert_ofensive_stats__(self,squad):
    keys = ['goals_for','goals_per_shot','goals_per_shot_on_target','shots_on_target','shots_on_target_pct','shots_total','average_shot_distance',
            'shots_free_kicks','pens_att','pens_made','xg_for','npxg','npxg_per_shot','xg_net','sca','sca_passes_live','sca_passes_dead','sca_dribbles',
            'sca_shots','sca_fouled','sca_defense','gca','gca_passes_live','gca_passes_dead','gca_dribbles','gca_shots','gca_fouled','gca_defense','crosses','fouled','offsides']
    squad_fields = [squad.get(k) for k in keys]

    squad_service.insert_ofensive_stats(squad_fields)
  
  def __insert_defensive_stats__(self,squad):
    keys = ['xg_against','tackles','tackles_def_3rd','tackles_mid_3rd','tackles_att_3rd','tackles_won','dribble_tackles','dribbles_vs','dribble_tackles_pct',
            'dribbled_past','pressures','pressure_regains','pressure_regain_pct','pressures_def_3rd','pressures_mid_3rd','pressures_att_3rd','blocks','blocked_shots',
            'blocked_shots_saves','blocked_passes','tackles_interceptions','clearances','errors','cards_red','cards_yellow','fouls','interceptions']
    squad_fields = [squad.get(k) for k in keys]

    squad_service.insert_defensive_stats(squad_fields)
  
  def __insert_gk_stats__(self,squad):
    keys = ['clean_sheets','pens_allowed','pens_saved','save_pct','saves','shots_on_target_against','psxg_gk','psxg_net_gk','passes_completed_launched_gk',
            'passes_launched_gk','passes_pct_launched_gk','passes_gk','passes_throws_gk','pct_passes_launched_gk','passes_length_avg_gk','goal_kicks',
            'pct_goal_kicks_launched','goal_kick_length_avg','crosses_gk','crosses_stopped_gk','crosses_stopped_pct_gk','def_actions_outside_pen_area_gk','avg_distance_def_actions_gk',]
    squad_fields = [squad.get(k) for k in keys]

    squad_service.insert_gk_stats(squad_fields)
  
  def __insert_pass_stats__(self,squad):
    keys = ['assists','passes_completed','passes','passes_pct','passes_total_distance','passes_progressive_distance','passes_completed_short',
            'passes_short','passes_pct_short','passes_completed_medium','passes_medium','passes_pct_medium','passes_completed_long','passes_long',
            'passes_pct_long','xa','assisted_shots','passes_into_final_third','passes_into_penalty_area','crosses_into_penalty_area','progressive_passes',
            'passes_live','passes_dead','passes_free_kicks','through_balls','passes_pressure','passes_switches','corner_kicks','corner_kicks_in','corner_kicks_out',
            'corner_kicks_straight','passes_ground','passes_low','passes_high','passes_left_foot','passes_right_foot','passes_head','throw_ins','passes_other_body',
            'passes_offsides','passes_oob','passes_intercepted','passes_blocked']
    squad_fields = [squad.get(k) for k in keys]

    squad_service.insert_pass_stats(squad_fields)

  def __insert_possession_stats__(self, squad):
    keys = ['touches','touches_def_pen_area','touches_def_3rd','touches_mid_3rd','touches_att_3rd','touches_att_pen_area','touches_live_ball','dribbles_completed',
            'dribbles','dribbles_completed_pct','players_dribbled_past','nutmegs','carries','carry_distance','carry_progressive_distance','progressive_carries','carries_into_final_third',
            'carries_into_penalty_area','miscontrols','dispossessed','pass_targets','passes_received','passes_received_pct','progressive_passes_received']
    squad_fields = [squad.get(k) for k in keys]

    squad_service.insert_possession_stats(squad_fields)
  
  def save_squad(self, squad):
    # TODO
    pass