drop view if exists vw_player_train_data;
drop view if exists vw_keeper_train_data;
drop view if exists vw_player_performance;
drop view if exists vw_keeper_performance;
drop view if exists vw_squad_performance;
drop table if exists tb_player_performance;
drop table if exists tb_keeper_performance;
drop table if exists tb_squad_performance;
drop table if exists tb_player_match_stats;
drop table if exists tb_squad_match_stats;
drop table if exists tb_squad_round;
drop table if exists tb_player;
drop table if exists tb_squad;

create table tb_squad(
	squad_id varchar(20),
	squad_name varchar(50),
  competition varchar(50),
	country varchar(25),
	primary key(squad_id)
);

create table tb_player(
	player_id varchar(20),
	squad_id  varchar(20),
	player_name varchar(50),
	born date,
	nationality varchar(10),
	field_area varchar(5),
	position varchar(20),
	foot varchar(6),
	height smallint,
	weight smallint,
	primary key(player_id)
);

create table tb_squad_round(
  id_squad_round serial,
  round varchar(30),
  round_num smallint,
  round_date date,
  dayofweek varchar(3),
  venue char(4),
  squad_id varchar(50),
  opponent varchar(50),
  referee varchar(70),
  result  char(1),
  primary key (id_squad_round),
  unique(squad_id, round_date)
);

create table tb_squad_match_stats(
	id_squad_match_stat serial,
  id_squad_round integer,
  squad_id varchar(50),
  captain varchar(50),
  formation varchar(15),
  goals_against numeric(4,1),
  goals_for numeric(4,1),
  possession numeric(4,1),
  goals numeric(4,1),
  goals_per_shot numeric(3,2),
  goals_per_shot_on_target numeric(3,2),
  pens_att numeric(4,1),
  pens_made numeric(4,1),
  shots_on_target numeric(4,1),
  shots_on_target_pct numeric(4,1),
  shots_total numeric(4,1),
  opponent_goals numeric(4,1),
  opponent_goals_against numeric(4,1),
  opponent_goals_for numeric(4,1),
  opponent_goals_per_shot numeric(3,2),
  opponent_goals_per_shot_on_target numeric(3,2),
  opponent_pens_att numeric(4,1),
  opponent_pens_made numeric(4,1),
  opponent_shots_on_target numeric(4,1),
  opponent_shots_on_target_pct numeric(4,1),
  opponent_shots_total numeric(4,1),
  clean_sheets numeric(4,1),
  goals_against_gk numeric(4,1),
  pens_allowed numeric(4,1),
  pens_att_gk numeric(4,1),
  pens_missed_gk numeric(4,1),
  pens_saved numeric(4,1),
  save_pct numeric(4,1),
  saves numeric(4,1),
  shots_on_target_against numeric(4,1),
  opponent_clean_sheets numeric(4,1),
  opponent_goals_against_gk numeric(4,1),
  opponent_pens_allowed numeric(4,1),
  opponent_pens_att_gk numeric(4,1),
  opponent_pens_missed_gk numeric(4,1),
  opponent_pens_saved numeric(4,1),
  opponent_save_pct numeric(4,1),
  opponent_saves numeric(4,1),
  opponent_shots_on_target_against numeric(4,1),
  cards_red numeric(4,1),
  cards_yellow numeric(4,1),
  cards_yellow_red numeric(4,1),
  crosses numeric(4,1),
  fouled numeric(4,1),
  fouls numeric(4,1),
  interceptions numeric(4,1),
  offsides numeric(4,1),
  own_goals numeric(4,1),
  pens_conceded numeric(4,1),
  pens_won numeric(4,1),
  tackles_won numeric(4,1),
  opponent_cards_red numeric(4,1),
  opponent_cards_yellow numeric(4,1),
  opponent_cards_yellow_red numeric(4,1),
  opponent_crosses numeric(4,1),
  opponent_fouled numeric(4,1),
  opponent_fouls numeric(4,1),
  opponent_interceptions numeric(4,1),
  opponent_offsides numeric(4,1),
  opponent_own_goals numeric(4,1),
  opponent_pens_conceded numeric(4,1),
  opponent_pens_won numeric(4,1),
  opponent_tackles_won numeric(4,1),
	primary key(id_squad_match_stat),
  unique(squad_id, id_squad_round)
);

