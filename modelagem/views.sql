drop view if exists vw_player_performance;
create or replace view vw_player_performance as 
with cte as (
	select 
		p.player_id,
		p.squad_id,
		player_name,
		field_area,
		coalesce(p.position,pms.position,p.field_area) as position,
		round_num,
		venue,
		date,
		opponent,
		((coalesce(clean_sheets,0)*5.0)+(coalesce(tackles_won,0)*1.0)+(coalesce(goals,0)*8.0)+(coalesce(assists,0)*5.0)+((coalesce(shots_total,0)-coalesce(shots_on_target,0))*0.8)+(coalesce(shots_on_target,0)*1.2)+(coalesce(fouled,0)*0.5)-(coalesce(own_goals,0)*5.0)-(coalesce(cards_red,0)*5.0)-(coalesce(cards_yellow,0)*2.0)-((coalesce(fouls,0)+coalesce(pens_made,0))*0.5)-(coalesce(offsides,0)*0.5)) as score,
		round((sum(replace(minutes,',','')::numeric(7,2)) over (partition by p.player_id order by p.player_id, date))/90.00,2) as games,
		(sum(clean_sheets) over (partition by p.player_id order by p.player_id, date)) as clean_sheets,
		(sum(goals) over (partition by p.player_id order by p.player_id, date)) as goals,
		(sum(assists) over (partition by p.player_id order by p.player_id, date)) as assists,
		(sum(tackles_won) over (partition by p.player_id order by p.player_id, date)) as tackles_won,
		(sum(shots_total) over (partition by p.player_id order by p.player_id, date)) as shots_total,
		(sum(shots_on_target) over (partition by p.player_id order by p.player_id, date)) as shots_on_target,
		(sum(fouled) over (partition by p.player_id order by p.player_id, date)) as fouled,
		(sum(own_goals) over (partition by p.player_id order by p.player_id, date)) as own_goals,
		(sum(cards_red) over (partition by p.player_id order by p.player_id, date)) as cards_red,
		(sum(cards_yellow) over (partition by p.player_id order by p.player_id, date)) as cards_yellow,
		(sum(fouls) over (partition by p.player_id order by p.player_id, date)) as fouls,
		(sum(offsides) over (partition by p.player_id order by p.player_id, date)) as offsides,
		(sum(pens_made) over (partition by p.player_id order by p.player_id, date)) as pens_made
	from tb_player as p
	join tb_player_match_stats as pms
		on p.player_id=pms.player_id
	join tb_squad_round as sr
		on pms.id_squad_round=sr.id_squad_round
	where field_area<>'GK' and round is not null and bench_explain is null
)
select 
	player_id,
	squad_id,
	player_name,
	field_area,
	position,
	round_num,
	venue,
	date,
	opponent,
	score,
	round(coalesce(clean_sheets,0)/games,2) as clean_sheets,
	round(coalesce(goals,0)/games,2) as goals,
	round(coalesce(assists,0)/games,2) as assists,
	round(coalesce(tackles_won,0)/games,2) as tackles_won,
	round(coalesce(shots_total,0)/games,2) as shots_total,
	round(coalesce(shots_on_target,0)/games,2) as shots_on_target,
	round(coalesce(fouled,0)/games,2) as fouled,
	round(coalesce(own_goals,0)/games,2) as own_goals,
	round(coalesce(cards_red,0)/games,2) as cards_red,
	round(coalesce(cards_yellow,0)/games,2) as cards_yellow,
	round(coalesce(fouls,0)/games,2) as fouls,
	round(coalesce(offsides,0)/games,2) as offsides,
	round(coalesce(pens_made,0)/games,2) as pens_made
from cte;

drop view if exists vw_keeper_performance;
create view vw_keeper_performance as 
with cte as (
	select 
		p.player_id,
		p.squad_id,
		player_name,
		field_area,
		coalesce(p.position,pms.position,p.field_area) as position,
		round_num,
		venue,
		date,
		opponent,
		((coalesce(clean_sheets,0)*5.0)+(coalesce(goals,0)*8.0)+(coalesce(assists,0)*5.0)+(coalesce(saves,0)*1.2)+(coalesce(pens_saved,0)*7.0)-(coalesce(cards_red,0)*5.0)-(coalesce(goals_against_gk,0)*2.0)-(coalesce(cards_yellow,0)*2.0)-(coalesce(fouls,0)+coalesce(pens_made,0)*0.5)) as score,
		round((sum(replace(minutes,',','')::numeric(7,2)) over (partition by p.player_id order by p.player_id, date))/90.00,2) as games,
		(sum(clean_sheets) over (partition by p.player_id order by p.player_id, date))::numeric(3,1) as clean_sheets,
		(sum(goals) over (partition by p.player_id order by p.player_id, date))::numeric(3,1) as goals,
		(sum(assists) over (partition by p.player_id order by p.player_id, date))::numeric(3,1) as assists,
		(sum(cards_red) over (partition by p.player_id order by p.player_id, date))::numeric(3,1) as cards_red,
		(sum(cards_yellow) over (partition by p.player_id order by p.player_id, date))::numeric(3,1) as cards_yellow,
		(sum(fouls) over (partition by p.player_id order by p.player_id, date))::numeric(3,1) as fouls,
		(sum(pens_made) over (partition by p.player_id order by p.player_id, date))::numeric(3,1) as pens_made,
		(sum(pens_saved) over (partition by p.player_id order by p.player_id, date))::numeric(3,1) as pens_saved,
		(sum(goals_against_gk) over (partition by p.player_id order by p.player_id, date))::numeric(3,1) as goals_against_gk,
		(sum(saves) over (partition by p.player_id order by p.player_id, date))::numeric(3,1) as saves
	from tb_player as p
	join tb_player_match_stats as pms
		on p.player_id=pms.player_id
	join tb_squad_round as sr
		on pms.id_squad_round=sr.id_squad_round
	where field_area='GK' and bench_explain is null
)
select 
	player_id,
	squad_id,
	player_name,
	field_area,
	position,
	round_num,
	venue,
	date,
	opponent,
	score,
	round(coalesce(clean_sheets,0)/games,2) as clean_sheets,
	round(coalesce(goals,0)/games,2) as goals,
	round(coalesce(assists,0)/games,2) as assists,
	round(coalesce(cards_red,0)/games,2) as cards_red,
	round(coalesce(cards_yellow,0)/games,2) as cards_yellow,
	round(coalesce(fouls,0)/games,2) as fouls,
	round(coalesce(pens_made,0)/games,2) as pens_made,
	round(coalesce(pens_saved,0)/games,2) as pens_saved,
	round(coalesce(goals_against_gk,0)/games,2) as goals_against_gk,
	round(coalesce(saves,0)/games,2) as saves
