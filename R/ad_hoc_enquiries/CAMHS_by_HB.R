
# load -------------------------------------------------------------------------

library(tidyverse)

data <- readRDS("data/CAMHS.rds")

out <- data %>% 
  filter(To == max(To) | To == max(To) - years(1)) %>% 
  mutate(Quarter = paste("Quarter ending in", format(To, "%b %y")),
         HB = fct_relevel(HB, "Scotland", after = 0L)) %>% 
  arrange(To, HB) %>% 
  select(HB, Quarter, HB_indicator) %>% 
  pivot_wider(names_from = Quarter, values_from = HB_indicator)

# save -------------------------------------------------------------------------

writexl::write_xlsx(out, "output/CAMHS_enquiry.xlsx")
