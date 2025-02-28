library(tidyverse)
library(extrafont)
library(patchwork)
source("R/00_config.R")

data <- readRDS("data/indicator_data.rds") %>% 
  mutate(Indicator = ifelse(!is.na(Sub_indicator), paste(Indicator, Sub_indicator), Indicator))

# set time range for chart
start_date <- dmy("01012015")
end_date <- dmy("01012026")

# Health boards
HBs <- c("Scotland",
         "Ayrshire and Arran",
         "Borders",
         "Dumfries and Galloway",
         "Fife",
         "Forth Valley",
         "Grampian",
         "Greater Glasgow and Clyde",
         "Highland",    
         "Island Boards",
         "Lanarkshire",
         "Lothian",
         "Orkney",
         "Shetland",
         "Tayside",
         "Western Isles")

# group indicators
indicators_infections <- c("CDI", "SAB")
indicators_other <- c("sick", "smoke")
indicators_dead <- c("ABI", "DCE") 

# 'at least x %' targets
indicators_01 <- c("TTG",
                   "RTT",
                   "outpatient",
                   "AandE",
                   "CAMHS",
                   "PT",
                   "cancerWT 62 day standard",
                   "cancerWT 31 day standard",
                   "PDS",
                   "drug",
                   "ante",
                   "IVF")

# HB breakdown available
indicators_GP <- c("GP Advance", "GP Two_days")


data %>% 
  filter(HB != "Scotland",
         Indicator %in% indicators_01,
         # not enough HB-level data in GP indicators
         !grepl("GP", Indicator)
  ) %>% 
  mutate(Indicator = factor(Indicator, levels = indicators_01, ordered = TRUE),
         HB = factor(HB, levels = HBs, ordered = TRUE)) %>% 
  ggplot(aes(x = To)) +
  geom_ribbon(aes(xmin = start_date, xmax = end_date,
                  ymin = -Inf, ymax = Target), 
              fill = spcols["darkblue"], alpha = 0.8, show.legend = FALSE) +
  geom_ribbon(aes(xmin = start_date, xmax = end_date, 
                  ymin = Target, ymax = Inf), 
              fill = spcols["gold"], alpha = 1, show.legend = FALSE) +
  geom_line(aes(y = HB_indicator, group = HB, colour = Geography), linewidth = 0.8, colour = "white") +
  facet_wrap(~Indicator, ncol = 3) +
  theme_minimal() +
  scale_x_date(limits = c(start_date, end_date)) +
  scale_y_continuous(limits = c(0.2, 1.2)) +
  theme(axis.title = element_blank(),
        axis.text = element_blank(),
        panel.grid = element_blank()) 
