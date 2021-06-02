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
  
  speed_mean <- mean(logger_list[[i]]$Speed, na.rm = T)
  speed_max <- max(logger_list[[i]]$Speed, na.rm = T)
  NA_speed <- length(logger_list[[i]]$Speed[is.na(logger_list[[i]]$Speed)])
  NA_prop_speed <- length(logger_list[[i]]$Speed[is.na(logger_list[[i]]$Speed)])/N_points*100
  
  
  bilan <- data.frame(logger, N_points, speed_mean, speed_max, NA_speed, NA_prop_speed)
  speed_bilan <- rbind(speed_bilan, bilan)
}

speed_bilan

# GPS points plot

head(gps)
rainb_col <- rainbow(n = length(unique(gps$Logger_ID)))

plot(x = logger_list[[1]]$Longitude[!is.na(logger_list[[1]]$Longitude)],
     y = logger_list[[1]]$Latitude[!is.na(logger_list[[1]]$Latitude)],
     type = "l",
     col = rainb_col[1],
     bty = 'n',
     xlim = c(min(gps$Longitude, na.rm = T), max(gps$Longitude, na.rm = T)),
     ylim = c(min(gps$Latitude, na.rm = T), max(gps$Latitude, na.rm = T)),
     xlab = 'Longitude',
     ylab = 'Latitude')

for (i in 2: length(logger_list)){
  lines(x = logger_list[[i]]$Longitude[!is.na(logger_list[[i]]$Longitude)],
       y = logger_list[[i]]$Latitude[!is.na(logger_list[[i]]$Latitude)],
       type = "l",
       col = rainb_col[i])
}
