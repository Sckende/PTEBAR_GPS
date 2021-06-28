
```{r, include = F}
if (knitr::is_html_output()) knitr::knit_hooks$set(
  plot = function(x, options) {
    cap  <- options$fig.cap  # figure caption
    tags <- htmltools::tags
    as.character(tags$figure(
      tags$img(src = x, alt = cap),
      tags$figcaption(cap)
    ))
  }
)
# packages
require(knitr)
require(mapview)
require(tidyverse)
require(sf)
```

# Mise en contexte
  
## Mission 1 - Grand Bénare - 18 au 19 décembre 2018
  

Dans le cadre du projet Life + Pétrels, 10 balises GPS ont été déployées sur des pétrels de Barau entre le 18-12-2018 et le 19-12-2018. Les balises sont des GPS écotone type PICA de 5g. Les individus équipés sont tous nicheurs et localisés dans la vallée des Deux Miches (**Tab. 1**). Un des but du déployement de cette technologie était de décrire finement les zones de passage ainsi que l'altitude de vol des pétrels lors des entrées et des sorties de la colonie de reproduction.  

La configuration des GPS est la suivante:  
 - SOIR : activation de 16:30 à 22h30 (heure locale)  
 - MATIN : activation de 2:30 à 6h30 (heure locale)  
 - Fréquence d'acquisitaion : 1 point/min  
 - Base range : en marche (indication sur la présence ou non de l'individu au terrier)  
 - No GPS signal : le GPS s'éteint  
 
```{r tableau_1, echo = F}
tab1 <- data.frame(nest_ID = c(108,104,31,30,20,103,100,11,13,12, NA, NA),
                   nest_X = c(336447.0443, 336504.2641, 336502.2784, 336499.6882, 336484.4198, 336484.4198, 336488.4353, 336472.4654, 336472.4654, 336472.4654, NA, NA),
                   nest_Y = c(7663586.004, 7663608.288, 7663609.486, 7663608.796, 7663586.108, 7663586.108, 7663591.191, 7663571.436, 7663571.436, 7663571.436, NA, NA),
                   Logger_ID = c('PAC11', 'PAC20', 'PAC16', 'PAC15', 'PAC04', 'PAC03', 'PAC14', 'PAC10', 'PAC06', 'PAC12', 'PAC05', 'PAC13'),
                   ring_ID = c('FX25185', 'FS88360', 'GE41788', 'FS88338', 'FS88926', 'FX24884', 'FX24893', 'FS75797', 'FS88846', 'GE41695', NA, NA),
                   
                   breed_stat = c(rep('AD/O', 3), 'AD/P', '2AD/echec', 'AD/P', rep('AD/O', 4), NA, NA),
                   ring_year = c(2017, 2012, 2015, 2012, 2013, 2018, 2018, 2009, 2014, 2014, NA, NA),
                   weight = c(390,420,470,390,410,410,420,430,400,430, NA, NA),
                   GPS_config = c(rep('SOIR', 5), rep('MATIN', 5), NA, NA))
knitr::kable(tab1[order(tab1$nest_ID),],
             caption = 'Tab. 1. Bilan de la localisation des nids (nest_ID, nest_X & nest_Y) et du statut des individus équipés avec un GPS. ring_ID = numéro de bague, breed_stat = statut de reproduction avec AD/O, adulte sur oeuf, AD/P, adulte sur poussin & 2AD/echec, 2 adultes dans le nid avec echec de repro, ring_year = année de baguage de l individu, weight = poids en g.',
             row.names = F)
```
  
   
## Mission 2 - Grand Bénare - 9 au 10 janvier 2019
  
Au cours de cette mission, aucun GPS n'a été récupéré et aucune donnée n'a été réceptionnée par l'antenne. De plus, certains individus semblent avoir changé de partenaire (**Tab. 2**).
  
```{r tableau_2, echo = F}
tab2 <- data.frame(nest_ID = c(103, 13, 12, 11, 100, 20, 30, 31, 104, 108, NA, NA),
                   nest_X = c(336484.4198, 336472.46542, 336472.46542, 336472.46542, 336488.435295066, 336484.419824, 336499.688166827, 336502.278433023, 336504.264095001, 336447.044301, NA, NA),
                   nest_Y = c(7663586.108, 7663571.436, 7663571.436, 7663571.436, 7663591.191, 7663586.108, 7663608.796, 7663609.486, 7663608.288, 7663586.004, NA, NA),
                   Logger_ID = c('PAC03', 'PAC06', 'PAC12', 'PAC10', 'PAC14', 'PAC04', 'PAC15', 'PAC16', 'PAC20', 'PAC11', 'PAC05', 'PAC13'),
                   nest_status = c('vide', 'vide', 'pul seul', 'vide', 'non trouvé', 'pul seul', 'vide', 'vide', 'vide', 'AD non bagué', NA, NA),
                   ring_ind1 = c('pas d ind', ' ', 'FS78167', ' ', 'FL38093', ' ', ' ', ' ', 'FX24885', ' ', NA, NA),
                   ring_ind2= c('pas d ind', ' ', 'FS88849', ' ', ' ', ' ', ' ', ' ', 'FX24691', ' ', NA, NA),
                   rmq = c('vide le 01/2019', 'vide le 11/2019', 'ind2=nouveau partenaire?', 'vide le 11/2019', 'AD/O le11/2019', 'TPROF 11/2019', 'AD INAX puis TPROF le 11/2019', 'AD INAX puis TPROF le 11/2019', 'ind2=nouveau partenaire?', 'vide le 11/2019', NA, NA))
knitr::kable(tab2[order(tab2$nest_ID),],
             caption = 'Tab. 2. Bilan du suivi des nids occupés par les adultes avec GPS à lors de la mission précédente. pul = poussin',
             row.names = F)
```
  
## Mission 3 - Grand Bénare - 11 au 12 février 2019
  
Aucun oiseau avec GPS n'a été contrôlé sur la colonie. La communication entre les GPS et l'antenne deployée sur colonie (GPS point ?) semble avoir été faible, avec peu de données transmises : 4 GPS sur 10 et disparition du GPS **PAC20** (**Tab. 3**). Suite à ces observations, l'emplacement du récepteur de signal a été modifié (point GPS ?) afin d'optimiser la communication entre le récepteur et les GPS. La configuration des GPS a également été modifiée:  
- SOIR : activation de 17:00 à 23:00 (heure locale)  
- MATIN : activation de 3:00 à 7:00 (heure locale)  
  
  
```{r tableau_3, echo = F}
tab3 <- data.frame(nest_ID = c(108,104,31,30,20,103,100,11,13,12),
                   Logger_ID = c('PAC11', 'PAC20', 'PAC16', 'PAC15', 'PAC04', 'PAC03', 'PAC14', 'PAC10', 'PAC06', 'PAC12'),
                   N_records = c(271, NA, 893, 173, 10, 403, 4, 1, 1, 2),
                   ring_ID = c('FX25185', 'FS88360', 'GE41788', 'FS88338', 'FS88926', 'FX24884', 'FX24893', 'FS75797', 'FS88846', 'GE41695'),
                   GPS_config = c(rep('SOIR', 5), rep('MATIN', 5)))
knitr::kable(tab3[order(tab3$N_records),],
             caption = 'Tab. 3. Nombre de points enregistrés par GPS en date du 11 et 12 novembre 2019',
             row.names = F)
```
  
## Mission 4 - Grand Bénare - 4 septembre 2019  
  
Cette mission a permis de redéployer l'antenne réceptrice de données GPS sur la colonie de pétrel de Barau. Aucune donnée n'a été reçu. Les terriers des individus équipés l'année précédente ont été visités. Sur 10 nids, seulement deux (nids 20 & 108) étaient occupés par le partenaire de l'oiseau équipé.
  
## Limitations  
   
- Il semblerait qu'aucun des oiseaux avec une balise GPS n'aient été recontrôlés depuis le déploiement. Cela remet en question la méthode du *back-pack* utilisé pour installer les balises.  
- La configuration des GPS n'a peut-être pas été prise en compte puisque les données ne présentent pas d'altitude et que des points GPS ont été enregistrés au-delà des heures d'activation de la balise (MATIN vs SOIR, sauf si mécompréhension du protocole et que ce créneau horaire correspond au moment où les balises peuvent communiquer avec l'antenne réceptrice).  
- Les balises **PAC05** & **PAC13** ne sont pas répertoriées dans les comptes rendus (CR) de missions *tracking*. Cependant, deux balises (**PAC20** & **PAC14**) sont mentionnées dans le CR mais n'apparaissent pas dans le jeux de données.

