# Dementia post-diagnostic support

# manual update of url required!
url <- "https://publichealthscotland.scot/media/27287/2024-05-28_dementia-pds_excel-tables_final.xlsx"

download.file(url, "data/PDS.xlsx", mode = "wb")

data <- readxl::read_xlsx("data/PDS.xlsx", sheet = "Tab 7", range = "B5:H20") %>% 
  pivot_longer(cols = 2:7, values_to = "HB_indicator", names_to = "Year") %>% 
  rename(HB = 1) %>% 
  mutate(HB = str_replace(HB, "NHS ", ""),
         Year = str_sub(Year, 1, 7),
         HB_indicator = round2(HB_indicator, 3),
         From = dmy(paste("1 4",str_sub(Year, 1, 4))),
         To = dmy(paste("31 3",str_sub(Year, 6, 7))),
         Indicator = "PDS",
         Target = 1,
         Target_met = HB_indicator >= Target)  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, HB)

saveRDS(data, "data/PDS.rds")