from cte;

drop view if exists vw_squad_performance;
create or replace view vw_squad_performance as 
with cte as (
	select 
		s.squad_id,
		squad_name,
		formation,
		captain,
		round_num,
		venue,
		date,
		opponent,
		(count(round) over (partition by s.squad_id order by s.squad_id, date)) as games,
		(sum(clean_sheets) over (partition by s.squad_id order by s.squad_id, date)) as clean_sheets,
		(sum(possession) over (partition by s.squad_id order by s.squad_id, date)) as possession,
		(sum(goals) over (partition by s.squad_id order by s.squad_id, date)) as goals,
		(sum(goals_per_shot) over (partition by s.squad_id order by s.squad_id, date)) as goals_per_shot,
		(sum(tackles_won) over (partition by s.squad_id order by s.squad_id, date)) as tackles_won,
		(sum(fouled) over (partition by s.squad_id order by s.squad_id, date)) as fouled,
		(sum(shots_total) over (partition by s.squad_id order by s.squad_id, date)) as shots_total,
		(sum(shots_on_target) over (partition by s.squad_id order by s.squad_id, date)) as shots_on_target,
		(sum(cards_red) over (partition by s.squad_id order by s.squad_id, date)) as cards_red,
		(sum(cards_yellow) over (partition by s.squad_id order by s.squad_id, date)) as cards_yellow,
		(sum(fouls) over (partition by s.squad_id order by s.squad_id, date)) as fouls,
		(sum(pens_conceded) over (partition by s.squad_id order by s.squad_id, date)) as pens_conceded,
		(sum(pens_won) over (partition by s.squad_id order by s.squad_id, date)) as pens_won,
		(sum(goals_against) over (partition by s.squad_id order by s.squad_id, date)) as goals_against,
		(sum(saves) over (partition by s.squad_id order by s.squad_id, date)) as saves,
		(sum(opponent_goals_per_shot) over (partition by s.squad_id order by s.squad_id, date)) as opponent_goals_per_shot,
		(sum(opponent_shots_on_target) over (partition by s.squad_id order by s.squad_id, date)) as opponent_shots_on_target,
		(sum(opponent_shots_total) over (partition by s.squad_id order by s.squad_id, date)) as opponent_shots_total
	from tb_squad as s
	join tb_squad_match_stats as sms
		on s.squad_id=sms.squad_id
	join tb_squad_round as sr
		on sms.id_squad_round=sr.id_squad_round
	where date is not null
)

select 
	squad_id,
	squad_name,
	formation,
	captain,
	round_num,
	venue,
	date,
	opponent,
	round(coalesce(clean_sheets,0)/games,2) as clean_sheets,
	round(coalesce(possession,0)/games,2) as possession,
	round(coalesce(goals,0)/games,2) as goals,
	round(coalesce(goals_per_shot,0)/games,2) as goals_per_shot,
	round(coalesce(tackles_won,0)/games,2) as tackles_won,
	round(coalesce(fouled,0)/games,2) as fouled,
	round(coalesce(shots_total,0)/games,2) as shots_total,
	round(coalesce(shots_on_target,0)/games,2) as shots_on_target,
	round(coalesce(cards_red,0)/games,2) as cards_red,
	round(coalesce(cards_yellow,0)/games,2) as cards_yellow,
	round(coalesce(fouls,0)/games,2) as fouls,
	round(coalesce(pens_conceded,0)/games,2) as pens_conceded,
	round(coalesce(pens_won,0)/games,2) as pens_won,
	round(coalesce(goals_against,0)/games,2) as goals_against,
	round(coalesce(saves,0)/games,2) as saves,
	round(coalesce(opponent_goals_per_shot,0)/games,2) as opponent_goals_per_shot,
	round(coalesce(opponent_shots_on_target,0)/games,2) as opponent_shots_on_target,
	round(coalesce(opponent_shots_total,0)/games,2) as opponent_shots_total
from cte;