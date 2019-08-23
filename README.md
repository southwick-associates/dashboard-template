# A template for preparing agency dashboard data

This workflow includes all code necessary to produce dashboard input (i.e., summary data) from standardized license data for your state (using R). It was prepared by Southwick Associates to aid state agencies in AFWA's National/Regional dashboard effort. Simply download (or clone) this repository to utilize the template for your state's data.

## Installation

You'll need a version of [R Software](https://www.r-project.org/) installed (version 3.5.0 or greater). Additionally, 3 packages will be needed:

- dplyr is used directly for this workflow: `install.packages("dplyr")`
- data.table is used internally by salic: `install.packages("data.table")`
- install salic

## Usage

This workflow depends heavily on package salic (vignette link)

Run `source("code/run.R")` from R (ensuring working directory is set to the template folder).
