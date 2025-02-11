# Psychological therapies waiting times

id <- "ca3f8e44-9a84-43d6-819c-a880b23bd278"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                id, "&limit=100000")

data <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>% 
  select(Month, HB, TotalPatientsSeen, NumberOfPatientsSeen0To18Weeks) %>% 
  rename(Total = 3,
         Within18 = 4,
         HBT = HB) %>% 
 left_join(HB_lookup, by = "HBT") %>% 
  mutate(From = ym(Month),
         To = ceiling_date(From, "month") - days(1),
         HB_indicator = round2(Within18/Total, 3),
         Target = 0.9,
         Target_met = HB_indicator >= Target,
         Indicator = "PT")  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, HB)

saveRDS(data, "data/PT.rds")
