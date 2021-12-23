library(mongolite)
library(tidyverse)

theme_set(theme_light(base_size = 14))
mongohost <- "mongodb://172.29.128.1"


# set up databases variables
squadsdb <- mongolite::mongo(url=mongohost, collection = "squads", db = "fbstats")
playersdb <- mongolite::mongo(url=mongohost, collection = "players", db = "fbstats")
squads_statsdb <- mongolite::mongo(url=mongohost, collection = "squads_stats", db = "fbstats")

# load players and squads data
squads <- base::as.data.frame(squadsdb$find())
players <- base::as.data.frame(playersdb$find(fields = '{
          "player_id":true, "name":true, "age":true, "position":true, "squad_id":true, "nationality":true,
          "goals_per90":true, "assists_per90":true, "goals_per_shot":true, 
          "shots_total_per90":true, "shots_on_target_per90":true, "fouled":true, 
          "interceptions":true, "fouls":true, "tackles_won":true, "crosses":true, "minutes":true, 
          "cards_yellow":true, "cards_red":true, "plus_minus_per90":true, "points_per_match":true}'))
player_squad <- dplyr::inner_join(squads, players, by = "squad_id")



player_squad %>% filter(name.y=="Akinkumni Amoo")


theme_set(theme_void(base_family = "Roboto"))
theme_update(
  plot.background = element_rect(fill = "#f6f6f6", color = "#f6f6f6"),
  plot.margin = margin(rep(17, 4)),
  plot.title = element_text(color = "#252525", face = "bold", size = 16),
  plot.subtitle = element_text(color = "#252525", face = "plain", size = 10),
  plot.caption =  element_text(color = "#252525", face = "plain", size = 8),
  
  axis.text.x = element_text(color = "#252525", face = "bold", size = 8, 
                             margin = margin(t = 6)),
  axis.text.y = element_text(color = "#252525", size = 10, hjust = 1, 
                             margin = margin(r = 6), family = "Roboto Mono"),
  panel.grid.major.y = element_line(color = "#252525", size = .1),
  legend.position = "right",
  legend.justification = c("right", "bottom"),
  legend.text = element_text(color = "#252525", face = "bold", family = "Roboto Mono", size = 8),
  legend.title = element_text(color = "#252525", face = "bold", size = 10),
  strip.background = element_rect(fill = "#f6f6f6")
)

my_pal = c("#EC5C37","#277C52","#2C80B7","#EDC942", "#72B7C4", "#F5ECDB")

player <- player_squad %>% 
  filter(player_id == "a40af810") %>% 
  mutate(tackles_won=round(tackles_won/(minutes/90),2),
         interceptions=round(interceptions/(minutes/90),2), 
         fouls=round(fouls/(minutes/90),2), 
         fouled=round(fouled/(minutes/90),2),
         crosses=round(crosses/(minutes/90),2),
         cards_yellow=round(cards_yellow/(minutes/90),2),
         cards_red=round(cards_red/(minutes/90),2))

chart_title <- player %>% 
  mutate(chart_title = paste(name.y, "|", position), sep=" ") %>% 
  select(chart_title)


description <- player %>% 
  mutate(description=paste(paste("Idade:",age), 
                           paste("Nacionalidade:",nationality), 
                           paste("Posição:",position), 
                           paste("Clube:",name.x), 
                           paste("Minutos:",minutes), 
                      sep="\n")
         ) %>% 
  select(description)              


player %>% 
  select(goals_per90, assists_per90, goals_per_shot, shots_total_per90, shots_on_target_per90, fouled, 
         interceptions, fouls, tackles_won, cards_yellow, cards_red, points_per_match, plus_minus_per90) %>%  
  rename("Gols"=goals_per90, "Assistências"=assists_per90, "Gols por Chute"=goals_per_shot, "Chutes"=shots_total_per90, 
         "Chutes no Gol"=shots_on_target_per90, "Faltas Sofridas"=fouled, "Interceptações"=interceptions, "Desarmes"=tackles_won,
         "Faltas Cometidas"=fouls, "C. Amarelo"=cards_yellow, "C. Vermelho"=cards_red,
         "Pts por Partida"=points_per_match, "+- 90"=plus_minus_per90) %>% 
  gather("skill", "value", 1:13) %>% 
  mutate(category = if_else(skill %in% c("Gols", "Assistências", "Gols por Chute", "Chutes", "Chutes no Gol", "Faltas Sofridas"),"Ataque", 
                            if_else(skill %in% c("Interceptações", "Faltas Cometidas", "Desarmes"),"Defesa",
                                    if_else(skill %in% c("C. Amarelo", "C. Vermelho"),"Disciplina","Desempenho Equipe"))),
         value = as.numeric(value)) %>%
  ggplot(aes(x=fct_reorder(skill, category), y=value, label=value, fill=category)) +
  labs(
    title=chart_title,
    subtitle=description,
    fill="",
    caption="source: FBref"
  ) +
  geom_col(colour="#252525", 
           position="dodge2", show.legend=TRUE, alpha=.9) +
  geom_text(aes(x=skill, y=value+0.5, label=value), vjust=0, colour="#252525", size=3, position = position_dodge(0.9), fontface="bold") +
  scale_color_brewer(palette = my_pal) +
  coord_polar() +
  theme(axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text.y = element_blank())