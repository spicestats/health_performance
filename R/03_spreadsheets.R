# load -------------------------------------------------------------------------

data <- readRDS("data/indicator_data.rds")

# names & defs -----------------------------------------------------------------

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
  outpatient = "95% of new outpatients should receive an outpatient appointment within 12 weeks. Health boards should work towards 100%.",
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
  CDI = "NHS Boards' rate of healthcare-associated clostridium difficile infections in patients aged 15 and over should be 0.32 cases or less per 1,000 total occupied bed days. Standard currently under review.",
  SAB = "NHS Boards' rate of healthcare-associated SAB (staphylococcus aureus bacteraemia (including MRSA)) cases should be 0.24 or less per 1,000 acute occupied bed days. Standard currently under review.", 
  drug = "90% of clients should wait no longer than 3 weeks from referral received to appropriate drug or alcohol treatment that supports their recovery.",
  ABI = "NHS Boards should sustain and embed alcohol brief interventions in 3 priority settings (primary care, A&E, antenatal) and broaden delivery in wider settings.")

links <- c(
  "https://turasdata.nes.nhs.scot/data-and-reports/official-workforce-statistics/all-official-statistics-publications/03-december-2024-workforce/?pageid=13014",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20491",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20499",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20497",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20544",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20544",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20545",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20543",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20465",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20467",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20467",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20520",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20552",
  "https://www.gov.scot/publications/health-care-experience-survey-2023-24-national-results/",
  "https://www.gov.scot/publications/health-care-experience-survey-2023-24-national-results/",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20574",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20549",
  "https://www.nss.nhs.scot/publications/quarterly-epidemiological-data-on-clostridioides-difficile-infection-escherichia-coli-bacteraemia-staphylococcus-aureus-bacteraemia-and-surgical-site-infection-in-scotland-july-to-september-q3-2024/",
  "https://www.nss.nhs.scot/publications/quarterly-epidemiological-data-on-clostridioides-difficile-infection-escherichia-coli-bacteraemia-staphylococcus-aureus-bacteraemia-and-surgical-site-infection-in-scotland-july-to-september-q3-2024/",
  "https://publichealthscotland.scot/publications/show-all-releases?id=20553",
  "https://publichealthscotland.scot/publications/alcohol-brief-interventions/alcohol-brief-interventions-201920/")

# xlsx for powerBI -------------------------------------------------------------

