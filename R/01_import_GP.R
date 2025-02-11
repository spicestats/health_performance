# GP access --------------------------------------------------------------------

data1920_advance_Scot <- readxl::read_xlsx("data/HACE_1920.xlsx", sheet = "1.5", range = "A7:C12") %>% 
  rename(Year = 1,
         Advance = 3) %>% 
  select(Year, Advance) %>% 
  mutate(Advance = Advance / 100)

data1920_48_Scot <- readxl::read_xlsx("data/HACE_1920.xlsx", sheet = "1.6", range = "A7:F9") %>% 
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
         Advance = 6) %>% 
  filter(Q == "If you ask to make an appointment with a doctor 3 or more working days in advance, does your GP practice allow you to?") %>% 
  select(HB, Advance) %>% 
  mutate(Advance = Advance / 100,
         HB = str_replace(HB, "NHS ", ""))

data2122_advance_Scot <- readxl::read_xlsx("data/HACE_2122.xlsx", sheet = "Scotland - PNN Questions") %>% 
  rename(Q = 4,
         Advance = 6) %>% 
  filter(Q == "If you ask to make an appointment with a doctor 3 or more working days in advance, does your GP practice allow you to?") %>% 
  select(Advance) %>% 
  mutate(Advance = Advance / 100)


data2122_48_HB <- readxl::read_xlsx("data/HACE_2122.xlsx", sheet = "HB - PNN Questions") %>% 
  rename(HB = 1,
         Q = 4,
         Two_days = 6) %>% 
  filter(Q == "The last time you needed to see or speak to a doctor or nurse from your GP practice quite urgently, how long did you wait?") %>% 
  select(HB, Two_days) %>% 
  mutate(Two_days = Two_days / 100,
         HB = str_replace(HB, "NHS ", ""))

data2122_48_Scot <- readxl::read_xlsx("data/HACE_2122.xlsx", sheet = "Scotland - PNN Questions") %>% 
  rename(Q = 4,
         Two_days = 6) %>% 
  filter(Q == "The last time you needed to see or speak to a doctor or nurse from your GP practice quite urgently, how long did you wait?") %>% 
  select(Two_days) %>% 
  mutate(Two_days = Two_days / 100)

data2122 <- data2122_advance_HB %>% 
  left_join(data2122_48_HB, by = "HB") %>% 
  pivot_longer(cols = c(Advance, Two_days), names_to = "Sub_indicator", 
               values_to = "HB_indicator") %>% 
  rbind(data2122_48_Scot %>% 
          cbind(data2122_advance_Scot) %>% 
          pivot_longer(cols = c(Advance, Two_days), names_to = "Sub_indicator", 
                       values_to = "HB_indicator") %>% 
          mutate(HB = "Scotland")
  ) %>% 
  mutate(Year = "2021/22")


data2324_advance <- readxl::read_xlsx("data/HACE_2324.xlsx", sheet = "Positive, Neutral or Negative") %>% 
  rename(Area_type = 1,
         HB = 3,
         Q = 6,
         Advance = 8) %>% 
  filter(Area_type %in% c("Scotland", "Health Board"),
         Q == "If you ask to make an appointment with a doctor 3 or more working days in advance, does your General Practice allow you to?") %>% 
  select(HB, Advance)

data2324_48 <- readxl::read_xlsx("data/HACE_2324.xlsx", sheet = "Information Questions") %>% 
  rename(Area_type = 1,
         HB = 3,
         Q = 6,
         R = 7,
         Two_days = 9) %>% 
  filter(Area_type %in% c("Scotland", "Health Board"),
         Q == "The last time you needed to see or speak to a doctor or a nurse from your General Practice quite urgently, how long did you wait?",
         R %in% c("I saw or spoke to a doctor or nurse on the same day",
                  "I saw or spoke to a doctor or nurse within 1 or 2 working days")) %>% 
  summarise(.by = HB,
            Two_days = sum(Two_days))

data2324 <- data2324_advance %>% 
  left_join(by = "HB",
            data2324_48) %>% 
  pivot_longer(cols = c(Advance, Two_days), names_to = "Sub_indicator", 
               values_to = "HB_indicator") %>% 
  mutate(Year = "2023/24",
         HB = str_replace(HB, "NHS ", "")) 

# combine all ------------------------------------------------------------------

data <- rbind(data2324, data2122, data1920) %>% 
  mutate(Indicator = "GP",
         From = dmy(paste("1 4 ", str_sub(Year, 1,4))),
         To = dmy(paste("31 3 ", str_sub(Year, 6, 7))),
         Target = 0.9,
         Target_met = HB_indicator >= Target)  %>% 
  select(From, To, HB, Indicator, Sub_indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, Sub_indicator, HB)

saveRDS(data, "data/GP.rds")



