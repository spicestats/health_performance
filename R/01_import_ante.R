# Early access to antenatal services

id <- "edc632af-4a14-4917-81c8-ce6bb5fcbdc5"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                id, "&limit=100000")

data <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>% 
  select(FinancialYear, CA, SIMDQuintile, BookedBy12wks, Maternities) %>%
  left_join(CA_to_HB_lookup, by = "CA") %>% 
  mutate(HBName = ifelse(CA == "S92000003", "Scotland", HBName),
         SIMDQuintile = as.numeric(SIMDQuintile)) %>% 
  
  filter(!is.na(SIMDQuintile)) %>%  
  summarise(.by = c(FinancialYear, HBName, SIMDQuintile, BookedBy12wks),
            Maternities =  sum(Maternities)) %>%  
  arrange(FinancialYear, HBName, SIMDQuintile, desc(BookedBy12wks)) %>% 
  summarise(.by = c(FinancialYear, HBName, SIMDQuintile),
            HB_indicator =  Maternities[1] / sum(Maternities)) %>% 
  filter(.by = c(FinancialYear, HBName),
         HB_indicator == min(HB_indicator)) %>% 
  rename(Year = FinancialYear,
         HB = HBName) %>% 
  mutate(From = dmy(paste("1 4 ", str_sub(Year, 1, 4))),
         To =  dmy(paste("31 3 ", str_sub(Year, 6, 7))),
         Indicator = "ante",
         Target = 0.8,
         Target_met = HB_indicator >= Target,
         HB_indicator = round2(HB_indicator, 3))   %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, HB)

saveRDS(data, "data/ante.rds")

