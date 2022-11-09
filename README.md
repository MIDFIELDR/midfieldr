
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr

Tools for Studying MIDFIELD Student Unit Record Data in R

<!-- badges: start -->

[![R-CMD-check](https://github.com/MIDFIELDR/midfieldr/workflows/R-CMD-check/badge.svg)](https://github.com/MIDFIELDR/midfieldr/actions)
[![codecov](https://codecov.io/gh/MIDFIELDR/midfieldr/branch/main/graph/badge.svg?token=KcuCzBkLBP)](https://app.codecov.io/gh/MIDFIELDR/midfieldr)
[![CRAN
status](https://www.r-pkg.org/badges/version/midfieldr)](https://CRAN.R-project.org/package=midfieldr)
[![License: GPL
v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
<!-- badges: end -->

The goal of midfieldr is to provide tools and guides for working with
longitudinal data from the MIDFIELD database.

## Overview

<a href="https://midfield.online"
target="_blank"><strong>MIDFIELD</strong></a> (as of June 2022) contains
Student Unit Records (SURs) of 1.7M undergraduates at nineteen US
institutions from 1987 through 2018, though different institutions
provide data over different time spans. MIDFIELD is large enough to
permit summarizing by multiple characteristics such as race/ethnicity,
sex, and program.

Access to the MIDFIELD research database is currently limited to
MIDFIELD partner institutions. However, a sample of the data are
accessible via the midfielddata R package.

**midfieldr** is an R package that provides tools for working with
MIDFIELD SURs, both MIDFIELD research data and midfielddata practice
data.

[**midfielddata**](https://midfieldr.github.io/midfielddata/) is an R
data package that provides a proportionate stratified sample of the
MIDFIELD research data. The sample contains anonymized SURs for nearly
98,000 undergraduates at 12 institutions from 1987–2016. We refer to
these sample data tables as the MIDFIELD *practice* data, suitable for
practice working with SURs but not for drawing inferences about program
attributes or student experiences. The practice data are characterized
in Table 1.

<table class=" lightable-paper" style="font-family: &quot;Arial Narrow&quot;, arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;">
<caption>
Table 1: Attributes of the practice data tables in midfielddata
</caption>
<thead>
<tr>
<th style="text-align:left;background-color: #c7eae5 !important;">
Practice data table
</th>
<th style="text-align:left;background-color: #c7eae5 !important;">
Each row is
</th>
<th style="text-align:right;background-color: #c7eae5 !important;">
No. of rows
</th>
<th style="text-align:right;background-color: #c7eae5 !important;">
No. of columns
</th>
<th style="text-align:right;background-color: #c7eae5 !important;">
Memory
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;font-family: monospace;color: black !important;background-color: white !important;">
course
</td>
<td style="text-align:left;color: black !important;background-color: white !important;">
a student in a course
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
3,439,936
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
12
</td>
<td style="text-align:right;">
340 Mb
</td>
</tr>
<tr>
<td style="text-align:left;font-family: monospace;color: black !important;background-color: white !important;">
term
</td>
<td style="text-align:left;color: black !important;background-color: white !important;">
a student in a term
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
710,841
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
13
</td>
<td style="text-align:right;">
80 Mb
</td>
</tr>
<tr>
<td style="text-align:left;font-family: monospace;color: black !important;background-color: white !important;">
student
</td>
<td style="text-align:left;color: black !important;background-color: white !important;">
a degree-seeking student
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
97,640
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
13
</td>
<td style="text-align:right;">
19 Mb
</td>
</tr>
<tr>
<td style="text-align:left;font-family: monospace;color: black !important;background-color: white !important;">
degree
</td>
<td style="text-align:left;color: black !important;background-color: white !important;">
a student who graduates
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
47,499
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
5
</td>
<td style="text-align:right;">
10.2 Mb
</td>
</tr>
</tbody>
</table>

All four data tables (in both the research data and the practice data)
are keyed by student ID. The `course` table has multiple observations
(rows) per student with one observation per student per course. The
`term` table also has multiple rows per student, with one observation
per student per term. The `student` and `degree` tables each have one
observation per student.

## Usage

The outline of a typical workflow is:

- Plan which records, programs, and metrics to use
- Gather relevant blocs of records
- Join appropriate grouping variables
- Compute metrics
- Create tables and charts to display results
- Assess findings and iterate.

To illustrate usage, we tabulate counts of engineering students by
race/ethnicity, sex, and graduation status. Data processing is performed
using data.table syntax.

``` r
# Packages used
library("midfieldr")
library("midfielddata")
suppressPackageStartupMessages(library("data.table"))

# Load the practice data
data(student, term, degree, package = "midfielddata")

# Reduce dimensions of source data tables
student <- select_required(student)
term    <- select_required(term)
degree  <- select_required(degree)

# Initialize the working data frame
DT <- term[, .(mcid, cip6)]

# Filter observations for data sufficiency
DT <- add_timely_term(DT, term)
DT <- add_data_sufficiency(DT, term)
DT <- DT[data_sufficiency == "include"]

# Inner join to filter observations for degree-seeking
cols_we_want <- student[, .(mcid)]
DT <- cols_we_want[DT, on = c("mcid"), nomatch = NULL]

# Filter observations for engineering programs
DT <- DT[cip6 %like% "^14"]

# Filter observations for unique students (first instance)
DT <- DT[, .SD[1], by = c("mcid")]

# Add completion status variable
DT <- add_completion_status(DT, degree)

# Left join to add race/ethnicity and sex variables (omit unknowns)
cols_we_want <- student[, .(mcid, race, sex)]
DT <- student[DT, on = c("mcid")]
DT <- DT[!(race %ilike% "unknown" | sex %ilike% "unknown")]

# Create a variable combining race/ethnicity and sex
DT[, people := paste(race, sex)]

# Aggregate observations by groupings
DT_display <- DT[, .N, by = c("completion_status", "people")]

# Transform to row-record form
DT_display <- dcast(DT_display, people ~ completion_status, value.var = "N")

# Prepare the table for display 
setcolorder(DT_display, c("people", "timely", "late"))
setkeyv(DT_display, c("people"))
setnames(DT_display,
         old = c("people", "timely", "late", "NA"),
         new = c("People", "Timely completion", "Late completion", "Did not complete"))
```

Tabulated results of usage example are shown in Table 2, ordered
alphabetically. “Timely completion” is the count of graduates completing
their programs in no more than 6 years; “Late completion” is the count
of those graduating in more than 6 years; “Did not complete” is the
count of non-graduates.

<table class=" lightable-paper" style="font-family: &quot;Arial Narrow&quot;, arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;">
<caption>
Table 2: Completion status of engineering undergraduates in the practice
data
</caption>
<thead>
<tr>
<th style="text-align:left;background-color: #c7eae5 !important;">
People
</th>
<th style="text-align:right;background-color: #c7eae5 !important;">
Timely completion
</th>
<th style="text-align:right;background-color: #c7eae5 !important;">
Late completion
</th>
<th style="text-align:right;background-color: #c7eae5 !important;">
Did not complete
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Asian Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
124
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
19
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
59
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Asian Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
388
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
89
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
180
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Black Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
309
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
47
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
201
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Black Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
376
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
104
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
423
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
International Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
22
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
6
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
12
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
International Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
114
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
30
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
74
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Latine Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
63
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
6
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
21
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Latine Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
188
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
27
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
103
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Native American Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
10
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
3
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
3
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Native American Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
27
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
11
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
19
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
White Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
1226
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
154
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
468
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
White Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
4527
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
634
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
2191
</td>
</tr>
</tbody>
</table>

## Documentation

- <a href="https://midfieldr.github.io/midfieldr/articles/"
  target="_blank">Articles.</a> For a listing of all vignettes.
- <a href="https://midfieldr.github.io/midfieldr/reference/"
  target="_blank">Reference (midfieldr).</a> For a listing of all
  midfieldr functions and prepared data.
- <a href="https://midfieldr.github.io/midfielddata/reference/"
  target="_blank">Reference (midfielddata).</a> For a listing of the
  four practice MIDFIELD data tables.

## Requirements

- <a href="https://www.r-project.org/" target="_blank">R</a> (\>= 3.5.0)
- <a href="https://rdatatable.gitlab.io/data.table/"
  target="_blank">data.table</a> (\>= 1.9.8)  
- <a href="https://ggplot2.tidyverse.org/" target="_blank">ggplot2</a>
  recommended for data graphics, but not required.

## Install midfieldr

midfieldr is not yet available from [CRAN](https://cran.r-project.org/).
To install the development version of midfieldr from its `drat`
repository, type in the Console:

``` r
# Install midfieldr from drat repo
install.packages("midfieldr", 
                 repos = "https://MIDFIELDR.github.io/drat/", 
                 type = "source")
```

You can confirm a successful installation by running the following lines
to bring up the package help page in the Help window.

``` r
# Run in Console
library("midfieldr")
help("midfieldr-package")
```

<img src="man/figures/README-midfieldr-help-page-1.png"
style="width:100.0%" />

## Install midfielddata

Because of its size, installing the practice data takes time; please be
patient and wait for the prompt “\>” to reappear. In the Console, run:

``` r
# Install midfielddata  
install.packages("midfielddata", 
                 repos = "https://MIDFIELDR.github.io/drat/", 
                 type = "source")
# be patient
```

You can confirm a successful installation by running the following lines
to bring up the package help page in the Help window.

``` r
# Run in Console
library("midfielddata")
help("midfielddata-package")
```

<img src="man/figures/README-midfielddata-help-page-1.png"
style="width:100.0%" />

## Contributing

To contribute to midfieldr,

- Please clone this repo locally.  
- Commit your contribution on a separate branch.
- If you submit a function, please use the *checkmate* package to
  include runtime argument checks and the *tinytest* package to write
  unit tests for your code. Save tests in the `inst/tinytest/`
  directory.

To provide feedback or report a bug,

- Use the GitHub <a href="https://github.com/MIDFIELDR/midfieldr/issues"
  target="_blank">Issues</a> page.
- Please run the package unit tests and report the results with your bug
  report. Any user can run the package tests by installing the
  *tinytest* package and running:

``` r
# Detailed test results
test_results <- tinytest::test_package("midfieldr")
as.data.frame(test_results)
```

Participation in this open source project is subject to a [Code of
Conduct](CONDUCT.html).

## Acknowledgments

This work is supported by a grant from the US National Science
Foundation (EEC 1545667).

## License

midfieldr is licensed under GPL (\>= 2.0) [(full
license)](LICENSE.html)  
© 2018–2022 Richard Layton, Russell Long, Susan Lord, Matthew Ohland,
and Marisa Orr.
