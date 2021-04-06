-- player predict data 
select 
 	pp.player_id,
	pp.squad_id,
	pp.player_name,
	pp.field_area,
	pp.position,
	pp.round_num,
    pp.venue,
	pp.date,
	pp.opponent,
	pp.score,
	pp.clean_sheets,
	pp.goals,
	pp.assists,
	pp.tackles_won,
	pp.shots_total,
	pp.shots_on_target,
	pp.fouled,
	pp.own_goals,
	pp.cards_red,
	pp.cards_yellow,
	pp.fouls,
	pp.offsides,
	pp.pens_made,
	op.clean_sheets as opponent_clean_sheets,
	op.possession as opponent_possession,
	op.goals as opponent_goals,
	op.goals_per_shot as opponent_goals_per_shot,
	op.tackles_won as opponent_tackles_won,
	op.fouled as opponent_fouled,
	op.shots_total as opponent_shots_total,
	op.shots_on_target as opponent_shots_on_target,
	op.cards_red as opponent_cards_red,
	op.cards_yellow as opponent_cards_yellow,
	op.fouls as opponent_fouls,
	op.pens_conceded as opponent_pens_conceded,
	op.pens_won as opponent_pens_won,
	op.saves as opponent_saves,
	op.goals_against as opponent_goals_against,
	op.opponent_goals_per_shot as opponent_goals_per_shot_against,
	op.opponent_shots_on_target as opponent_shots_on_target_against,
	op.opponent_shots_total as opponent_shots_total_against
from tb_player_performance as pp
join lateral (
  select max(round_num) as last_round
  from tb_player_performance
  where player_id=pp.player_id
) lr on true
left join lateral (
  select * 
    from tb_squad_performance
    where squad_name=pp.opponent
    and round_num=25
) op on true
where pp.round_num=lr.last_round;

-- keeper predict data 
select
	kp.player_id,
	kp.squad_id,
	kp.player_name,
	kp.field_area,
	kp.position,
	kp.round_num,
    kp.venue,
	kp.date,
	kp.opponent,
	kp.score,
	kp.clean_sheets,
	kp.goals,
	kp.assists,
	kp.cards_red,
	kp.cards_yellow,
	kp.fouls,
	kp.pens_made,
	kp.pens_saved,
	kp.goals_against_gk,
	kp.saves,
	op.clean_sheets as opponent_clean_sheets,
	op.possession as opponent_possession,
	op.goals as opponent_goals,
	op.goals_per_shot as opponent_goals_per_shot,
	op.tackles_won as opponent_tackles_won,
	op.fouled as opponent_fouled,
	op.shots_total as opponent_shots_total,
	op.shots_on_target as opponent_shots_on_target,
	op.cards_red as opponent_cards_red,
	op.cards_yellow as opponent_cards_yellow,
	op.fouls as opponent_fouls,
	op.pens_conceded as opponent_pens_conceded,
	op.pens_won as opponent_pens_won,
	op.saves as opponent_saves,
	op.goals_against as opponent_goals_against,
	op.opponent_goals_per_shot as opponent_goals_per_shot_against,
	op.opponent_shots_on_target as opponent_shots_on_target_against,
	op.opponent_shots_total as opponent_shots_total_against
from tb_keeper_performance as kp
join lateral (
  select max(round_num) as last_round
  from tb_keeper_performance
  where player_id=kp.player_id
) lr on true
left join lateral (
  select * 
    from tb_squad_performance
    where squad_name=kp.opponent
    and round_num=25
) op on true
where kp.round_num=lr.last_round
  and kp.clean_sheets is not null;