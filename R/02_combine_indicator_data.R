library(tidyverse)

files <- list.files("data", ".rds", full.names = TRUE)
files <- files[!grepl("scraped", files)]
files <- files[!grepl("indicator_data", files)]

files_old <- readRDS("data/indicator_data.rds")

data <- lapply(files, readRDS) %>% 
  bind_rows() %>% 
  
  # files_old is needed to overwrite (and not d uplicate) any revised stats
  mutate(files_old = FALSE) %>% 
  rbind(files_old %>% mutate(files_old = TRUE)) %>% 
  mutate(Geography = case_when(HB == "Scotland" ~ "Country",
                               !is.na(Geography) ~ Geography,
                               TRUE ~ "Health board"),
         HB = str_replace(HB, "&", "and"),
         HB = ifelse(HB == "NHS24", "NHS 24", HB),
         HB = case_when(grepl("Golden Jubilee", HB) ~ "Golden Jubilee", 
                        HB == "Glasgow" ~ "Greater Glasgow and Clyde",
                        TRUE ~ HB)) %>% 
  select(Indicator, Sub_indicator, From, To, Geography, HB, HB_indicator, 
         Target, Target_met, files_old) %>% 
  arrange(desc(files_old), Indicator, Sub_indicator, desc(To), Geography, HB) %>% 
  distinct(Indicator, Sub_indicator, From, To, Geography, HB, HB_indicator, 
           Target, Target_met) %>% 
  
  # remove other geographies for now
  filter(Geography %in% c("Country", "Health board"),
         !grepl("NHS|State Hospital|Golden Jubilee|Centre|Ambulance|Health", HB)) 


saveRDS(data, "data/indicator_data.rds")

# save xlsx for powerBI --------------------------------------------------------

indicator_levels <- c("sick",
                      "PDS", "PT", "CAMHS",
                      "outpatient", "TTG", "RTT", "diagnostic",
                      "DCE",
                      "cancerWT 31 day standard",
                      "cancerWT 62 day standard",
                      "AandE",
                      "smoke",
                      "GP Advance",
                      "GP Two_days",
                      "ante", "IVF",  
                      "CDI", "SAB", 
                      "drug", "ABI")


indicator_labels <- c("Sickness absence",
                      "Dementia post-diagnostic support",
                      "Psychological therapies",
                      "Child and adolescent mental health",
                      "12 weeks first outpatient appointment",
                      "Treatment time guarantee",
                      "18 weeks referral to treatment",
                      "Diagnostic waiting times",
                      "Detect Cancer Early",
                      "Cancer - 31 day standard",
                      "Cancer - 62 day standard",
                      "Accident and Emergency",
                      "Smoking cessation",
                      "GP Advance booking",
                      "GP 48 hr access",
                      "Early access to antenatal services",
                      "IVF",
                      "Clostridium difficile infections",
                      "SAB infections",
                      "Drug and alcohol treatment",
                      "Alcohol Brief Interventions")

# Health boards
HBs <- c("Scotland",
         "Ayrshire and Arran",
         "Borders",
         "Dumfries and Galloway",
         "Fife",
         "Forth Valley",
         "Grampian",
         "Greater Glasgow and Clyde",
         "Highland",    
         "Lanarkshire",
         "Lothian",
         "Orkney",
         "Shetland",
         "Tayside",
         "Western Isles")

data_prepped <- data  %>% 
  filter(HB %in% HBs,
         To >= dmy("01012015")) %>% 
  mutate(Indicator = ifelse(!is.na(Sub_indicator), paste(Indicator, Sub_indicator), Indicator),
         Indicator = factor(Indicator, levels = indicator_levels, labels = indicator_labels, ordered = TRUE),
         HB = factor(HB, levels = HBs, ordered = TRUE),
         Period = case_when(as.numeric(difftime(To, From), unit = "days") %in% c(1090:1460) ~ paste("Two years to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(729:731) ~ paste("Two years to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(360: 370) ~ paste("Year to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(88:95) ~ paste("Quarter to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(27:31) ~ paste("Month to", format(To, "%d %b %Y")))) %>% 
  
  select(Indicator, To, HB, HB_indicator, Target, Period)

# add in extra rows for the target

later <- data_prepped %>% 
  filter(.by = c(HB, Indicator),
         To == max(To)) %>% 
  mutate(To = dmy("01012035"),
         HB_indicator = NA,
         Period = NA)

earlier <- data_prepped %>% 
  filter(.by = c(HB, Indicator),
         To == min(To)) %>% 
  mutate(To = dmy("01012015"),
         HB_indicator = NA,
         Period = NA)
  
data_prepped %>% 
  rbind(later, earlier)  %>% 
  arrange(Indicator, desc(To), HB) %>% 
  writexl::write_xlsx("output/indicator_data.xlsx")

