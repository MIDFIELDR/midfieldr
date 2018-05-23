
# midfieldr <a href="https://engineering.purdue.edu/MIDFIELD" target="blank"><img src="man/figures/midfieldcut.png" align="right"/></a>

<!-- [![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/midfieldr)](http://cran.r-project.org/package=midfieldr)  -->

[![Build
Status](https://travis-ci.org/MIDFIELDR/midfieldr.svg?branch=master)](https://travis-ci.org/MIDFIELDR/midfieldr)
[![License: GPL
v3](man/figures/License-GPL-v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

midfieldr is a package for investigating student record data provided by
registrars at US universities participating in the MIDFIELD project.

A stratified sample of the MIDFIELD database is accessible using
midfieldr. The sample comprises demographic, term, course, and degree
information for 97,640 undergraduate students from 1987 to 2016. Because
of their size, the sample datasets are provided in separate data
packages.

midfieldr includes functions for selecting specific fields of study and
aggregating, computing, and graphing student persistence metrics.

## Installation

midfieldr is not currently available from CRAN, but the development
version can be installed from GitHub with:

    install.packages("devtools")
    devtools::install_github("MIDFIELDR/midfieldr")

## Usage

The basic units for computing persistence metrics are the individual
student, course, term, program, or institution.

For investigating graduation rates

  - `gather_start()`
  - `gather_grad()`
  - `tally_gradrate()`
  - `graph_gradrate()`

For investigating stickiness

  - `gather_ever()`
  - `gather_grad()`
  - `tally_stickiness()`
  - `graph_stickiness()`

Helper functions

  - `cip_filter()`
  - `join_demographics()`
  - `count_and_fill()`

## Data

The sample of the MIDFIELD database that is accessible using midfieldr
and its data packages includes:

  - `cip` in the [midfieldr](https://github.com/MIDFIELDR/midfieldr)
    package. A tidy data frame with 1544 observations and 6 CIP
    variables of program codes and names at the 2, 4, and 6-digit
    levels. Each observation is a unique program. Occupies 362 kb of
    memory.

  - `midfieldstudents` in the
    [midfieldstudents](https://github.com/MIDFIELDR/midfieldstudents)
    package. A tidy data frame with 97,640 observations and 15
    demographic variables. Each observation is a unique student.
    Ooccupies 19 Mb of memory.

  - `midfieldcourses` in the
    [midfieldcourses](https://github.com/MIDFIELDR/midfieldcourses)
    package. A tidy data frame with 3.5 M observations and 12 academic
    course variables. Each observation is one course in one term for one
    student. Occupies 348 Mb of memory.

  - `midfieldterms` in the
    [midfieldterms](https://github.com/MIDFIELDR/midfieldterms) package.
    A tidy data frame with 729,014 observations and 13 academic term
    variables. Each observation is one term for one student. Occupies 82
    Mb of memory.

  - `midfielddegrees` in the
    [midfielddegrees](https://github.com/MIDFIELDR/midfielddegrees)
    package. A tidy data frame with 97,640 observations and 5 graduation
    variables. Each observation is a unique student. Occupies 10 Mb of
    memory.

## Meta

  - Please [report any issues or
    bugs](https://github.com/MIDFIELDR/midfieldr/issues).
  - License: GPL-3
  - Get citation information for `midfieldr` in R with `citation(package
    = 'midfieldr')`
  - Please note that this project is released with a [Contributor Code
    of Conduct](CONDUCT.md). By participating in this project you agree
    to abide by its terms.
