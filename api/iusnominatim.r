library(plumber)
# 'plumber.R' is the location of the file shown above
source('./api/iusnominatim_functions.r')
pr("./api/iusnominatim_interactions.r") %>%
  pr_run(port=8000)

  # test <- list(address = "são paulo, Viaduto do Chá, 15", code_ibge = 3550308)
# curl "http://localhost:8000/echo?add=hello"