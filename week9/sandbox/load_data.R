rm(list = ls())
library(tidyverse)
# salary data
salaries <- read_csv("https://bit.ly/2TdbYYU") %>% 
  select(-title) %>% rename(rank = title_category) %>% 
  filter(rank != "lecturer")
# name data
names <- read_csv("https://tinyurl.com/ycc4ndkd") %>% 
  select(year, name, sex, count)
# department data
departments <- read_csv("departments.csv")