create table if not exists tb_player_match_stats (
  player_id varchar(20),
  id_squad_round integer,
  clean_sheets numeric(4,1),
  game_started varchar(2),
  goals_against_gk numeric(4,1),
  minutes varchar(6),
  pens_allowed numeric(4,1),
  pens_att_gk numeric(4,1),
  pens_missed_gk numeric(4,1),
  pens_saved numeric(4,1),
  position varchar(10),
  save_pct numeric(3,2),
  saves numeric(4,1),
  shots_on_target_against numeric(4,1),
  assists numeric(4,1),
  assists_per90 numeric(3,2),
  cards_red numeric(4,1),
  cards_yellow numeric(4,1),
  crosses numeric(4,1),
  fouled numeric(4,1),
  fouls numeric(4,1),
  games numeric(4,1),
  games_starts numeric(4,1),
  goals numeric(4,1),
  goals_assists_pens_per90 numeric(3,2),
  goals_assists_per90 numeric(3,2),
  goals_pens_per90 numeric(3,2),
  goals_per90 numeric(3,2),
  interceptions numeric(4,1),
  offsides numeric(4,1),
  own_goals numeric(4,1),
  pens_att numeric(4,1),
  pens_conceded numeric(4,1),
  pens_made numeric(4,1),
  pens_won numeric(4,1),
  shots_on_target numeric(4,1),
  shots_total numeric(4,1),
  tackles_won numeric(4,1),
  bench_explain varchar(70)
);

create table tb_player_performance(
	player_id varchar(20),
	squad_id varchar(20),
	player_name varchar(50),
	field_area varchar(20),
	position varchar(20),
	round_num smallint,
  venue char(4),
	date date,
	opponent varchar(50),
	score numeric(3,1),
	goals numeric(4,1),
  clean_sheets numeric(4,1),
	assists numeric(4,1),
	tackles_won numeric(4,1),
	shots_total numeric(4,1),
	shots_on_target numeric(4,1),
	fouled numeric(4,1),
	own_goals numeric(4,1),
	cards_red numeric(4,1),
	cards_yellow numeric(4,1),
	fouls numeric(4,1),
	offsides numeric(4,1),
	pens_made numeric(4,1)
);

create table tb_keeper_performance(
	player_id varchar(20),
	squad_id varchar(20),
	player_name varchar(50),
	field_area varchar(20),
	position varchar(20),
	round_num smallint,
  venue char(4),
	date date,
	opponent varchar(50),
	score numeric(3,1),
	clean_sheets numeric(3,2),
	goals numeric(3,2),
	assists numeric(3,2),
	cards_red numeric(3,2),
	cards_yellow numeric(3,2),
	tackles_won numeric(3,2),
	shots_total numeric(3,2),
	shots_on_target numeric(3,2),
	fouls numeric(4,1),
	pens_made numeric(3,2),
  pens_saved numeric(3,2),
  goals_against_gk numeric(3,2),
  saves numeric(4,1)
);

create table tb_squad_performance(
	squad_id varchar(20),
  squad_name varchar(50),
  formation varchar(15),
	captain varchar(50),
	round_num smallint,
  venue char(4),
	date date,
	opponent varchar(50),
	clean_sheets numeric(4,1),
	possession numeric(4,1),
	goals numeric(4,1),
	goals_per_shot numeric(4,1),
	tackles_won numeric(4,1),
	fouled numeric(4,1),
	shots_total numeric(4,1),
	shots_on_target numeric(4,1),
	cards_red numeric(4,1),
	cards_yellow numeric(4,1),
	fouls numeric(4,1),
	pens_conceded numeric(4,1),
	pens_won numeric(4,1),
	goals_against numeric(4,1),
	saves numeric(4,1),
	opponent_goals_per_shot numeric(4,1),
	opponent_shots_on_target numeric(4,1),
	opponent_shots_total numeric(4,1)
);

alter table tb_player
	add constraint fk_tb_squad_TO_tb_player
	foreign key (squad_id)
	references tb_squad(squad_id);

alter table tb_squad_match_stats
	add constraint fk_tb_squad_TO_tb_squad_match_stats
	foreign key (squad_id)
	references tb_squad(squad_id);

alter table tb_squad_match_stats
	add constraint fk_tb_squad_round_TO_tb_squad_match_stats
	foreign key (id_squad_round)
	references tb_squad_round(id_squad_round);

alter table tb_player_match_stats
	add constraint fk_tb_squad_TO_tb_player_match_stats
	foreign key (player_id)
	references tb_player(player_id);

alter table tb_player_match_stats
	add constraint fk_tb_squad_round_TO_tb_player_match_stats
	foreign key (id_squad_round)
	references tb_squad_round(id_squad_round);