# NEW ----

# push to github so that dashboard automatically updates
# git push github master


# open data indicators ---------------------------------------------------------

files_od <- c("R/01_import_AandE.R",
              "R/01_import_ante.R",
              "R/01_import_CAMHS.R",
              "R/01_import_cancerWT.R",
              "R/01_import_CDI_SAB.R",
              "R/01_import_diagnostic.R",
              "R/01_import_drug.R",
              "R/01_import_IVF.R",
              "R/01_import_outpatient_TTG.R",
              "R/01_import_PT.R") 


# spreadsheet only -------------------------------------------------------------
# all annual or every 2 years

files_manual <- c("R/01_import_GP.R", # next: spring 2026; every 2 years; 48-hour sub-indicator only available on request
                  "R/01_import_sick.R", # next: Mar 2026?; manual download via dashboard only
                  "R/01_import_smoke.R") # next: winter 2025/2026; manual download via dashboard while spreadsheet is too awful to automate


# no longer active -------------------------------------------------------------

files_dead <- c("R/01_import_DCE.R",
                "R/01_import_ABI.R",
                "R/01_import_RTT.R",
                "R/01_import_PDS.R")

# A&E indicator needs live session: --------------------------------------------

# xlsx files get updated more quickly
url <- "https://publichealthscotland.scot/healthcare-system/urgent-and-unscheduled-care/accident-and-emergency/downloads-and-open-data/our-downloads"


# need live session as website loads dynamically
session <- read_html_live(url)

links <- session %>% 
  html_elements(".chart-downloads") %>% 
  html_elements("a") %>% 
  html_attr("href")

download_link <- links[grepl("monthly-attendance-and-waiting-times.xlsx", links)]

download.file(paste0("https://publichealthscotland.scot/", download_link), 
              "data/AE.xlsx", mode = "wb")


# run import and combine scripts -----------------------------------------------

source("R/00_config.R")
lapply(c(#files_manual,
         files_od), source)

source("R/02_combine_indicator_data.R")
source("R/03_spreadsheets.R")

# charts
source("R/03_overview_chart.R")
