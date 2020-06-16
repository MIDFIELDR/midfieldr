
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
education institutions with engineering programs. As of June, 2019,
MIDFIELD contains registrar’s population data for 2.2M undergraduates at
20 institutions from 1987–2017. The data are organized in four related
tables: students, courses, terms, and degrees. The MIDFIELD population
data set is available to partner institutions only
[(link)](https://engineering.purdue.edu/MIDFIELD).

**midfieldr** is an R package that provides tools specialized for the
midfielddata sample data set.

**midfielddata** is an R package that provides a stratified sample of
the MIDFIELD population data set. The sample contains data for 97,640
undergraduates at 12 institutions from 1987–2016
[(link)](https://midfieldr.github.io/midfielddata/).

The midfielddata data dictionaries are a subset of the MIDFIELD
dictionaries. When creating the midfielddata sample data set, some
MIDFIELD variables were omitted and some were re-coded to preserve
confidentiality. In general, however, scripts written for the
midfielddata sample data set will work for the MIDFIELD population data
set.

## Installation

The data package is too large for CRAN, so it is stored on GitHub in a
drat repository. Installation takes time; please be patient and wait for
the Console prompt \> to reappear. Installation must be in the order
shown: install midfielddata before midfieldr.

``` r
install.packages("midfielddata", repos = "https://MIDFIELDR.github.io/drat/", type = "source")
```

Install the development version of midfieldr from GitHub using:

``` r
devtools::install_github("MIDFIELDR/midfieldr")
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

It’s hard to succinctly describe how midfieldr works because going from
raw unit-records to a grouped and summarized persistence metric entails
a number of operations. However, in most cases, you start with a metric
and a set of academic programs in mind and follow steps something like
this, using a combination of functions from the tidyverse and
specialized functions from midfieldr:

  - `cip_filter()` to select programs from the CIP data
  - `cip6_select()` to add custom program labels for grouping
  - `ever_filter()`, `grad_filter()`, etc. to identify students
  - `race_sex_join()` to join student sex and race
  - `group_summarize()` from seplyr to count students
  - `join()` and `mutate()` from dplyr to compute a persistence metric  
  - `multiway_order()` to prepare the results for graphing
  - `ggplot()` from ggplot2 to graph the metric

A short but complete example is provided in the “Getting started”
vignette [(link)](articles/getting_started.html).

## Meta

  - Data provided by MIDFIELD
    [(link)](https://engineering.purdue.edu/MIDFIELD)  
  - Get citation information with `citation("midfieldr")`
  - This project is released with a Code of Conduct
    [(link)](https://midfieldr.github.io/midfieldr/CONDUCT.html). If you
    contribute to this project you agree to abide by its terms.
