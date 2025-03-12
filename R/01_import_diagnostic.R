
# HBs 2019 - now ---------------------------------------------------------------

id1 <- "10dfe6f3-32de-4039-84c2-7e7794a06b31"
query1 <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                 id1, "&limit=200000")

data1 <- content(httr::GET(query1))$result$records %>% 
  bind_rows() 

df1 <- data1 %>% 
  filter(DiagnosticTestDescription %in% c("Cystoscopy", "Lower Endoscopy", "CT",
                                          "MRI", "Ultrasound", "Colonoscopy",
                                          "Upper Endoscopy", "Barium Studies")) %>% 
  select(MonthEnding, HBT, WaitingTime, NumberOnList) %>% 
  rename(Month = 1,
         Number = 4) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  mutate(To = ymd(Month),
         From = floor_date(To, "month"),
         Waiting = ifelse(WaitingTime %in% c("0-7 days", "8-14 days", "15-21 days", "22-28 days",
                                             "29-35 days", "36-42 days"), Number, 0)) %>% 
  summarise(.by = c(From, To, , HB),
            HB_indicator = round2(sum(Waiting) / sum(Number), 3),
            
            Target = 1,
            Target_met = HB_indicator >= Target,
            Indicator = "diagnostic")  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) 


# Scotland 2019 - now ----------------------------------------------------------

id2 <- "df75544f-4ba1-488d-97c7-30ab6258270d"
query2 <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                 id2, "&limit=100000")

data2 <- content(httr::GET(query2))$result$records %>% 
  bind_rows() 

df2 <- data2 %>% 
  filter(DiagnosticTestDescription %in% c("Cystoscopy", "Lower Endoscopy", "CT",
                                          "MRI", "Ultrasound", "Colonoscopy",
                                          "Upper Endoscopy", "Barium Studies")) %>% 
  select(MonthEnding, Country, WaitingTime, NumberOnList) %>% 
  rename(Month = 1,
         HBT = 2,
         Number = 4) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  mutate(To = ymd(Month),
         From = floor_date(To, "month"),
         Waiting = ifelse(WaitingTime %in% c("0-7 days", "8-14 days", "15-21 days", "22-28 days",
                                             "29-35 days", "36-42 days"), Number, 0)) %>% 
  summarise(.by = c(From, To, , HB),
            HB_indicator = round2(sum(Waiting) / sum(Number), 3),
            
            Target = 1,
            Target_met = HB_indicator >= Target,
            Indicator = "diagnostic")  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met)

# HB data 2007 - 2019 ----------------------------------------------------------

id3 <- "624e2299-f28f-4e7b-a4f6-a33ef14ac04c"
query3 <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                 id3, "&limit=100000")

data3 <- content(httr::GET(query3))$result$records %>% 
  bind_rows() 

df3 <- data3 %>% 
  filter(DiagnosticTestDescription %in% c("Cystoscopy", "Lower Endoscopy", "CT",
                                          "MRI", "Ultrasound", "Colonoscopy",
                                          "Upper Endoscopy", "Barium Studies")) %>% 
  select(MonthEnding, HBT2014, NumberOnList, NumberWaitingOverSixWeeks) %>% 
  rename(Month = 1,
         HBT = 2,
         Number = 3,
         WaitingOver = 4) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  summarise(.by = c(HB, Month),
            HB_indicator = round2(1 - sum(WaitingOver) / sum(Number), 3)) %>% 
  mutate(To = ymd(Month),
         From = floor_date(To, "month"),
         Target = 1,
         Target_met = HB_indicator >= Target,
         Indicator = "diagnostic")  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met)  %>% 
  
  # remove latest value as it's revised in the newer dataset
  filter(To != ymd("2019-03-31"))


# Scotland data 2007 - 2019 ----------------------------------------------------------

id4 <- "d61e6e61-3fa6-4b14-8312-2c76d17094bb"
query4 <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                 id4, "&limit=100000")

data4 <- content(httr::GET(query4))$result$records %>% 
  bind_rows() 

df4 <- data4 %>% 
  filter(DiagnosticTestDescription %in% c("Cystoscopy", "Lower Endoscopy", "CT",
                                          "MRI", "Ultrasound", "Colonoscopy",
                                          "Upper Endoscopy", "Barium Studies")) %>% 
  select(MonthEnding, Country, NumberOnList, NumberWaitingOverSixWeeks) %>% 
  rename(Month = 1,
         HBT = 2,
         Number = 3,
         WaitingOver = 4) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  summarise(.by = c(HB, Month),
            HB_indicator = round2(1 - sum(WaitingOver) / sum(Number), 3)) %>% 
  mutate(To = ymd(Month),
         From = floor_date(To, "month"),
         Target = 1,
         Target_met = HB_indicator >= Target,
         Indicator = "diagnostic")  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  
  # remove latest value as it's revised in the newer dataset
  filter(To != ymd("2019-03-31"))

comb <- rbind(df1, df2, df3, df4)  %>% 
  arrange(desc(To), Indicator, HB)
  


saveRDS(comb, "data/diagnostic.rds")
