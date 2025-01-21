# load -------------------------------------------------------------------------

library(tidyverse)
library(polite)
library(rvest)
library(httr)
library(jsonlite)

source("R/f_round2.R")

# HB lookup
HB_lookup <- readxl::read_xlsx("data/HBcodes_specialties_lookup.xlsx", sheet = "lookups", range = "A1:B100") %>% 
  rename(HBT = 1,
         HB = 2) %>% 
  filter(!is.na(HB))


# Indicator list ---------------------------------------------------------------

url <- "https://www.gov.scot/publications/nhsscotland-performance-against-ldp-standards/pages/updates/"

session <- polite::bow(url)
indicators <- polite::scrape(session) %>%
  html_elements(".ds_side-navigation__list") %>% 
  html_elements("a") %>% 
  html_text()

indicators <- indicators[!grepl("Introduction|Calendar", indicators)]  %>% 
  str_squish()

## Accident and Emergency waiting times ----------------------------------------
# https://www.opendata.nhs.scot/dataset/monthly-accident-and-emergency-activity-and-waiting-times/resource/37ba17b1-c323-492c-87d5-e986aae9ab59

AE_query <- "https://www.opendata.nhs.scot/dataset/997acaa5-afe0-49d9-b333-dcf84584603d/resource/37ba17b1-c323-492c-87d5-e986aae9ab59/download/monthly_ae_activity_202411.csv"

AE <- content(httr::GET(AE_query)) %>% 
  select(Month, HBT, NumberOfAttendancesAll, NumberWithin4HoursAll) %>% 
  rename(Attendances = 3,
         Within4hrs = 4) %>% 
  mutate(Month = ym(Month)) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  summarise(.by = c(Month, HB),
            Within4hrs = sum(Within4hrs, na.rm = TRUE),
            Attendances = sum(Attendances, na.rm = TRUE)) %>% 
  mutate(.by = Month,
         HB_indicator = round2(Within4hrs/Attendances, 3),
         Scotland_indicator = round2(sum(Within4hrs)/sum(Attendances), 3)) %>% 
  select(-c(Within4hrs, Attendances))

## Alcohol Brief Interventions -------------------------------------------------
# under review?

## Child and Adolescent Mental Health (CAMHS) waiting times --------------------
# https://www.opendata.nhs.scot/dataset/child-and-adolescent-mental-health-waiting-times/resource/7a2fe10d-1339-41c1-a2f2-a469644fd619

CA_query <- "https://www.opendata.nhs.scot/dataset/f9bab568-501e-49d3-a0a4-0b9a7578b0de/resource/d43cae98-a620-4f24-a02f-a6451c297478/download/camhs-adjusted-patients-waiting.csv"

CA <- content(httr::GET(CA_query)) %>% 
  select(Month, HB, TotalPatientsWaiting, NumberOfPatientsWaiting0To18Weeks) %>% 
  rename(HBT = HB,
         All = 3,
         Upto18 = 4) %>% 
  left_join(HB_lookup, by = "HBT") %>% 
  mutate(.by = c(Month, HB),
         Month = ym(Month),
         HB_indicator = round2(Upto18 / All, 3)) %>% 
  mutate(.by = Month,
         Scotland_indicator = round2(sum(Upto18) / sum(All), 3)) %>% 
  select(-c(HBT, All, Upto18))

## Cancer waiting times --------------------------------------------------------

## Clostridium Difficile infections --------------------------------------------                        
## Dementia post-diagnostic support --------------------------------------------
## Detect Cancer Early ---------------------------------------------------------
## Drug and alcohol treatment waiting times ------------------------------------ 
## Early access to antenatal services ------------------------------------------
## Financial performance -------------------------------------------------------
## GP access -------------------------------------------------------------------
## IVF waiting times -----------------------------------------------------------
## Psychological therapies waiting times ---------------------------------------
## SAB (MRSA/MSSA) -------------------------------------------------------------
## Sickness absence ------------------------------------------------------------
## Smoking cessation -----------------------------------------------------------
## Treatment time guarantee ----------------------------------------------------
## 12 weeks first outpatient appointment ---------------------------------------
## 18 weeks referral to treatment ----------------------------------------------



