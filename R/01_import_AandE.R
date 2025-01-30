# Accident and Emergency waiting times
# https://www.opendata.nhs.scot/dataset/monthly-accident-and-emergency-activity-and-waiting-times/resource/37ba17b1-c323-492c-87d5-e986aae9ab59

id <- "37ba17b1-c323-492c-87d5-e986aae9ab59"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                id, "&limit=100000")

data <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>% 
  select(Month, HBT, NumberOfAttendancesAll, NumberWithin4HoursAll) %>% 
  rename(Attendances = 3,
         Within4hrs = 4) %>% 
  mutate(Month = ym(Month)) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  summarise(.by = c(Month, HB),
            Within4hrs = sum(Within4hrs, na.rm = TRUE),
            Attendances = sum(Attendances, na.rm = TRUE)) %>% 
  mutate(.by = Month,
         HB_indicator = round2(Within4hrs/Attendances, 3),
         Scotland_indicator = round2(sum(Within4hrs)/sum(Attendances), 3)) %>% 
  select(-c(Within4hrs, Attendances))

saveRDS(data, "data/AandE.rds")
