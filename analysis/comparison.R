library(mongolite)
library(tidyverse)
library(ggtext)
library(reactable)
library(waffle)
library(patchwork)


coord_radar <- function (theta = "x", start = 0, direction = 1) {
  theta <- match.arg(theta, c("x", "y"))
  r <- if (theta == "x") "y" else "x"
  ggproto("CordRadar", CoordPolar, theta = theta, r = r, start = start, 
          direction = sign(direction),
          is_linear = function(coord) TRUE)
}

player_one <- 'Heitor'
player_two <- 'Fabricio Bustos'
squads_players <- c('Internacional','Independiente')


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


players_comparison <- player_squad %>% 
  filter((name.x %in% squads_players) 
         & (name.y == player_one | name.y == player_two)) %>% 
  mutate(tackles_won_per90=round(tackles_won/(minutes/90),2),
         interceptions_per90=round(interceptions/(minutes/90),2), 
         fouls_per90=round(fouls/(minutes/90),2), 
         fouled_per90=round(fouled/(minutes/90),2),
         crosses_per90=round(crosses/(minutes/90),2),
         cards_yellow_per90=round(cards_yellow/(minutes/90),2),
         cards_red_per90=round(cards_red/(minutes/90),2))

comparison_chart <- players_comparison %>% 
  select(goals_per90, assists_per90, goals_assists_per90, shots_total_per90, shots_on_target_per90,
         interceptions_per90, fouls_per90,
         tackles_won_per90, crosses_per90, name.y) %>%  
  rename("Goals"=goals_per90, "Assists"=assists_per90, "G+A"=goals_assists_per90,"Shots"=shots_total_per90, "Shots on Target"=shots_on_target_per90,
          "Interceptions"=interceptions_per90, "Tackles Won"=tackles_won_per90, 
          "Fouls Commited"=fouls_per90, "Crosses"=crosses_per90) %>% 
  gather("skill", "value", 1:9) %>%   
  mutate(category = if_else(skill %in% c("Goals", "Assists", "G+A", "Shots", "Crosses", "Shots on Target"),"Attack", 
                        if_else(skill %in% c("Interceptions", "Tackles Won"),"Defense",
                                if_else(skill %in% c("Fouls Committed"),"Discipline","Impact"))),
     value = as.numeric(value)) %>%
  ggplot(aes(x=factor(skill), y=value, label=value, group=name.y, col=name.y, fill=name.y)) +
  geom_line(size=.7) +
  geom_text(aes(x=skill, y=value+0.2, label=value), check_overlap = TRUE, vjust=0, colour="#212121", size=3, position = position_identity(), stat='identity',fontface="bold") +
  labs(
    title = paste(player_one, 'x', player_two),
    fill="",
    caption ="source: FBref | @abn3rrios"
  ) +
  scale_x_discrete(labels=function(x){sub("\\s", "\n", x)}, 
                   expand=expansion(mult = c(0, .1))) +
  scale_color_manual(values = my_pal) +
  guides(shape=guide_legend(title.position = NULL)) + 
  theme(axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_text(angle=0, colour='#212121', size=7, face='bold'),
        plot.background = element_rect(fill='white'),
        plot.title = element_text(size=18, hjust=0.5, face='bold', colour='#212121'),
        plot.subtitle = element_text(size=12, hjust=1, colour='#212121'),
        plot.caption = element_text(size=10, face='bold', hjust=1, colour='#212121'),
        panel.background = element_rect(fill='white', size=1),
        panel.border = element_blank(),
        panel.grid.major = element_line(colour='#e3e3e3'),
        legend.position = 'bottom',
        legend.key.size = unit(0.3, "cm"),
        legend.text = element_text(size=10, face='bold', colour='#212121'),
        legend.title = element_blank()
  ) +
  coord_radar(start=-pi*1/9)


comparison_chart
