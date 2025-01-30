# 18 weeks referral to treatment
# report: https://publichealthscotland.scot/publications/show-all-releases?id=20545
# https://www.opendata.nhs.scot/dataset/18-weeks-referral-to-treatment/resource/f2598c24-bf00-4171-b7ef-a469bbacbf6c

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
         Scotland_indicator = round2(sum(Within18Weeks)/sum(Within18Weeks + Over18Weeks), 3)) %>% 
  select(Month, HB, HB_indicator, Scotland_indicator)

saveRDS(data, "data/RTT.rds")
