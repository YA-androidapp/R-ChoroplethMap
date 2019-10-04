# update.packages(ask = FALSE)

shape_path = "shape/h27ka13.shp"
data_path = "data/H30.csv"

setwd("~/GitHub/R-ChoroplethMap")



# sf package

# install.packages("ggplot2", dependencies = T)
# install.packages("sf", dependencies = T)

library(ggplot2)
library(sf)

map <- read_sf(shape_path)
ggplot(map) + geom_sf()

#TODO



# leaflet

# install.packages("dplyr", dependencies = T)
# install.packages("httpuv", dependencies = T)
# install.packages("leaflet", dependencies = T)
# install.packages("rgdal", dependencies = T)

library(dplyr)
library(leaflet)
library(rgdal)

shape <-
  readOGR(shape_path, stringsAsFactors = FALSE, encoding = "UTF-8")
shape@data$市区町丁  <-
  paste0(shape@data$CITY_NAME, ifelse(is.na(shape@data$S_NAME), "", shape@data$S_NAME))
head(shape@data)

datacsv <-
  read.csv(data_path,
           stringsAsFactors = FALSE,
           fileEncoding = "UTF-8")
head(datacsv)

joined <-
  left_join(shape@data, datacsv, by = "市区町丁") # キーにしたい列名が異なる場合: by = c("CITY_NAME" = "市区町丁")

nrow(shape@data)
nrow(datacsv)
nrow(joined)

population_density <-
  as.numeric(shape@data$JINKO) / shape@data$AREA * 1000000 # 単位面積1 km2当たり人口密度
household_density <-
  as.numeric(shape@data$SETAI) / shape@data$AREA * 1000000 # 単位面積1 km2当たり世帯密度

crimecase_density <-
  as.numeric(joined$総合計) / joined$AREA * 1000000 # 単位面積1 km2当たり認知件数

# data_density <- population_density
# data_density <- household_density
data_density <- crimecase_density


# 欠損値(NA)を0で置換する
data_density[is.na(data_density)] <- 0

color_pallet <-
  # colorNumeric("Blues", domain = data_density, reverse = F) # 連続量を塗り分け
  colorQuantile("Blues",
                domain = data_density,
                reverse = F,
                n = 8) # 分位数で塗り分け

labels <- sprintf("<strong>%s</strong><br/>%5.1f",
                  paste0(joined$MOJI),
                  data_density) %>% lapply(htmltools::HTML)
shape %>%
  leaflet() %>%
  setView(lat = 35.65, lng = 139.75, zoom = 12) %>% # 初期表示
  addProviderTiles(providers$CartoDB.Positron) %>% # ベースマップ
  addPolygons(
    fillOpacity = 0.7,
    weight = 1,
    color = "#666",
    fillColor = ~ color_pallet(data_density),
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
    values = ~ data_density,
    title = "1km2当たり認知件数"
  )
