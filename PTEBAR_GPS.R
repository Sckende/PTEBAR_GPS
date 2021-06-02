setwd("/home/claire/Bureau")
gps <- read.csv2("PTEBAR_GPS_all.csv", dec = ".")
gps
head(gps)
names(gps)
summary(gps)
table(gps$Logger_ID)

gps$Logger_ID <- as.character(gps$Logger_ID)
speed_bilan <- data.frame()
for (i in unique(gps$Logger_ID)){
  logger <- i
  speed_mean <- mean(gps$Speed[gps$Logger_ID == i])
  speed_max <- max(gps$Speed[gps$Logger_ID == i])
  
  speed_bilan <- rbind(speed_bilan, c(logger, speed_mean, speed_max))
}
