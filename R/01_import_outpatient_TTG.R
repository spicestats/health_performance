# 12 Weeks First Outpatient Appointment & Treatment Time Gurantee

id <- "4c091d26-1492-41e5-9577-832cbc1cd4cf"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", id, "&limit=100000")

data <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>% 
  select(QuarterEnding, HBT, PatientType, Specialty, NumberSeen, WaitedOver12Weeks) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  left_join(Specialty_lookup, by = c(Specialty = "Code")) %>% 
  filter(Name == "All specialities") %>% 
  mutate(Indicator = ifelse(PatientType == "New Outpatient", "outpatient", "TTG")) %>% 
  summarise(.by = c(QuarterEnding, HB, Indicator),
            NumberSeen = sum(NumberSeen, na.rm = TRUE),
            WaitedOver12Weeks = sum(WaitedOver12Weeks, na.rm = TRUE)) %>% 
  mutate(.by = c(QuarterEnding, Indicator),
         HB_indicator = case_when(HB == "Scotland" ~ round2(1 - sum(WaitedOver12Weeks)/sum(NumberSeen), 3),
                                  TRUE ~ round2(1 - WaitedOver12Weeks/NumberSeen, 3)),
         From = floor_date(ymd(QuarterEnding), unit = "quarter"),
         To = ymd(QuarterEnding),
         Target = case_when(Indicator == "outpatient" & HB == "Scotland" ~ 0.95,
                            Indicator == "outpatient" & HB != "Scotland" ~ 1,
                            Indicator == "TTG" ~ 1),
           Target_met = HB_indicator >= Target) %>% 
    select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
    arrange(desc(To), Indicator, HB)

saveRDS(data, "data/outpatient_TTG.rds")

