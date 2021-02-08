insert into tb_squad(
  squad_id,
  squad_name,
  country
)
select distinct 
  squad_id,
  squad,
  'Brazil'
from stage_squads;

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

insert into tb_squad_round(
	squad_id,
	round,
	round_num,
	date,
	dayofweek,
	venue,
	opponent,
	referee,
	result
)
select distinct
	ss.squad_id,
	ss.round,
	ss.round_num::smallint,
	sp.date,
	ss.dayofweek,
	ss.venue,
	ss.opponent,
	ss.referee,
	ss.result
from stage_squads as ss
left join stage_players as sp
	on ss.squad=sp.squad
	and ss.round=sp.round
order by date;