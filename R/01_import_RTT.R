# 18 weeks referral to treatment

id <- "f2598c24-bf00-4171-b7ef-a469bbacbf6c"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", id, "&limit=100000")

data <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>%  
  select(Month, HBT, Within18Weeks, Over18Weeks, Performance) %>% 
  mutate(Month = ym(Month)) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  filter(HB != "Scotland") %>% 
  mutate(.by = Month,
         HB_indicator = round2(Within18Weeks / (Within18Weeks + Over18Weeks), 3),
         HB_indicator = ifelse(is.nan(HB_indicator), NA, HB_indicator),
         Scotland_indicator = round2(sum(Within18Weeks)/sum(Within18Weeks + Over18Weeks), 3)) %>% 
  pivot_longer(cols = c(HB_indicator, Scotland_indicator), names_to = "HB2", values_to = "HB_indicator") %>% 
  mutate(HB = ifelse(HB2 == "Scotland_indicator", "Scotland", HB),
         From = Month,
         To = ceiling_date(From, "month") - days(1),
         Indicator = "RTT",
         Target = 0.9,
         Target_met = HB_indicator >= Target) %>% 
  select(From, To, Indicator, HB, HB_indicator, Target, Target_met) %>% 
  distinct() %>% 
  arrange(desc(To), HB)


saveRDS(data, "data/RTT.rds")
