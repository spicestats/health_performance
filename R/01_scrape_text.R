library(tidyverse)
library(polite)
library(rvest)

# Create a session
session <- bow("https://www.gov.scot/publications/nhsscotland-performance-against-ldp-standards/")


# Scrape the main page
main_page <- scrape(session)

# Extract links to all pages
links <- main_page %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  str_subset("/publications/nhsscotland-performance-against-ldp-standards/pages/")

links <- links[!grepl("introduction|updates", links)]

# Function to scrape text from a single page
scrape_page <- function(url) {
  page <- bow(url) %>% scrape()
  text <- page %>% html_elements(".publication-content") %>% html_text()
  return(text)
}

# Scrape text from all pages
all_text <- lapply(paste0("https://www.gov.scot/", links), scrape_page) %>% 
  unlist()

data <- data.frame(text = all_text %>%
            str_split("\n^LDP Standard$\n") %>% 
            unlist() %>% 
            str_squish()) %>% 
  mutate(Name = str_split_i(text, "Current national performance", 1),
         Name = str_replace(Name, "LDP Standard |LDP standard ", ""),
         About = str_split_i(text, "About this LDP standard", 2) %>% str_squish(),
         About = str_split_i(About, "Performance against this standard|Performance against standard|Performance against target|Reference", 1),
         LDP = c("AandE", "ABI", "CAMHS", "cancerWT", "CDI", "PDS", "DCE", "drug", "ante", "fin", "GP", "IVF", "PT", "SAB", "sick", "smoke", "TTG", "outpatient", "RTT")) %>% 
  select(LDP, Name, About)

saveRDS(data, "data/scraped_indicator_text.rds")


