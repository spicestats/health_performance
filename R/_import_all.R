


# import all
files <- list.files("R", full.names = TRUE)
files <- files[grepl("01_import", files)]

lapply(files, source)

# combine
source("R/02_combine_indicator_data.R")

# charts
source("R/03_overview_chart.R")
