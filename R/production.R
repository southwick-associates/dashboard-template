# functions for producing a dashboard for specified permission-timeframe

#' Build license history table
#' 
#' This function mostly wraps salic::rank_sale() and salic::make_history(),
#' with logic based on time period and license types included.
#' 
#' @param cust,lic,sale standardized license data frames
#' @param yrs years to include in dashboard
#' @param timeframe time period covered ("full-year" or "mid-year")
#' @param lic_types license types (lic$type) included. This should correspond to
#' a permission group (e.g., c("hunt", "combo") for "hunt" permission).
#' 
#' @family functions for dashboard production
#' @export
#' @examples 
#' library(salic)
#' data(cust, lic, sale)
#' build_history(cust, lic, sale, 2008:2018, "full-year", c("hunt", "combo"))
build_history <- function(
    cust, lic, sale, yrs, timeframe, lic_types
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

#' Calculate dashbord metrics
#' 
#' This produces all metrics with segment breakouts. It returns a list with one
#' element for each metric, which in turn has one element for each segment.
#' 
#' @param history data frame produced by build_history()
#' @param tests test thresholds for salic::est_part(), salic::est_churn(), and
#' salic::est_recruit()
#' @param scaleup_test test_threshold for salic::scaleup_part()
#' @param segs vector of segments to be summarized
#' 
#' @family functions for dashboard production
#' @export
#' @examples 
#' library(salic)
#' data(history)
#' metrics <- calc_metrics(history)
#' metrics$participants$tot # overall participation
calc_metrics <- function(
    history,
    tests = c(tot = 20, res = 35, sex = 35, agecat = 35),
    scaleup_test = 10,
    segs = c("tot", "res", "sex", "agecat")
) {
    # prepare category variables
    history <- history %>%
        label_categories() %>%
        recode_agecat()
    
    # exclude youths/seniors
    history <- filter(history, !agecat %in% c("0-17", "65+"))
    
    # calculate metrics across segments
    participants <- calc_participants(history, segs, tests, scaleup_test)
    
    residents <- filter(history, res == "Resident") %>% 
        calc_participants(
            segs, tests, scaleup_test,  
            part_total = filter(participants$res, res == "Resident"),   
            outvar = "residents" 
    )
    if ("R3" %in% names(history)) {
        recruits <- filter(history, R3 == "Recruit") %>%
            calc_participants(segs, tests, scaleup_test, outvar = "recruits")
    }
    if ("lapse" %in% names(history)) {
        churn <- sapply(segs, function(x) est_churn(history, x, tests[x]), 
                        simplify = FALSE)
    }
    # combine results by metric into a single output list
    mets <- c("participants", "residents", "recruits", "churn")
    sapply(mets, function(x) if (exists(x)) get(x), simplify = FALSE)
}

#' Calculate participants by segment
#' 
#' This is to be called from calc_metrics(). It essentially wraps salic::est_part()
#' and salic::scaleup_part() with some logic to work for participants overall vs. 
#' residents vs. recruits
#' 
#' @param part_total reference data frame for use in calculating recruits. 
#' This is necessary because resident breakouts need to be pegged to already 
#' scaled total residents (in case of missing values in res).
#' @param outvar name to use for output variable that holds the summary value
#' @inheritParams calc_metrics
#' 
#' @family functions for dashboard production
#' @export
calc_participants <- function(
    history, segs, tests, scaleup_test, part_total = NULL, outvar = "participants"
) {
    # apply est_part() by segment
    part <- sapply(segs, function(x) est_part(history, x, tests[x]), 
                   simplify = FALSE)
    
    # apply scaleup_part() by segment
    if (is.null(part_total)) {
        part_total <- part$tot # for overall & recruits
    }
    part <- lapply(part, function(x) scaleup_part(x, part_total, scaleup_test))
    lapply(part, function(x) rename(x, !! outvar := participants))
} 

#' Format metrics (list) into a single data frame
#' 
#' This formats the list results of calc_metrics() into a data frame used as 
#' input to dashboard visualization software.
#' 
#' @param metrics list produced by calc_metrics()
#' @param timeframe time period covered ("full-year" or "mid-year")
#' @param group name of permission group ("fish", "hunt", "all_sports")
#' 
#' @family functions for dashboard production
#' @export
#' @examples 
#' library(salic)
#' data(metrics)
#' format_metrics(metrics, "full-year", "all_sports")
format_metrics <- function(
    metrics, timeframe, group
) {
    lapply_format <- function(metric) {
        lapply(metric, function(x) format_result(x, timeframe, group))
    }
    bind_rows(
        lapply_format(metrics$participants),
        lapply_format(metrics$residents),
        if ("recruits" %in% names(metrics)) lapply_format(metrics$recruits),
        if ("churn" %in% names(metrics)) lapply_format(metrics$churn)
    )
}
