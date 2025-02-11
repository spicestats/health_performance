library(tidyverse)
library(extrafont)

data <- readRDS("data/indicator_data.rds") %>% 
  filter(HB == "Scotland",
         !is.na(Target_met),
         From >= dmy("01-01-2016")) %>% 
  mutate(Indicator = ifelse(is.na(Sub_indicator), Indicator, 
                            paste0(Indicator, " - ", Sub_indicator)),
         Indicator = factor(Indicator, levels = c(
           "smoke",
           "GP - Advance", "GP - Two_days",
           "PDS", "PT", "CAMHS",
           "outpatient", "TTG", "RTT", 
           "AandE",
           "DCE",
           "cancerWT - 62 day standard", "cancerWT - 31 day standard",
           "IVF", "ante", 
           "CDI", "SAB", 
           "drug", "ABI"),
           ordered = TRUE)) %>% 
  mutate(Label = ifelse(From == min(From), as.character(Indicator), NA),
         Target_met = ifelse(Target_met, "Target met", "Target missed"),
         .by = Indicator) %>% 
  arrange(Indicator, desc(To)) 

ggplot(data) +
  geom_rect(aes(xmin = From, xmax = To, fill = Target_met),
            ymin = -Inf, ymax = Inf, 
            color = "white") +
  geom_text(aes(label = Label), x = dmy("01112015"), y = 0.5, hjust = 1) +
  scale_x_date(limits = c(dmy("01012016", "01062025")),
               date_breaks = "years",
               date_labels = "%Y",
               expand = expansion(add = c(800, 0))) +
  theme_minimal() +
  facet_wrap(~Indicator, ncol = 1) +
  theme(strip.text = element_blank(),
        legend.position = "top",
        legend.direction = "horizontal",
        legend.text = element_text(size = 14, family = "Arial"),
        #legend.background = element_blank(),
        legend.title = element_blank(),
        # Plot
        plot.margin = unit(c(1, 1, 1, 1), "lines"),
        #TEXT
        text = element_text(size = 14, family = "Arial"),
        #TITLES
        plot.title = element_text(lineheight = 0.8, size = 21, family = "Arial", face = "bold"),
        plot.subtitle = element_text(size = 16, family = "Arial"),
        plot.caption = element_text(size = 14, family = "Arial"),
        plot.title.position = "plot",
        plot.caption.position = "plot",
        # Grid lines
        panel.grid = element_blank(),
        #AXIS TEXT
        axis.text.y = element_text(size = 12, colour = "black", family = "Arial"),
        # Background blank
        plot.background = element_blank(),
        panel.background = element_blank(),
        panel.border = element_blank(),
        # Facet
        panel.spacing = unit(0.5, "lines"))

