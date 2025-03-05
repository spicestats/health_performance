# Child and Adolescent Mental Health (CAMHS) waiting times

id <- "7a2fe10d-1339-41c1-a2f2-a469644fd619"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                id, "&limit=100000")

data <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>% 
  select(Month, HB, TotalPatientsSeen, NumberOfPatientsSeen0To18Weeks) %>% 
  rename(HBT = HB,
         All = 3,
         Upto18 = 4) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  filter(!is.na(All)) %>% 
  
  # turn monthly into quarterly data (as it's reported)
  mutate(Month = ym(Month),
         Quarter = ceiling_date(Month, "quarter") - days(1)) %>% 
  summarise(.by = c(Quarter, HB),
            HB_indicator = round2(sum(Upto18, na.rm = TRUE) / sum(All, na.rm = TRUE), 3)) %>% 
  mutate(From = floor_date(Quarter, "quarter"),
         To = Quarter,
         Indicator = "CAMHS",
         Target = 0.9,
         Target_met = HB_indicator >= Target)   %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  distinct() %>% 
  arrange(desc(To), Indicator, HB)

saveRDS(data, "data/CAMHS.rds")
