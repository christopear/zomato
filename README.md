# Zomato

This script is no different than any of my other webscraping scripts. A script is provided for scraping the [Zomato directory](https://www.zomato.com/directory) to allow choosing which cities you would like to scrape.

In web scraping the cities, each restaurant is pulled down and put into a data.frame. Where there have been no reviews there is a score of zero (anomaly). They can then be plotted.


### Results
In plotting the scores for each country, it's clear that the most popular restaurants are also the most highly rated. However, unexpectedly, the worst rated restaurants are also popular (creating a 'tick' shape in the trend).

![Zomato](https://raw.githubusercontent.com/christopear/zomato/master/images/restaurants.png)

It is perhaps due to location that some of the most popular restaurants have low scores: e.g. many people visiting out of convenience of location rather than for its food. See Mission Bay's De Fontein Belgian Beer restaurant for an example of this.
