# A template for preparing agency dashboard data

This workflow includes all code necessary to produce dashboard input (i.e., summary data) from standardized license data for your state (using R). It was prepared by Southwick Associates to aid state agencies in AFWA's National/Regional dashboard effort.

## Installation

Install [R package salic](https://southwick-associates.github.io/salic/) and then download this repository (via "clone or download").

## Usage

See [the salic vignette](https://southwick-associates.github.io/salic/articles/salic.html) for an introduction to the workfow. For production, run `source("code/run.R")` from the R console. This will save a CSV file to an "out" folder.

Note that sample data is used by default. You'll need to edit "code/run.R" to specify your state's data and set the "yrs" and "timeframe" parameters as needed.

### Threshold Tests

**Warnings**: Running on the sample data will produce several threshold warning messages because certain segments (e.g., nonresidents) vary quite a bit year-to-year. I included these threshold checks because large changes can sometimes indicate data problems. You can adjust thresholds using the "tests" argument in calc_metrics() ("code/functions.R") to suit your needs.

**Errors**: By default, the script will stop with an error if any segment (res, sex, agecat) contains missing values that account for more than 10% of the total (High missing percentages reduce the accuracy of corresponding metrics). You can adjust the threshold using the "scaleup_test" argument in calc_metrics() to prevent a particular error.

### System Requirements

Large R data files can use up quite a bit of memory, so you may need to watch your RAM usage. As a rule of thumb,  you can probably get by using a computer with 8gb of RAM if you have fewer than 15 million rows in the sale table.

Running the example data should only take a few seconds, but running on production data may take a few minutes.
