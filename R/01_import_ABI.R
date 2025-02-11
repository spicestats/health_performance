# Alcohol Brief Interventions

file <- "data/2020-09-29-alcoholbriefinterventions-tables.xlsx"

abis <- readxl::read_xlsx(file, sheet = "Table1", range = "A5:K21") %>% 
  rename(HB = 1)
targets <- readxl::read_xlsx(file, sheet = "Table1", range = "M5:V21") %>% 
  mutate(HB = abis$HB) %>% 
  pivot_longer(cols = 1:10, values_to = "Target", names_to = "Year")

data <- abis %>% 
  pivot_longer(cols = 2:11, values_to = "HB_indicator", names_to = "Year") %>% 
  left_join(targets, by = c("Year", "HB")) %>% 
  filter(!is.na(HB)) %>% 
  mutate(Indicator = "ABI",
         Target_met = HB_indicator >= Target,
         Year = str_replace(Year, "2015/163", "2015/16"),
         From = dmy(paste("01 04", str_sub(Year, 1, 4))),
         To = dmy(paste0("31 03 20", str_sub(Year, -2, -1))),
         HB = str_replace(HB, "NHS ", ""),
         HB = str_replace(HB, "&", "and"),
         HB = str_replace(HB, "2", ""))  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, HB)

saveRDS(data, "data/ABI.rds")


