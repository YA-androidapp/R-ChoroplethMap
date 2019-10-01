update.packages(ask = FALSE)

shape_path = "shape/h27ka13.shp"
data_path = "data/H30.csv"

setwd("~/GitHub/R-ChoroplethMap")



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

shape <-
  readOGR(shape_path, stringsAsFactors = FALSE, encoding = "UTF-8")
head(shape@data)

population_density <-
  as.numeric(shape@data$JINKO) / shape@data$AREA * 1000000 # 単位面積1 km2当たり人口密度
household_density <-
  as.numeric(shape@data$SETAI) / shape@data$AREA * 1000000 # 単位面積1 km2当たり世帯密度

color_pallet <-
  colorNumeric("Blues", domain = population_density, reverse = F)
labels <- sprintf("<strong>%s</strong><br/>%5.1f",
                  paste0(shape@data$MOJI),
                  population_density) %>% lapply(htmltools::HTML)
shape %>%
  leaflet() %>%
  setView(lat = 35.65, lng = 139.75, zoom = 12) %>% # 初期表示
  addProviderTiles(providers$CartoDB.Positron) %>% # ベースマップ
  addPolygons(
    fillOpacity = 0.7,
    weight = 1,
    color = "#666",
    fillColor = ~ color_pallet(population_density),
    label = labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto"
    )
  ) %>%
  # 凡例
  addLegend(
    "bottomright",
    pal = color_pallet,
    values = ~ population_density,
    title = "人口密度"
  )
