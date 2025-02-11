# Clostridium Difficile infections & SAB (MRSA/MSSA) infections

id <- "6d30b0c0-bdcf-4721-9d5c-bd7967c11bac"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", id, "&limit=100000")

data <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>%  
  select(Date, HB, HealthcareCdiffInfection, HealthcareSaureusBacteraemia, HealthcareTotalOccupiedBedDays) %>% 
  rename(Quarter = 1,
         CDI = 3,
         SAB = 4,
         Bed_days = 5) %>% 
  mutate(Quarter = case_when(grepl("Q1", Quarter) ~ paste("03", str_sub(Quarter, 1, 4)),
                             grepl("Q2", Quarter) ~ paste("06", str_sub(Quarter, 1, 4)),
                             grepl("Q3", Quarter) ~ paste("09", str_sub(Quarter, 1, 4)),
                             grepl("Q4", Quarter) ~ paste("12", str_sub(Quarter, 1, 4))),
         Quarter = my(Quarter)) %>% 
  left_join(HB_lookup, by = c(HB = "HBT"), suffix = c("HB", "")) %>% 
  pivot_longer(cols = c(CDI, SAB), names_to = "Indicator", values_to = "Cases") %>% 
  mutate(.by = Quarter,
         HB_indicator = round2(1000 * Cases / Bed_days, 3),
         Scotland_indicator = round2(1000 * sum(Cases)/sum(Bed_days), 3))  %>% 
  pivot_longer(cols = c(HB_indicator, Scotland_indicator), names_to = "HB2", values_to = "HB_indicator") %>% 
  mutate(HB = ifelse(HB2 == "Scotland_indicator", "Scotland", HB),
         To = ceiling_date(Quarter, "month") - days(1),
         From = floor_date(To, unit = "quarter"),
         Target = ifelse(Indicator == "SAB", 0.24, 0.32),
         Target_met = HB_indicator <= Target)  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, HB) %>% 
  distinct()


# save -------------------------------------------------------------------------

saveRDS(data, "data/CDI_SAB.rds")