# Bilan data brutes  
  
Le **tableau 4** fait le bilan des données GPS déployés sur les 10 individus nichant au Grand Bénarre en décembre 2018.  
  
```{r setup, include=FALSE}
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
  
  time_min <- as.character(min(gps_list[[i]]$time))
  time_max <- as.character(max(gps_list[[i]]$time))
  
  bilan <- rbind(bilan, c(log_ID, point_numb, NA_numb, prop_NA, time_min, time_max))
}
names(bilan) <- c('log_ID', 'point_numb', 'NA_numb', 'prop_NA (%)', 'time_min', 'time_max')
```

```{r, echo = F}
library(knitr)
kable(bilan[order(as.numeric(bilan$point_numb)),],
      row.names = F,
      caption = 'Tab. 4. Details des données brutes des balises GPS déployées sur des individus nicheurs de la colonie du Grand Bénare, en décembre 2019. point_numb = nombre de points enregistrés par le GPS, NA_numb = nombre de NA pour les données de lat/long, prop_NA = proportion des lat/long correspondant à des NA, time_min = date/heure du premier point enregistré, time_max = date/heure du dernier point enregistré.')
```

# Bilan des données non dupliquées  
  
Les données ont été filtrées à partir de la variable **time** (composée de la date et de l'heure lors de l'enregistrement du point GPS). Dans le cas où deux dates identiques pour un même GPS sont présentes, la ligne conservée est celle qui présente le **searching_time** (time to fix) le plus court. Les lignes avec des *NA* pour lat/long ont été retirés. Les balises dysfonctionnelles ont également été exclues (*PAC04*, *PAC13* & *PAC05*). Les données restantes sont résumées dans le **tableau 5**.


