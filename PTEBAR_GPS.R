setwd("C:/Users/Etudiant/Desktop/SMAC/Projet_publi/4-PTEBAR_GPS/DATA")
gps <- read.csv2("PTEBAR_GPS_all.csv", dec = ".")
gps
head(gps)
names(gps)
summary(gps)
table(gps$Logger_ID)
table(gps$Year)

# Information summary about speed/bird
logger_list <- split(gps, gps$Logger_ID)

speed_bilan <- data.frame()
for (i in 1:length(logger_list)){
  logger <- unique(logger_list[[i]]$Logger_ID)
  N_points <- length(logger_list[[i]]$Logger_ID)
  ini_date <- paste0(c(logger_list[[i]]$Year[1], logger_list[[i]]$Month[1], logger_list[[i]]$Day[1]), collapse = "-")
  end_date <- paste0(c(logger_list[[i]]$Year[N_points], logger_list[[i]]$Month[N_points], logger_list[[i]]$Day[N_points]), collapse = "-")
  
  speed_mean <- mean(logger_list[[i]]$Speed, na.rm = T)
  speed_max <- max(logger_list[[i]]$Speed, na.rm = T)
  NA_speed <- length(logger_list[[i]]$Speed[is.na(logger_list[[i]]$Speed)])
  NA_prop_speed <- length(logger_list[[i]]$Speed[is.na(logger_list[[i]]$Speed)])/N_points*100
  
  
  bilan <- data.frame(logger, N_points, ini_date, end_date, speed_mean, speed_max, NA_speed, NA_prop_speed)
  speed_bilan <- rbind(speed_bilan, bilan)
}

speed_bilan
# Individuals to remove
# PAC04, PAC05, PAC13
# => balises de 2019 non fonctionnelles ?

# GPS points plot

head(gps)

gps2 <- gps[!(gps$Logger_ID %in% c("PAC04", "PAC05", "PAC13")),]
rainb_col <- rainbow(n = length(unique(gps2$Logger_ID)))
logger_list2 <- split(gps2, gps2$Logger_ID)

plot(x = logger_list2[[1]]$Longitude[!is.na(logger_list2[[1]]$Longitude)],
     y = logger_list2[[1]]$Latitude[!is.na(logger_list2[[1]]$Latitude)],
     type = "l",
     col = rainb_col[1],
     bty = 'n',
     xlim = c(min(gps$Longitude, na.rm = T), max(gps$Longitude, na.rm = T)),
     ylim = c(min(gps$Latitude, na.rm = T), max(gps$Latitude, na.rm = T)),
     xlab = 'Longitude',
     ylab = 'Latitude')

for (i in 2: length(logger_list2)){
  lines(x = logger_list2[[i]]$Longitude[!is.na(logger_list2[[i]]$Longitude)],
       y = logger_list2[[i]]$Latitude[!is.na(logger_list2[[i]]$Latitude)],
       type = "l",
       col = rainb_col[i])
}

#### moveVis package ####
library(moveVis)
library(move)
library(raster)
library(ggplot2)

# Package example
# http://movevis.org/articles/example-1.html
data("move_data")

unique(timestamps(move_data))
timeLag(move_data, unit = "mins")

move_data <- align_move(move_data, res = 4, unit = "mins")

frames <- frames_spatial(move_data, path_colours = c("red", "green", "blue"),
                         map_service = "osm", map_type = "watercolor", alpha = 0.5)

length(frames) # number of frames
frames[[100]] # display one of the frames
frames[[130]]

animate_frames(frames, out_file = "example_1.gif")


# Conversion of dataframe to move object

#time has to be of class POSIXct
names(gps2)
gps2$timest <- paste(paste(gps2$Year, gps2$Month, gps2$Day, sep = "-"), paste(gps2$Hour, gps2$Minute, gps2$Second, sep = ":"), sep = " ")

gps2$timest <- as.POSIXct(gps2$timest)

gps3 <- gps2[!is.na(gps2$Latitude),]
gps3 <- gps3[gps3$Logger_ID == "PAC15",]
gps3_move <- df2move(gps3,
                     proj = "+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0",
                     x = "Longitude",
                     y = "Latitude",
                     time = "timest",
                     track_id = "Logger_ID")
#### Bathymetry visualization ####
# see https://pjbartlein.github.io/REarthSysSci/netCDF.html#introduction for use of .nc file

library('ncdf4')
ncfname <- 'C:/Users/Etudiant/Downloads/gebco_2020_tid_netcdf/GEBCO_2020_TID.nc'

# open a netCDF file
ncin <- ncdf4::nc_open(ncfname)
print(ncin)

# get longitude and latitude
lon <- ncvar_get(ncin,"lon")
nlon <- dim(lon)
head(lon)

lat <- ncvar_get(ncin,"lat")
nlat <- dim(lat)
head(lat)

print(c(nlon,nlat))

