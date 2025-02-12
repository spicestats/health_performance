# GP access --------------------------------------------------------------------

# note that for the 48 hour indicator, the LDP definition is different from the
# intuitive definition. Until 2019/20, both sets of stats were published. Since
# then, I believe, only the intuitive definition. 

# "For the LDP Standard, individuals are considered to have been able to obtain 
# two working day access if they were offered an appointment within two working 
# days, even if they then turned the appointment down."

data1920_advance_Scot <- readxl::read_xlsx("data/HACE_1920.xlsx", sheet = "1.5", range = "A7:C12") %>% 
  rename(Year = 1,
         Advance = 3) %>% 
  select(Year, Advance) %>% 
  mutate(Advance = Advance / 100)

data1920_48_Scot <- readxl::read_xlsx("data/HACE_1920.xlsx", sheet = "1.6", range = "A29:F30") %>% 
  pivot_longer(cols = 2:6, names_to = "Year", values_to = "Two_days") %>% 
  summarise(.by = Year,
            Two_days = sum(Two_days / 100))

data1920 <- data1920_advance_Scot %>% 
  left_join(data1920_48_Scot, by = "Year") %>% 
  pivot_longer(cols = c(Advance, Two_days), names_to = "Sub_indicator", values_to = "HB_indicator") %>% 
  mutate(HB = "Scotland")


data2122_advance_HB <- readxl::read_xlsx("data/HACE_2122.xlsx", sheet = "HB - PNN Questions") %>% 
  rename(HB = 1,
         Q = 4,
         HB_indicator = 6) %>% 
  filter(Q == "If you ask to make an appointment with a doctor 3 or more working days in advance, does your GP practice allow you to?") %>% 
  select(HB, HB_indicator) %>% 
  mutate(HB_indicator = HB_indicator / 100,
         HB = str_replace(HB, "NHS ", ""))

data2122_advance_Scot <- readxl::read_xlsx("data/HACE_2122.xlsx", sheet = "Scotland - PNN Questions") %>% 
  rename(Q = 4,
         HB_indicator = 6) %>% 
  filter(Q == "If you ask to make an appointment with a doctor 3 or more working days in advance, does your GP practice allow you to?") %>% 
  select(HB_indicator) %>% 
  mutate(HB_indicator = HB_indicator / 100,
         HB = "Scotland")

data2122 <- data2122_advance_HB %>% 
  rbind(data2122_advance_Scot) %>% 
  mutate(HB = "Scotland",
         Year = "2021/22",
         Sub_indicator = "Advance")


data2324 <- readxl::read_xlsx("data/HACE_2324.xlsx", sheet = "Positive, Neutral or Negative") %>% 
  rename(Area_type = 1,
         HB = 3,
         Q = 6,
         HB_indicator = 8) %>% 
  filter(Area_type %in% c("Scotland", "Health Board"),
         Q == "If you ask to make an appointment with a doctor 3 or more working days in advance, does your General Practice allow you to?") %>% 
  select(HB, HB_indicator) %>% 
  mutate(Sub_indicator = "Advance",
         Year = "2023/24",
         HB = str_replace(HB, "NHS ", "")) 

# combine all ------------------------------------------------------------------

data <- rbind(data2324, data2122, data1920) %>% 
  mutate(Indicator = "GP",
         From = dmy(paste("1 4 ", str_sub(Year, 1,4))),
         To = dmy(paste("31 3 ", str_sub(Year, 6, 7))),
         Target = 0.9,
         Target_met = HB_indicator >= Target)  %>% 
  select(From, To, HB, Indicator, Sub_indicator, HB_indicator, Target, Target_met) %>% 

    # add the 2021/22 figure manually in
  rbind(data.frame(From = dmy("01042021"),
                   To = dmy("31032022"),
                   HB = "Scotland",
                   Indicator = "GP",
                   Sub_indicator = "Two_days",
                   HB_indicator = 0.89, # from SG LDP webpage
                   Target = 0.9) %>% 
          mutate(Target_met = HB_indicator > Target)) %>% 
  arrange(desc(To), Indicator, Sub_indicator, HB)

saveRDS(data, "data/GP.rds")



