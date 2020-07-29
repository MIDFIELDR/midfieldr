
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr <span class="border-wrap"><img src="man/figures/logo.png" align="right" height="122" width="106" alt="logo.png"></span>

[![License: GPL
v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/midfieldr)](https://cran.r-project.org/package=midfieldr)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/midfieldr)](http://cran.r-project.org/package=midfieldr)
[![Build
Status](https://travis-ci.org/MIDFIELDR/midfieldr.svg?branch=master)](https://travis-ci.org/MIDFIELDR/midfieldr)
[![Coverage
Status](https://img.shields.io/codecov/c/github/MIDFIELDR/midfieldr/master.svg)](https://codecov.io/github/MIDFIELDR/midfieldr?branch=master)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

## Undergoing major revision

Based on feedback from workshop attendees, the package is undergoing
major revision to the vignettes and the underlying functionality.

While in this ambiguous state, the package should be used experimentally
only. We hope to have the update complete by the end of August 2020.

## Tools for student records research

The *Multiple-Institution Database for Investigating Engineering
Longitudinal Development*
[(MIDFIELD)](https://engineering.purdue.edu/MIDFIELD) is a partnership
of US higher education institutions with engineering programs. MIDFIELD
contains registrar’s data for 1.7M undergraduates in all majors at 19
institutions from 1987–2019. The data are organized in four related
tables: students, courses, terms, and degrees. A MIDFIELD sample is
provided in the midfielddata package.

**midfielddata** [(link)](https://midfieldr.github.io/midfielddata/) A
stratified sample of MIDFIELD data. Contains data for 97,640
undergraduates at 12 institutions from 1987–2016 in four data sets:
`midfieldstudents`, `midfieldcourses`, `midfieldterms`, and
`midfielddegrees`.

**midfieldr** Tools for studying student records from midfielddata or
the larger MIDFIELD database. Enables research in the intersectionality
of race/ethnicity, sex, and discipline with metrics such as stickiness
(retention by a discipline), migrator graduation rate, and migration
yield (attraction of a discipline).

For MIDFIELD partner researchers: In making the midfielddata package
public, confidentiality required some MIDFIELD variables to be
anonymized and others to be omitted. Thus the midfielddata data
dictionary is a subset of the MIDFIELD data dictionary.

<br> <a href="#top">▲ top of page</a>

## Installation

Install midfielddata first.

Because of its size, the data package is stored in a drat repository.
Installation takes time; please be patient and wait for the Console
prompt “\>” to reappear.

``` r
# install midfielddata first 
install.packages("midfielddata", 
                 repos = "https://MIDFIELDR.github.io/drat/", 
                 type = "source")
```

To confirm a successful installation, run the following to view the
package help page.

``` r
library(midfielddata)
? midfielddata
```

If the installation is successful, the code chunk above should produce a
view of the help page as shown here.

<img src="man/figures/README-midfielddata-help-page-2.png" alt="midfielddata help page" class="center" width="80%">

Once you have conformed that midfielddata is successfully installed,
install midfieldr. The package is currently available from GitHub, but
should be submitted to CRAN by September 2020.

``` r
# install from CRAN (not yet available)
# install.packages("midfieldr")

# or install the development version from GitHub (available now)
# install.packages("devtools")
devtools::install_github("MIDFIELDR/midfieldr")
```

<br> <a href="#top">▲ top of page</a>

## Data

The midfieldr package includes:

  - `cip` Data frame with 1584 observations and 6 CIP variables of
    program codes and names at the 2, 4, and 6-digit levels. Each
    observation is a unique program keyed by a 6-digit CIP code.
    Occupies 380 kB of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfieldr/reference/cip.html).

The midfielddata package contains four data sets that constitute a
stratified sample of the MIDFIELD database.

  - `midfieldstudents` Data frame with 97,640 observations and 15
    demographic variables. Each observation is a unique student keyed by
    student ID. Occupies 19 MB of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfieldstudents.html).

  - `midfieldcourses` Data frame with 3.5 M observations and 12 academic
    course variables keyed by student ID, term, and course. Each
    observation is one course in one term for one student. Occupies 349
    MB of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfieldcourses.html).

  - `midfieldterms` Data frame with 727,369 observations and 13 academic
    term variables keyed by student ID and term. Each observation is one
    term for one student. Occupies 82 MB of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfieldterms.html).

  - `midfielddegrees` A data frame with 97,640 observations and 5
    graduation variables keyed by student ID. Each observation is a
    unique student. Occupies 10.2 MB of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfielddegrees.html).

<br> <a href="#top">▲ top of page</a>

## Usage

**midfieldr functions** are designed to work with MIDFIELD-structured
data to access and manipulate student records. A typical workflow might
include:

  - `get_cip()` search the CIP data set for program codes  
  - `label_programs()` isolate and label specific programs to study  
  - `get_enrollees()` gather students ever enrolled in the programs
  - `completion_feasible()` subset students for 6-year completion
    feasibility
  - `get_race_sex()` obtain student sex and race/ethnicity
  - `order_multiway()` condition multiway data for graphing

**R ecosystem**. midfieldr uses data.table functions and syntax.
midfielddata data sets are class `data.table` and `data.frame`. However,
midfieldr functions attempt to preserve data frame extensions assigned
by the user (`tbl` for example). Thus users who prefer a different
ecosystem such as dplyr should find that the package is compatible with
their preference.

In general the midfieldr vignettes use the following packages:

  - midfieldr
  - midfielddata
  - data.table (Dowle and Srinivasan,
    [2020](#ref-Dowle+Srinivasan:2020:data.table))
  - ggplot2 (Wickham, [2016](#ref-Wickham:2016:ggplot2))

**example**. The *Getting started* vignette
[(link)](getting_started.html) introduces some of the basic midfieldr
functions and the midfielddata data sets. Additional vignettes develop
the material in more detail.

## Meta

  - Data provided by MIDFIELD
    [(link)](https://engineering.purdue.edu/MIDFIELD)  
  - Get citation information with `citation("midfieldr")`
  - This project is released with a Code of Conduct
    [(link)](https://midfieldr.github.io/midfieldr/CONDUCT.html). If you
    contribute to this project you agree to abide by its terms.

## References

<div id="refs">

<div id="ref-Dowle+Srinivasan:2020:data.table">

Dowle M and Srinivasan A (2020) *data.table: Extension of ‘data.frame‘.*
R package version 1.13.0 <https://CRAN.R-project.org/package=data.table>

</div>

<div id="ref-Wickham:2016:ggplot2">

Wickham H (2016) *ggplot2: Elegant Graphics for Data Analysis.* ISBN
978-3-319-24277-4; Springer-Verlag New York
<https://ggplot2.tidyverse.org>

</div>

</div>

<br> <a href="#top">▲ top of page</a>
