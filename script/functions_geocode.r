# https://nominatim.org/release-docs/latest/api/Search/#parameters

# 1. Receber endereço como uma lista (não a mesma lista gerada pela função do libpostal; cada elemento daquela lista é um endereço distinto)
# 2. Fazer query no OSM com o endereço completo; se resultado, terminar aqui
# 3. Fazer query estruturada com elementos que tenham sido identificados no libpostal;
# 4. Se nenhuma das duas tentativas retornar uma coord, tentar o endereço completo com a google api; 
# 5. Ao passar por uma lista de endereços gerada pelo libpostal, só usar o google api se nenhum endereço anterior tiver sido localizado pelo open street maps

## Função para geolocalizar endereços pelo OSM e, se permitido, pelo Google Maps
## input: 
## 1. lista com endereço, parseado ou não; 
## 3. parâmetro para informar se pode usar Google Maps
## output, lista com elementos:
## 1. coordenadas como data frame (lat, lon)
## 2. informação de quantas vezes a API do google foi utilizada

#alterar para usar docker local
get_coords_osm <- function(address = NULL){
  #Se não passar endereço, retornar data frame vazio
  if(suppressWarnings(is.null(address))){return(data.frame())}
  
  #Se a chamada der erro, retornar data frame vazio
  tryCatch(
    d <- jsonlite::fromJSON( 
      gsub('\\@addr\\@', gsub('\\s+', '\\%20', address), 
           'http://nominatim.openstreetmap.org/search/@addr@?format=json&addressdetails=0&limit=1')
    ), error = function(c) return(data.frame())
  )
  #Se a chamada não retornar nada, retornar data frame vazio
  if(length(d) == 0){return(data.frame())}
  
  #Se a chamada retornar coordenadas, preparar data frame com coordenadas e retornar isso
  res <- data.frame(lon = as.numeric(d$lon), lat = as.numeric(d$lat))
  return(res)
}

#get_coords_google <- function(address = NULL){} #retornar quantas vezes a API do google foi chamada 