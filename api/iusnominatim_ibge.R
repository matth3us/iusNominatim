## Configurações
## Função para conferir se um pacote já está instalado; se estiver, carregá-lo, se não, instalar e depois carregar
lock.and.load <- function(list.of.packages){
    new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
    if(length(new.packages)) {
        install.packages(new.packages)
    }
    for(i in 1:length(list.of.packages)){
        library(list.of.packages[1], character.only=T)
    }
}

## Instalar e carregar pacotes necessários abaixo
lock.and.load('sf')
lock.and.load('dplyr')
lock.and.load('geobr')
lock.and.load('here')

# Código para baixar dados do pacote geobr, inserir 
# bounding boxes dos municípios e salvar data frame
# final como RDS

rg <- geobr::read_region() %>% 
    dplyr::mutate(code_ibge = as.integer(code_region)) %>%   
    dplyr::select (code_ibge, geom) 
st <- geobr::read_state() %>% 
    dplyr::mutate(code_ibge = as.integer(code_state)) %>% 
    dplyr::select (code_ibge, geom) 
mu <- geobr::read_municipality() %>% 
    dplyr::mutate(code_ibge = as.integer(code_muni)) %>% 
    dplyr::select (code_ibge, geom) 
sr <- geobr::read_meso_region() %>% 
    dplyr::mutate(code_ibge = as.integer(code_meso)) %>% 
    dplyr::select (code_ibge, geom) 
cr <- geobr::read_micro_region() %>% 
    dplyr::mutate(code_ibge = as.integer(code_micro)) %>% 
    dplyr::select (code_ibge, geom) 
ir <- geobr::read_intermediate_region() %>% 
    dplyr::mutate(code_ibge = as.integer(code_intermediate)) %>% 
    dplyr::select (code_ibge, geom) 
mr <- geobr::read_immediate_region() %>% 
    dplyr::mutate(code_ibge = as.integer(code_immediate)) %>% 
    dplyr::select (code_ibge, geom) 
wa <- geobr::read_weighting_area() %>% 
    dplyr::mutate(code_ibge = as.integer(code_weighting)) %>% 
    dplyr::select (code_ibge, geom) 
ct <- geobr::read_census_tract(code_tract="all") %>% 
    dplyr::mutate(code_ibge = as.integer(code_tract)) %>% 
    dplyr::select (code_ibge, geom) 
ne <- geobr::read_neighborhood() %>% 
    dplyr::mutate(code_ibge = as.integer(code_neighborhood)) %>% 
    dplyr::select (code_ibge, geom) 

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

saveRDS(ibge, here('api', 'ibge.rds'))