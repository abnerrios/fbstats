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

create table tb_country(
	country varchar(50),
	alpha varchar(3)
);

create table tb_competition(
  competition_id serial,
  competition varchar(50),
  unique (competition)
)

create table tb_squad(
	squad_id varchar(20),
	squad_name varchar(50),
	country char(2),
	primary key(squad_id)
);

create table tb_squad_round(
  id_squad_round serial,
  competition_id integer,
  round varchar(60),
  round_date date,
  dayofweek varchar(3),
  venue varchar(8),
  squad_id varchar(50),
  opponent varchar(50),
  referee varchar(70),
  result  char(1),
  primary key (id_squad_round),
  unique(squad_id, competition_id,round_date)
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
  xg_for  numeric(4,1),
  xg_against  numeric(4,1),
  attendance  numeric(4,1),
  average_shot_distance   numeric(4,1),
  shots_free_kicks   numeric(4,1),
  npxg  numeric(4,1),
  npxg_per_shot  numeric(4,1),
  xg_net  numeric(4,1),
  psxg_gk  numeric(4,1),
  psxg_net_gk  numeric(4,1),
  passes_completed_launched_gk integer,
  passes_launched_gk integer,
  passes_pct_launched_gk  numeric(4,1),
  passes_gk integer,
  passes_throws_gk integer,
  pct_passes_launched_gk  numeric(4,1),
  passes_length_avg_gk  numeric(4,1),
  goal_kicks integer,
  pct_goal_kicks_launched  numeric(4,1),
  goal_kick_length_avg  numeric(4,1),
  crosses_gk integer,
  crosses_stopped_gk integer,
  crosses_stopped_pct_gk  numeric(4,1),
  def_actions_outside_pen_area_gk integer,
  avg_distance_def_actions_gk  numeric(4,1),
  passes_completed integer,
  passes integer,
  passes_pct  numeric(4,1),
  passes_total_distance integer,
  passes_progressive_distance integer,
  passes_completed_short integer,
  passes_short integer,
  passes_pct_short  numeric(4,1),
  passes_completed_medium integer,
  passes_medium integer,
  passes_pct_medium  numeric(4,1),
  passes_completed_long integer,
  passes_long integer,
  passes_pct_long  numeric(4,1),
  xa  numeric(4,1),
  assisted_shots integer,
  passes_ integero_final_third integer,
  passes_ integero_penalty_area integer,
  crosses_ integero_penalty_area integer,
  progressive_passes integer,
  passes_live integer,
  passes_dead integer,
  passes_free_kicks integer,
  through_balls integer,
  passes_pressure integer,
  passes_switches integer,
  corner_kicks integer,
  corner_kicks_in integer,
  corner_kicks_out integer,
  corner_kicks_straight integer,
  passes_ground integer,
  passes_low integer,
  passes_high integer,
  passes_left_foot integer,
  passes_right_foot integer,
  passes_head integer,
  throw_ins integer,
  passes_other_body integer,
  passes_offsides integer,
  passes_oob integer,
  passes_ integerercepted integer,
  passes_blocked integer,
  sca integer,
  sca_passes_live integer,
  sca_passes_dead integer,
  sca_dribbles integer,
  sca_shots integer,
  sca_fouled integer,
  sca_defense integer,
  gca integer,
  gca_passes_live integer,
  gca_passes_dead integer,
  gca_dribbles integer,
  gca_shots integer,
  gca_fouled integer,
  gca_defense integer,
  tackles integer,
  tackles_def_3rd integer,
  tackles_mid_3rd integer,
  tackles_att_3rd integer,
  dribble_tackles integer,
  dribbles_vs integer,
  dribble_tackles_pct  numeric(4,1),
  dribbled_past integer,
  pressures integer,
  pressure_regains integer,
  pressure_regain_pct integer,
  pressures_def_3rd integer,
  pressures_mid_3rd integer,
  pressures_att_3rd integer,
  blocks integer,
  blocked_shots integer,
  blocked_shots_saves integer,
  blocked_passes integer,
  tackles_ integererceptions integer,
  clearances integer,
  errors integer,
  touches integer,
  touches_def_pen_area integer,
  touches_def_3rd integer,
  touches_mid_3rd integer,
  touches_att_3rd integer,
  touches_att_pen_area integer,
  touches_live_ball integer,
  dribbles_completed integer,
  dribbles integer,
  dribbles_completed_pct  numeric(4,1),
  players_dribbled_past integer,
  nutmegs integer,
  carries integer,
  carry_distance integer,
  carry_progressive_distance integer,
  progressive_carries integer,
  carries_ integero_final_third integer,
  carries_ integero_penalty_area integer,
  miscontrols integer,
  dispossessed integer,
  pass_targets integer,
  passes_received integer,
  passes_received_pct integer,
  progressive_passes_received integer
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