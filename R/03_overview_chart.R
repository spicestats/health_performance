library(tidyverse)
library(extrafont)
library(patchwork)
source("R/00_config.R")

data <- readRDS("data/indicator_data.rds") %>% 
  filter(HB == "Scotland",
         !is.na(Target_met),
         From >= dmy("01-06-2015")) %>% 
  mutate(Indicator = factor(Indicator, levels = c(
    "smoke",
    "sick",
    "PDS", "PT", "CAMHS",
    "outpatient", "TTG", "RTT", 
    "AandE",
    "GP",
    "DCE",
    "cancerWT",
    "IVF", "ante", 
    "CDI", "SAB", 
    "drug", "ABI"),
    labels = c(
      "Smoking cessation",
      "Sickness absence",
      "Dementia post-diagnostic\nsupport",
      "Psychological therapies\nwaiting times",
      "Child and adolescent mental\nhealth waiting times",
      "12 weeks first outpatient\nappointment",
      "Treatment time guarantee",
      "18 weeks referral\nto treatment",
      "Accident and Emergency\nwaiting times",
      "GP",
      "Detect Cancer Early",
      "Cancer waiting times",
      "IVF waiting times",
      "Early access to\nantenatal services",
      "Clostridium difficile\ninfections",
      "SAB infections",
      "Drug and alcohol treatment\nwaiting times",
      "Alcohol Brief Interventions"),
    ordered = TRUE),
    Sub_indicator = case_when(Sub_indicator == "Advance" ~ "advance booking",
                              Sub_indicator == "Two_days" ~ "48 hour access",
                              TRUE ~ Sub_indicator),
    Sub_indicator = ifelse(is.na(Sub_indicator), as.character(Indicator), 
                           paste0(as.character(Indicator), " ", Sub_indicator))) %>% 
  
  mutate(Label = ifelse(From == min(From), as.character(Sub_indicator), NA),
         Label = ifelse(Label == "Cancer waiting times 62 day standard", "62 day standard", Label),
         Target_met = ifelse(Target_met, "Target met", "Target missed"),
         Target_met = factor(Target_met),
         .by = Indicator) %>% 
  arrange(Indicator, desc(To), Target_met) 

indicators <- unique(data$Indicator)

charts <- lapply(indicators, function(i) {
  
  data %>% 
    filter(Indicator == i) %>% 
    ggplot() +
    geom_rect(aes(xmin = From, xmax = To, fill = Target_met),
              ymin = -Inf, ymax = Inf, 
              color = "white") +
    geom_text(aes(label = Label), x = dmy("01052015"), y = 0.5, hjust = 1,
              size = 5,
              lineheight = 0.95) +
    
    scale_x_date(limits = c(dmy("01062015", "01012025")),
                 breaks = dmy(paste("1-1-", c(2015:2025))),
                 date_labels = "%Y",
                 expand = expansion(add = c(1600, 30))) +
    scale_fill_manual(values = c("Target missed" = unname(spcols["orange"]),
                                 "Target met" = unname(spcols["midblue"])),
                      guide = guide_legend(reverse = TRUE),
                      drop = FALSE)  +
    theme_minimal() +
    facet_wrap(~Sub_indicator, ncol = 1) +
    theme(strip.text = element_blank(),
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
          panel.spacing = unit(0, "lines"))
  
})

for (i in 1:17) {charts[[i]] <- charts[[i]] + theme(axis.text = element_blank())}

plot <- wrap_plots(charts, ncol = 1) +
  plot_layout(guides = "collect") & 
  theme(plot.margin = unit(c(0, 0.2, 0, 0), "cm"),
        legend.position = "top")

#plot

ggsave(plot = plot, "output/chart.png", dpi = 700, bg = "white", 
       width = 11, height = 10)

