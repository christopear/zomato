library(tidyverse)
library(data.table)
library(xml2)

get.all.items = function(page, timepiece) {
  # to not overload the server
  Sys.sleep(max(timepiece + rnorm(1, sd = 3), 0.5)) 
  
  zomatos = read_html(page) %>%
    xml_find_all("//div[@class='ui cards']/div[contains(@class,'search-card')]")
  rbindlist(lapply(zomatos, get.details),use.names = TRUE, fill = TRUE)
}




get.dining.type = function(item) {
  item %>% 
    xml_find_first(".//div[@class='col-s-12']/div[contains(@class, 'res-snippet-small-establishment')]/a") %>% 
    xml_text()
}

get.url = function(item) {
  item %>% 
    xml_find_first(".//div[@class='col-s-12']/a[contains(@class, 'result-title')]") %>% 
    xml_attr("href")
}

get.name = function(item) {
  item %>% 
    xml_find_first(".//div[@class='col-s-12']/a[contains(@class, 'result-title')]") %>% 
    xml_text()
}

get.sub.location = function(item) {
  item %>% 
    xml_find_first(".//div[@class='col-s-12']/a[contains(@class, 'search_result_subzone')]") %>% 
    xml_text()
}

get.address = function(item) {
  item %>%
    xml_find_first(".//div[contains(@class, 'search-result-address')]") %>%
    xml_text()
}


get.rating = function(item) {
  item %>% 
    xml_find_first(".//div[@class='row']//div[contains(@class, 'search_result_rating')]/div") %>%
    xml_text() %>%
    trimws()
}

get.reviewers = function(item) {
  item %>% 
    xml_find_first(".//div[@class='row']//div[contains(@class, 'search_result_rating')]/span") %>%
    xml_text()
}

get.price = function(item) {
  item %>%
    xml_find_first(".//div[contains(@class, 'search-page-text')]/div[contains(@class,'res-cost')]") %>%
    xml_text()
}


get.details = function(item) {
  data.frame(DiningType = get.dining.type(item),
             URL = get.url(item),
             Restaurant = get.name(item),
             Suburb = get.sub.location(item),
             Address = get.address(item),
             Rating = get.rating(item),
             Reviewers = get.reviewers(item),
             Price = get.price(item)
  )
}

scraper = function(location, timepiece) {


  z.url = paste0("https://www.zomato.com/",location,"/restaurants?page=")
  zomato = paste0(z.url, "1") %>%
    read_html()
  
  page.count = zomato %>% 
    xml_find_first("//div[contains(@class, 'pagination-number')]") %>%
    xml_attr("aria-label")
  
  print(paste0(location, ": ", page.count))
  
  page.count = gsub("Page [0-9]+ of ([0-9]+) *$","\\1",page.count) %>%
    as.numeric()
  
  
  zomato.urls = paste0(z.url, 1:page.count)

  
  zomato.restaurants = lapply(zomato.urls, 
                              get.all.items, 
                              timepiece)
  
  rbindlist(zomato.restaurants,
            fill = TRUE,
            use.names = TRUE) %>%
    fwrite(paste0("data/",location,".csv"))
  
  1
}

locations = c("auckland","london","edinburgh",
              "san-francisco","new-york-city",
              "sydney", "melbourne",
              "bali", 
              "dubai",
              "rome", "milan",
              "montreal", "quebec",
              "sao-paolo-sp", "santiago",
              "ncr", "mumbai", 
              "singapore","kuala-lumpur")
lapply(locations, possibly(scraper, NA), 2)

