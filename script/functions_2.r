## -------
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
lock.and.load('tidyr')
lock.and.load('jsonlite')
lock.and.load('httr')
lock.and.load('stringr')

## -------
## Carregar as cidades do IBGE como input para funções
cities <- 
  readRDS('./transformed/cities.rds')


#########################
## MELHORIAS NAS FUNÇÕES
#########################


test <- list(address = "planalto vinhais ii, rua 7, casa 7", code_ibge = 412673)

#Transforma um endereço em uma lista
createAddress <- function(listAdd){
    instance = list(
          address = listAdd[['address']]
        , code_ibge = listAdd[['code_ibge']]
        , latitude = NA
        , longitude = NA
        , crs = NA
    )
    return(instance)
}

#Transforma o input em uma lista de endereços
createInput <- function(input){
    instance = list(
          original = createAddress(input)
        , output = list(createAddress(input))
    )
    return(instance)
}

#generateAlternatives
# ref.: recebe um objeto do tipo input, pega o parâmetro original, e devolve o output 
# preenchido com objetos do tipo endereço

generateAlternatives <- function(inputList, host = "localhost:3000"){
  
  address <- inputList$original$address
    
  libpostal_query <- 
    paste0('{"query": "', address, '"}')
  expanded_address <- 
    httr::POST(paste0(host,"/expand"), body = libpostal_query) %>% 
    httr::content() %>%
    c(stringr::str_to_lower(address)) %>% 
    lapply(function(x){return(
      createAddress(list(address = x))
    )})
  
  newInput <- inputList
  newInput$output <- c(newInput$output, expanded_address)
  return(newInput)
}

#geocodeAddress
geocodeAddress <- function(instanceAddress, host){
  
  address = instanceAddress$address
  
  #Se não passar endereço, retornar data frame vazio
  if(suppressWarnings(is.null(address))){return(data.frame())}
  
  #Se a chamada der erro, retornar data frame vazio
  tryCatch(
    d <- jsonlite::fromJSON( 
      gsub('\\@addr\\@', gsub('\\s+', '\\%20', address), 
           host)
    ), error = function(c) return(data.frame())
  )
  #Se a chamada não retornar nada, retornar data frame vazio
  if(length(d) == 0){return(data.frame())}
  
  #Se a chamada retornar coordenadas, devolver lista de input preenchida
  newAddress <- instanceAddress
  newAddress$latitude <- as.numeric(d$lat)
  newAddress$longitude <- as.numeric(d$lon) 
  newAddress$crs <- "WGS84" 
  
  return(newAddress)
}

#geocode
# ref.: recebe m parâmetro output de um objeto input e preenche Lat/Lon/CRS em cada um dos 
# objetos output
geocode <- function(listInput, host = 'http://nominatim.openstreetmap.org/search/@addr@?format=json&addressdetails=0&limit=1'){
    newList<- listInput
    geocodedOutput <- 
        listInput$output %>%
        lapply(geocodeAddress, host = host)
    newList$output <- geocodedOutput
    return(newList)
}

#checkIbgeAddress
# ref.: recebe uma lista do tipo Address e retorna um booleano da conferência de geolocalização
# ou um Nulo se não tiver informações o suficiente

checkIbgeAddress <- function(lat, lon, city_ibge=NULL){
  
  lat <- inputList$lat
  lon <- inputList$lon
  code_ibge <-inputList$code_ibge
  
  #se não for preenchido code_ibge, retornar nulo
  #caso contrário, seguir
  if(is.null(code_ibge) | is.null(lat) | is.null(lon)){return(NULL)}
  
  point <- 
    sf::st_as_sf(
      data.frame(lat = lat, lon = lon)
      , coords = c("lat", "lon")
      , crs = "WGS84"
    )
  
  geo <- 
    geoBr %>%
    dplyr::filter(code_muni == code_ibge)
  
  inside_box <- 
    dplyr::between(lat, geo$xmin, geo$xmax) & dplyr::between(lon, geo$ymin, geo$ymax)
  
  inside_city <- FALSE
  
  if(inside_box){
    inside_city <- !is.na(sf::st_join(point, geo, join=st_within)$codigo_ibge)
  }
  
  return(inside_city)
}

#checkIbge
# ref.: recebe um parâmetro output de um objeto input e remove todos os que o checkIbge derem falso



