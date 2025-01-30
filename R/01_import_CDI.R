# Clostridium Difficile infections

# under review?

# report: https://www.nss.nhs.scot/publications/quarterly-epidemiological-data-on-clostridioides-difficile-infection-escherichia-coli-bacteraemia-staphylococcus-aureus-bacteraemia-and-surgical-site-infection-in-scotland-july-to-september-q3-2024/
# https://www.opendata.nhs.scot/dataset/quarterly-epidemiological-data-on-healthcare-associated-infections

id <- "6d30b0c0-bdcf-4721-9d5c-bd7967c11bac"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", id, "&limit=100000")

data <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>%  
  select(Date, HB, HealthcareCdiffInfection, HealthcareTotalOccupiedBedDays) %>% 
  rename(Quarter = 1,
         Cases = 3,
         Bed_days = 4) %>% 
  mutate(Quarter = case_when(grepl("Q1", Quarter) ~ paste("03", str_sub(Quarter, 1, 4)),
                             grepl("Q2", Quarter) ~ paste("06", str_sub(Quarter, 1, 4)),
                             grepl("Q3", Quarter) ~ paste("09", str_sub(Quarter, 1, 4)),
                             grepl("Q4", Quarter) ~ paste("12", str_sub(Quarter, 1, 4))),
         Quarter = my(Quarter)) %>% 
  left_join(HB_lookup, by = c(HB = "HBT"), suffix = c("HB", "")) %>% 
  mutate(.by = Quarter,
         HB_indicator = round2(100000 * Cases / Bed_days, 1),
         Scotland_indicator = round2(100000 * sum(Cases)/sum(Bed_days), 1)) %>%
  select(Quarter, HB, HB_indicator, Scotland_indicator)

# save -------------------------------------------------------------------------

saveRDS(data, "data/CDI.rds")
