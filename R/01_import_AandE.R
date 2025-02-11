# Accident and Emergency waiting times

id <- "37ba17b1-c323-492c-87d5-e986aae9ab59"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                id, "&limit=100000")

data <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>% 
  select(Month, HBT, NumberOfAttendancesAll, NumberWithin4HoursAll) %>% 
  rename(Attendances = 3,
         Within4hrs = 4) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  summarise(.by = c(Month, HB),
            Within4hrs = sum(Within4hrs, na.rm = TRUE),
            Attendances = sum(Attendances, na.rm = TRUE)) %>% 
  mutate(.by = Month,
         HB_indicator = round2(Within4hrs/Attendances, 3),
         Scotland_indicator = round2(sum(Within4hrs)/sum(Attendances), 3)) %>% 
  pivot_longer(cols = c(HB_indicator, Scotland_indicator), names_to = "HB2", values_to = "HB_indicator") %>% 
  mutate(HB = ifelse(HB2 == "Scotland_indicator", "Scotland", HB),
         Indicator = "AandE",
         Target = ifelse(HB == "Scotland", 0.95, 0.98),
         Target_met = HB_indicator >= Target,
         From = ym(Month),
         To = ceiling_date(From, "month") - days(1)) %>% 
  select(From, To, Indicator, HB, HB_indicator, Target, Target_met)

saveRDS(data, "data/AandE.rds")
