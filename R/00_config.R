# load -------------------------------------------------------------------------

library(tidyverse)
library(polite)
library(rvest)
library(httr)
library(jsonlite)
library(scales)
library(openxlsx)
library(extrafont)
library(patchwork)

source("R/f_round2.R")

# Lookups ----------------------------------------------------------------------

# Health board code to name
HB_lookup <- readxl::read_xlsx("data/HBcodes_specialties_lookup.xlsx", 
                               sheet = "lookups", range = "A1:B100") %>% 
  rename(HBT = 1,
         HB = 2) %>% 
  filter(!is.na(HB))

# council code to health board name
id <- "967937c4-8d67-4f39-974f-fd58c4acfda5"
query <- paste0("https://www.opendata.nhs.scot/api/3/action/datastore_search?resource_id=", 
                id, "&limit=100000")

CA_to_HB_lookup <- content(httr::GET(query))$result$records %>% 
  bind_rows() %>% 
  select(CA, HBName) %>% 
  distinct() %>% 
  mutate(HBName = str_replace(HBName, "NHS ", ""))

# Speciality code to name
Specialty_lookup <- readxl::read_xlsx("data/HBcodes_specialties_lookup.xlsx", 
                                      sheet = "lookups", range = "D1:E300") %>% 
  rename(Code = 1, 
         Name = 2) %>% 
  filter(!is.na(Name))

SP_path <- "C:/Users/s910140/The Scottish Parliament/Scottish Parliament Information Centre - Data sync/Dashboards/health performance"







