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
           labels = c(
             "Smoking cessation",
             "GP access\nadvance booking",
             "GB access\n48 hour access",
             "Dementia post-diagnostic\nsupport",
             "Psychological therapies\nwaiting times",
             "Child and adolescent mental\nhealth waiting times",
             "12 weeks first outpatient\nappointment",
             "Treatment time guarantee",
             "18 weeks referral\nto treatment",
             "Accident and Emergency\nwaiting times",
             "Detect Cancer Early",
             "Cancer waiting times\n62 day standard",
             "Cancer waiting times\n31 day standard",
             "IVF waiting times",
             "Early access to\nantenatal services",
             "Clostridium difficile\ninfections",
             "SAB infections",
             "Drug and alcohol treatment\nwaiting times",
             "Alcohol Brief Interventions"),
           ordered = TRUE)) %>% 
  mutate(Label = ifelse(From == min(From), as.character(Indicator), NA),
         Target_met = ifelse(Target_met, "Target met", "Target missed"),
         .by = Indicator) %>% 
  arrange(Indicator, desc(To)) 

chart <- ggplot(data) +
  geom_rect(aes(xmin = From, xmax = To, fill = Target_met),
            ymin = -Inf, ymax = Inf, 
            color = "white") +
  geom_text(aes(label = Label), x = dmy("01112015"), y = 0.5, hjust = 1,
            size = 4,
            lineheight = 0.95) +
  scale_x_date(limits = c(dmy("01012016", "01012025")),
               date_breaks = "years",
               date_labels = "%Y",
               expand = expansion(add = c(850, 30))) +
  scale_fill_manual(values = c("Target met" = unname(spcols["midblue"]),
                               "Target missed" = unname(spcols["orange"]))) +
  theme_minimal() +
  facet_wrap(~Indicator, ncol = 1) +
  theme(strip.text = element_blank(),
        legend.position = "top",
        legend.direction = "horizontal",
        legend.text = element_text(size = 14, family = "Arial"),
        legend.title = element_blank(),
        # Plot
        plot.margin = unit(c(1, 1, 1, 1), "lines"),
        #TEXT
        axis.text = element_text(size = 14, family = "Arial"),
        #TITLES
        plot.title = element_text(lineheight = 0.8, size = 21, family = "Arial", face = "bold"),
        plot.subtitle = element_text(size = 16, family = "Arial"),
        plot.caption = element_text(size = 14, family = "Arial"),
        plot.title.position = "plot",
        plot.caption.position = "plot",
        # Grid lines
        panel.grid = element_blank(),
        # Background blank
        plot.background = element_blank(),
        panel.background = element_blank(),
        panel.border = element_blank(),
        # Facet
        panel.spacing = unit(0.2, "lines")) +
  labs(title = "NHS Scotland performance against Local Delivery Plan (LDP) standards",
       subtitle = "Using monthly, quarterly and annual NHS Scotland statistics")

ggsave(plot = chart, "output/chart.png", dpi = 900, bg = "white", 
       width = 11, height = 10)
