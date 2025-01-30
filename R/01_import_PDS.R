# Dementia post-diagnostic support

# manual update of urls required!

# report: https://publichealthscotland.scot/publications/dementia-post-diagnostic-support/dementia-post-diagnostic-support-local-delivery-plan-standard-figures-to-202122/
url <- "https://publichealthscotland.scot/media/27287/2024-05-28_dementia-pds_excel-tables_final.xlsx"

download.file(url, "data/PDS.xlsx", mode = "wb")

data <- readxl::read_xlsx("data/PDS.xlsx", sheet = "Tab 7", range = "B5:H20") %>% 
  pivot_longer(cols = 2:7, values_to = "HB_indicator", names_to = "Year") %>% 
  rename(HB = 1) %>% 
  mutate(Year = str_sub(Year, 1, 7),
         HB_indicator = round2(HB_indicator, 2),
         Scotland_indicator = case_when(HB == "Scotland" ~ HB_indicator)) %>% 
  mutate(.by = Year,
         Scotland_indicator = max(Scotland_indicator, na.rm = TRUE)) %>% 
  filter(HB != "Scotland")

saveRDS(data, "data/PDS.rds")
