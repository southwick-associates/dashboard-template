# A template for preparing agency dashboard data

This workflow includes all code necessary to produce dashboard input (i.e., summary data) from standardized license data for your state (using R). It was prepared by Southwick Associates to aid state agencies in AFWA's National/Regional dashboard effort.

## Installation

Install [R package salic](https://southwick-associates.github.io/salic/) and then download this repository.

## Usage

See (vignette link) for an introduction to the workfow. For production, run `source("code/run.R")` from the console. This will save a CSV file to an "out" folder.

Note that sample data is used by default, you'll need to edit "code/run.R" to specify your state's data and set the "yrs" and "timeframe" parameters.  
