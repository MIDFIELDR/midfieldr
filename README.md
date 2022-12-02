
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr

Tools for Studying MIDFIELD Student Unit Record Data in ‘R’

<!-- badges: start -->

[![R-CMD-check](https://github.com/MIDFIELDR/midfieldr/workflows/R-CMD-check/badge.svg)](https://github.com/MIDFIELDR/midfieldr/actions)
[![codecov](https://codecov.io/gh/MIDFIELDR/midfieldr/branch/main/graph/badge.svg?token=KcuCzBkLBP)](https://app.codecov.io/gh/MIDFIELDR/midfieldr)
[![CRAN
status](https://www.r-pkg.org/badges/version/midfieldr)](https://CRAN.R-project.org/package=midfieldr)
[![License:
MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.html)
<!-- badges: end -->

The goal of ‘midfieldr’ is to provide tools and methods for working with
longitudinal data from the MIDFIELD database.

## Overview

Provides tools for working with registrar’s data from
[**MIDFIELD**](https://midfield.online), a database containing (as of
October, 2022) Student Unit Records (SURs) for 1.7M undergraduate
students at 19 US institutions from 1987 through 2018.

Access to the research database is currently limited to MIDFIELD partner
institutions, but a sample of the data is available in the ‘R’ data
package [**‘midfielddata’**](https://midfieldr.github.io/midfielddata/),
providing practice data and documentation of anonymized SURs for
approximately 98,000 students at three US institutions from 1988 through
2018. These practice data, characterized in Table 1, are a proportionate
stratified sample of the MIDFIELD database.

The tools in **‘midfieldr’** are designed to work with both data
collections: the MIDFIELD research database and the **‘midfielddata’**
practice data.

<table class=" lightable-paper" style="font-family: &quot;Arial Narrow&quot;, arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;">
<caption>
Table 1: Attributes of the practice data tables in ‘midfielddata’
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
3,289,532
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
12
</td>
<td style="text-align:right;">
324 Mb
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
639,915
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
13
</td>
<td style="text-align:right;">
73 Mb
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
97,555
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
13
</td>
<td style="text-align:right;">
18 Mb
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
49,543
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
5
</td>
<td style="text-align:right;">
5 Mb
</td>
</tr>
</tbody>
</table>

All data tables are keyed by student ID. The `course` table has multiple
observations (rows) per student with one observation per student per
course per term. The `term` table also has multiple rows per student,
with one observation per student per term. The `degree` table has one
observation per student per degree and `student` has one observation per
student.

*Caveat.*   The data in ‘midfielddata’ are practice data, suitable for
learning to work with Student Unit Records (SURs) generally. Unlike the
MIDFIELD research database, the data tables in ‘midfielddata’ are not
research data; they are not suitable for drawing inferences about
program attributes or student experiences.

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
library(midfieldr)
library(midfielddata)
library(data.table)

# Load the practice data
data(student, term, degree, package = "midfielddata")

# Reduce dimensions of source data tables
student <- select_required(student)
term <- select_required(term)
degree <- select_required(degree)

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
DT_display <- dcast(DT_display, people ~ completion_status, value.var = "N", fill = 0)

# Prepare the table for display
setcolorder(DT_display, c("people", "timely", "late"))
setkeyv(DT_display, c("people"))
setnames(DT_display,
  old = c("people", "timely", "late", "NA"),
  new = c("People", "Timely completion", "Late completion", "Did not complete")
)
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
87
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
4
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
43
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Asian Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
315
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
19
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
163
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Black Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
26
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
3
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
39
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Black Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
80
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
5
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
84
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
International Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
110
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
9
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
51
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
International Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
501
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
41
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
280
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Latine Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
36
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
3
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
31
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Latine Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
181
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
19
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
102
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Native American Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
2
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
0
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
2
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Native American Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
13
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
3
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
6
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
White Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
985
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
51
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
386
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
White Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
4100
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
269
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
2034
</td>
</tr>
</tbody>
</table>

## Documentation

- [Vignettes](https://midfieldr.github.io/midfieldr/articles/)   for
  details on usage and methods.  
- [Reference page
  ‘midfieldr’](https://midfieldr.github.io/midfieldr/reference/)   for
  function help pages.
- [Reference page
  ‘midfielddata’](https://midfieldr.github.io/midfielddata/reference/)  
  for help pages and data dictionaries for `student`, `course`, `term`,
  and `degree`.

## Requirements

- [‘R’](https://www.r-project.org/) (\>= 3.5.0)
- [‘data.table’](https://rdatatable.gitlab.io/data.table/) (\>= 1.9.8)  
- [‘ggplot2’](https://ggplot2.tidyverse.org/) recommended for data
  graphics, but not required.

## Install ‘midfieldr’

‘midfieldr’ is not yet available from
[CRAN](https://cran.r-project.org/). To install the development version
of ‘midfieldr’ from its ‘drat’ repository, type in the Console:

``` r
# Install 'midfieldr' from drat repo
install.packages("midfieldr", 
                 repos = "https://MIDFIELDR.github.io/drat/", 
                 type = "source")
```

You can confirm a successful installation by running the following lines
to bring up the package help page in the Help window.

``` r
# Run in Console
library(midfieldr)
help(midfieldr-package)
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
library(midfielddata)
help("midfielddata-package")
```

<img src="man/figures/README-midfielddata-help-page-1.png"
style="width:100.0%" />

## Contributing

To contribute to ‘midfieldr’,

- Please clone this repo locally.  
- Commit your contribution on a separate branch.
- If you submit a function, please use the *checkmate* package to
  include runtime argument checks and the *tinytest* package to write
  unit tests for your code. Save tests in the `inst/tinytest/`
  directory.

To provide feedback or report a bug,

- Use the GitHub [Issues](https://github.com/MIDFIELDR/midfieldr/issues)
  page.
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

## License

[MIT](LICENSE.html) + file [LICENSE](LICENSE-text.html)

## Acknowledgments

This work is supported by a grant from the US National Science
Foundation (EEC 1545667).
