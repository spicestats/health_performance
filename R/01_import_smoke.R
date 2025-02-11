# Smoking cessation

file <- "data/2024-12-17-nhs-stop-smoking-services-data-tablesv.xlsx"

deprived_12wk_quits <- readxl::read_xlsx(file,
                                         sheet = "Data Tables",
                                         range = "A13818:J13833") %>% 
  pivot_longer(cols = 2:10, names_to = "Year", values_to = "HB_indicator")

targets <- readxl::read_xlsx(file,
                             sheet = "Data Tables",
                             range = "A13872:J13887") %>% 
  pivot_longer(cols = 2:10, names_to = "Year", values_to = "Target")

data <- deprived_12wk_quits %>% 
  left_join(targets, by = c("Year", "NHS Board")) %>% 
  rename(HB = 1) %>% 
  mutate(From = ymd(paste0(substr(Year, 1, 4), "-04-01")),
         To = ymd(paste0(substr(Year, 6, 9), "-03-31")),
         Indicator = "smoke",
         Target_met = HB_indicator >= Target)  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, HB)

saveRDS(data, "data/smoke.rds")
