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
lock.and.load('plumber')
lock.and.load('here')

## -------
## Carregar códigos IBGE

if(!file.exists(here('api', 'ibge.rds'))){source(here('api', 'iusnominatim_ibge.R'))}
ibge <- readRDS(here('api', 'ibge.rds'))

## -------
## Criação de "Classes"
#Transforma um endereço em uma lista
createAddress <- function(apiInput){
    instance = list(
          address = apiInput[['address']]
        , code_ibge = apiInput[['code_ibge']]
        , latitude = NA
        , longitude = NA
        , crs = NA
        , osm_id = NA
    )
    return(instance)
}

#Transforma o input em uma lista de endereços
createInput <- function(apiInput){
    instance = list(
          original = createAddress(apiInput)
        , output = list(createAddress(apiInput))
    )
    return(instance)
}

## -------
## Criação de "Métodos"
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
geocodeAddress <- function(addressList){
  
  address = addressList$address
  host = 'http://nominatim.openstreetmap.org/search.php?q=@addr@&format=jsonv2'
  
  #Se a chamada der erro, retornar data frame vazio
  tryCatch(
    listData <- 
        jsonlite::fromJSON( 
          base::gsub('\\@addr\\@', gsub('\\s+', '\\%20', address), host)
        ) %>% 
        # dplyr::filter(osm_type == "node") %>% 
        dplyr::top_n(1) %>% 
        dplyr::select(osm_id, lat, lon) %>% 
        base::as.list()
    , error = function(c) return(data.frame())
  )
  #Se a chamada não retornar nada, retornar data frame vazio
  if(length(listData) == 0){return(addressList)}
  
  #Se a chamada retornar coordenadas, devolver lista de input preenchida
  newAddress <- addressList
  newAddress$latitude <- as.numeric(listData$lat)
  newAddress$longitude <- as.numeric(listData$lon) 
  newAddress$osm_id <- as.character(listData$osm_id) 
  newAddress$crs <- "WGS84" 
  
  return(newAddress)
}

#geocode
# ref.: recebe m parâmetro output de um objeto input e preenche Lat/Lon/CRS em cada um dos 
# objetos output
geocode <- function(listInput){
    newList<- listInput
    geocodedOutput <- 
        listInput$output %>%
        lapply(geocodeAddress)
    newList$output <- geocodedOutput
    return(newList)
}

#checkIbgeAddress
# ref.: recebe uma lista do tipo Address e retorna um booleano da conferência de geolocalização
# ou um Nulo se não tiver informações o suficiente
checkIbgeAddress <- function(addressList){
  
  lat <- addressList$latitude
  lon <- addressList$longitude
  code_ibge_input <-addressList$code_ibge
  
  #se não for preenchido code_ibge, retornar True
  #caso contrário, seguir
  if(is.null(code_ibge_input) | is.null(lat) | is.null(lon)){return(TRUE)}
  
  point <- 
    sf::st_as_sf(
      data.frame(lat = lat, lon = lon)
      , coords = c("lon", "lat")
      , crs = "WGS84"
    )
  
  geo <- 
    ibge %>%
    dplyr::filter(code_ibge == code_ibge_input) %>% 
    st_as_sf(crs = st_crs(point))
  
  inside_box <- 
    dplyr::between(lon, geo$xmin, geo$xmax) & dplyr::between(lat, geo$ymin, geo$ymax)
  
  inside_city <- FALSE
  
  if(inside_box){
    inside_city <- !is.na(sf::st_join(point, geo, join=st_within)$code_ibge)
  }
  
  return(inside_city)
}

#checkIbge
# ref.: recebe um parâmetro output de um objeto input e remove todos os que o checkIbge derem falso
checkIbge <- function(inputList){
  outputList <- inputList$output
  newOutput <- lapply(outputList, function(x){
      if(checkIbgeAddress(x)){
        return(x)
      } else {
        return(NULL)
      }
  })
  newInputList <- inputList
  newInputList$output <- newOutput
  return(newInputList)
}