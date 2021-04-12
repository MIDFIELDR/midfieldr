
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
Status](https://img.shields.io/codecov/c/github/MIDFIELDR/midfieldr/master.svg)](https://codecov.io/github/MIDFIELDR/midfieldr?branch=main)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

## Undergoing major revision

Based on feedback from workshop attendees, the package is undergoing
major revision to the vignettes and the underlying functionality. While
in this ambiguous state, the package should be used experimentally only.

We hope to have the update completed by July 2021.

## Tools for student records research

The *Multiple-Institution Database for Investigating Engineering
Longitudinal Development* (MIDFIELD) is a partnership of US higher
education institutions with engineering programs. MIDFIELD contains
registrar’s data for 1.7M undergraduates in all majors at 19
institutions from 1987–2019.

Our software environment comprises two R packages:

-   **midfieldr** An R package providing functions specialized for
    manipulating MIDFIELD data to examine the intersectionality of
    race/ethnicity, sex, and discipline in persistence metrics such as
    stickiness (retention by a discipline) and graduation rate.

-   **midfielddata** [(link)](https://midfieldr.github.io/midfielddata/)
    An R package with practice data for users to learn about student
    record analysis using R—definitions, assumptions, and methods.
    However, these data are not suitable for drawing inferences about
    student performance, i.e., not for research.

## Data

**CIP data**

midfieldr includes a Classification of Instructional Programs (CIP) data
set—a taxonomy of academic programs curated by the US National Center
for Education Statistics (NCES), Integrated Postsecondary Education Data
System (IPEDS).

-   `cip` Data frame with 1584 observations and 6 CIP variables of the
    2010 program codes and names at the 2, 4, and 6-digit levels. Each
    observation is a unique program keyed by a 6-digit CIP code.
    Occupies 380 kB of memory. Data dictionary
    [(link)](reference/cip.html).

**Student records data for practice**

The midfielddata package contains four data sets that are proportionate
stratified random samples of 12 institutions in the larger MIDFIELD data
sets. The sampling strata are institution, cip4 (the first four digits
of the 6-digit CIP code), transfer status, race/ethnicity, and sex.
Contains data for 97,640 undergraduates at 12 institutions from
1987–2016 in four data sets:

-   `midfieldstudents` Data frame with 97,640 observations and 15
    demographic variables. Each observation is a unique student keyed by
    student ID. Occupies 19 MB of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfieldstudents.html).

-   `midfieldcourses` Data frame with 3.5 M observations and 12 academic
    course variables keyed by student ID, term, and course. Each
    observation is one course in one term for one student. Occupies 349
    MB of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfieldcourses.html).

-   `midfieldterms` Data frame with 727,369 observations and 13 academic
    term variables keyed by student ID and term. Each observation is one
    term for one student. Occupies 82 MB of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfieldterms.html).

-   `midfielddegrees` A data frame with 97,640 observations and 5
    graduation variables keyed by student ID. Each observation is a
    unique student. Occupies 10.2 MB of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfielddegrees.html).

In making the midfielddata package public, confidentiality required some
variables to be anonymized and others to be omitted. Thus the data
dictionary of the practice data is a subset of the data dictionary of
the (complete MIDFUIELD) research data.

**Student records data for research**

Complete MIDFIELD data sets suitable for student-records research are
available to researchers under the following conditions:

-   Your institutional IRB has granted approval for your project to
    study students using MIDFIELD. At most institutions, the use of
    MIDFIELD data for research is in the IRB “Exempt” category, but
    institutional practices vary.

-   Each researcher using the data signs a letter of confidentiality
    describing the guidelines for how the data may be reported.

The research data and practice data have the same structure (students,
degrees, terms, and courses) with consistent variable names. Thus R
scripts written for the practice data should work as well with the
research data with only minor (if any) modification.

For more information about obtaining access to MIDFIELD research data,
contact Russell Long (<ralong@purdue.edu>)

## For the absolute R beginner

Experienced R users may skip this section. If you are an R novice and
need an introduction to the R environment, good introductory tutorials
are available. You might start with:

