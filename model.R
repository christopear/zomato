library(tidyverse)
library(data.table)
library(Cairo)
loggy = function(x) {
    log(x + 1)
}

antiloggy = function(x) {
    exp(x) - 1
}

antiloggy.round = function(x) {
  round(antiloggy(x))
}

read.file = function(loc) {
  fread(loc) %>% 
    mutate(
      Rating = as.numeric(Rating),
      Reviewers = as.numeric(gsub(" .+$","",Reviewers)),
      Price = as.numeric(gsub("[^0-9.]","",Price)),
      Reviewers = ifelse(is.na(Reviewers),0,Reviewers),
      Location = loc
    ) %>%
      filter(!is.na(Restaurant),
             !(Restaurant == ""))
}


restaurants = rbindlist(lapply(list.files("data",full.names = TRUE),
                               read.file),
                        fill = TRUE,
                        use.names = TRUE) %>%
  na.omit() %>%
  merge(fread("helpers/NameMap.csv"))



gg = restaurants %>%
  group_by(LocationName) %>%
  filter(
    Reviewers > quantile(Reviewers, 1/3)
    ) %>%
  mutate(
    Reviewers = loggy(Reviewers)
  )


png(width=1280,height=720,type="cairo-png")
ggplot(gg,
       aes(Rating, Reviewers, colour=LocationName)) +
  geom_point(alpha = 0.1,position = "jitter") +
  geom_smooth(aes(Rating, Reviewers),colour = "black", se=FALSE, span = 5) +
  facet_wrap(~LocationName, scales="free_y") +
  theme_bw() +
  guides(colour = FALSE,
         size = FALSE) +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
  )
dev.off()