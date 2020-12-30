source('./script/functions_2.r')
test <- list(address = "são paulo, Viaduto do Chá, 15", code_ibge = 3550308)

# Funciona sem passar pelo LibPostal
obj <- createInput(test)
objGeo <- geocode(obj)
checkedGeo <- checkIbge(objGeo)

#Funcionou passando pelo libPostal!
multiObj <- generateAlternatives(obj)
multiGeo <- geocode(multiObj)
multiCheckedGeo <- checkIbge(multiGeo)

