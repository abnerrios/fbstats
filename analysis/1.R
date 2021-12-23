library(mongolite)
library(tidyverse)

theme_set(theme_light(base_size = 14))
mongohost <- "mongodb://172.29.128.1"

theme_set(theme_void(base_family = "Roboto"))
theme_update(
  plot.background = element_rect(fill = "#252525", color = "#252525"),
  plot.margin = margin(rep(17, 4)),
  plot.title = element_text(color = "#f6f6f6", face = "bold", size = 16, family = "URWHelvetica"),
  plot.subtitle = element_text(color = "#f6f6f6", face = "plain", size = 10),
  plot.caption =  element_text(color = "#f6f6f6", face = "plain", size = 8),
  
  axis.text.x = element_text(color = "#f6f6f6", face = "plain", size = 10, 
                             margin = margin(t = 6)),
  axis.text.y = element_text(color = "#f6f6f6", size = 10, hjust = 1, 
                             margin = margin(r = 6), family = "Roboto Mono"),
  panel.grid.major.y = element_line(color = "#f6f6f6", size = .3),
  legend.position = "bottom",
  legend.text = element_text(color = "#f6f6f6", family = "Roboto Mono", size = 10),
  legend.title = element_text(color = "#f6f6f6", face = "bold", size = 10)
)


# set up databases variables
squadsdb <- mongolite::mongo(url=mongohost, collection = "squads", db = "fbstats")
playersdb <- mongolite::mongo(url=mongohost, collection = "players", db = "fbstats")
squads_statsdb <- mongolite::mongo(url=mongohost, collection = "squads_stats", db = "fbstats")

# load players and squads data
squads <- base::as.data.frame(squadsdb$find())
players <- base::as.data.frame(playersdb$find())
player_squad <- dplyr::inner_join(squads, players, by = "squad_id")


# gráfico distribuição de idade brasileirão 2021
player_squad %>%
  dplyr::filter(national_league == "Campeonato Brasileiro Série A"
                & minutes >= 270) %>%
  ggplot(mapping = aes(x = name.x, y = age)) +
  ggdist::stat_interval(.width=c(.25, .5, .75, 1)) +
  stat_summary(geom="point", fun="median", color="white", size=3.5) +
  scale_y_continuous(breaks=c(16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40)) +
  scale_color_viridis_d(
    option="mako", name="", direction=-1,
    begin=.15, end=.9,
    labels=function(x) paste(as.numeric(x)*100,"%")
  ) +
  labs(
    title = "Campeonato Brasileiro Série A 2021",
    subtitle="Distribuição de idade dos clubes, considerando apenas jogadores com ao menos 270 minutos jogados.",
    caption = "source: FBref"
  ) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


# grafico inter idade x minutos
player_squad %>%
  dplyr::filter(name.x == "Internacional" & as.numeric(minutes)>=45) %>%
  ggplot(mapping = aes(y = as.numeric(minutes), x = age, color = as.numeric(plus_minus_per90))) +
  scale_color_gradient2(low="#3483eb", high="#fc0808", midpoint=.2) +
  geom_point() +
  labs(
    title = "Internacional - Campeonato Brasileiro 2021",
    subtitle = "Idade x % de minutos jogados.",
    x = "Idade",
    y = "% Minutos",
    color = "+- 90",
    caption = "source: FBref"
  ) +
  geom_text(
    aes(label=ifelse(as.numeric(minutes)>=700,paste(plus_minus_per90,name.y),
                     ifelse(as.numeric(plus_minus_per90)>.4,paste(plus_minus_per90,name.y),"")
                     )
        ),
    size=3, hjust=-.12, vjust=0.4
  )
