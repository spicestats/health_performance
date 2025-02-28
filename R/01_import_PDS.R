# Dementia post-diagnostic support

# get latest release 

# release page
page <- "https://publichealthscotland.scot/publications/show-all-releases?id=20491"

session <- polite::bow(page)

urls <- polite::scrape(session) %>% 
  html_elements("a") %>% 
  html_attr("href")

url <- urls[grepl("dementia-post-diagnostic-support-local-delivery-plan-standard-figures", urls)][1]

session2 <- polite::bow(paste0("https://publichealthscotland.scot", url))

files <- polite::scrape(session2) %>% 
  html_nodes(".download-file") %>% 
  html_elements("a") %>% 
  html_attr("href")

xl_file <- paste0("https://publichealthscotland.scot", files[grepl("xls", files)])

download.file(xl_file, "data/PDS.xlsx", mode = "wb")

data <- readxl::read_xlsx("data/PDS.xlsx", sheet = "data") %>% 
  filter(category == "geog",
         grepl("NHS", category_split)) %>% 
  select(fy, category_split, rate) %>% 
  mutate(HB = str_replace(category_split, "NHS ", ""),
         HB_indicator = round2(as.numeric(rate), 3),
         From = dmy(paste("1 4",str_sub(fy, 1, 4))),
         To = dmy(paste("31 3",str_sub(fy, 6, 7))),
         Indicator = "PDS",
         Target = 1,
         Target_met = HB_indicator >= Target)  %>% 
  select(From, To, HB, Indicator, HB_indicator, Target, Target_met) %>% 
  arrange(desc(To), Indicator, HB)

saveRDS(data, "data/PDS.rds")




