# IVF waiting times

# IVF centres

id <- "c0ab7f62-0ad1-4890-8a15-0346143a1b06"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                id, "&limit=100000")

data_centre <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>% 
  filter(IVFCentre != "Scotland") %>% 
  select(Quarter, IVFCentre, NumberScreenedWithin52WeeksPc) %>% 
  rename(HB_indicator = 3,
         HB = IVFCentre) %>% 
  mutate(Quarter = case_when(grepl("Q1", Quarter) ~ paste("03", str_sub(Quarter, 1, 4)),
                             grepl("Q2", Quarter) ~ paste("06", str_sub(Quarter, 1, 4)),
                             grepl("Q3", Quarter) ~ paste("09", str_sub(Quarter, 1, 4)),
                             grepl("Q4", Quarter) ~ paste("12", str_sub(Quarter, 1, 4))),
         Quarter = my(Quarter),
         HB_indicator = HB_indicator / 100,
         Geography = "IVF Centre") 

# health boards

id <- "f40db799-158e-427e-89f5-3f7887c14971"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                id, "&limit=100000")

data <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>% 
  select(Quarter, HBR, NumberScreenedWithin52WeeksPc) %>% 
  rename(HB_indicator = 3) %>% 
  mutate(Quarter = case_when(grepl("Q1", Quarter) ~ paste("03", str_sub(Quarter, 1, 4)),
                             grepl("Q2", Quarter) ~ paste("06", str_sub(Quarter, 1, 4)),
                             grepl("Q3", Quarter) ~ paste("09", str_sub(Quarter, 1, 4)),
                             grepl("Q4", Quarter) ~ paste("12", str_sub(Quarter, 1, 4))),
         Quarter = my(Quarter),
         HB_indicator = HB_indicator / 100) %>% 
  filter(HBR != "") %>% 
  left_join(HB_lookup, by = c("HBR" = "HBT")) %>% 
  mutate(Geography = "Health board") %>% 
  select(Quarter, Geography, HB, HB_indicator) %>% 
  rbind(data_centre) %>% 
  mutate(Geography = ifelse(HB == "Scotland", "Country", Geography),
         To = ceiling_date(Quarter, "month") - days(1),
         From = floor_date(To, "quarter"),
         Indicator = "IVF",
         Target = 0.9,
         Target_met = HB_indicator >= Target) %>% 
  select(From, To, Geography, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, Geography, HB) %>% 
  mutate(Target_met = ifelse(is.na(Target_met) & HB == "Scotland" & To < dmy("1 12 2015"), "TRUE", Target_met),
         Target_met = as.logical(Target_met))

saveRDS(data, "data/IVF.rds")

