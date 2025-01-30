# 12 Weeks First Outpatient Appointment
# https://www.opendata.nhs.scot/dataset/stage-of-treatment-waiting-times/resource/4c091d26-1492-41e5-9577-832cbc1cd4cf

id <- "4c091d26-1492-41e5-9577-832cbc1cd4cf"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", id, "&limit=100000")

data <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>% 
  select(QuarterEnding, HBT, PatientType, Specialty, NumberSeen, WaitedOver12Weeks) %>% 
  mutate(QuarterEnding = ymd(QuarterEnding)) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  left_join(Specialty_lookup, by = c(Specialty = "Code")) %>% 
  filter(PatientType == "New Outpatient",
         Name == "All specialities") %>% 
summarise(.by = c(QuarterEnding, HB),
          NumberSeen = sum(NumberSeen, na.rm = TRUE),
          WaitedOver12Weeks = sum(WaitedOver12Weeks, na.rm = TRUE)) %>% 
  mutate(.by = QuarterEnding,
         HB_indicator = round2(1 - WaitedOver12Weeks/NumberSeen, 3),
         Scotland_indicator = round2(1 - sum(WaitedOver12Weeks)/sum(NumberSeen), 3)) %>% 
  select(-c(NumberSeen, WaitedOver12Weeks)) %>% 
  filter(HB != "Scotland")

saveRDS(data, "data/outpatient.rds")
