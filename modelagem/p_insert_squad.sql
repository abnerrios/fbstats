drop procedure if exists p_insert_squad;
create procedure p_insert_squad(
	_squad_id varchar(20);
	_squad_name varchar(50);
  _competition varchar(50);
	_country varchar(25);
  _round varchar(30);
  _round_num smallint;
  _round_date date;
  _dayofweek varchar(3);
  _venue char(4);
  _opponent varchar(50);
  _referee varchar(70);
  _result  char(1);
  _captain varchar(50);
  _formation varchar(15);
  _goals_against numeric(4,1);
  _goals_for numeric(4,1);
  _possession numeric(4,1);
  _goals numeric(4,1);
  _goals_per_shot numeric(3,2);
  _goals_per_shot_on_target numeric(3,2);
  _pens_att numeric(4,1);
  _pens_made numeric(4,1);
  _shots_on_target numeric(4,1);
  _shots_on_target_pct numeric(4,1);
  _shots_total numeric(4,1);
  _clean_sheets numeric(4,1);
  _goals_against_gk numeric(4,1);
  _pens_allowed numeric(4,1);
  _pens_att_gk numeric(4,1);
  _pens_missed_gk numeric(4,1);
  _pens_saved numeric(4,1);
  _save_pct numeric(4,1);
  _saves numeric(4,1);
  _cards_red numeric(4,1);
  _cards_yellow numeric(4,1);
  _cards_yellow_red numeric(4,1);
  _crosses numeric(4,1);
  _fouled numeric(4,1);
  _fouls numeric(4,1);
  _interceptions numeric(4,1);
  _offsides numeric(4,1);
  _own_goals numeric(4,1);
  _pens_conceded numeric(4,1);
  _pens_won numeric(4,1);
  _tackles_won numeric(4,1);
  _opponent_goals numeric(4,1);
  _opponent_goals_against numeric(4,1);
  _opponent_goals_for numeric(4,1);
  _opponent_goals_per_shot numeric(3,2);
  _opponent_goals_per_shot_on_target numeric(3,2);
  _opponent_pens_att numeric(4,1);
  _opponent_pens_made numeric(4,1);
  _opponent_shots_on_target numeric(4,1);
  _opponent_shots_on_target_pct numeric(4,1);
  _opponent_shots_total numeric(4,1);
  _shots_on_target_against numeric(4,1);
  _opponent_clean_sheets numeric(4,1);
  _opponent_goals_against_gk numeric(4,1);
  _opponent_pens_allowed numeric(4,1);
  _opponent_pens_att_gk numeric(4,1);
  _opponent_pens_missed_gk numeric(4,1);
  _opponent_pens_saved numeric(4,1);
  _opponent_save_pct numeric(4,1);
  _opponent_saves numeric(4,1);
  _opponent_shots_on_target_against numeric(4,1);
  _opponent_cards_red numeric(4,1);
  _opponent_cards_yellow numeric(4,1);
  _opponent_cards_yellow_red numeric(4,1);
  _opponent_crosses numeric(4,1);
  _opponent_fouled numeric(4,1);
  _opponent_fouls numeric(4,1);
  _opponent_interceptions numeric(4,1);
  _opponent_offsides numeric(4,1);
  _opponent_own_goals numeric(4,1);
  _opponent_pens_conceded numeric(4,1);
  _opponent_pens_won numeric(4,1);
  _opponent_tackles_won numeric(4,1)
)
language plpgsql as $$
begin 

  -- Insere os dados do clube
  insert into tb_squad(
    squad_id,
    squad_name,
    competition,
    country
  )
  values(
    _squad_id,
    _squad_name,
    _competition,
    _country
  )
  on conflict(squad_id)
  do nothing;

  -- Insere infos de rodadas
  insert into tb_squad_round(
    round,
    round_num,
    round_date,
    dayofweek,
    venue,
    squad_id,
    opponent,
    referee,
    result
  )
  values(
    _round,
    _round_num,
    _round_date,
    _dayofweek,
    _venue,
    _squad_id,
    _opponent,
    _referee,
    _result
  )
  on conflict(squad_id, round_date)
  do update
  set round = EXCLUDED.round,
    round_num = EXCLUDED.round_num,
    dayofweek = EXCLUDED.dayofweek,
    venue = EXCLUDED.venue,
    opponent = EXCLUDED.opponent,
    referee = EXCLUDED.referee,
    result = EXCLUDED.result
  where squad_id = _squad_id
    and round_date = _round_date
  returning id_squad_round into _id_squad_round;


  -- Insere estatisticas da partida
  insert into tb_squad_match_stats(
    id_squad_round,
    squad_id,
    captain,
    formation,
    goals_against,
    goals_for,
    possession,
    goals,
    goals_per_shot,
    goals_per_shot_on_target,
    pens_att,
    pens_made,
    shots_on_target,
    shots_on_target_pct,
    shots_total,
    opponent_goals,
    opponent_goals_against,
    opponent_goals_for,
    opponent_goals_per_shot,
    opponent_goals_per_shot_on_target,
    opponent_pens_att,
    opponent_pens_made,
    opponent_shots_on_target,
    opponent_shots_on_target_pct,
    opponent_shots_total,
    clean_sheets,
    goals_against_gk,
    pens_allowed,
    pens_att_gk,
    pens_missed_gk,
    pens_saved,
    save_pct,
    saves,
    shots_on_target_against,
    opponent_clean_sheets,
    opponent_goals_against_gk,
    opponent_pens_allowed,
    opponent_pens_att_gk,
    opponent_pens_missed_gk,
    opponent_pens_saved,
    opponent_save_pct,
    opponent_saves,
    opponent_shots_on_target_against,
    cards_red,
    cards_yellow,
    cards_yellow_red,
    crosses,
    fouled,
    fouls,
    interceptions,
    offsides,
    own_goals,
    pens_conceded,
    pens_won,
    tackles_won,
    opponent_cards_red,
    opponent_cards_yellow,
    opponent_cards_yellow_red,
    opponent_crosses,
    opponent_fouled,
    opponent_fouls,
    opponent_interceptions,
    opponent_offsides,
    opponent_own_goals,
    opponent_pens_conceded,
    opponent_pens_won,
    opponent_tackles_won
  )
  values (
    _id_squad_round,
    _squad_id,
    _captain,
    _formation,
    _goals_against,
    _goals_for,
    _possession,
    _goals,
    _goals_per_shot,
    _goals_per_shot_on_target,
    _pens_att,
    _pens_made,
    _shots_on_target,
    _shots_on_target_pct,
    _shots_total,
    _opponent_goals,
    _opponent_goals_against,
    _opponent_goals_for,
    _opponent_goals_per_shot,
    _opponent_goals_per_shot_on_target,
    _opponent_pens_att,
    _opponent_pens_made,
    _opponent_shots_on_target,
    _opponent_shots_on_target_pct,
    _opponent_shots_total,
    _clean_sheets,
    _goals_against_gk,
    _pens_allowed,
    _pens_att_gk,
    _pens_missed_gk,
    _pens_saved,
    _save_pct,
    _saves,
    _shots_on_target_against,
    _opponent_clean_sheets,
    _opponent_goals_against_gk,
    _opponent_pens_allowed,
    _opponent_pens_att_gk,
    _opponent_pens_missed_gk,
    _opponent_pens_saved,
    _opponent_save_pct,
    _opponent_saves,
    _opponent_shots_on_target_against,
    _cards_red,
    _cards_yellow,
    _cards_yellow_red,
    _crosses,
    _fouled,
    _fouls,
    _interceptions,
    _offsides,
    _own_goals,
    _pens_conceded,
    _pens_won,
    _tackles_won,
    _opponent_cards_red,
    _opponent_cards_yellow,
    _opponent_cards_yellow_red,
    _opponent_crosses,
    _opponent_fouled,
    _opponent_fouls,
    _opponent_interceptions,
    _opponent_offsides,
    _opponent_own_goals,
    _opponent_pens_conceded,
    _opponent_pens_won,
    _opponent_tackles_won
  )
  on conflict(squad_id, id_squad_round)
  do update 
  set 
    captain = EXCLUDED.captain,
    formation = EXCLUDED.formation,
    goals_against = EXCLUDED.goals_against,
    goals_for = EXCLUDED.goals_for,
    possession = EXCLUDED.possession,
    goals = EXCLUDED.goals,
    goals_per_shot = EXCLUDED.goals_per_shot,
    goals_per_shot_on_target = EXCLUDED.goals_per_shot_on_target,
    pens_att = EXCLUDED.pens_att,
    pens_made = EXCLUDED.pens_made,
    shots_on_target = EXCLUDED.shots_on_target,
    shots_on_target_pct = EXCLUDED.shots_on_target_pct,
    shots_total = EXCLUDED.shots_total,
    opponent_goals = EXCLUDED.opponent_goals,
    opponent_goals_against = EXCLUDED.opponent_goals_against,
    opponent_goals_for = EXCLUDED.opponent_goals_for,
    opponent_goals_per_shot = EXCLUDED.opponent_goals_per_shot,
    opponent_goals_per_shot_on_target = EXCLUDED.opponent_goals_per_shot_on_target,
    opponent_pens_att = EXCLUDED.opponent_pens_att,
    opponent_pens_made = EXCLUDED.opponent_pens_made,
    opponent_shots_on_target = EXCLUDED.opponent_shots_on_target,
    opponent_shots_on_target_pct = EXCLUDED.opponent_shots_on_target_pct,
    opponent_shots_total = EXCLUDED.opponent_shots_total,
    clean_sheets = EXCLUDED.clean_sheets,
    goals_against_gk = EXCLUDED.goals_against_gk,
    pens_allowed = EXCLUDED.pens_allowed,
    pens_att_gk = EXCLUDED.pens_att_gk,
    pens_missed_gk = EXCLUDED.pens_missed_gk,
    pens_saved = EXCLUDED.pens_saved,
    save_pct = EXCLUDED.save_pct,
    saves = EXCLUDED.saves,
    shots_on_target_against = EXCLUDED.shots_on_target_against,
    opponent_clean_sheets = EXCLUDED.opponent_clean_sheets,
    opponent_goals_against_gk = EXCLUDED.opponent_goals_against_gk,
    opponent_pens_allowed = EXCLUDED.opponent_pens_allowed,
    opponent_pens_att_gk = EXCLUDED.opponent_pens_att_gk,
    opponent_pens_missed_gk = EXCLUDED.opponent_pens_missed_gk,
    opponent_pens_saved = EXCLUDED.opponent_pens_saved,
    opponent_save_pct = EXCLUDED.opponent_save_pct,
    opponent_saves = EXCLUDED.opponent_saves,
    opponent_shots_on_target_against = EXCLUDED.opponent_shots_on_target_against,
    cards_red = EXCLUDED.cards_red,
    cards_yellow = EXCLUDED.cards_yellow,
    cards_yellow_red = EXCLUDED.cards_yellow_red,
    crosses = EXCLUDED.crosses,
    fouled = EXCLUDED.fouled,
    fouls = EXCLUDED.fouls,
    interceptions = EXCLUDED.interceptions,
    offsides = EXCLUDED.offsides,
    own_goals = EXCLUDED.own_goals,
    pens_conceded = EXCLUDED.pens_conceded,
    pens_won = EXCLUDED.pens_won,
    tackles_won = EXCLUDED.tackles_won,
    opponent_cards_red = EXCLUDED.opponent_cards_red,
    opponent_cards_yellow = EXCLUDED.opponent_cards_yellow,
    opponent_cards_yellow_red = EXCLUDED.opponent_cards_yellow_red,
    opponent_crosses = EXCLUDED.opponent_crosses,
    opponent_fouled = EXCLUDED.opponent_fouled,
    opponent_fouls = EXCLUDED.opponent_fouls,
    opponent_interceptions = EXCLUDED.opponent_interceptions,
    opponent_offsides = EXCLUDED.opponent_offsides,
    opponent_own_goals = EXCLUDED.opponent_own_goals,
    opponent_pens_conceded = EXCLUDED.opponent_pens_conceded,
    opponent_pens_won = EXCLUDED.opponent_pens_won,
    opponent_tackles_won = EXCLUDED.opponent_tackles_won
  where squad_id = _squad_id
    and id_squad_round = _id_squad_round;

end $$;