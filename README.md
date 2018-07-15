
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr <span class="border-wrap"><img src="man/figures/midfieldhex04.png" align="right" height="122" width="106" alt="logo.png"></span>

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/midfieldr)](http://cran.r-project.org/package=midfieldr)
[![Build
Status](https://travis-ci.org/MIDFIELDR/midfieldr.svg?branch=master)](https://travis-ci.org/MIDFIELDR/midfieldr)
[![Coverage
Status](https://img.shields.io/codecov/c/github/MIDFIELDR/midfieldr/master.svg)](https://codecov.io/github/MIDFIELDR/midfieldr?branch=master)
[![](https://cranlogs.r-pkg.org/badges/grand-total/midfieldr)](https://cran.r-project.org/package=midfieldr)
[![License: GPL
v3](man/figures/License-GPL-v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A package for investigating student record data provided by registrars
at US universities participating in the MIDFIELD project.

Analytical tools for research in student pathways are generally scarce.
midfieldr provides an entry to this type of intersectional research for
anyone with basic proficiency in R and familiarity with packages from
the tidyverse.

midfieldr provides access to
[midfielddata](https://midfieldr.github.io/midfielddata/), a data
package containing a stratified sample of the MIDFIELD database. The
sample comprises demographic, term, course, and degree information for
97,640 undergraduate students from 1987 to 2016. The purpose of creating
these packages is to share our data, methods, and metrics for
intersectional research in student persistence. Potential audiences
include:

  - Researchers interested in student persistence metrics, especially if
    they are R novices
  - Institutional researchers responsible for reporting student
    persistence metrics
  - Statistics instructors looking for new data for their students
    explore

## Installation

midfieldr depends on midfielddata, a data package available from a [drat
repository](https://midfieldr.github.io/drat/) on GitHub. Install
midfielddata before installing midfieldr.

``` r
install.packages("drat")
drat::addRepo("midfieldr")
install.packages("midfielddata")
```

The development version of midfieldr can be installed from GitHub.

``` r
install.packages("devtools")
devtools::install_github("MIDFIELDR/midfieldr")
```

## Data

The midfieldr package includes:

  - `cip` A data frame with 1584 observations and 6 CIP variables of
    program codes and names at the 2, 4, and 6-digit levels. Each
    observation is a unique program. Occupies 364 kb of memory.

The midfielddata package contains the four datasets that comprise a
stratified sample of the MIDFIELD database.

  - `midfieldstudents` A data frame with 97,640 observations and 15
    demographic variables. Each observation is a unique student.
    Occupies 19 Mb of memory.

  - `midfieldcourses` A data frame with 3.5 M observations and 12
    academic course variables. Each observation is one course in one
    term for one student. Occupies 348 Mb of memory.

  - `midfieldterms` A data frame with 729,014 observations and 13
    academic term variables. Each observation is one term for one
    student. Occupies 82 Mb of memory.

  - `midfielddegrees` A data frame with 97,640 observations and 5
    graduation variables. Each observation is a unique student. Occupies
    10 Mb of memory.

## Usage

It’s hard to succinctly describe how midfieldr works because going from
raw unit-records to a grouped and summarized persistence metric entails
a number of operations. However, in most cases, you start with a metric
and a set of academic programs in mind and follow steps something like
this, using a combination of functions from the tidyverse and
specialized functions from midfieldr:

  - cip\_filter() to select programs from the CIP data
  - cip\_label() to add custom program labels for grouping
  - ever\_filter(), grad\_filter(), etc. to identify students
  - race\_sex\_join() to join student sex and race
  - group\_by() and summarize() to count students
  - join() and mutate() to compute a persistence metric  
  - multiway\_order() to prepare the results for graphing
  - ggplot() to graph the metric

A short but complete example is provided in the [Getting
started](getting_started.html) vignette.

## Meta

  - Data provided by the
    [MIDFIELD](https://engineering.purdue.edu/MIDFIELD) project
  - Get citation information with `citation("midfieldr")`
  - Please note that this project is released with a [Code of
    Conduct](https://midfieldr.github.io/midfieldr/CONDUCT.html). If you
    contribute to this project you agree to abide by its terms.
