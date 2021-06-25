#### GPS fixes frequencies function ####
# allows the computation of number of GPS fixes per day
# x = df with a 'date' variable

# For first PETBAR GPS data, date range =  
test <- function(x){
  x$date <- as.Date(strftime(x$time, "%Y-%m-%d"))
  sequen <- data.frame(date = seq.Date(from = min(x$date), to = max(x$date), by = 1), n = 0)
  
  mm <- dplyr::count(x, date)
  mm <- rbind(mm, sequen[!(sequen$date %in% mm$date),])
  mm <- mm[order(mm$date, decreasing = F),]
  mm <- cbind(Logger_ID = unique(x$Logger_ID), mm)
  return(mm)
}

# For first PETBAR GPS data
# x = df with a 'date' variable, date_min & date_max with a "%Y-%m-%d" format
test_V2 <- function(x, date_min, date_max){
  x$date <- as.Date(strftime(x$time, "%Y-%m-%d"))
  sequen <- data.frame(date = seq.Date(from = as.Date(strftime(date_min, "%Y-%m-%d")), to = as.Date(strftime(date_max, "%Y-%m-%d")), by = 1), n = 0)
  
  xx <- x[x$date %in% sequen$date,]
  mm <- dplyr::count(xx, date)
  mm <- rbind(mm, sequen[!(sequen$date %in% mm$date),])
  mm <- mm[order(mm$date, decreasing = F),]
  mm <- cbind(Logger_ID = unique(x$Logger_ID), mm)
  return(mm)
}


#### Color function for life cycle periods ####

# Function which selects the color associated to the life cycle period of the PETBAR and based on the date
# x = vector of dates

col_choice <- function(x){
  # WARNING - periods selected here are extra specific to the first GPS data of PETBAR
  # post_dates <- seq.Date(as.Date(strftime('2018-05-01', "%Y-%m-%d")),
  #                        as.Date(strftime('2018-08-30', "%Y-%m-%d")),
  #                        by = 1)
  # prospec_dates <- seq.Date(as.Date(strftime('2018-09-01', "%Y-%m-%d")),
  #                           as.Date(strftime('2018-10-31', "%Y-%m-%d")),
  #                           by = 1)
  # inc_dates <- seq.Date(as.Date(strftime('2018-11-01', "%Y-%m-%d")),
  #                       as.Date(strftime('2018-12-31', "%Y-%m-%d")),
  #                       by = 1)
  # rear_dates <- seq.Date(as.Date(strftime('2019-01-01', "%Y-%m-%d")),
  #                        as.Date(strftime('2019-04-30', "%Y-%m-%d")),
  #                        by = 1)
  pal <- viridis::viridis(4) # 1 color per period i.e., winter, prosp, incub, rearing
  
  colors <- NULL
  
  for(i in 1:length(x)){
    
    if(lubridate::month(x[i]) %in% 5:8){
      col <- pal[1]
    } else if(lubridate::month(x[i]) %in% 9:10){
      col <- pal[2]
    } else if(lubridate::month(x[i]) %in% 11:12){
      col <- pal[3]
    } else {
      col <- pal[4]
    }
    colors <- c(colors, col)
  }
  return(colors)
}

# Function test 
# dates <- seq.Date(as.Date(strftime('2018-05-01', "%Y-%m-%d")),
#                   as.Date(strftime('2019-04-30', "%Y-%m-%d")),
#                   by = 1)
# dates
# df <- data.frame(date = dates, n = sample(1:1000, length(dates)))
# barplot(df$n,
#         col = col_choice(df$date))

#### Barplot of gps fixes frequencies ####
# x = df with variables 'date', 'n', 'Logger_ID'
barp_list <- function(x){
  pal <- viridis::viridis(4) # only for the legend
  par(oma = c(0,0,0,0)) # Set right margin
  
  barplot(x$n,
          names.arg = x$date,
          ylim = c(0, 350),
          main = unique(x$Logger_ID),
          las = 2,
          cex.names = 0.8,
          col = col_choice(x$date),
          ylab = 'GPS fixes number')
  legend('top',
         legend = c('non-breed', 'prosp', 'incub', 'rear'),
         fill = pal,
         bty = 'n',
         ncol = 2)
}