data_prepped <- data  %>% 
  filter(HB %in% HBs,
         To >= dmy("01012015")) %>% 
  mutate(Indicator = ifelse(!is.na(Sub_indicator), paste(Indicator, Sub_indicator), Indicator),
         Indicator = factor(Indicator, levels = indicator_levels, labels = indicator_labels, ordered = TRUE),
         HB = factor(HB, levels = HBs, ordered = TRUE)) %>% 
  select(Indicator, From, To, HB, HB_indicator, Target, Target_met)

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
  
  # make Scotland values a separate column
  mutate(loc = ifelse(HB == "Scotland", "Scotland_indicator", "HB_indicator")) %>%
  pivot_wider(names_from = "loc", values_from = "HB_indicator") %>% 
  
  mutate(.by = c(Indicator, To),
         Scotland_indicator = max(Scotland_indicator, na.rm = TRUE),
         Scotland_indicator = ifelse(Scotland_indicator == -Inf, NA, Scotland_indicator),
         HB_indicator = ifelse(is.na(HB_indicator) & HB == "Scotland", Scotland_indicator, HB_indicator)) %>% 
  #filter(HB != "Scotland") %>% 
  
  mutate(Period = case_when(as.numeric(difftime(To, From), unit = "days") %in% c(1090:1460) ~ paste("Two years to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(729:731) ~ paste("Two years to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(360: 370) ~ paste("Year to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(88:95) ~ paste("Quarter to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(27:31) ~ paste("Month to", format(To, "%d %b %Y"))),
         Target_met = ifelse(is.na(HB_indicator), NA, Target_met),
         Target_col = case_when(Target_met ~ "#568125", 
                                !Target_met ~ "#E40046"),
         Symbol = case_when(Target_met ~ "J",
                            !Target_met ~ "x"),
         Formatted_value = case_when(Indicator %in% c("Smoking cessation", "Alcohol Brief Interventions") ~ comma(HB_indicator, 1),
                                     Indicator %in% c("SAB infections", "Clostridium difficile infections") ~ comma(HB_indicator, 0.01),
                                     TRUE ~ percent(HB_indicator, 0.1)),
         Formatted_Scotland_value = case_when(Indicator %in% c("Smoking cessation", "Alcohol Brief Interventions") ~ comma(Scotland_indicator, 1),
                                              Indicator %in% c("SAB infections", "Clostridium difficile infections") ~ comma(Scotland_indicator, 0.01),
                                              TRUE ~ percent(Scotland_indicator, 0.1)),
         Scotland_comparison = case_when(HB_indicator < Scotland_indicator ~ "lower than",
                                         HB_indicator > Scotland_indicator ~ "higher than",
                                         HB_indicator == Scotland_indicator ~ "the same as"),
         Target_label = case_when(!is.na(HB_indicator) & Indicator %in% c("Smoking cessation", "Alcohol Brief Interventions") & Target_met ~ paste0("meets standard (at least ", comma(Target, 1), ")"),
                                  !is.na(HB_indicator) & Indicator %in% c("Smoking cessation", "Alcohol Brief Interventions") & !Target_met ~ paste0("does not meet standard (at least ", comma(Target, 1), ")"),
                                  !is.na(HB_indicator) & Indicator %in% c("SAB infections", "Clostridium difficile infections") & Target_met ~ paste0("meets standard (at most ", Target, ")"),
                                  !is.na(HB_indicator) & Indicator %in% c("SAB infections", "Clostridium difficile infections") & !Target_met ~ paste0("does not meet standard (at most ", Target, ")"),
                                  !is.na(HB_indicator) & Target == 1 & Target_met ~ paste0("meets standard (", percent(Target, 1), ")"),
                                  !is.na(HB_indicator) & Target == 1 & !Target_met ~ paste0("does not meet standard (", percent(Target, 1), ")"),
                                  !is.na(HB_indicator) & Target_met & HB_indicator <= Target ~ paste0("meets standard (at most ", percent(Target, 1), ")"),
                                  !is.na(HB_indicator) & Target_met & HB_indicator >= Target ~  paste0("meets standard (at least ", percent(Target, 1), ")"),
                                  !is.na(HB_indicator) & !Target_met & HB_indicator <= Target ~  paste0("does not meet standard (at least ", percent(Target, 1), ")"),
                                  !is.na(HB_indicator) & !Target_met & HB_indicator >= Target ~   paste0("does not meet standard (at most ", percent(Target, 1), ")")),
         Target_label1 = ifelse(!is.na(Target_label), paste0(HB, " ", Target_label, "."), NA),
         Target_label2 = ifelse(!is.na(Scotland_comparison), paste0(HB, " estimate is ", Scotland_comparison, " Scotland estimate (", Formatted_Scotland_value, ")."), NA),
         Target_label2 = ifelse(grepl("Scotland estimate is the same as Scotland estimate", Target_label2), NA, Target_label2),
         Defs = factor(Indicator, levels = indicator_labels, labels = indicator_definitions),
         
         # remove Scotland values from smoking measure as the scale of it messes up the charts
         Scotland_indicator = ifelse(Indicator == "Smoking cessation", NA, Scotland_indicator),
         Target_label2 = ifelse(Indicator == "Smoking cessation", NA, Target_label2),
         
         HB = str_replace(HB, " and ", " & "),
         HB = factor(HB, ordered = TRUE),
         HB = fct_relevel(HB, "Scotland", after = 0L),
         HB_order = factor(HB, levels = levels(HB), labels = 1:16),
         HB_order = as.numeric(HB_order)) %>% 
  arrange(Indicator, desc(To), HB) %>% 
  select(-From, -Target_met, -Formatted_Scotland_value, -Scotland_comparison, -Target_label) 


writexl::write_xlsx(final, paste0(Gdrive_path, "/indicator_data.xlsx"))
writexl::write_xlsx(final, "dashboard_output/indicator_data.xlsx")

# xlsx for publishing ----------------------------------------------------------

xls_pub <- data_prepped %>% 
  mutate(Period = case_when(as.numeric(difftime(To, From), unit = "days") %in% c(1090:1460) ~ paste("Two years to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(729:731) ~ paste("Two years to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(360: 370) ~ paste("Year to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(88:95) ~ paste("Quarter to", format(To, "%d %b %Y")),
                            as.numeric(difftime(To, From), unit = "days") %in% c(27:31) ~ paste("Month to", format(To, "%d %b %Y"))),
         HB_indicator = ifelse(is.nan(HB_indicator), NA, HB_indicator)) %>% 
  select(Indicator, HB, Period, To, HB_indicator, Target, Target_met) %>% 
  arrange(Indicator, desc(To), HB) %>% 
  rename("Health board" = HB,
         Estimate = HB_indicator,
         "Target met" = Target_met)

tables <- lapply(indicator_labels, function(i) {
  xls_pub %>% 
    filter(Indicator == i) %>% 
    select(-Indicator)})

names(tables) <- indicator_levels

# create workbook and sheets

wb <- createWorkbook()
lapply(seq_along(indicator_levels), function(i) {
  
  addWorksheet(wb, sheetName = indicator_levels[i], gridLines = FALSE)
  
  # title
  writeData(wb, sheet = i, x = indicator_labels[i])
  
  # definition
  writeData(wb, sheet = i, startRow = 2, x = indicator_definitions[i])
  
  # stats report
  hyperlink <- links[i]
  names(hyperlink) <- "Statistics report with more information"
  class(hyperlink) <- "hyperlink"
  writeData(wb, sheet = i, startRow = 3, x = hyperlink)
  
  # table
  writeDataTable(wb, sheet = i, startRow = 4, x = tables[[i]], 
                 withFilter = FALSE, 
                 tableName = str_replace_all(indicator_levels[i], " ", "_"))
  setColWidths(wb, sheet = i, cols = 1:7, widths = c(25, 20, 12, 10, 10, 10))
  
  # formatting
  addStyle(wb, sheet = i, rows = 1, cols = 1, style = createStyle(textDecoration = "bold"))
  addStyle(wb, sheet = i, rows = 4, gridExpand = TRUE, cols = 3:5,
           createStyle(halign = 'right'))
  addStyle(wb, sheet = i, rows = 4, cols = 6,
           createStyle(halign = 'left'))
  
  if (indicator_levels[i] %in% c("CDI", "SAB")) {
    
    addStyle(wb, sheet = i, rows = 5:3000, cols = 4:5, gridExpand = TRUE,
             style = createStyle(numFmt =  "0.000"))  
    
  } else if (indicator_levels[i] == "smoke") {
    
    addStyle(wb, sheet = i, rows = 5:3000, cols = 4:5, gridExpand = TRUE,
             style = createStyle(numFmt = "#,##0"))
    
  } else {
    
    addStyle(wb, sheet = i, rows = 5:3000, cols = 4:5, gridExpand = TRUE,
             style = createStyle(numFmt = "0.0%"))}
  
})

# rename sheets
names(wb) <- indicator_labels

removeWorksheet(wb, "Alcohol Brief Interventions")
removeWorksheet(wb, "Detect Cancer Early")
removeWorksheet(wb, "18 weeks referral to treatment")
removeWorksheet(wb, "Dementia post-diagnostic suppor")

# rearrange worksheets alphabetically
worksheetOrder(wb) <- order(names(wb))

saveWorkbook(wb,  paste0(Gdrive_path, "/All_measures.xlsx"), overwrite = TRUE)
saveWorkbook(wb,  "dashboard_output/All_measures.xlsx", overwrite = TRUE)

# checks -----------------------------------------------------------------------
# for most indicators, values and targets should not exceed 1; when they do, it's
# usually a data error or an aggregation error

final %>% 
  filter(Target > 1 | HB_indicator > 1,
         !(Indicator %in% c("Smoking cessation",
                            "Clostridium difficile infections",
                            "SAB infections",
                            "Alcohol Brief Interventions")))

final %>% 
  summarise(.by = Indicator,
            miny = comma(min(HB_indicator, na.rm = T), 0.001),
            maxy = comma(max(HB_indicator, na.rm = T), 0.001)) %>% 
  arrange(miny) %>% 
  view()
