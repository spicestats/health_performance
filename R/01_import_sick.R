
data <- readxl::read_xlsx("data/sickness_absences.xlsx", skip = 1) %>% 
  rename(HB = 3,
         Year = 4,
         HB_indicator = 5) %>% 
  mutate(Year = ymd(Year),
         Geography = ifelse(Region == "National & Special", "National & special board", "Health board"),
         HB = ifelse(Region == "National & Special", HB, str_replace(HB, "NHS ", "")),
         HB_indicator = round2(HB_indicator, 3),
         Target = 0.04,
         Target_met = HB_indicator <= Target,
         Indicator = "sick",
         To = Year,
         From = dmy(paste("1 4", year(Year)-1)))  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, HB)

saveRDS(data, "data/sick.rds")
