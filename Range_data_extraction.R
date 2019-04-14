install.packages(c("raster", "rgdal", "dismo", "rJava"))
install.packages("jsonlite")
install.packages("maptools")
install.packages("maps")
install.packages("tiff")
library(raster)
library(rgdal)
library(dismo)
library(rJava)
library(jsonlite)
library(maptools)
library(maps)
library(tiff)

# pulling data from GBIF
ant_range <- gbif('Solenopsis', 'invicta', geo = TRUE, sp = TRUE, download = TRUE)
projection(ant_range) <- CRS('+proj=longlat +datum=WGS84')

# plotting data
world <- map("world", fill = T)
class(world)
ids <- world$names
world <- map2SpatialPolygons(world, IDs = ids, proj4string = CRS('+proj=longlat +datum=WGS84'))
plot(world)
proj4string(world)
plot(ant_range, col = "red")
plot(world, add = T)

# temp and precip data clean
rainfall_test <- raster('./wc2.0_10m_prec_01.tif')
plot(rainfall_test)
plot(world, add = T)

read_env <- function(y) {
temp_list <- vector("list", length = length(dir(y)))
tempo <- dir(y)
for(i in seq_along(tempo)) {
  ras <- raster(paste0(y, '/', tempo[i]))
  temp_list[i] <- ras
}
f <- stack(temp_list)
print(mean(f))
}

mean_rainfall <- read_env('./rainfall')
mean_temperature <- read_env('./temperature')
save(mean_rainfall, file = './rasters/mean_rainfall.Rdata')
save(mean_temperature, file = './rasters/mean_temperature.Rdata')

# Disturbance data read in
tree_loss <- raster('./tree_cover_loss.tiff')
tree_loss <- projectRaster(from = tree_loss, to = mean_rainfall)
tree_loss <- mask(tree_loss, mask = world)
save(tree_loss, file = './rasters/tree_loss.Rdata')

load('./rasters/mean_rainfall.Rdata')
load('./rasters/mean_temperature.Rdata')
load('./rasters/tree_loss.Rdata')

# using extract to get predictor variables at occurrence points
predictors <- stack(mean_rainfall, mean_temperature, tree_loss)
bckg <- randomPoints(predictors, n = 2000)
bckg <- data.frame(bckg)
coordinates(bckg) <- ~x+y
presences <- extract(predictors, ant_range)
absences <- extract(predictors, bckg)

present <- c(rep(1, nrow(presences)), rep(0, nrow(absences)))

sdm_data <- data.frame(cbind(present, rbind(presences, absences)))
# colnames(sdm_data) <- c("present", "rainfall", "temperature", "disturbance")

