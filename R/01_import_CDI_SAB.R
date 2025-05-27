# Clostridium Difficile infections & SAB (MRSA/MSSA) infections


# latest updates ---------------------------------------------------------------

id <- "6d30b0c0-bdcf-4721-9d5c-bd7967c11bac"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                id, "&limit=100000")

opendata <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>% 
  select(Date, HB, HealthcareCdiffInfection, HealthcareSaureusBacteraemia, HealthcareTotalOccupiedBedDays) %>% 
  rename(Quarter = 1,
         HBT = 2,
         CDI = 3,
         SAB = 4,
         Beds = 5) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  pivot_longer(cols = c(CDI, SAB), names_to = "Indicator", values_to = "Count") %>% 
  arrange(Indicator, HB, Quarter) %>% 
  mutate(.by = c(HB, Indicator),
         Count_annual = Count + lag(Count) + lag(Count, 2) + lag(Count, 3),
         Beds_annual = Beds + lag(Beds) + lag(Beds, 2) + lag(Beds, 3)) %>% 
  mutate(.by = c(Quarter, HB, Indicator),
         HB_indicator = Count_annual / Beds_annual * 1000) %>% 
  mutate(.by = c(Quarter, Indicator),
         Scotland_indicator = sum(Count_annual) / sum(Beds_annual) * 1000) %>% 
  pivot_longer(cols = c(HB_indicator, Scotland_indicator), names_to = "HB2", values_to = "HB_indicator") %>% 
  mutate(HB = ifelse(HB2 == "Scotland_indicator", "Scotland", HB),
         Quarter = case_when(grepl("Q1", Quarter) ~ paste("03", str_sub(Quarter, 1, 4)),
                             grepl("Q2", Quarter) ~ paste("06", str_sub(Quarter, 1, 4)),
                             grepl("Q3", Quarter) ~ paste("09", str_sub(Quarter, 1, 4)),
                             grepl("Q4", Quarter) ~ paste("12", str_sub(Quarter, 1, 4))),
         Quarter = my(Quarter),
         To = ceiling_date(Quarter, "month") - days(1),
         From = To - years(1) + days(1),
         HB_indicator = round2(HB_indicator, 3),
         Target = ifelse(Indicator == "SAB", 0.24, 0.32),
         Target_met = HB_indicator <= Target)  %>% 
  filter(!is.na(HB_indicator))  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  distinct()


# older data -------------------------------------------------------------------
# from spreadsheets 

file <- "data/sab-cdi-ecoli-ssi-infections-q3-2024-data-v10 (1).xlsm"

data <- readxl::read_excel(file, sheet = "trend data") %>% 
  mutate(Indicator = str_sub(ref, 1, 3),
         To = unlist(str_extract_all(ref, "\\d+")),
         q = as.numeric(str_sub(To, 5, 6)),
         y = str_sub(To, 1, 4),
         To = case_when(q == 4 ~ dmy(paste("31 12", y)),
                          q == 3 ~ dmy(paste("30 09", y)),
                          q == 2 ~ dmy(paste("30 06", y)),
                          q == 1 ~ dmy(paste("31 03", y))),
         HB = str_split_i(ref, "04|03|02|01", -1),
         ref2 = str_sub(ref, 4, 5)) %>% 
  filter(Indicator %in% c("CDI", "SAB"),
         ref2 == "HC",
         To < dmy("01122017")) %>% 
 arrange(Indicator, HB, To) %>% 
  mutate(.by = c(HB, Indicator),
         Count_annual = cases + lag(cases) + lag(cases, 2) + lag(cases, 3),
         Beds_annual = OCBD + lag(OCBD) + lag(OCBD, 2) + lag(OCBD, 3)) %>% 
  mutate(.by = c(To, HB, Indicator),
         HB_indicator = Count_annual / Beds_annual * 1000) %>% 
  mutate(From = To - years(1) + days(1),
         HB_indicator = round2(HB_indicator, 3),
         Target = ifelse(Indicator == "SAB", 0.24, 0.32),
         Target_met = HB_indicator <= Target) %>% 
  filter(!is.na(HB_indicator))  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  distinct()


# combine ----------------------------------------------------------------------

combined <- opendata %>% 
  rbind(data) %>% 
  distinct() %>% 
  arrange(desc(To), Indicator, HB)

# save -------------------------------------------------------------------------

saveRDS(combined, "data/CDI_SAB.rds")

