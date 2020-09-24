#read CSV and save as RDS
library(tidyverse)
es <- 
    readr::read_csv('./data/estatais.csv') %>% 
    dplyr::mutate(municipio_ibge = as.character(municipio_ibge))

readr::write_rds(es, "./transformed/estatais.rds")
rm(es)
