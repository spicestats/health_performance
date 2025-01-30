# Drug and alcohol treatment waiting times
# https://publichealthscotland.scot/publications/national-drug-and-alcohol-treatment-waiting-times/national-drug-and-alcohol-treatment-waiting-times-1-july-2024-to-30-september-2024/


# more data available in dashboard:
# https://publichealthscotland.scot/publications/national-drug-and-alcohol-treatment-waiting-times/national-drug-and-alcohol-treatment-waiting-times-1-july-2024-to-30-september-2024/dashboard/


id <- "6a76fafd-e45c-43c5-96e6-c4f01bd33e96"

query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                id, "&limit=100000")

data <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>% 
  filter(SubstanceType == "All",
    grepl("All NHS", ADPName), 
         Measure == "Number") %>% 
  select(Quarter, HB, ServiceType, LDP_standard_waited_3_weeks_or_less, LDP_standard_waited_more_than_3_weeks) %>% 
  mutate(Quarter = case_when(grepl("Q1", Quarter) ~ paste("06", str_sub(Quarter, 4, 7)),
                             grepl("Q2", Quarter) ~ paste("09", str_sub(Quarter, 4, 7)),
                             grepl("Q3", Quarter) ~ paste("12", str_sub(Quarter, 4, 7)),
                             grepl("Q4", Quarter) ~ paste("03", str_sub(Quarter, 9, 12))),
         Quarter = my(Quarter)) %>% 
  left_join(HB_lookup, by = c(HB = "HBT"), suffix = c("HB", "")) %>% 
  filter(!is.na(HB)) %>% 
  summarise(.by = c(Quarter, HB),
            Within3weeks = sum(LDP_standard_waited_3_weeks_or_less, na.rm = TRUE),
            Longer = sum(LDP_standard_waited_more_than_3_weeks, na.rm = TRUE)) %>% 
  mutate(.by = Quarter,
         HB_indicator = round2(Within3weeks/(Within3weeks + Longer), 3),
         Scotland_indicator = round2(sum(Within3weeks)/sum(Within3weeks + Longer), 3)) %>% 
  select(Quarter, HB, HB_indicator, Scotland_indicator)

saveRDS(data, "data/drug.rds")
