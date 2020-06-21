
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr <span class="border-wrap"><img src="man/figures/logo.png" align="right" height="122" width="106" alt="logo.png"></span>

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/midfieldr)](http://cran.r-project.org/package=midfieldr)
[![Build
Status](https://travis-ci.org/MIDFIELDR/midfieldr.svg?branch=master)](https://travis-ci.org/MIDFIELDR/midfieldr)
[![Coverage
Status](https://img.shields.io/codecov/c/github/MIDFIELDR/midfieldr/master.svg)](https://codecov.io/github/MIDFIELDR/midfieldr?branch=master)
[![](https://cranlogs.r-pkg.org/badges/grand-total/midfieldr)](https://cran.r-project.org/package=midfieldr)
[![License: GPL
v3](man/figures/License-GPL-v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Tools for student records research

MIDFIELD—the *Multiple-Institution Database for Investigating
Engineering Longitudinal Development*—is a partnership of US higher
education institutions with engineering programs. As of June, 2020,
MIDFIELD contains registrar’s population data for 1.7M undergraduates at
19 institutions from 1987–2019. The data are organized in four related
tables: students, courses, terms, and degrees. The MIDFIELD population
data set is available to partner institutions only
[(link)](https://engineering.purdue.edu/MIDFIELD).

**midfieldr** is an R package that provides tools specialized for the
midfielddata sample data set.

**midfielddata** is an R package that provides a stratified sample of
the MIDFIELD population data set. The sample contains data for 97,640
undergraduates at 12 institutions from 1987–2016
[(link)](https://midfieldr.github.io/midfielddata/).

For members of MIDFIELD partner institutions: The midfielddata data
dictionaries are a subset of the MIDFIELD data dictionaries. When
creating the midfielddata sample data set, some MIDFIELD variables were
omitted and some were re-coded to preserve confidentiality. In general,
however, scripts written for the midfielddata sample data set will work
for the MIDFIELD population data set.

## Installation

The data package is too large for CRAN, so it is stored on GitHub in a
drat repository. Installation takes time; please be patient and wait for
the Console prompt \> to reappear.

Installation must be in the order shown: install midfielddata before
midfieldr.

``` r
install.packages("midfielddata", repos = "https://MIDFIELDR.github.io/drat/", type = "source")
```

Install the development version of midfieldr from GitHub using:

``` r
devtools::install_github("MIDFIELDR/midfieldr")
```

Once midfieldr is available on CRAN (planned for the summer of 2020),
use:

``` r
install.packages("midfieldr")
```

## Data

The midfieldr package includes:

  - `cip` A data frame with 1584 observations and 6 CIP variables of
    program codes and names at the 2, 4, and 6-digit levels. Each
    observation is a unique program. Occupies 364 kB of memory. Data
    dictionary
    [(link)](https://midfieldr.github.io/midfieldr/reference/cip.html).

The midfielddata package contains the four datasets that comprise a
stratified sample of the MIDFIELD database.

  - `midfieldstudents` A data frame with 97,640 observations and 15
    demographic variables. Each observation is a unique student.
    Occupies 19 Mb of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfieldstudents.html).

  - `midfieldcourses` A data frame with 3.5 M observations and 12
    academic course variables. Each observation is one course in one
    term for one student. Occupies 348 Mb of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfieldcourses.html).

  - `midfieldterms` A data frame with 727,369 observations and 13
    academic term variables. Each observation is one term for one
    student. Occupies 82 Mb of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfieldterms.html).

  - `midfielddegrees` A data frame with 97,640 observations and 5
    graduation variables. Each observation is a unique student. Occupies
    10 Mb of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfielddegrees.html).

## Usage

This package provides functions to access, manipulate, and graph student
record data. To illustrate the workflow, we would use these functions to
compute and display the “stickiness” persistence metric:

  - `cip_filter()` to filter programs from the CIP data.
  - `cip6_select()` to select 6-digit CIPs and add custom labels.
  - `gather_ever()` to gather students ever enrolled.
  - `gather_grad()` to gather graduating students.
  - `race_sex_join()` to join student sex and race/ethnicity.
  - dplyr package (or equivalent) to group, summarize, join, and compute
    a persistence metric.
  - `multiway_order()` to prepare the results for graphing.
  - ggplot2 package (or equivalent) to graph the results.

A short but complete example is provided in the “Using midfieldr”
vignette [(link)](articles/using_midfieldr.html).

## Meta

  - Data provided by MIDFIELD
    [(link)](https://engineering.purdue.edu/MIDFIELD)  
  - Get citation information with `citation("midfieldr")`
  - This project is released with a Code of Conduct
    [(link)](https://midfieldr.github.io/midfieldr/CONDUCT.html). If you
    contribute to this project you agree to abide by its terms.
