update.packages(ask = FALSE)

shape_path = "13tokyo/h27ka13.shp"



# sf package

install.packages("ggplot2", dependencies = T)
install.packages("sf", dependencies = T)

library(ggplot2)
library(sf)

map <- read_sf(shape_path)
ggplot(map) + geom_sf()

#TODO



# leaflet

install.packages("httpuv", dependencies = T)
install.packages("leaflet", dependencies = T)
install.packages("rgdal", dependencies = T)

library(leaflet)
library(rgdal)

shape <- readOGR(shape_path, stringsAsFactors = FALSE, encoding = "UTF-8")
head(shape@data)

shape %>% 
  leaflet() %>% 
  addTiles() %>% 
  setView(lat = 35.65, lng = 139.75, zoom = 12) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>% 
  addPolygons(fillOpacity = 0.5,
              weight = 1,
              fillColor = "lightblue")

#TODO
