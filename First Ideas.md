Tentar busca estruturada quando a busca livre não retornar um pontoTestar busca estruturada e limitar busca para  bounding box do município (https://www.geoapify.com/nominatim-geocoder/)

Testar em geolocalização de escolas públicas, que será relegada pelos DEVs de qualquer forma

Testar normalização de endereços de escolas com libpostal sobre amostra de 50.000 escolas aleatórias, e comparar geolocalização via open street map sem a normalização do libpostal com a normalização

https://github.com/ClickSend/libpostal-rest-dockerhttps://github.com/openvenues/libpostalhttps://github.com/ironholds/poster

Se bem sucedido, convencer o pessoal de engenharia a deixar um docker do libpostal e do open street map online, normalizando todo endereço de usuário/escola e geolocalizando automaticamente, deixando para higienização eventual; Isso permitiria geolocalizar todo endereço que recebermos
