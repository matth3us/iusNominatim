library(tidyverse)
library(sf)
library(geobr)

# Código para baixar dados do pacote geobr, inserir 
# bounding boxes dos municípios e salvar data frame
# final como RDS

rg <- geobr::read_region() %>% 
    mutate(code_ibge = as.integer(code_region)) %>%   
    select (code_ibge, geom) 
st <- geobr::read_state() %>% 
    mutate(code_ibge = as.integer(code_state)) %>% 
    select (code_ibge, geom) 
mu <- geobr::read_municipality() %>% 
    mutate(code_ibge = as.integer(code_muni)) %>% 
    select (code_ibge, geom) 
sr <- geobr::read_meso_region() %>% 
    mutate(code_ibge = as.integer(code_meso)) %>% 
    select (code_ibge, geom) 
cr <- geobr::read_micro_region() %>% 
    mutate(code_ibge = as.integer(code_micro)) %>% 
    select (code_ibge, geom) 
ir <- geobr::read_intermediate_region() %>% 
    mutate(code_ibge = as.integer(code_intermediate)) %>% 
    select (code_ibge, geom) 
mr <- geobr::read_immediate_region() %>% 
    mutate(code_ibge = as.integer(code_immediate)) %>% 
    select (code_ibge, geom) 
wa <- geobr::read_weighting_area() %>% 
    mutate(code_ibge = as.integer(code_weighting)) %>% 
    select (code_ibge, geom) 
ct <- geobr::read_census_tract(code_tract="all") %>% 
    mutate(code_ibge = as.integer(code_tract)) %>% 
    select (code_ibge, geom) 
ne <- geobr::read_neighborhood() %>% 
    mutate(code_ibge = as.integer(code_neighborhood)) %>% 
    select (code_ibge, geom) 

ibge <- rg %>% 
    dplyr::bind_rows(sr) %>% 
    dplyr::bind_rows(st) %>% 
    dplyr::bind_rows(wa) %>% 
    dplyr::bind_rows(cr) %>%
    dplyr::bind_rows(ct) %>% 
    dplyr::bind_rows(ir) %>% 
    dplyr::bind_rows(mr) %>% 
    dplyr::bind_rows(mu) %>% 
    dplyr::bind_rows(ne) %>% 
    sf::st_transform(crs = "WGS84") %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
          xmin = unname(st_bbox(geom, crs = "WGS84")$xmin)
        , ymin = unname(st_bbox(geom, crs = "WGS84")$ymin)
        , xmax = unname(st_bbox(geom, crs = "WGS84")$xmax)
        , ymax = unname(st_bbox(geom, crs = "WGS84")$ymax)
    ) %>%
    dplyr::ungroup()

rm(rg,sr,st,wa,cr,ct,ir,mr,mu,ne)

saveRDS(ibge, './transformed/ibge.rds')