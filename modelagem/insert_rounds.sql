insert into tb_competition(
	competition
)
select distinct competition
from stage_squads
on conflict (competition)
do nothing;

insert into tb_squad(
	squad_id, 
	squad_name, 
	country
)
select distinct 
	squad_id, 
	squad, 
	governing_country
from stage_squads
where squad is not null
on conflict (squad_id);

insert into tb_squad_round(
	competition_id,
	squad_id,
	round,
	round_date,
	dayofweek,
	venue,
	opponent,
	referee,
	result
)
select distinct
	c.competition_id,
	ss.squad_id,
	ss.round,
	ss.date,
	ss.dayofweek,
	ss.venue,
	ss.opponent,
	ss.referee,
	ss.result
from stage_squads as ss
join tb_competition as c
	on ss.competition=c.competition
order by ss.date
on conflict (squad_id, competition_id,round_date)
do nothing;


insert into tb_player(
	player_id,
	squad_id,
	player_name,
	born,
  nationality,
	field_area,
	position,
	foot,
	height,
	weight
)
select distinct
	player_id,
	squad_id,
	name,
	born,
  nationality,
	field_area,
	player_position,
	footed,
	height::smallint,
	weight::smallint
from stage_players;
