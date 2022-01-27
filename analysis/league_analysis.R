library(mongolite)
library(tidyverse)

theme_set(theme_light(base_size = 14))
mongohost <- "mongodb://fbscout_app:ceqfym-4pAqvi-qymhes@cluster0-shard-00-00.old9q.mongodb.net:27017,cluster0-shard-00-01.old9q.mongodb.net:27017,cluster0-shard-00-02.old9q.mongodb.net:27017/myFirstDatabase?ssl=true&replicaSet=atlas-13pm6z-shard-0&authSource=admin&retryWrites=true&w=majority"


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
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        plot.title = element_text(size=18, hjust=0.5),
        plot.subtitle = element_text(size=10, hjust=0.5),
        panel.background = element_rect(fill='white', size=1),
        panel.border = element_blank(),
        panel.grid.major = element_line(colour='#e3e3e3'),
        legend.position = 'top',
        legend.key.size = unit(0.3, "cm"),
        legend.text = element_text(size=8, face='bold')
      )
