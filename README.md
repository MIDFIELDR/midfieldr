
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr

Tools for studying MIDFIELD student unit record data in R

<!-- badges: start -->

[![build](https://github.com/MIDFIELDR/midfieldr/workflows/build/badge.svg)](https://github.com/MIDFIELDR/midfieldr/actions)
[![codecov](https://codecov.io/gh/MIDFIELDR/midfieldr/branch/main/graph/badge.svg?token=KcuCzBkLBP)](https://codecov.io/gh/MIDFIELDR/midfieldr)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/midfieldr)](http://cran.r-project.org/package=midfieldr)
[![License: GPL
v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
<!-- badges: end -->

The goal of midfieldr is to provide tools for working with MIDFIELD
data, a resource of longitudinal, de-identified, individual student unit
records.

## Overview

[**MIDFIELD**](https://engineering.purdue.edu/MIDFIELD) contains
individual Student Unit Record (SUR) data for 1.7M students at 33 US
institutions (as of June 2021). MIDFIELD is large enough to permit
grouping and summarizing by multiple characteristics, enabling
researchers to examine student characteristics (race/ethnicity, sex,
prior achievement) and curricular pathways (including coursework and
major) by institution and over time.

**midfieldr** is an R package that provides tools for working with
MIDFIELD SURs. The tools in midfieldr work equally well with the
research data in MIDFIELD and the practice data in midfielddata.

[**midfielddata**](https://midfieldr.github.io/midfielddata/) is an R
package that provides practice data (a proportionate stratified sample
of MIDFIELD) with longitudinal SURs for nearly 98,000 undergraduates at
12 institutions from 1987–2016 organized in four data tables:

| Data set                                                                     | Each row is                           |  N rows | N columns |
|:-----------------------------------------------------------------------------|:--------------------------------------|--------:|----------:|
| [`student`](https://midfieldr.github.io/midfielddata/reference/student.html) | a student upon being admitted         |  97,640 |        13 |
| [`course`](https://midfieldr.github.io/midfielddata/reference/course.html)   | a student in a course                 |    3.5M |        12 |
| [`term`](https://midfieldr.github.io/midfielddata/reference/term.html)       | a student in a term                   | 728,000 |        13 |
| [`degree`](https://midfieldr.github.io/midfielddata/reference/degree.html)   | a student who completes their program |  48,000 |         5 |

## Usage

In this brief usage example, we compare counts of engineering students
by race/ethnicity, sex, and graduation status. Data manipulation is
performed using the data.table package.

``` r
# packages used 
library("midfieldr")
library("midfielddata")
library("data.table")

# Load the data tables
data(student, term, degree)

# Filter for engineering programs 
DT <- term[cip6 %like% "^14", .(mcid, institution, cip6)]
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
result <- DT[, .N, by = .(grad_status, sex, race)]
result[order(grad_status, sex, race)]
#>     grad_status    sex            race     N
#>          <char> <char>          <char> <int>
#>  1:        grad Female           Asian   182
#>  2:        grad Female           Black   433
#>  3:        grad Female Hispanic/Latinx    85
#>  4:        grad Female   International    30
#>  5:        grad Female Native American    14
#> ---                                         
#> 24:    non-grad   Male Hispanic/Latinx   176
#> 25:    non-grad   Male   International   157
#> 26:    non-grad   Male Native American    38
#> 27:    non-grad   Male   Other/Unknown   113
#> 28:    non-grad   Male           White  4423
```

## Requirements

-   [R](https://www.r-project.org/) (>= 3.5.0)
-   [midfielddata](https://midfieldr.github.io/midfielddata/) for
    practice working with student unit records.
-   [data.table](https://rdatatable.gitlab.io/data.table/) recommended
    for data manipulation, but not required.  
-   [ggplot2](https://ggplot2.tidyverse.org/) recommended for data
    graphics, but not required.

## Installation

To install the development version of midfieldr from
[GitHub](https://github.com/), type in the Console:

``` r
# install remotes
if (!require(remotes)) install.packages("remotes")

# install midfieldr
remotes::install_github("MIDFIELDR/midfieldr")
```

You can confirm a successful installation by running the following lines
to bring up the package help page in the Help window.

``` r
library("midfieldr")
help("midfieldr-package")
```

<img src="man/figures/README-midfieldr-help-page-1.png" width="75%" />

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

<img src="man/figures/README-midfielddata-help-page-1.png" width="75%" />

## Contributing

-   To contribute to midfieldr, clone this repo locally and commit your
    code on a separate branch. Please include runtime argument checks in
    functions using *checkmate* and write unit tests for your code using
    *tinytest*.
-   Please use the GitHub
    [Issues](https://github.com/MIDFIELDR/midfieldr/issues) page to
    report bugs or provide feedback.
-   Participation in this open source project is subject to a [Code of
    Conduct](CONDUCT.html).

## Related work

-   [midfielddata](https://midfieldr.github.io/midfielddata/) Sample of
    MIDFIELD student unit record data.
-   [MIDFIELD](https://engineering.purdue.edu/MIDFIELD) A partnership of
    US institutions.
-   [MIDFIELD
    workshops](https://midfieldr.github.io/2021-asee-workshop/) for
    additional information and tutorials.

## Acknowledgments

This work is supported by a grant from the US National Science
Foundation (EEC 1545667).

## License

*midfieldr* is licensed under GPL (>= 2)  
© 2018 Richard Layton, Russell Long, Matthew Ohland, Susan Lord, and
Marisa Orr
