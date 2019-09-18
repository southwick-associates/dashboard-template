# namespace definitions for Southwick internal use

#' @import salic dplyr shiny ggplot2
#' @importFrom utils read.csv
NULL

if (getRversion() >= "2.15.1") {
    utils::globalVariables(
        c("R3", "agecat", "category", "group", "metric", "month", "pct_change", 
          "segment", "type", "value", "year")
    )
}
