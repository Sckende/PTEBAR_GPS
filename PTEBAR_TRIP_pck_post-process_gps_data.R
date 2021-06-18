# Use of TRIP package for the post-process of the gps data
rm(list = ls())

require(trip)
gps <- read.csv2("C:/Users/Etudiant/Desktop/SMAC/Projet_publi/4-PTEBAR_GPS/DATA/PTEBAR_GPS_all.csv", dec = ".")
summary(gps)
names(gps)

# Creation of 'time' variable
gps$time <- paste(paste(gps$Year, gps$Month, gps$Day, sep = "-"), paste(gps$Hour, gps$Minute, gps$Second, sep = ":"), sep = " ")
gps$time <- as.POSIXct(gps$time)

# here keeping only date, ID, lat & long
gps1 <- gps[, c(2, 9, 10, 29)]

# For each logger, % of missing data
#all(is.na(gps$Latitude) == is.na(gps$Longitude)) # check point

gps_list <- split(gps1, gps1$Logger_ID)

bilan <- data.frame()

for (i in 1:length(gps_list)){
  log_ID <- unique(gps_list[[i]]$Logger_ID)
  point_numb <- nrow(gps_list[[i]])
  NA_numb <- length(gps_list[[i]]$Latitude[is.na(gps_list[[i]]$Latitude)])
  prop_NA <- round(NA_numb/point_numb*100, digits = 1)
  
  bilan <- rbind(bilan, c(log_ID, point_numb, NA_numb, prop_NA))
  
}
names(bilan) <- c('log_ID', 'point_numb', 'NA_numb', 'prop_NA')
bilan[order(as.numeric(bilan$point_numb)),]

# Visual explo
require(mapview)

for (i in 1:length(gps_list)){
  g <- gps_list[[i]][!is.na(gps_list[[i]]$Latitude),]
  sp::coordinates(g) <- c('Longitude', 'Latitude')
  #g_sf <- sf::st_as_sf(g)
  #g_sf <- sf::st_cast(g_sf, 'LINESTRING')
  #mapview::mapview(g)
  plot(g)
  lines(g)
}

sp::coordinates(gps_list[[1]]) <- c("Longitude", "Latitude")
gps_sf <- sf::st_as_sf(gps_list[[1]])
mapview::mapview(gps_sf, zcol = 'tripID') # Wonderful map to develop !!!!