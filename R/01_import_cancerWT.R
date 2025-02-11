# Cancer waiting times

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

data <- rbind(data62 %>% mutate(Sub_indicator = "62 day standard"),
              data31 %>% mutate(Sub_indicator = "31 day standard")) %>% 
  pivot_longer(cols = c(HB_indicator, Scotland_indicator), names_to = "HB2", values_to = "HB_indicator") %>% 
  mutate(HB = ifelse(HB2 == "Scotland_indicator", "Scotland", HB),
         Indicator = "cancerWT",
         To = ceiling_date(Quarter, "month") - days(1),
         From = floor_date(To, "quarter"),
         Target = 0.95,
         Target_met = HB_indicator >= Target)  %>% 
  select(From, To, HB, Indicator, Sub_indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, HB) %>% 
  distinct()

# save -------------------------------------------------------------------------

saveRDS(data, "data/cancerWT.rds")



