
# open data indicators ---------------------------------------------------------

files_od <- c("R/01_import_AandE.R",
              "R/01_import_ante.R",
              "R/01_import_CAMHS.R",
              "R/01_import_cancerWT.R",
              "R/01_import_CDI_SAB.R",
              "R/01_import_drug.R",
              "R/01_import_IVF.R",
              "R/01_import_outpatient_TTG.R",
              "R/01_import_PT.R",
              "R/01_import_RTT.R")

# spreadsheet only -------------------------------------------------------------
# all annual or every 2 years

files_xl <- c("R/01_import_GP.R", # next: spring 2026; every 2 years; 48-hour sub-indicator only available on request
              "R/01_import_PDS.R", # automated
              "R/01_import_sick.R", # next: 4 Mar 2025; manual download via dashboard only
              "R/01_import_smoke.R") # next: winter 2025/2026; manual download via dashboard while spreadsheet is too awful to automate

# no longer active -------------------------------------------------------------

files_dead <- c("R/01_import_DCE.R",
                "R/01_import_ABI.R")

# run import and combine scripts -----------------------------------------------

source("R/00_config.R")
lapply(c(files_od, files_xl), source)

source("R/02_combine_indicator_data.R")

# charts
source("R/03_overview_chart.R")

