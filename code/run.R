# produce dashboard summary data

library(dplyr)
library(salic)
source("code/functions.R")

# parameters
yrs <- 2008:2018
timeframe <- "full-year" # full-year or mid-year

# load data
# - uses salic sample data by default
# - load your state's standardized data instead for production
data(cust, lic, sale)
data_check(cust, lic, sale)

# produce summaries for each permission
hunt <- run_group(
    cust, lic, sale, yrs, timeframe, "hunt", c("hunt", "combo")
)
fish <- run_group(
    cust, lic, sale, yrs, timeframe, "fish", c("fish", "combo")
)
all_sports <- run_group(
    cust, lic, sale, yrs, timeframe, "all_sports", c("hunt", "fish", "combo")
)

# combine permissions & save output to CSV
dashboard <- bind_rows(all_sports, fish, hunt)
outfile <- file.path("out", paste0(timeframe, yrs[length(yrs)], ".csv"))

dir.create("out", showWarnings = FALSE)
write.csv(dashboard, file = outfile, row.names = FALSE)
