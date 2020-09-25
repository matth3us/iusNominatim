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
lock.and.load('tidyr')
lock.and.load('jsonlite')
lock.and.load('httr')
lock.and.load('stringr')

## Carregar as cidades do IBGE como input para funções
cities <- 
    read_rds('./transformed/cities.rds')

## Função para geolocalizar endereços usando OSM nomimatim e Google Maps API  

## Função para retornar endereço mais facilmente geolocalizado, usando o modelo de ML libpostal
## input: string com endereço original  
## output: dataframe com endereço parseado, com colunas para cada uma das labels + coluna source para o endereço parseado
# https://github.com/ClickSend/libpostal-rest-docker
# curl POST -d '{"query": "Quatre-vingt-douze Ave des Champs-Élisées"}' localhost:3000/expand
# docker start boring_poitras

get_better_address <- function(address){
  libpostal_query <- 
      paste0('{"query": "', address, '"}')
  expanded_address <- 
      httr::POST("localhost:3000/expand", body = libpostal_query) %>% 
      httr::content() %>%
      c(stringr::str_to_lower(address))
  return(expanded_address)
}

get_parsed_address <- function(address){
  #labels úteis do libpostal 
  libpostal_labels <- c(
    "house"
    , "near"
    , "house_number"
    , "road"
    , "suburb"
    , "city_district"
    , "city"
    , "state"
    , "country_region"
  )
  
  libpostal_query <- 
      paste0('{"query": "', address, '"}')
  
  parsed_address <- 
      httr::POST("localhost:3000/parser", body = libpostal_query) %>%
      httr::content() %>%
      dplyr::bind_rows() %>% 
      dplyr::filter(label %in% libpostal_labels) %>%
      tidyr::pivot_wider(names_from = "label", values_from = "value") %>%
      dplyr::mutate(source = address) %>%
      dplyr::group_split()
  
  return(parsed_address)
}

get_libpost_address <- function(address){
  libp_ad <-
      get_better_address(address) %>%
      lapply(get_parsed_address)

  return(libp_ad)
}

## Função para retornar se uma coordenada está dentro de um município como definido pelo ibge; 
## Os inputs são latitude, longitude e o código do município no IBGE
## O output é booleano (verdadeiro/falso)

check_geocoded_city <- function(lat, lon, city_ibge=NULL){
  
  #se não for preenchido city_ibge, retornar nulo
  #caso contrário, seguir
  if(is.null(city_ibge)){return(NULL)}
  
  point <- 
    sf::st_as_sf(
      data.frame(lat = lat, lon = lon)
      , coords = c("lat", "long")
      , crs = "WGS84"
    )
  
  city <- 
    cities %>%
    dplyr::filter(code_muni == city_ibge)
  
  inside_box <- 
    dplyr::between(lat, city$xmin, city$xmax) & dplyr::between(lon, city$ymin, city$ymax)
  
  inside_city <- FALSE
  
  if(inside_box){
    inside_city <- !is.na(sf::st_join(point, city, join=st_within)$codigo_ibge_cidade)
  }
  
  return(inside_city)
}
