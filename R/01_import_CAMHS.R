# Child and Adolescent Mental Health (CAMHS) waiting times
# https://www.opendata.nhs.scot/dataset/child-and-adolescent-mental-health-waiting-times/resource/d43cae98-a620-4f24-a02f-a6451c297478

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
  mutate(.by = c(Month, HB),
         Month = ym(Month),
         HB_indicator = round2(Upto18 / All, 3)) %>% 
  mutate(.by = Month,
         Scotland_indicator = round2(sum(Upto18) / sum(All), 3)) %>% 
  select(-c(HBT, All, Upto18))

saveRDS(data, "data/CAMHS.rds")
