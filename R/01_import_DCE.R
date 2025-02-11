# Detect Cancer Early

# pre 2022 data
lookup <- readxl::read_excel("data/dce_staging_trends.xlsm", sheet = "Lookups", range = "A1:B30",
                             col_names = c("code", "name"))


data <- readxl::read_excel("data/dce_staging_trends.xlsm", sheet = "Data DCE") %>% 
  select(1, 2, 12) %>% 
  rename(code = 1, 
         stage1 = 2, 
         total = 3) %>% 
  mutate(HBcode = str_sub(code, 1, 1),
         cancer = str_sub(code, 2, 2),
         Yearcode = str_sub(code, 3, 4)) %>% 
  filter(cancer == 4) %>% 
  left_join(lookup %>% rename(HB = name), by = c(HBcode = "code")) %>% 
  left_join(lookup %>% rename(Year = name), by = c(Yearcode = "code")) %>% 
  mutate(Year = str_sub(Year, -9, -1),
         From = dmy(paste("1 1 ", str_sub(Year, 1, 4))),
         To = dmy(paste("31 12 ", str_sub(Year, -4, -1))),
         Indicator = "DCE",
         HB_indicator = stage1 / total,
         HB = str_replace(HB, "NHS Board", "") %>% str_squish(),
         Baseline = ifelse(From == dmy("01-01-2010"), HB_indicator, NA),
         Baseline = max(Baseline, na.rm = TRUE),
         Target = Baseline * 1.25,
         Target_met = HB_indicator >= Target,
         .by = HB)   %>% 
  filter(!(HB %in% c("NOSCAN", "SCAN", "WOSCAN"))) %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, HB)


# 2022 data

lookup22 <- readxl::read_excel("data/staging_trends.xlsm", sheet = "Lookups",
                             col_names = c("code", "name")) %>% 
  head(22)


data22 <- readxl::read_excel("data/staging_trends.xlsm", sheet = "Data DCE") %>% 
  select(1, 2, 12) %>% 
  rename(code = 1, 
         stage1 = 2, 
         total = 3) %>% 
  mutate(HBcode = str_sub(code, 1, 1),
         cancer = str_sub(code, 2, 2),
         Yearcode = str_sub(code, 3, 4)) %>% 
  filter(cancer == 4) %>% 
  left_join(lookup22 %>% rename(HB = name), by = c(HBcode = "code")) %>% 
  left_join(lookup22 %>% rename(Year = name), by = c(Yearcode = "code")) %>%
  filter(Year == "2022") %>% 
  mutate(From = dmy(paste("1 1 ", Year)),
         To = dmy(paste("31 12 ", Year)),
         Indicator = "DCE",
         HB_indicator = stage1 / total,
         HB = str_replace(HB, "NHS Board", "") %>% str_squish()) %>% 
  left_join(data %>% select(HB, Target) %>% distinct(), by = "HB") %>% 
  mutate(Target_met = HB_indicator >= Target)   %>% 
  filter(!(HB %in% c("NOSCAN", "SCAN", "WOSCAN"))) %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  rbind(data) %>% 
  arrange(desc(To), Indicator, HB)

saveRDS(data22, "data/DCE.rds")
