
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr

Tools for Studying MIDFIELD Student Unit Record Data in R

<!-- badges: start -->

[![R-CMD-check](https://github.com/MIDFIELDR/midfieldr/workflows/R-CMD-check/badge.svg)](https://github.com/MIDFIELDR/midfieldr/actions)
[![codecov](https://codecov.io/gh/MIDFIELDR/midfieldr/branch/main/graph/badge.svg?token=KcuCzBkLBP)](https://codecov.io/gh/MIDFIELDR/midfieldr)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/midfieldr)](http://cran.r-project.org/package=midfieldr)
[![License: GPL
v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
<!-- badges: end -->

The goal of midfieldr is to provide tools for working with MIDFIELD
data, a resource of longitudinal, de-identified, individual student unit
records.

## Overview

<a href="https://engineering.purdue.edu/MIDFIELD" target="_blank"><strong>MIDFIELD</strong></a>
contains individual Student Unit Record (SUR) data for 1.7M students at
33 US institutions (as of June 2021). MIDFIELD is large enough to permit
grouping and summarizing by multiple characteristics, enabling
researchers to examine student characteristics (race/ethnicity, sex,
prior achievement) and curricular pathways (including coursework and
major) by institution and over time.

**midfieldr** is an R package that provides tools for working with
MIDFIELD SURs. The tools in midfieldr work equally well with the
research data in MIDFIELD and the practice data in midfielddata.

<a href="https://midfieldr.github.io/midfielddata/" target="_blank"><strong>midfielddata</strong></a>
is an R package that provides practice data (a proportionate stratified
sample of MIDFIELD) with longitudinal SURs for nearly 98,000
undergraduates at 12 institutions from 1987–2016 organized in four data
tables:

| Data set                                                                     | Each row is                           |  N rows | N columns |
|:-----------------------------------------------------------------------------|:--------------------------------------|--------:|----------:|
| [`student`](https://midfieldr.github.io/midfielddata/reference/student.html) | a student upon being admitted         |  97,640 |        13 |
| [`course`](https://midfieldr.github.io/midfielddata/reference/course.html)   | a student in a course                 |    3.5M |        12 |
| [`term`](https://midfieldr.github.io/midfielddata/reference/term.html)       | a student in a term                   | 728,000 |        13 |
| [`degree`](https://midfieldr.github.io/midfielddata/reference/degree.html)   | a student who completes their program |  48,000 |         5 |

## Usage

In this brief usage example, we compare counts of engineering students
by race/ethnicity, sex, and graduation status. Data manipulation is
performed using data.table syntax.

``` r
# packages used
library("midfieldr")
library("midfielddata")
suppressMessages(library("data.table"))

# Load the data tables
data(student, term, degree)

# Filter for engineering programs
DT <- copy(term)
DT <- DT[cip6 %like% "^14", .(mcid, institution, cip6)]
DT <- unique(DT)

# Ensure students are degree-seeking
DT <- filter_match(DT, match_to = student, by_col = "mcid")

# Estimate timely completion terms
DT <- add_timely_term(DT, midfield_term = term)

# Determine graduation status
DT <- add_completion_timely(DT, midfield_degree = degree)
DT[, grad_status := fifelse(completion_timely, "grad", "non-grad")]

# Apply the data sufficiency criterion
DT <- add_data_sufficiency(DT, midfield_term = term)
DT <- DT[data_sufficiency == TRUE]

# Obtain race/ethnicity and sex
DT <- add_race_sex(DT, midfield_student = student)

# Count by grouping variables
DT <- DT[, .N, by = .(grad_status, sex, race)]

# Examine the result
DT
#>     grad_status    sex            race     N
#>          <char> <char>          <char> <int>
#>  1:        grad   Male           White  7172
#>  2:        grad   Male           Black   533
#>  3:    non-grad   Male           White  4423
#>  4:    non-grad   Male           Black   706
#>  5:    non-grad   Male   Other/Unknown   113
#> ---                                         
#> 24:        grad Female   Other/Unknown    35
#> 25:        grad Female Native American    14
#> 26:    non-grad Female   International    24
#> 27:    non-grad Female Native American     7
#> 28:        grad   Male Native American    36
```

## Documentation

-   <a href="https://midfieldr.github.io/midfieldr/articles/" target="_blank">Articles.</a>
    For a listing of all vignettes.
-   <a href="https://midfieldr.github.io/midfieldr/reference/" target="_blank">Reference (midfieldr).</a>
    For a listing of all midfieldr functions and prepared data.
-   <a href="https://midfieldr.github.io/midfielddata/reference/" target="_blank">Reference (midfielddata).</a>
    For a listing of the four practice MIDFIELD data tables.

## Requirements

-   <a href="https://www.r-project.org/" target="_blank">R</a> (>=
    3.5.0)
-   <a href="https://rdatatable.gitlab.io/data.table/" target="_blank">data.table</a>
    (>= 1.9.8)  
-   <a href="https://ggplot2.tidyverse.org/" target="_blank">ggplot2</a>
    recommended for data graphics, but not required.

## Install midfieldr

midfieldr is not yet available from [CRAN](https://cran.r-project.org/).
To install the development version of midfieldr from its `drat`
repository, type in the Console:

``` r
# install midfieldr from drat repo
install.packages("midfieldr", 
                 repos = "https://MIDFIELDR.github.io/drat/", 
                 type = "source")
```

You can confirm a successful installation by running the following lines
to bring up the package help page in the Help window.

``` r
library("midfieldr")
help("midfieldr-package")
```

<img src="man/figures/README-midfieldr-help-page-1.png" width="75%" style="display: block; margin: auto;" />

## Install midfielddata

Because of its size, installing the practice data takes time; please be
patient and wait for the prompt “\>” to reappear. In the Console, run:

``` r
# install midfielddata  
install.packages("midfielddata", 
                 repos = "https://MIDFIELDR.github.io/drat/", 
                 type = "source")
# be patient
```

You can confirm a successful installation by running the following lines
to bring up the package help page in the Help window.

``` r
library("midfielddata")
help("midfielddata-package")
```

<img src="man/figures/README-midfielddata-help-page-1.png" width="75%" style="display: block; margin: auto;" />

## Contributing

To contribute to midfieldr,

-   Please clone this repo locally.  
-   Commit your code on a separate branch.
-   Use the *checkmate* package to include runtime argument checks in
    functions.
-   Use the *tinytest* package to write unit tests for your code. Save
    tests in the `inst/tinytest/` directory.

To provide feedback or report a bug,

-   Use the GitHub
    <a href="https://github.com/MIDFIELDR/midfieldr/issues" target="_blank">Issues</a>
    page.
-   Please run the package unit tests and report the results with your
    bug report. Any user can run the package tests by installing the
    *tinytest* package and running:

``` r
    test_results <- tinytest::test_package("midfieldr")
    as.data.frame(test_results)
```

Participation in this open source project is subject to a [Code of
Conduct](CONDUCT.html).

## Related work

-   <a href="https://midfieldr.github.io/midfielddata/" target="_blank">midfielddata</a>
    Sample of MIDFIELD student unit record data.
-   <a href="https://engineering.purdue.edu/MIDFIELD" target="_blank">MIDFIELD</a>
    A partnership of US institutions.
-   <a href="https://midfieldr.github.io/2021-asee-workshop/" target="_blank">MIDFIELD workshops</a>
    for additional information and tutorials.

## Acknowledgments

This work is supported by a grant from the US National Science
Foundation (EEC 1545667).

## License

midfieldr is licensed under GPL (>= 2.0)  
© 2018 Richard Layton, Russell Long, Matthew Ohland, Susan Lord, and
Marisa Orr
