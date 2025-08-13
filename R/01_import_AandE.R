# Accident and Emergency waiting times

# id <- "37ba17b1-c323-492c-87d5-e986aae9ab59"
# query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
#                 id, "&limit=100000")
# 
# opendata <- content(httr::GET(query))$result$records %>% bind_rows() 


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
              "data/AE.xlsx",
              mode = "wb")

excel <- readxl::read_xlsx("data/AE.xlsx", sheet = "Scotland") %>% 
  rbind(readxl::read_xlsx("data/AE.xlsx", sheet = "NHSBoards"))

data <- excel %>% 
  filter(AttendanceCategory == "All") %>% 
  select(MonthEndingDate, NHSBoardName, PercentageWithin4HoursAll) %>% 
  mutate(To = as.Date(MonthEndingDate),
         From = floor_date(To, "month"),
         Indicator = "AandE",
         HB = str_remove(NHSBoardName, "NHS "),
         HB_indicator = round2(PercentageWithin4HoursAll/100, 3),
         Target = ifelse(HB == "Scotland", 0.95, 0.98),
         Target_met = HB_indicator >= Target) %>% 
  select(From, To, Indicator, HB, HB_indicator, Target, Target_met)


saveRDS(data, "data/AandE.rds")
