library(plumber)
library(tidyverse)

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
