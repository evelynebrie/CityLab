library(rvest) 
library(tidyverse)
library(stringr)
library(tictoc)

url <- "https://fbinter.stadt-berlin.de/fb/berlin/service_intern.jsp?id=a_dom@senstadt&type=FEED"
page <- read_html(url)

scraping <- function(x){
  tibble(zips = html_nodes(x, "tr~ tr+ tr a") %>% html_text(), # Scraping the petition's title
         titles = html_nodes(x, "br~ .abstand_oben tr~ tr+ tr .standard_fett") %>% html_text())
}

tic() 
myResults <- url %>% 
  map(read_html) %>% 
  map_df(scraping) 
toc()

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

for (i in 1:length(zips)){
  destination<-paste0("/Users/evelynebrie/Dropbox/CityLab/Projects/Ideas/Sunlight/Data/",i,".zip")
  mapply(function(x, y) download.file(x,y, mode="wb"),x = zips[i], y = destination)
  unzip(destination, exdir="/Users/evelynebrie/Dropbox/CityLab/Projects/Ideas/Sunlight/Data/Unzip")
}
