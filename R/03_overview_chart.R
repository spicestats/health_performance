library(tidyverse)
library(extrafont)
library(patchwork)
source("R/00_config.R")

# Colours ----------------------------------------------------------------------

spcols <- c(purple = "#500778",
            darkblue = "#003057",
            midblue = "#007DBA",
            brightblue = "#00A9E0",
            jade = "#108765",
            green = "#568125",
            magenta = "#B0008E",
            mauve = "#B884CB",
            red = "#E40046",
            orange = "#E87722",
            gold = "#CC8A00",
            mustard = "#DAAA00")

data <- readRDS("data/indicator_data.rds") %>% 
  filter(HB == "Scotland",
         !is.na(Target_met),
         From >= dmy("01-04-2015"),
         Indicator != "RTT",
         Indicator != "ABI",
         Indicator != "DCE") %>% 
  mutate(Indicator = factor(Indicator, levels = c(
    "sick",
    "PDS", "PT", "CAMHS",
    "outpatient", "TTG", "RTT", 
    "diagnostic",
    "DCE",
    "cancerWT",
    "AandE",
    "smoke",
    "GP",
    "ante", "IVF",  
    "CDI", "SAB", 
    "drug", "ABI"),
    labels = c(
      "Sickness absence",
      "Dementia post-diagnostic\nsupport",
      "Psychological therapies\nwaiting times",
      "Child and adolescent mental\nhealth waiting times",
      "12 weeks first outpatient\nappointment",
      "Treatment time guarantee",
      "18 weeks referral\nto treatment",
      "Diagnostic treatment times",
      "Detect Cancer Early",
      "Cancer waiting times",
      "Accident and Emergency\nwaiting times",
      "Smoking cessation",
      "GP",
      "Early access to\nantenatal services",
      "IVF waiting times",
      "Clostridium difficile\ninfections",
      "SAB infections",
      "Drug and alcohol treatment\nwaiting times",
      "Alcohol Brief Interventions"),
    ordered = TRUE),
    Sub_indicator = case_when(Sub_indicator == "Advance" ~ "advance booking",
                              Sub_indicator == "Two_days" ~ "48 hour access",
                              TRUE ~ Sub_indicator),
    Sub_indicator = ifelse(is.na(Sub_indicator), as.character(Indicator), 
                           paste0(as.character(Indicator), " ", Sub_indicator)),
    Sub_indicator = fct_relevel(Sub_indicator, "GP 48 hour access", after = 13L)
    ) %>% 
  
  mutate(Label = case_when(From == min(From) ~ Sub_indicator),
         Label = case_when(Label == "Cancer waiting times 62 day standard" ~ "62 day standard",
                           Label == "GP 48 hour access" ~ "48 hour access",
                           TRUE ~ Label),

         Target_met = ifelse(Target_met, "Target met", "Target missed"),
         Target_met = factor(Target_met),
         .by = Indicator) %>% 
  arrange(Indicator, desc(To), Target_met) 


charts <- lapply(unique(data$Indicator), function(i) {
  
  data %>% 
    filter(Indicator == i) %>% 
    ggplot() +
    geom_rect(aes(xmin = From, xmax = To, fill = Target_met),
              ymin = -Inf, ymax = Inf, 
              color = "white", linewidth = 0.4) +
    geom_text(aes(label = Label), x = dmy("01022015"), y = 0.5, hjust = 1,
              size = 5,
              lineheight = 0.95) +
    
    scale_x_date(limits = c(dmy("01042015", "01012026")),
                 breaks = dmy(paste("1-1-", c(2015:2026))),
                 date_labels = "%Y",
                 expand = expansion(add = c(1700, 30))) +
    scale_fill_manual(values = c("Target missed" = unname(spcols["darkblue"]),
                                 "Target met" = unname(spcols["gold"])),
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

for (i in 1:15) {charts[[i]] <- charts[[i]] + theme(axis.text = element_blank())}

plot <- wrap_plots(charts, ncol = 1) +
  plot_layout(guides = "collect") & 
  theme(plot.margin = unit(c(0, 0.2, 0, 0), "cm"),
        legend.position = "top")

#plot

ggsave(plot = plot, "output/chart.png", dpi = 700, bg = "white", 
       width = 12, height = 10)

