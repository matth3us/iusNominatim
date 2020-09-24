library(tidyverse)
library(sf)
library(geobr)

#Código para baixar dados do pacote geobr, inserir bounding boxes dos municípios e salvar data frame final como RDS
ipea_s <-
    geobr::read_state(code_state = "all", year=2018) %>%
    sf::st_set_geometry(NULL) %>% 
    dplyr::mutate(code_state = as.factor(code_state))
ipea_m <- 
    geobr::read_municipality(code_muni="all", year=2018)

cities <- 
  ipea_m %>% 
  sf::st_transform(crs = "WGS84") %>% 
  dplyr::left_join(ipea_s) %>% 
  dplyr::rowwise() %>%
  dplyr::mutate(
    xmin = unname(st_bbox(geom, crs = "WGS84")$xmin)
    , ymin = unname(st_bbox(geom, crs = "WGS84")$ymin)
    , xmax = unname(st_bbox(geom, crs = "WGS84")$xmax)
    , ymax = unname(st_bbox(geom, crs = "WGS84")$ymax)
  ) %>% 
  dplyr::ungroup() %>%
  dplyr::select(code_muni:name_region, xmin:ymax, geom)

saveRDS(cities, './transformed/cities.rds')