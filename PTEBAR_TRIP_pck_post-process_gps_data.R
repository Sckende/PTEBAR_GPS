# Use of TRIP package for the post-process of the gps data
rm(list = ls())
source('C:/Users/Etudiant/Desktop/SMAC/GITHUB/PTEBAR_GPS/PETBAR_Script_Functions.R')

gps <- read.csv2("C:/Users/Etudiant/Desktop/SMAC/Projet_publi/4-PTEBAR_GPS/DATA/PTEBAR_GPS_all.csv", dec = ".")
summary(gps)
names(gps)

#### Creation of 'time' variable ####
gps$time <- paste(paste(gps$Year, gps$Month, gps$Day, sep = "-"), paste(gps$Hour, gps$Minute, gps$Second, sep = ":"), sep = " ")
gps$time <- as.POSIXct(gps$time)

names(gps)
#### here keeping only date, ID, lat & long, speed, searching_time, Voltage ####
gps1 <- gps[, c(2, 9:13, 29)]

#### Addition of a 'period' variable

gps1$period[month(gps1$time) %in% 1:4] <- 'rearing'
gps1$period[month(gps1$time) %in% 5:8] <- 'winter'
gps1$period[month(gps1$time) %in% 9:10] <- 'prosp'
gps1$period[month(gps1$time) %in% 11:12] <- 'incub'

table(gps1$period, useNA = 'always')
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

#### CORRECTION OF FIRST DATE and PERIOD - PAC12
gps_list2$PAC12$time[1] <- as.POSIXct('2018-12-18 11:33:00')
gps_list2$PAC12$period[1] <- 'incub'

#### Visual explo ####
#require(trip)
require(mapview)

# data conversion in SF LINESTRING

gps2 <- gps[!(gps$Logger_ID %in% c('PAC04', 'PAC13', 'PAC05')),]
gps2 <- gps2[!is.na(gps2$Latitude),]

projcrs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
gps2 <- sf::st_as_sf(gps2,
                     coords = c('Longitude', 'Latitude'),
                     crs = projcrs)
head(gps2)

# Creation of SF LINESTRINGS
require(tidyverse)
require(sf)
track_lines <- gps2 %>% group_by(Logger_ID) %>% summarize(do_union = FALSE) %>% st_cast("LINESTRING")

mapview(track_lines)

# Loading of Reunion Island spatial polygons
run <- st_read("C:/Users/Etudiant/Desktop/SMAC/SPATIAL_data_RUN/Admin/REU_adm0.shp")

mapview(track_lines) + mapview(run)

#### Extract points outside of the Reunion Island ####
head(gps2)

# Points inside the island only
in_run <- st_intersection(gps2, run)
mapview(in_run)

# Points outside the island only
out_run <- sf::st_difference(gps2, run)
mapview(out_run,
        zcol = 'Logger_ID')

# track_lines_out <- out_run %>% group_by(Logger_ID) %>% summarize(do_union = FALSE) %>% st_cast("LINESTRING")
# mapview(track_lines_out)

#### Number of fixes per day ####

head(gps2)
# computation
list_fix_freq <- lapply(gps_list2, test)

# Visualization
bars <- lapply(list_fix_freq, barp_list)

# Summary of fixes frequencies for all the period

su <- do.call('rbind', list_fix_freq)
su_list <- tapply(su$n, su$Logger_ID, summary)
su_df <- do.call('rbind', su_list); su_df

# Summary of fixes frequencies for the rearing period only
rear_dates <- seq.Date(as.Date(strftime('2019-01-01', "%Y-%m-%d")),
                      as.Date(strftime('2019-04-30', "%Y-%m-%d")),
                      by = 1)

su_rear <- su[su$date %in% rear_dates,]
su_rear_list <- tapply(su_rear$n, su_rear$Logger_ID, summary)
su_rear_df <- do.call('rbind', su_rear_list); su_rear_df


#### Filtering based on the part of monitored breeding colony ####

mon_col <- st_read("C:/Users/Etudiant/Desktop/SMAC/SPATIAL_data_RUN/Lieu_dit_terrain/lieu_dit_terrain.shp")
protec_col <- st_read("C:/Users/Etudiant/Desktop/SMAC/SPATIAL_data_RUN/APB_PTEBAR/APB_PTEBAR.shp")
