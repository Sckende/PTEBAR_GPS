# Use of TRIP package for the post-process of the gps data
rm(list = ls())

gps <- read.csv2("C:/Users/Etudiant/Desktop/SMAC/Projet_publi/4-PTEBAR_GPS/DATA/PTEBAR_GPS_all.csv", dec = ".")
summary(gps)
names(gps)

#### Creation of 'time' variable ####
gps$time <- paste(paste(gps$Year, gps$Month, gps$Day, sep = "-"), paste(gps$Hour, gps$Minute, gps$Second, sep = ":"), sep = " ")
gps$time <- as.POSIXct(gps$time)

names(gps)
#### here keeping only date, ID, lat & long, speed, searching_time, Voltage ####
gps1 <- gps[, c(2, 9:13, 29)]

#### For each logger, % of missing data, max/min speed, ... ####
#all(is.na(gps$Latitude) == is.na(gps$Longitude)) # check point

gps_list <- split(gps1, gps1$Logger_ID)

# NA summary
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

# Delete the duplicated rows for DATE/TIME based on the lower searching_time
bilan2 <- data.frame()

for(i in 1:length(gps_list)){
  t <- gps_list[[i]][!is.na(gps_list[[i]]$Latitude),]
  t <- t[order(t$time, t$Searching_time, decreasing = F),]
  t <- t[!duplicated(t$time),]
  
  log_ID <- unique(t$Logger_ID)
  point_numb <- nrow(t)
  time_min <- as.character(min(t$time))
  time_max <- as.character(max(t$time))
  speed_min <- min(t$Speed)
  speed_max <- max(t$Speed)
  
  bilan2 <- rbind(bilan2, c(log_ID, point_numb, time_min, time_max, speed_min, speed_max))
}
names(bilan2) <- c('log_ID', 'point_numb', 'time_min', 'time_max', 'speed_min', 'speed_max')
bilan2[order(as.numeric(bilan2$point_numb)),]

#### DELETION of PAC04, PAC13 & PAC05 ####
# Due to low number of GPS fixes
k <- c('PAC04', 'PAC13', 'PAC05')
no <- setdiff(names(gps_list), k)
gps_list2 <- gps_list[no] # keeping list levels with data of interest

#### Visual explo ####
#require(trip)
require(mapview)

# data conversion in SF LINESTRING
track_lines <- data.frame()
track_list <- list()

par(mfrow = c(2,4))
projcrs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

for(i in 1:length(gps_list2)){
  tk <- gps_list2[[i]]
  
  tk <- tk[!is.na(tk$Latitude),]
  tk <- tk[order(tk$time, decreasing = F),]
  coord <- as.matrix(tk[, c('Longitude', 'Latitude')])
  track <- sf::st_linestring(coord)
  
  track_lines <- rbind(track_lines, c(unique(tk$Logger_ID), sf::st_linestring(coord)))
  track_list[[i]] <- track
  names(track_list)[i] <- unique(tk$Logger_ID)
  plot(track)
}

mapview::mapview(track_list,
                 color = rainbow(n = length(track_list)),
                 legend = T)

