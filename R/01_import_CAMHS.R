# Child and Adolescent Mental Health (CAMHS) waiting times

id <- "d43cae98-a620-4f24-a02f-a6451c297478"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                id, "&limit=100000")

data <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>% 
  select(Month, HB, TotalPatientsWaiting, NumberOfPatientsWaiting0To18Weeks) %>% 
  rename(HBT = HB,
         All = 3,
         Upto18 = 4) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  filter(!is.na(All)) %>% 
  mutate(.by = c(Month, HB),
         Month = ym(Month),
         HB_indicator = round2(Upto18 / All, 3)) %>% 
  mutate(.by = Month,
         Scotland_indicator = round2(sum(Upto18) / sum(All), 3)) %>% 
  pivot_longer(cols = c(HB_indicator, Scotland_indicator), names_to = "HB2", values_to = "HB_indicator") %>% 
  mutate(HB = ifelse(HB2 == "Scotland_indicator", "Scotland", HB),
         From = Month,
         To = ceiling_date(From, "month") - days(1),
         Indicator = "CAMHS",
         Target = 0.9,
         Target_met = HB_indicator >= Target)   %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  distinct() %>% 
  arrange(desc(To), Indicator, HB)

saveRDS(data, "data/CAMHS.rds")