```{r, include = F}
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
  speed_min <- min(t$Speed)*1.852 # Avec conversion knot -> km.h
  speed_max <- max(t$Speed)*1.852 # Avec conversion knot -> km.h
  
  bilan2 <- rbind(bilan2, c(log_ID, point_numb, time_min, time_max, speed_min, speed_max))
}
names(bilan2) <- c('log_ID', 'point_numb', 'time_min', 'time_max', 'speed_min (km/h)', 'speed_max (km/h)')
```

```{r, echo = F}
library(knitr)
kable(bilan2[order(as.numeric(bilan2$point_numb)),],
      row.names = F,
      caption = 'Tab. 5. Synthèse des données restantes après le retrait des balises dysfonctionnelles, les valeurs inconnues et les duplicats.')
```
  
  
# Visualisation des trajets

```{r, include = F}
#### DELETION of PAC04, PAC13 & PAC05 ####
# Due to low number of GPS fixes
k <- c('PAC04', 'PAC13', 'PAC05')
no <- setdiff(names(gps_list), k)
gps_list2 <- gps_list[no] # keeping list levels with data of interest
#### CORRECTION OF FIRST DATE - PAC12
gps_list2$PAC12$time[1] <- as.POSIXct('2018-12-18 11:33:00')
#### Visual explo ####
# data conversion in SF LINESTRING
gps2 <- gps[!(gps$Logger_ID %in% c('PAC04', 'PAC13', 'PAC05')),]
gps2 <- gps2[!is.na(gps2$Latitude),]
gps2$time[gps2$Logger_ID == 'PAC12'][1] <- as.POSIXct('2018-12-18 11:33:00')
projcrs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
gps2 <- sf::st_as_sf(gps2,
                     coords = c('Longitude', 'Latitude'),
                     crs = projcrs)
# Creation of SF LINESTRINGS
track_lines <- gps2 %>% group_by(Logger_ID) %>% summarize(do_union = FALSE) %>% st_cast("LINESTRING")
```
```{r pressure, echo = FALSE}
mapview::mapview(track_lines,
                 zcol = 'Logger_ID',
                 burst = T,
                 homebutton = F)
```
  
Carte 1. Représentation des trajets complets pour les sept balises GPS restantes.  
  
# Points sur terre
  
```{r, include = F}
run <- st_read("C:/Users/Etudiant/Desktop/SMAC/SPATIAL_data_RUN/Admin/REU_adm0.shp")
mapview(track_lines) + mapview(run)
#### Extract points outside of the Reunion Island
# Points inside the island only
in_run <- st_intersection(gps2, run)
```

```{r, echo = F}
mapview(in_run,
        zcol = 'Logger_ID',
        burst = T,
        homebutton = F)
```
Carte 2. Représentation des passages d'entrées et de sorties de la colonie du Grand Bénare, n = 7 balises.  
  
# Points en mer

```{r, include = F}
# Points outside the island only
out_run <- sf::st_difference(gps2, run)
```

```{r, echo = F}
track_lines_out <- out_run %>% group_by(Logger_ID) %>% summarize(do_union = FALSE) %>% st_cast("LINESTRING")
```

```{r, echo = F}
mapview(out_run,
        zcol = 'Logger_ID',
        burst = T,
        homebutton = F) + mapview(track_lines_out,
                 zcol = 'Logger_ID',
                 burst = T,
                 homebutton = F)
``` 
Carte 3. Représentation des trajets en mer et de la fréquence d'acquisition des points GPS pour les 7 balises GPS.
# Fréquence d'enregistrement par GPS

```{r, include = F}
list_fix_freq <- lapply(gps_list2, test_V2,
                        date_min = strsplit(as.character(min(gps2$time)), ' ')[[1]][1],
                        date_max = strsplit(as.character(max(gps2$time)), ' ')[[1]][1])
list_fix_freq_rear <- lapply(gps_list2, test_V2,
                             date_min = '2019-01-01',
                             date_max = '2019-04-30')
```

```{r, echo = F}
bars <- lapply(list_fix_freq, barp_list)
#bars_rear <- lapply(list_fix_freq_rear, barp_list)
```
```{r}
library(plotly)
p <- ggplot(data = diamonds,
aes =(x = cut, fill = clarity)) +
geom_bar(position = "dodge")
ggplot(p)
```
