library(tidyverse)
library(scales)

files <- list.files("data", ".rds", full.names = TRUE)
files <- files[!grepl("scraped", files)]
files <- files[!grepl("indicator_data", files)]

files_old <- readRDS("data/indicator_data.rds")

data <- lapply(files, readRDS) %>% 
  bind_rows() %>% 
  
  # files_old is needed to overwrite (and not d uplicate) any revised stats
  mutate(files_old = FALSE) %>% 
  rbind(files_old %>% mutate(files_old = TRUE)) %>% 
  mutate(Geography = case_when(HB == "Scotland" ~ "Country",
                               !is.na(Geography) ~ Geography,
                               TRUE ~ "Health board"),
         HB = str_replace(HB, "&", "and"),
         HB = ifelse(HB == "NHS24", "NHS 24", HB),
         HB = case_when(grepl("Golden Jubilee", HB) ~ "Golden Jubilee", 
                        HB == "Glasgow" ~ "Greater Glasgow and Clyde",
                        TRUE ~ HB)) %>% 
  select(Indicator, Sub_indicator, From, To, Geography, HB, HB_indicator, 
         Target, Target_met, files_old) %>% 
  arrange(desc(files_old), Indicator, Sub_indicator, desc(To), Geography, HB) %>% 
  distinct(Indicator, Sub_indicator, From, To, Geography, HB, HB_indicator, 
           Target, Target_met) %>% 
  
  # remove other geographies for now
  filter(Geography %in% c("Country", "Health board"),
         !grepl("NHS|State Hospital|Golden Jubilee|Centre|Ambulance|Health", HB))


saveRDS(data, "data/indicator_data.rds")

# save xlsx for powerBI --------------------------------------------------------

indicator_levels <- c("sick",
                      "PDS", "PT", "CAMHS",
                      "outpatient", "TTG", "RTT", "diagnostic",
                      "DCE",
                      "cancerWT 31 day standard",
                      "cancerWT 62 day standard",
                      "AandE",
                      "smoke",
                      "GP Advance",
                      "GP Two_days",
                      "ante", "IVF",  
                      "CDI", "SAB", 
                      "drug", "ABI")

indicator_labels <- c("Sickness absence",
                      "Dementia post-diagnostic support",
                      "Psychological therapies",
                      "Child and adolescent mental health",
                      "12 weeks first outpatient appointment",
                      "Treatment time guarantee",
                      "18 weeks referral to treatment",
                      "Diagnostic waiting times",
                      "Detect Cancer Early",
                      "Cancer - 31 day standard",
                      "Cancer - 62 day standard",
                      "Accident and Emergency",
                      "Smoking cessation",
                      "GP Advance booking",
                      "GP 48 hr access",
                      "Early access to antenatal services",
                      "IVF",
                      "Clostridium difficile infections",
                      "SAB infections",
                      "Drug and alcohol treatment",
                      "Alcohol Brief Interventions")

indicator_definitions <- c(
  sick = "NHS Boards should achieve a sickness absence rate of 4% or less.",
  PDS = "People newly diagnosed with dementia should be offered a minimum of one year's post-diagnostic support, coordinated by a named link worker.",
  PT = "90% of patients should begin Psychological Therapy based treatment within 18 weeks of referral.", 
  CAMHS = "90% of young people should begin treatment for specialist Child and Adolescent Mental Health services within 18 weeks of referral.",
  outpatient = "95% of new outpatients should receive an outpatient appointment within 12 weeks. Health boards should work towards 100 per cent.",
  TTG = "All patients should receive their treatment within 12 weeks.", 
  RTT = "90% of planned / elective patients should begin treatment within 18 weeks of referral.", 
  diagnostic = "All patients should receive key diagnostic tests / investigations (upper & lower endoscopy, colonoscopy, cytoscopy, CT scan, MRI scan, barium studies, non-obstetric ultrasound) within 6 weeks.",
  DCE = "Increase the proportion of people diagnosed and treated in the first stage of breast, colorectal and lung cancer by 25%.",
  "cancerWT 31 day standard" = "95% of all patients diagnosed with cancer should begin treatment within 31 days of decision to treat.",
  "cancerWT 62 day standard" = "95% of those referred urgently with a suspicion of cancer should begin treatment within 62 days of receipt of referral.",
  AandE = "95% of people attending A&E should be seen, admitted, discharged or transferred within 4 hours. NHS Boards should work towards 98%.",
  smoke = "NHS Boards should sustain and embed successful smoking quits at 12 weeks post quit, in the 40% most deprived areas (60% in the Island Boards).",
  "GP Advance" = "GPs should provide advance booking for at least 90% of patients.",
  "GP Two_days" = "GPs should provide 48 hour access to an appropriate member of the GP team for at least 90% of patients.",
  ante = "At least 80% of pregnant women in each Scottish Index of Multiple Deprivation quintile should have booked for antenatal care by the 12th week of gestation.", 
  IVF = "90% of eligible patients should begin IVF treatment within 12 months of referral.",  
  CDI = "NHS Boards' rate of clostridium difficile infections in patients aged 15 and over should be 0.32 cases or less per 1,000 total occupied bed days. Standard currently under review.",
  SAB = "NHS Boards' rate of SAB (staphylococcus aureus bacteraemia (including MRSA)) cases should be 0.24 or less per 1,000 acute occupied bed days. Standard currently under review.", 
  drug = "90% of clients should wait no longer than 3 weeks from referral received to appropriate drug or alcohol treatment that supports their recovery.",
  ABI = "NHS Boards should sustain and embed alcohol brief interventions in 3 priority settings (primary care, A&E, antenatal) and broaden delivery in wider settings.")

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
         "Lanarkshire",
         "Lothian",
         "Orkney",
         "Shetland",
         "Tayside",
         "Western Isles",
         "Island Boards")

