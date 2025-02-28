# Drug and alcohol treatment waiting times


# latest updates ---------------------------------------------------------------

id <- "6a76fafd-e45c-43c5-96e6-c4f01bd33e96"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                id, "&limit=100000")

opendata <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>% 
  filter(SubstanceType == "All",
         Measure == "Number") %>% 
  select(Quarter, HB, LDP_standard_waited_3_weeks_or_less, LDP_standard_waited_more_than_3_weeks) %>% 
  rename(HBT = 2,
         Met = 3,
         Missed = 4) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  mutate(HB = ifelse(HBT == "NA", "Scotland", HB)) %>% 
  
  # aggregate to HB
  summarise(.by = c(Quarter, HB),
            Met = sum(Met, na.rm = TRUE),
            Missed = sum(Missed, na.rm = TRUE)) %>% 

  mutate(To = case_when(grepl("Q1", Quarter) ~ paste("30 06", str_sub(Quarter, 4, 7)),
                        grepl("Q2", Quarter) ~ paste("30 09", str_sub(Quarter, 4, 7)),
                        grepl("Q3", Quarter) ~ paste("31 12", str_sub(Quarter, 4, 7)),
                        grepl("Q4", Quarter) ~ paste("31 03", str_sub(Quarter, 9, 12))),
         To = dmy(To),
         From = floor_date(To, "quarter"),
         Indicator = "drug",
         HB_indicator = round2(Met / (Missed + Met), 3),
         Target = 0.9,
         Target_met = HB_indicator >= Target) %>% 
  select(From, To, Indicator, HB, HB_indicator, Target, Target_met)


# older data -------------------------------------------------------------------

# more data available in dashboard:
# https://publichealthscotland.scot/publications/national-drug-and-alcohol-treatment-waiting-times/national-drug-and-alcohol-treatment-waiting-times-1-july-2024-to-30-september-2024/dashboard/

file <- "data/Completed Waits_data.csv"

# create manually more quarters where all we know is that the target has been met

# Define the start and end dates
start_date <- ymd("2015-04-01")
end_date <- ymd("2018-09-30")

# Generate a sequence of dates for the first day of each quarter
from_dates <- seq.Date(from = start_date, to = end_date, by = "quarter") %>%
  floor_date(unit = "quarter")

# Generate a sequence of dates for the last day of each quarter
to_dates <- seq.Date(from = start_date, to = end_date, by = "quarter") %>%
  ceiling_date(unit = "quarter") - days(1)


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
  
  # add manually 3 more quarters from
  # https://publichealthscotland.scot/publications/national-drug-and-alcohol-treatment-waiting-times/national-drug-and-alcohol-treatment-waiting-times-1-october-31-december-2019/
  rbind(data.frame(From = c(dmy("01102018"), dmy("01012019"), dmy("01042019")),
                   To = c(dmy("31122018"), dmy("31032019"), dmy("30062019")),
                   HB_indicator = c(0.93495, 0.93188, 0.93189),
                   HB = "Scotland",
                   Target = 0.9,
                   Indicator = "drug") %>% 
          mutate(Target_met = HB_indicator >= Target)) %>% 
  
  # create manually more quarters where all we know is that the target has been met
  # (from https://www.gov.scot/publications/nhsscotland-performance-against-ldp-standards/pages/drug-and-alcohol-treatment-waiting-times/)
 rbind(data.frame(From = from_dates, 
                  To = to_dates,
                  HB_indicator = NA,
                  HB = "Scotland",
                  Target = 0.9,
                  Indicator = "drug",
                  Target_met = TRUE))

# combine ----------------------------------------------------------------------

combined <- opendata %>% 
  rbind(data) %>% 
  distinct() %>% 
  arrange(desc(To), Indicator, HB)
  
saveRDS(combined, "data/drug.rds")
