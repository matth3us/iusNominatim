## Função para conferir se um pacote já está instalado; se estiver, carregá-lo, se não, instalar e depois carregar
lock.and.load <- function(list.of.packages){
    new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
    if(length(new.packages)) {
      for(i in 1:length(unload_first)){
        if(unload_first[i] %in% installed.packages()[,"Package"]){unloadNamespace(unload_first[i])} 
      }
      install.packages(new.packages)
    }
    for(i in 1:length(list.of.packages)){
      library(list.of.packages[1], character.only=T)
    }
}

## Instalar e carregar pacotes necessários abaixo
lock.and.load('sf')
lock.and.load('dplyr')

## Carregar as cidades do IBGE como input para funções
cities <- 
    read_rds('./transformed/cities.rds')


## Função para retornar se uma coordenada está dentro de um município como definido pelo ibge; 
## Os inputs são latitude, longitude e o código do município no IBGE
## O output é booleano (verdadeiro/falso)


check_geocoded_city <- function(lat, lon, city_ibge){
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

# Função para melhorar endereço usando libpostal
# Pegar address e devolver correct_address
get_better_address <- function(address){
  
}