# Clostridium Difficile infections & SAB (MRSA/MSSA) infections

file <- "data/sab-cdi-ecoli-ssi-infections-q3-2024-data-v10 (1).xlsm"

data <- readxl::read_excel(file, sheet = "trend data") %>% 
  mutate(Indicator = str_sub(ref, 1, 3),
         To = unlist(str_extract_all(ref, "\\d+")),
         q = as.numeric(str_sub(To, 5, 6)),
         y = str_sub(To, 1, 4),
         From = case_when(q == 4 ~ dmy(paste("01 10", y)),
                          q == 3 ~ dmy(paste("01 07", y)),
                          q == 2 ~ dmy(paste("01 04", y)),
                          q == 1 ~ dmy(paste("01 01", y))),
         To = ceiling_date(From, "quarter") - days(1),
         HB = str_split_i(ref, "04|03|02|01", -1),
         ref2 = str_sub(ref, 4, 5),
         HB_indicator = rate / 100,
         Target = ifelse(Indicator == "SAB", 0.24, 0.32),
         Target_met = HB_indicator <= Target) %>% 
  filter(Indicator %in% c("CDI", "SAB"),
         ref2 == "HC") %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, HB)


# save -------------------------------------------------------------------------

saveRDS(data, "data/CDI_SAB.rds")

