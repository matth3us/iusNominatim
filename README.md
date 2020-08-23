# 🔎🗺️ Ius Nominatim

----

Ius Nominatim (from Latin, _'by the correct name'_), is a tool to search Open Street Map (OSM) data by name, address and Brazilian municipality (geocoding). The idea will be to:

1. use [libpostal's](https://github.com/openvenues/libpostal) library for parsing/normalizing street addresses; 
2. use the bounding boxes of Brazilian municipalities obtained from [GeoBR](https://github.com/ipeaGIT/geobr) library in order to bound the geolocalization of those addresses, preventing the common mistake of finding the same address in different cities
3. pass those parsed/normalized address and bounding boxes to OSM's [Nominatim](https://wiki.openstreetmap.org/wiki/Nominatim) (latim for _'by the name'_), so that we can geolocalize them.
