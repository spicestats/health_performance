# Sickness absences


# data from dashboard

# Scotland-level data
data_sc <- readxl::read_xlsx("data/sickness_absences_scotland_from_dashboard.xlsx",
                             range = "A3:B14") %>% 
  rename(Year = 1,
         HB_indicator = 2) %>% 
  mutate(HB = "Scotland",
         Region = NA,
         Country = NA)


data <- readxl::read_xlsx("data/sickness_absences.xlsx", skip = 1) %>% 
  rename(HB = 3,
         Year = 4,
         HB_indicator = 5) %>% 
  rbind(data_sc) %>% 
  mutate(Year = ymd(Year),
         HB = case_when(Region == "National & Special" ~ HB, 
                        TRUE ~ str_replace(HB, "NHS ", "")),
         HB_indicator = round2(HB_indicator, 3),
         Target = 0.04,
         Target_met = HB_indicator <= Target,
         Indicator = "sick",
         To = Year,
         From = dmy(paste("1 4", year(Year)-1)))  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, HB)


saveRDS(data, "data/sick.rds")

