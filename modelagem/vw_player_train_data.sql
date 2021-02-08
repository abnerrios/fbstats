create or replace view vw_player_train_data as 
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
	previous.clean_sheets,
	previous.goals,
	previous.assists,
	previous.tackles_won,
	previous.shots_total,
	previous.shots_on_target,
	previous.fouled,
	previous.own_goals,
	previous.cards_red,
	previous.cards_yellow,
	previous.fouls,
	previous.offsides,
	previous.pens_made,
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
select * 
	from tb_player_performance as p
	where p.player_id=pp.player_id
	and p.round_num=(pp.round_num-1)
) previous on true
left join lateral (
select * 
	from tb_squad_performance as s
	where s.squad_name=pp.opponent
	and s.round_num=(pp.round_num-1)
) op on true;