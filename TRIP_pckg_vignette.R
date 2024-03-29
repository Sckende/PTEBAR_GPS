#### TRIP package vignette ####
# Package allowing (1) foraging trip duration from the departure to the return to the colony,
#(2) cumulative distance travelled between all locations assuming straight-line Euclidean distances between 2 successive locations,
#(3) maximum distance from the colony (hereafter “maximum range”),
#(4) average travel speed along the trip at sea (i.e. total distance travelled divided by the trip duration), and (5) maximum travel speed during the trip, computed between two successive locations, and assuming straight-line Euclidean distances.
# https://rdrr.io/cran/trip/f/vignettes/trip.Rmd

require("trip")

#### Data input and validation ####
d <- data.frame(x = 1:10, y = rnorm(10), tms = Sys.time() + 1:10, id = gl(2, 5))
tr <- trip(d)
summary(tr) #When a print or summary is made the data are presented in terms of their grouping, with some handy summary values. When converting to sf or sp form as lines these summary values are recorded with each "multi"-line.

#### Simple plotting ####
plot(tr)
lines(tr) #The trip object acts as a sp data frame of points, but with the underlying grouping as lines when that is relevant.

plot(tr, pch = ".", col = rainbow(nrow(tr)))
lines(tr, col = c("dodgerblue", "firebrick"))

# Package example
## real world data in CSV
mi_dat <- read.csv(system.file("extdata/MI_albatross_sub10.csv", package = "trip"),
                   stringsAsFactors = FALSE)
## installed subset because the data is quite dense
## mi_dat <- mi_dat[seq(1, nrow(mi_dat), by = 10), ]
mi_dat$gmt <- as.POSIXct(mi_dat$gmt, tz = "UTC")
mi_dat$sp_id <-  sprintf("%s%s_%s_%s", mi_dat$species,
                         substr(mi_dat$breeding_status, 1, 1), mi_dat$band, mi_dat$tag_ID)
sp::coordinates(mi_dat) <- c("lon", "lat")
## there are many warnings, but the outcome is fine
## (sp_id == 'WAi_14030938_2123' has < 3 locations as does LMi_12143650_14257)
mi_dat <- trip(mi_dat, c("gmt", "sp_id") )
plot(mi_dat, pch = ".")
#lines(mi_dat)  ## ugly

mi_dat_polar <- reproj(mi_dat, "+proj=stere +lat_0=-90 +lon_0=154 +datum=WGS84")
plot(mi_dat_polar, pch = ".")
lines(mi_dat_polar)

# With the petrel data
gps <- read.csv2("C:/Users/Etudiant/Desktop/SMAC/Projet_publi/4-PTEBAR_GPS/DATA/PTEBAR_GPS_all.csv", dec = ".")

gps <- gps[!(gps$Logger_ID %in% c("PAC04", "PAC05", "PAC13")),]
gps <- gps[!is.na(gps$Latitude),]

gps$timest <- paste(paste(gps$Year, gps$Month, gps$Day, sep = "-"), paste(gps$Hour, gps$Minute, gps$Second, sep = ":"), sep = " ")
gps$timest <- as.POSIXct(gps$timest, tz = 'UTC')



# Plot first option - old school
gps1 <- gps
sp::coordinates(gps1) <- c("Longitude", "Latitude")
gps1 <- trip(gps, c("timest", "Logger_ID") )
plot(gps1, pch = ".")
lines(gps1)

maps::map("world2", add = TRUE)
axis(1)
sp::degAxis(2)

# Plot second option
gps2 <- as(gps1, 'SpatialLinesDataFrame') # need to use the trip object for proceeding to the conversion
gps_sf <- sf::st_as_sf(gps2)
mapview::mapview(gps_sf, zcol = 'tripID') # Wonderful map to develop !!!!

# Plot third option
require(moveVis)
# example
data(whitestork_data) # named 'm' in th eenvironment
stork <- cbind(m@trackId, m@data)
class(stork)
class(stork$time)
crs_stork <- m@proj4string

stork_move <- df2move(stork,
                      proj = crs_stork,
                      x = "x",
                      y = "y",
                      time = "time",
                      track_id = "trackID") # conversion of the df in move object
# align move_data to a uniform time scale
stork_move2 <- df2move(stork[stork$trackID =='Sara',],
                       proj = crs_stork,
                       x = "x",
                       y = "y",
                       time = "time",
                       track_id = "trackID")
mo <- align_move(stork_move, res = 4, unit = "mins")
mo2 <- align_move(stork_move2, res = 'max', unit = "mins")
# create spatial frames with a OpenStreetMap watercolour map
require(tidyverse)
frames <- frames_spatial(mo2,
                         path_colours = rainbow(1),
                         map_service = "osm",
                         map_type = "watercolor",
                         alpha = 0.5) %>%
  add_labels(x = "Longitude", y = "Latitude") #%>% # add some customizations, such as axis labels
  # add_northarrow() %>%
  # add_scalebar() %>%
  # add_timestamps(m, type = "label") %>%
  # add_progress()

frames[[100]] # preview one of the frames, e.g. the 100th frame

# animate frames
animate_frames(frames, out_file = "moveVis.gif")


#-------------------#
# Logger_ID  "PAC11" "PAC15" "PAC16" "PAC03" "PAC10" "PAC06" "PAC12"
mini_gps <- gps[gps$Logger_ID == 'PAC12', c(2, 9, 10, 29)]
# Check for doublons in data
tab <- table(mini_gps$timest)

tab[tab >1]
# Delete doublons
mini_gps <- mini_gps %>% distinct(timest, .keep_all = TRUE)

gps3 <- df2move(mini_gps,
                proj = crs_stork,
                x = "Longitude",
                y = "Latitude",
                time = "timest",
                track_id = "Logger_ID")

mo <- align_move(gps3, res = 400, unit = "mins")
frames <- frames_spatial(mo,
                         path_colours = rainbow(1),
                         map_service = "osm",
                         map_type = "watercolor",
                         alpha = 0.5)
frames[[100]]

# animate frames
animate_frames(frames, out_file = "PAC12_tracking.gif")


#### Gridding for time spent ####
#There is a key functionality to determine the time spent in area on a grid, by leveraging the rasterize() generic function in the raster package. Any raster object may be used, so the specification of pixel area, extent and map projection is up to the user. (The trip line segments must all fall within the raster). 
tg <- raster::rasterize(tr)
plot(tg, col = c('transparent', heat.colors(25)))

#### Reading from Argos files ####

argosfile <- system.file("extdata/argos/98feb.dat", package = "trip", mustWork = TRUE)
argos <- readArgos(argosfile) 

summary(argos)
plot(argos, pch = ".")
lines(argos)
maps::map("world2", add = TRUE)
axis(1)
sp::degAxis(2)

