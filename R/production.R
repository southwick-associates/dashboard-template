# functions to automate summary data production

# package imports (for Southwick internal use)
#' @import dplyr salic
NULL

#' Build license history table, including R3 & lapse (if applicable)
# - cust, lic, sale: standardized license data frames
# - yrs: years to include
# - timeframe: time period covered ("full-year" or "mid-year")
# - lic_types: license types (lic$type) included in permission group
build_history <- function(
    cust, lic, sale, yrs = 2008:2018, timeframe = "full-year", 
    lic_types = c("hunt", "combo")
) {
    first_month = if (timeframe == "mid-year") TRUE else FALSE
    carry_vars = if (timeframe == "mid-year") c("month", "res") else "res"
    yrs_lapse = if (timeframe == "full-year") yrs else NULL
    
    history <- lic %>%
        filter(type %in% lic_types) %>%
        inner_join(sale, by = "lic_id") %>%
        rank_sale(first_month = first_month) %>%
        make_history(yrs, carry_vars, yrs_lapse) %>%
        left_join(cust, by = "cust_id")
    
    if (timeframe == "mid-year") {
        history <- filter(history, month <= 6)
    }
    history
}

# calculate dashbord metrics and store the results in a list
# - history: data frame produced by build_history()
# - tests: test thresholds for est_part(), est_churn(), est_recruit()
# - scaleup_test: test_threshold for scaleup_part()
calc_metrics <- function(
    history,
    tests = c(tot = 20, res = 35, sex = 35, agecat = 35),
    scaleup_test = 10
) {
    # prepare category variables
    history <- history %>%
        label_categories() %>%
        recode_agecat()
    
    # exclude youths/seniors
    history <- filter(history, !agecat %in% c("0-17", "65+"))
    
    # calculate metrics across 4 segments
    segs <- c("tot", "res", "sex", "agecat")
    sapply2 <- function(x, ...) sapply(x, simplify = FALSE, ...) # for convenience
    
    part <- sapply2(segs, function(x) est_part(history, x, tests[x]))
    participants <- lapply(part, function(x) scaleup_part(x, part$tot, scaleup_test))
    
    if ("lapse" %in% names(history)) {
        churn <- sapply2(segs, function(x) est_churn(history, x, tests[x]))
    }
    if ("R3" %in% names(history)) {
        history <- filter(history, R3 == "Recruit")
        part <- sapply2(segs, function(x) est_recruit(history, x, tests[x]))
        recruits <- lapply(part, function(x) scaleup_recruit(x, part$tot, scaleup_test))
    }
    sapply2(c("participants", "recruits", "churn"), function(x) if (exists(x)) get(x))
}

# format metrics (list) into a single table output (data frame)
# - metrics: list produced by calc_metrics()
# - timeframe: time period covered ("full-year" or "mid-year")
# - group: name of permission group ("fish", "hunt", "all_sports")
format_metrics <- function(
    metrics, timeframe, group = "hunt"
) {
    lapply_format <- function(metric) {
        lapply(metric, function(x) format_result(x, timeframe, group))
    }
    bind_rows(
        lapply_format(metrics$participants),
        if ("recruits" %in% names(metrics)) lapply_format(metrics$recruits),
        if ("churn" %in% names(metrics)) lapply_format(metrics$churn)
    )
}