data_prepped <- data  %>% 
  filter(HB %in% HBs,
         To >= dmy("01012015")) %>% 
  mutate(Indicator = ifelse(!is.na(Sub_indicator), paste(Indicator, Sub_indicator), Indicator),
         Indicator = factor(Indicator, levels = indicator_levels, labels = indicator_labels, ordered = TRUE),
         HB = factor(HB, levels = HBs, ordered = TRUE),
         HB_order = match(HB, HBs)) %>% 
  select(Indicator, From, To, HB, HB_indicator, Target, Target_met, HB_order)

# add in extra rows for the target

later <- data_prepped %>% 
  filter(.by = c(HB, Indicator),
         To == max(To)) %>% 
  mutate(To = dmy("01012035"),
         HB_indicator = NA)

earlier <- data_prepped %>% 
  filter(.by = c(HB, Indicator),
         To == min(To)) %>% 
  mutate(To = dmy("01012015"),
         HB_indicator = NA)

final <- data_prepped %>% 
  rbind(later, earlier)  %>% 
  mutate(Period = case_when(as.numeric(difftime(To, From), unit = "days") %in% c(1090:1460) ~ paste("Two years to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(729:731) ~ paste("Two years to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(360: 370) ~ paste("Year to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(88:95) ~ paste("Quarter to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(27:31) ~ paste("Month to", format(To, "%d %b %Y"))),
         Target_met = ifelse(is.na(HB_indicator), NA, Target_met),
         Target_col = case_when(Target_met ~ "#568125", 
                                !Target_met ~ "#E40046"),
         Formatted_value = case_when(Indicator %in% c("Smoking cessation", "Alcohol Brief Interventions") ~ comma(HB_indicator, 1),
                                     Indicator %in% c("SAB infections", "Clostridium difficile infections") ~ comma(HB_indicator, 0.01),
                                     TRUE ~ percent(HB_indicator, 0.1)),
         Target_label = case_when(!is.na(HB_indicator) & Indicator %in% c("Smoking cessation", "Alcohol Brief Interventions") & Target_met ~ paste0(Formatted_value, " - value meets standard (at least ", comma(Target, 1), ")"),
                                  !is.na(HB_indicator) & Indicator %in% c("Smoking cessation", "Alcohol Brief Interventions") & !Target_met ~ paste0(Formatted_value, " - value does not meet standard (at least ", comma(Target, 1), ")"),
                                  !is.na(HB_indicator) & Indicator %in% c("SAB infections", "Clostridium difficile infections") & Target_met ~ paste0(Formatted_value, " - value meets standard (at most ", Target, ")"),
                                  !is.na(HB_indicator) & Indicator %in% c("SAB infections", "Clostridium difficile infections") & !Target_met ~ paste0(Formatted_value, " - value does not meet standard (at most ", Target, ")"),
                                  !is.na(HB_indicator) & Target == 1 & Target_met ~ paste0(percent(HB_indicator, 0.1), " - value meets standard (", percent(Target, 1), ")"),
                                  !is.na(HB_indicator) & Target == 1 & !Target_met ~ paste0(percent(HB_indicator, 0.1), " - value does not meet standard (", percent(Target, 1), ")"),
                                  !is.na(HB_indicator) & Target_met & HB_indicator <= Target ~ paste0(percent(HB_indicator, 0.1), " - value meets standard (at most ", percent(Target, 1), ")"),
                                  !is.na(HB_indicator) & Target_met & HB_indicator >= Target ~  paste0(percent(HB_indicator, 0.1), " - value meets standard (at least ", percent(Target, 1), ")"),
                                  !is.na(HB_indicator) & !Target_met & HB_indicator <= Target ~  paste0(percent(HB_indicator, 0.1), " - value does not meet standard (at least ", percent(Target, 1), ")"),
                                  !is.na(HB_indicator) & !Target_met & HB_indicator >= Target ~   paste0(percent(HB_indicator, 0.1), " - value does not meet standard (at most ", percent(Target, 1), ")")),
         Defs = factor(Indicator, levels = indicator_labels, labels = indicator_definitions)) %>% 
  arrange(Indicator, desc(To), HB) %>% 
  select(-From, -Target_met)


writexl::write_xlsx(final, "output/indicator_data.xlsx")

# checks -----------------------------------------------------------------------
# for most indicators, values and targets should not exceed 1; when they do, it's
# usually a data error or an aggregation error

final %>% 
  filter(Target > 1 | HB_indicator > 1,
         !(Indicator %in% c("Smoking cessation",
                            "Clostridium difficile infections",
                            "SAB infections",
                            "Alcohol Brief Interventions")))

# check order
final %>% 
  select(HB, HB_order) %>% 
  distinct() %>% 
  arrange(HB_order)

final %>% 
  summarise(.by = Indicator,
            maxy = comma(max(HB_indicator, na.rm = T), 0.001),
            miny = comma(min(HB_indicator, na.rm = T), 0.001)) %>% 
  arrange(miny) %>% 
  view()




