# load -------------------------------------------------------------------------

library(tidyverse)

files <- list.files("data", ".rds", full.names = TRUE)
files <- files[!grepl("scraped", files)]
files <- files[!grepl("indicator_data", files)]

files_old <- readRDS("data/indicator_data.rds")

# combine and tidy all indicators -----------------------------------------------

data <- lapply(files, readRDS) %>% 
  bind_rows() %>% 
  
  # files_old is needed to overwrite (and not duplicate) any revised stats
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
  arrange(Indicator, Sub_indicator, Geography, HB, desc(To), desc(files_old)) %>% 
  
  # filter out any revised values
  distinct(Indicator, Sub_indicator, From, To, Geography, HB, Target, Target_met, .keep_all = TRUE) %>% 
  
  # remove other geographies for now
  filter(Geography %in% c("Country", "Health board"),
         !grepl("NHS|State Hospital|Golden Jubilee|Centre|Ambulance|Health", HB))


saveRDS(data, "data/indicator_data.rds")



# check if data was updated ----------------------------------------------------


files_old %>% 
  group_by(Indicator) %>% 
  filter(To == max(To)) %>% 
  distinct(Indicator, To) %>% 
  rename(Old = To) %>% 
  left_join(data %>% 
              group_by(Indicator) %>% 
              filter(To == max(To)) %>% 
              distinct(Indicator, To) %>% 
              rename(New = To), 
            by = "Indicator") %>% 
  mutate(diff = New - Old,
         latest_data = today() - New) %>% 
  arrange(latest_data) %>% 
  print()


