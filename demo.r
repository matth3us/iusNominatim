source('./script/functions.r')

##------
# Exemplo
bad_geo <- get_coords_osm("Quatre vingt douze R. de l'Église")
process_address <- get_libpost_address("Quatre vingt douze R. de l'Église")
# address_processed <- get_better_address("Quatre vingt douze R. de l'Église")
good_geo <- get_coords(process_address)


##-----
## Visualização no Mapa do Exemplo
library(sf)
library(tmap)
tmap_mode("view")


p1 <- sf::st_as_sf(
    data.frame(lat = good_geo[[1]]$lat, lon = good_geo[[1]]$lon)
    , coords = c("lon", "lat")
    , crs = "WGS84"
  )

tm_shape(p1) +
  tm_dots() +
  tm_basemap(server = "OpenTopoMap")

p5 <- sf::st_as_sf(
  data.frame(lat = good_geo[[5]]$lat, lon = good_geo[[5]]$lon)
  , coords = c("lon", "lat")
  , crs = "WGS84"
)

tm_shape(p5) +
  tm_dots() +
  tm_basemap(server = "OpenTopoMap")
