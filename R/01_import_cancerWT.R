# Cancer waiting times
# report: https://publichealthscotland.scot/publications/cancer-waiting-times/cancer-waiting-times-1-july-to-30-september-2024/
# https://www.opendata.nhs.scot/dataset/cancer-waiting-times

# 62 day standard --------------------------------------------------------------

id <- "23b3bbf7-7a37-4f86-974b-6360d6748e08"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", id, "&limit=100000")

data62 <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>%  
  select(Quarter, HB, CancerType, NumberOfEligibleReferrals62DayStandard, NumberOfEligibleReferralsTreatedWithin62Days) %>% 
  filter(CancerType == "All Cancer Types") %>% 
  rename(Number = 4,
         Treated62 = 5) %>% 
   mutate(Quarter = case_when(grepl("Q1", Quarter) ~ paste("03", str_sub(Quarter, 1, 4)),
                              grepl("Q2", Quarter) ~ paste("06", str_sub(Quarter, 1, 4)),
                              grepl("Q3", Quarter) ~ paste("09", str_sub(Quarter, 1, 4)),
                              grepl("Q4", Quarter) ~ paste("12", str_sub(Quarter, 1, 4))),
          Quarter = my(Quarter)) %>% 
   left_join(HB_lookup, by = c(HB = "HBT"), suffix = c("T", "")) %>% 
   filter(HB != "Scotland") %>% 
  summarise(.by = c(Quarter, HB),
            Number = sum(Number),
            Treated62 = sum(Treated62)) %>% 
  mutate(.by = Quarter,
         HB_indicator = round2(Treated62 / Number, 3),
         Scotland_indicator = round2(sum(Treated62)/sum(Number), 3)) %>%
  select(Quarter, HB, HB_indicator, Scotland_indicator)

# 31 day standard --------------------------------------------------------------

id <- "58527343-a930-4058-bf9e-3c6e5cb04010"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", id, "&limit=100000")

data31 <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>%  
  select(Quarter, HBT, CancerType, NumberOfEligibleReferrals31DayStandard, NumberOfEligibleReferralsTreatedWithin31Days) %>% 
  filter(CancerType == "All Cancer Types") %>% 
  rename(Number = 4,
         Treated31 = 5) %>% 
  mutate(Quarter = case_when(grepl("Q1", Quarter) ~ paste("03", str_sub(Quarter, 1, 4)),
                             grepl("Q2", Quarter) ~ paste("06", str_sub(Quarter, 1, 4)),
                             grepl("Q3", Quarter) ~ paste("09", str_sub(Quarter, 1, 4)),
                             grepl("Q4", Quarter) ~ paste("12", str_sub(Quarter, 1, 4))),
         Quarter = my(Quarter)) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  filter(HB != "Scotland") %>% 
  summarise(.by = c(Quarter, HB),
            Number = sum(Number),
            Treated31 = sum(Treated31)) %>% 
  mutate(.by = Quarter,
         HB_indicator = round2(Treated31 / Number, 3),
         Scotland_indicator = round2(sum(Treated31)/sum(Number), 3)) %>%
  select(Quarter, HB, HB_indicator, Scotland_indicator)

# save -------------------------------------------------------------------------

saveRDS(data62, "data/cancerWT62.rds")
saveRDS(data31, "data/cancerWT31.rds")