-   *Basic Basics* series by R Ladies Sydney
    [(link)](https://www.youtube.com/hashtag/ryouwithme). Step-by-step
    video tutorials.  
-   *A Beginner’s Guide to R* ([Zuur et al.,
    2009](#ref-Zuur+Ieno+Meesters:2009)). A good resource for the
    absolute R beginner.

## Install the data

Install midfielddata first.

Because of its size, the data package is stored in a `drat` repository.
Installation takes time; please be patient and wait for the Console
prompt “&gt;” to reappear.

``` r
# install midfielddata first 
install.packages("midfielddata", 
                 repos = "https://MIDFIELDR.github.io/drat/", 
                 type = "source")
```

To confirm a successful installation, run the following to view the
package help page.

``` r
library("midfielddata")
? midfielddata
```

If the installation is successful, the code chunk above should produce a
view of the help page as shown here. If this step is successful, you can
go on to the next step.

<img src="man/figures/README-midfielddata-help-page-2.png" alt="midfielddata help page" class="center" width="80%">

## Install midfieldr

We use the `install_github()` function from the remotes package to
install midfieldr from GitHub. (Note to experienced users: you can use
devtools if you have it installed. We suggest the remotes package to
reduce the number of imported packages.)

``` r
# install the remotes package
install.packages("remotes")

# install midfieldr from GitHub
remotes::install_github("MIDFIELDR/midfieldr")
```

To confirm a successful installation, run the following to view the
package help page.

``` r
library("midfieldr")
? midfieldr
```

If the installation is successful, the code chunk above should produce a
view of the help page as shown here.

<img src="man/figures/README-midfieldr-help-page-2.png" alt="midfieldr help page" class="center" width="80%">

## Usage

**midfieldr functions** work with MIDFIELD-structured data to access and
manipulate student records. A typical workflow might include:

-   `filter_text()` gather programs to study  
-   `prepare_fye_mi()` condition first-year-engineering data for
    multiple imputation
-   `add_grad_column()` add column to classify graduation rate status
-   `subset_feasible()` subset for 6-year completion feasibility
-   `prepare_multiway()` condition multiway data for graphing

**R ecosystem**. midfieldr uses data.table functions and syntax.
midfielddata data sets are class `data.table` and `data.frame`. However,
midfieldr functions attempt to preserve data frame extensions assigned
by the user (`tbl` for example). Thus users who prefer a different
“dialect” such as base R or dplyr should find that the package is
compatible with their preference.

In general the midfieldr vignettes use the following packages:

-   midfieldr
-   midfielddata
-   data.table ([Dowle and Srinivasan,
    2020](#ref-Dowle+Srinivasan:2020:data.table))
-   ggplot2 ([Wickham, 2016](#ref-Wickham:2016:ggplot2))

**Get started** vignette [(link)](articles/get_started.html) introduces
some of the basic midfieldr functions and the midfielddata data sets.
Additional vignettes (accessible from the *Vignettes* pull-down menu)
develop the material in more detail.

## Meta

-   For more information about MIDFIELD
    [(link)](https://engineering.purdue.edu/MIDFIELD)  
-   Get citation information with `citation("midfieldr")`
-   This project is released with a Code of Conduct
    [(link)](CONDUCT.html). If you contribute to this project you agree
    to abide by its terms.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-Dowle+Srinivasan:2020:data.table" class="csl-entry">

Dowle, Matt and Srinivasan, Arun (2020) *<span
class="nocase">data.table: Extension of data.frame</span>*. R package
version 1.13.0. Available at:
<https://CRAN.R-project.org/package=data.table>.

</div>

<div id="ref-Wickham:2016:ggplot2" class="csl-entry">

Wickham, Hadley (2016) *<span class="nocase">ggplot2: Elegant Graphics
for Data Analysis</span>*. ISBN 978-3-319-24277-4; Springer-Verlag New
York. Available at: <https://ggplot2.tidyverse.org>.

</div>

<div id="ref-Zuur+Ieno+Meesters:2009" class="csl-entry">

Zuur, Alain F., Ieno, Elena N. and Meesters, Erik H. W. G. (2009) *<span
class="nocase">A Beginner’s Guide to R</span>*. Springer. Available at:
<https://link.springer.com/book/10.1007/978-0-387-93837-0>.

</div>

</div>
