library(tidyverse)

files <- list.files("data", ".rds", full.names = TRUE)
files <- files[!grepl("scraped", files)]

data <- lapply(files, readRDS) %>% 
  bind_rows() %>% 
  mutate(Geography = case_when(!is.na(Geography) ~ Geography,
                               HB == "Scotland" ~ "Scotland",
                               TRUE ~ "Health board"),
         HB = str_replace(HB, "&", "and"),
         HB = ifelse(HB == "NHS24", "NHS 24", HB)) %>% 
  select(Indicator, Sub_indicator, From, To, Geography, HB, HB_indicator, 
         Target, Target_met) %>% 
  arrange(Indicator, Sub_indicator, desc(To), Geography, HB) %>% 
  distinct()

saveRDS(data, "data/indicator_data.rds")
