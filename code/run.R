# produce dashboard summary data

library(dplyr)
library(salic)
source("code/functions.R")

# specify parameters
yrs <- 2008:2018         # years to include in output
timeframe <- "full-year" # full-year or mid-year

# load data
# - uses salic sample data by default
# - load your state's standardized data instead for production - see vignette("salic")
data(cust, lic, sale)
data_check(cust, lic, sale)

# produce summaries for each permission (group)
run_group <- function(group, lic_types) {
    build_history(cust, lic, sale, yrs, timeframe, lic_types) %>%
        calc_metrics() %>% 
        format_metrics(timeframe, group)
}
hunt <- run_group("hunt", c("hunt", "combo"))
fish <- run_group("fish", c("fish", "combo"))
all_sports <- run_group("all_sports", c("hunt", "fish", "combo")) 

# combine permission summaries and save output to CSV
dashboard <- bind_rows(all_sports, fish, hunt)

outfile <- file.path(
    "out", paste0(timeframe, yrs[1], "to", yrs[length(yrs)], ".csv")
)
dir.create("out", showWarnings = FALSE)
write.csv(dashboard, file = outfile, row.names = FALSE)
