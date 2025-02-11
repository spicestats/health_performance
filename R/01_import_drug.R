# Drug and alcohol treatment waiting times

# more data available in dashboard:
# https://publichealthscotland.scot/publications/national-drug-and-alcohol-treatment-waiting-times/national-drug-and-alcohol-treatment-waiting-times-1-july-2024-to-30-september-2024/dashboard/

file <- "data/Completed Waits_data.csv"

data <- read_delim(file) %>% 
  filter(`Substance type` == "All",
         Measure == "Number") %>% 
  select('Quarter ending', Location, 'Waited 3 weeks or less', 'Total number of waits') %>% 
  rename(Quarter = 1,
         HB = 2, 
         HB_indicator = 3,
         Total = 4) %>% 
  summarise(.by = c(Quarter, HB),
            HB_indicator = round2(sum(HB_indicator, na.rm = TRUE) / sum(Total, na.rm = TRUE), 3)) %>% 
  filter(grepl("Scotland|NHS", HB)) %>% 
  mutate(Quarter = dmy(Quarter),
         HB = str_replace(HB, "NHS ", ""),
         HB = str_replace(HB, "&", "and"),
         To = Quarter,
         From = floor_date(To, "quarter"),
         Indicator = "drug",
         Target = 0.9,
         Target_met = HB_indicator >= Target) %>% 
  distinct()  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, HB)

saveRDS(data, "data/drug.rds")
