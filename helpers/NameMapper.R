library(tidyverse)
library(data.table)
library(xml2)

url = "https://www.zomato.com/directory"

z = read_html(url)


possible.dirs = z %>% xml_find_all("//p/a")


data.frame(
  Location = possible.dirs %>% xml_attr("href"),
  LocationName = possible.dirs %>% xml_find_all(".//h2") %>% xml_text()
) %>%
  mutate(
    Location = gsub("^.+com/(.+)/directory","\\1",Location)
  ) %>%
  fwrite("NameMap.csv", quote = TRUE)
