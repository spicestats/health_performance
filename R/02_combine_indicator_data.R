library(tidyverse)

files <- list.files("data", ".rds", full.names = TRUE)
files <- files[!grepl("scraped", files)]

data <- lapply(files, readRDS) %>% 
  bind_rows() %>% 
  mutate(Geography = case_when(HB == "Scotland" ~ "Country",
                               !is.na(Geography) ~ Geography,
                               TRUE ~ "Health board"),
         HB = str_replace(HB, "&", "and"),
         HB = ifelse(HB == "NHS24", "NHS 24", HB),
         HB = case_when(grepl("Golden Jubilee", HB) ~ "Golden Jubilee", 
                        HB == "Glasgow" ~ "Greater Glasgow and Clyde",
                        TRUE ~ HB)) %>% 
  select(Indicator, Sub_indicator, From, To, Geography, HB, HB_indicator, 
         Target, Target_met) %>% 
  arrange(Indicator, Sub_indicator, desc(To), Geography, HB) %>% 
  distinct() %>% 
  
  # remove other geographies for now
  filter(Geography == c("Country", "Health board"),
         !grepl("NHS|State Hospital|Golden Jubilee|Centre|Ambulance|Health", HB)) 


saveRDS(data, "data/indicator_data.rds")

# save xlsx for powerBI --------------------------------------------------------

indicators1 <- c("TTG",
                 "RTT",
                 "outpatient",
                 "AandE",
                 "CAMHS",
                 "PT",
                 "cancerWT 62 day standard",
                 "cancerWT 31 day standard",
                 "PDS",
                 "drug",
                 "ante",
                 "IVF")

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
         "Island Boards",
         "Lanarkshire",
         "Lothian",
         "Orkney",
         "Shetland",
         "Tayside",
         "Western Isles")

data  %>% 
  filter(Indicator %in% indicators1,
         HB %in% HBs) %>% 
  mutate(Indicator = ifelse(!is.na(Sub_indicator), paste(Indicator, Sub_indicator), Indicator),
         Indicator = factor(Indicator, levels = indicators_01, ordered = TRUE),
         HB = factor(HB, levels = HBs, ordered = TRUE)) %>% 
  select(-Sub_indicator) %>% 
  arrange(Indicator, desc(To), HB) %>% 
  
  
  writexl::write_xlsx("output/indicator_data_1.xlsx")

