create or replace view vw_keeper_train_data as 
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
	previous.clean_sheets,
	previous.goals,
	previous.assists,
	previous.cards_red,
	previous.cards_yellow,
	previous.fouls,
	previous.pens_made,
	previous.pens_saved,
	previous.goals_against_gk,
	previous.saves,
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
	select * 
		from tb_keeper_performance as p
		where p.player_id=kp.player_id
		and p.round_num=(kp.round_num-1)
) previous on true
left join lateral (
	select * 
		from tb_squad_performance
		where squad_name=kp.opponent
		and round_num=(kp.round_num-1)
) op on true
where kp.round_num>1;