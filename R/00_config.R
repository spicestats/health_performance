# load -------------------------------------------------------------------------

library(tidyverse)
library(polite)
library(rvest)
library(httr)
library(jsonlite)

source("R/f_round2.R")

# HB and speciality lookups ----------------------------------------------------
HB_lookup <- readxl::read_xlsx("data/HBcodes_specialties_lookup.xlsx", 
                               sheet = "lookups", range = "A1:B100") %>% 
  rename(HBT = 1,
         HB = 2) %>% 
  filter(!is.na(HB))

Specialty_lookup <- readxl::read_xlsx("data/HBcodes_specialties_lookup.xlsx", 
                                      sheet = "lookups", range = "D1:E300") %>% 
  rename(Code = 1, 
         Name = 2) %>% 
  filter(!is.na(Name))

# Indicator list ---------------------------------------------------------------
# "https://www.gov.scot/publications/nhsscotland-performance-against-ldp-standards/pages/updates/"

indicators <- readRDS("data/indicators.rds")

abbr <- c("outpatient", "RTT", "AandE", "ABI", "CAMHS", "cancerWT", "CDI",
          "PDS", "DCE", )

reports <- c()


## Alcohol Brief Interventions -------------------------------------------------
# under review?

# Detect Cancer Early
# report: https://www.publichealthscotland.scot/publications/detect-cancer-early-staging-data/detect-cancer-early-staging-data-year-10-and-impact-of-covid-19/
# can't find up-to-date data - emailed PHS

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



