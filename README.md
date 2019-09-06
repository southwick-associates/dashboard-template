# A template for preparing agency dashboard data

This workflow includes all code necessary to produce dashboard input (i.e., summary data) from standardized license data for your state (using R). It was prepared by Southwick Associates to aid state agencies in AFWA's National/Regional dashboard effort.

## Installation

Install [R package salic](https://southwick-associates.github.io/salic/) and then download this repository (via "clone or download").

### System Requirements

You may need to watch your RAM usage for production data. As a rule of thumb, a computer with 8gb of RAM should be sufficient if you have fewer than 15 million rows in the sale table.

## Usage

See the [salic vignette](https://southwick-associates.github.io/salic/articles/salic.html) for an introduction to the workfow. For production, run from the R console:

``` r
# run results & save to csv
source("code/run.R")
```

Note that sample data is used by default. You'll need to edit "code/run.R" to specify your state's data and set the "yrs" and "timeframe" parameters as needed. Running on the sample data should only take a few seconds, but running on production data may take a few minutes.

### Threshold Tests

**Warnings**: Running on the sample data will produce several threshold warning messages since certain segments (e.g., nonresidents) vary quite a bit year-to-year. I included these threshold checks because large changes may indicate data problems. You can adjust thresholds using the "tests" argument in calc_metrics() (in "code/functions.R") to suit your needs.

**Errors**: By default, the script will stop with an error if any segment (res, sex, agecat) contains missing values that account for more than 10% of the total (high missing percentages reduce the accuracy of corresponding metrics). You can adjust the threshold using the "scaleup_test" argument in calc_metrics() to prevent a particular error.

### Visualize

You can visualize the results in an interactive window using the shiny package. This can be helpful for exploring and/or checking the summary results.

``` r
# install dependencies
install.packages(c("shiny", "ggplot2"))

# visualize
source("visualize/app-functions.R")
run_visual()
```
