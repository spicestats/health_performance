# load -------------------------------------------------------------------------

library(tidyverse)
library(polite)
library(rvest)
library(httr)
library(jsonlite)

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





