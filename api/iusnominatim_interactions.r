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
lock.and.load('dplyr')
lock.and.load('tidyr')
lock.and.load('plumber')

#* Geolocalizar endereço
#* @param address endereço
#* @param code_ibge código ibge onde o endereço tem que estar localizado
#* @post /geo
function(address="", code_ibge="", libpostal="False"){
  # testar que address é string
  # testar que libpostal é booleano
  # se code_ibge for inválido, não aplicar teste
  data <- list(
        address = address
      , code_ibge = code_ibge
      ) %>%
      createInput()

    result <-
      data %>%
      {if(as.logical(libpostal)){generateAlternatives(.)} else {.}} %>%
      geocode() %>%
      checkIbge()

  return(result)
}
