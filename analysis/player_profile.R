library(mongolite)
library(tidyverse)
library(ggtext)
library(reactable)
library(waffle)
library(patchwork)

# define configurações de acesso ao banco de dados
mongohost <- "mongodb://fbscout_app:ceqfym-4pAqvi-qymhes@cluster0-shard-00-00.old9q.mongodb.net:27017,cluster0-shard-00-01.old9q.mongodb.net:27017,cluster0-shard-00-02.old9q.mongodb.net:27017/myFirstDatabase?ssl=true&replicaSet=atlas-13pm6z-shard-0&authSource=admin&retryWrites=true&w=majority"

# set up databases variables
squadsdb <- mongolite::mongo(url=mongohost, collection = "squads", db = "fbstats")
playersdb <- mongolite::mongo(url=mongohost, collection = "players", db = "fbstats")
squads_statsdb <- mongolite::mongo(url=mongohost, collection = "squad_stats", db = "fbstats")

# load players and squads data
squads <- base::as.data.frame(squadsdb$find())
players <- base::as.data.frame(playersdb$find(fields = '{
          "player_id":true, "name":true, "age":true, "position":true, "squad_id":true, "nationality":true, "games":true,
          "goals_per90":true, "assists_per90":true, "goals_assists_per90":true, "goals_per_shot":true,
          "goals":true, "goals_assists":true, "assists":true,"shots_total":true,"shots_on_target":true, 
          "shots_total_per90":true, "shots_on_target_per90":true, "fouled":true, 
          "interceptions":true, "fouls":true, "tackles_won":true, "crosses":true, "minutes":true, 
          "cards_yellow":true, "cards_red":true, "plus_minus_per90":true, "points_per_match":true}'))
player_squad <- dplyr::inner_join(squads, players, by = "squad_id")


player_name <- "Julián Álvarez"
squad_name <- "River Plate"

#player_squad %>% filter(name.x==squad_name) %>% select(name.y)

theme_set(theme_light(base_size = 14))
# cria a palleta de cores
my_pal = c("#EC5C37","#2C80B7","#277C52","#EDC942", "#72B7C4", "#F5ECDB")

# select player 
pid <- (player_squad %>% filter(name.x==squad_name & name.y==player_name))$player_id
player <- player_squad %>% 
  filter(player_id == pid) %>% 
  mutate(tackles_won=round(tackles_won/(minutes/90),2),
         interceptions=round(interceptions/(minutes/90),2),            
         fouls=round(fouls/(minutes/90),2), 
         fouled=round(fouled/(minutes/90),2),
         crosses=round(crosses/(minutes/90),2),
         cards_yellow=round(cards_yellow/(minutes/90),2),
         cards_red=round(cards_red/(minutes/90),2))

# set chart title
chart_title <- player %>% 
  mutate(chart_title = paste(name.y, '|', position), sep=" ") %>% 
  select(chart_title)

# set chart subtitle
description <- player %>% 
  mutate(description=paste(nationality, 
                           paste("Age:",age), 
                           paste('Club:',name.x),
                           paste(minutes, "minutes", paste("|",games,"games")), 
                           sep="\n")
  ) %>% 
  select(description)


# create pizza chart of player (90 min based)
pizza_chart <- player %>% 
  select(goals_per90, assists_per90, goals_assists_per90, shots_total_per90, shots_on_target_per90, crosses, 
         interceptions, fouls, tackles_won, cards_yellow, cards_red) %>%  
  rename("Goals"=goals_per90, "Assists"=assists_per90, "G+A"=goals_assists_per90, "Shots"=shots_total_per90, 
         "Shots on Target"=shots_on_target_per90,"Crosses"=crosses,
         "Interceptions"=interceptions, "Tackles Won"=tackles_won,
         "Fouls Committed"=fouls, "Yellow Cards"=cards_yellow, "Red Cards"=cards_red) %>% 
  gather("skill", "value", 1:11) %>% 
  mutate(category = if_else(skill %in% c("Goals", "Assists", "G+A","Shots", "Crosses", "Shots on Target"),"Attack", 
                            if_else(skill %in% c("Interceptions", "Tackles Won"),"Defense",
                                    if_else(skill %in% c("Yellow Cards","Fouls Committed","Red Cards"),"Discipline","Impact"))),
         value = as.numeric(value)) %>%
  ggplot(aes(x=fct_reorder(skill, category), y=value, label=value, fill=category)) +
  labs(
    title=chart_title,
    subtitle=description,
    fill="",
    caption ="source: FBref | @abn3rrios"
  ) +
  scale_x_discrete(labels=function(x){sub("\\s", "\n", x)}) +
  geom_col(colour="#252525",
           position="dodge2", show.legend=TRUE, alpha=1) +
  geom_text(aes(x=skill, y=value+0.4, label=value), vjust=0, colour="#252525", size=2.5, position = position_dodge(0.9), fontface="bold") +
  scale_fill_manual(values = my_pal) +
  coord_polar() +
  theme(axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_text(angle=0, colour='#212121', size=7, face='bold'),
        plot.title = element_text(size=18, hjust=0, face='bold'),
        plot.subtitle = element_text(size=10, hjust=0),
        plot.caption = element_text(size=10, face='bold'),
        panel.background = element_rect(fill='white', size=1),
        panel.border = element_blank(),
        panel.grid.major = element_line(colour='#e3e3e3'),
        panel.grid.minor = element_blank(),
        legend.position = 'bottom',
        legend.key.size = unit(0.3, "cm"),
        legend.text = element_text(size=8, face='bold')
  )

# create waffle chart based on actions distribution
actions_chart <- player_squad %>% 
  filter(player_id == pid) %>%   
  select(goals, assists, shots_total, crosses,
         interceptions, fouls, tackles_won, cards_yellow, cards_red) %>%  
  gather("skill", "value", 1:9) %>% 
  mutate(category = if_else(skill %in% c("goals", "assists", "shots_total", "fouled", "crosses"),"Attack", 
                            if_else(skill %in% c("interceptions", "tackles_won"),"Defense",
                                    if_else(skill %in% c("cards_yellow","cards_red","fouls"),"Discipline","Impact"))),
         value = as.numeric(value)) %>% 
  arrange(category) %>% 
  ggplot(aes(fill=category, values=value)) +
  labs(
    fill=""
  ) +
  geom_waffle(aes(fill=category, values=value), size = 0.33, flip = TRUE, n_rows=4) +
  scale_fill_manual(values = my_pal) +
  coord_equal() +
  theme(axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_blank(),
        plot.title = element_text(size=18, hjust=0, face='bold'),
        plot.subtitle = element_text(size=12, hjust=0),
        panel.background = element_rect(fill='white', size=1),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.position = 'none',
        legend.key.size = unit(0.3, "cm"),
        legend.text = element_text(size=8, face='bold')
  )

pizza_chart + actions_chart
