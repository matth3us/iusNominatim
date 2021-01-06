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


## Funcionamento
source(here('api', 'iusnominatim_functions.r'))
plumber::pr(here('api', 'iusnominatim_interactions.r')) %>%
    plumber::pr_run(port=8000)
      
# test <- list(address = "são paulo, Viaduto do Chá, 15", code_ibge = 3550308)
# curl -X POST "http://127.0.0.1:8000/geo?address=s%C3%A3o%20paulo%2C%20Viaduto%20do%20Ch%C3%A1%2C%2015&code_ibge=3550308&libpostal=True" -H "accept: */*" -d ""