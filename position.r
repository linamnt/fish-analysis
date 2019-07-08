library(tidyverse)
library(magrittr)
library(lubridate)

file <- 'Tester-20190329T211750.csv'

# Get rid of extra metadata
# 4 is number of unnecessary last rows, 3 is first rows
skip_first <- 3
skip_last <- 4
nrows <- length(readLines(file)) - skip_first - skip_last

# read in the data
data <- read_csv(file,
                 quote='"', skip=3, n_max = nrows,
                 col_names = FALSE)

# rename the columns using the select() function
# use the mutate function to parse the time (hms = hours minutes seconds)
data <- data %>%
  select(time = X1, fish_id = X4, zone = X9, distance = X11) %>%
  mutate(time = hms(time))

# generate some fake x, y coordinates
data$x = rnorm(n = nrows)
data$y = rnorm(n = nrows)

calc_distance <- function(x1, x2, y1, y2) {
  sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
}


distance <- function(data) {
  # length of data
  n <- nrow(data)

    # assume there is x and y columns, shift by a row to get distance from one row to another
  data$distance[2:n] <- calc_distance(data$x[1:n-1], data$x[2:n], data$y[1:n-1], data$y[2:n])

  # get the cumulative distance
  data$cumulative_dist <- c(0, cumsum(data$distance)[-nrow(data)])

  data
}


speed_binned <- function(data, bins_sec){
  # get the length of the recording in seconds
  max_time <- max(data$time)

  # cut into 3s chunks, from 0 to max_time and set to a new column
  data$cuts <- cut(data$time, seq(0, bins_sec*round(max_time/bins_sec), by = bins_sec),
                   include.lowest = TRUE)

  speed <- data %>%
    group_by(cuts) %>%
    # v = d/t (distance/bins_sec)
    summarise(avg_speed = mean(distance)/bins_sec)

  speed
}

# run the functions on our data
data <- distance(data)
speed <- speed_binned(data, 3)

