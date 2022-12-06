
<!-- README.md is generated from README.Rmd. Please edit that file -->

<br>`midfieldr` is an `R` package that provides tools and methods for
studying undergraduate student-level records from the MIDFIELD database.
Practice data supplied by `midfielddata`.

![](https://github.com/MIDFIELDR/midfieldr/blob/main/docs/logo.png?raw=true)

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/midfieldr)](https://CRAN.R-project.org/package=midfieldr)
[![R-CMD-check](https://github.com/MIDFIELDR/midfieldr/workflows/R-CMD-check/badge.svg)](https://github.com/MIDFIELDR/midfieldr/actions)
[![codecov](https://codecov.io/gh/MIDFIELDR/midfieldr/branch/main/graph/badge.svg?token=KcuCzBkLBP)](https://app.codecov.io/gh/MIDFIELDR/midfieldr)

<!-- [![CRAN check](https://badges.cranchecks.info/summary/midfieldr.svg)](https://cran.r-project.org/web/checks/check_results_midfieldr.html) -->
<!-- badges: end -->

## Introduction

`midfieldr` provides functions for working with undergraduate
“student-level” data from the MIDFIELD database. Data at the
“student-level” refers to information about individual students
including demographics, programs, academic standing, courses, grades,
and degrees. For [more information](#more-information) on data
structure, see the companion `R` package `midfielddata`.

`midfieldr` services include:

- `add_completion_status()` Determine completion status for every
  student
- `add_data_sufficiency()` Determine data sufficiency for every student
- `add_timely_term()` Calculate a timely completion term for every
  student
- `filter_cip()` Subset rows that include matches to search strings
- `order_multiway()` Order categorical variables of multiway data
- `prep_fye_mice()` Prepare FYE data for multiple imputation
- `same_content()` Test for equal content between two data tables
- `select_required()` Select required midfieldr variables

``` r
# Tools and methods
library(midfieldr)
packageVersion("midfieldr")
#> [1] '1.0.0.9029'

# Practice data
library(midfielddata)
packageVersion("midfielddata")
#> [1] '0.2.0'

# Rendered
format(Sys.Date(), "%Y-%m-%d")
#> [1] "2022-12-06"
```

*Note on syntax.*   We use `data.table` syntax for data manipulation.
Other systems, e.g., base R or `dplyr`, could be used instead; each
system has its strengths. Users are welcome to translate our examples to
their preferred syntax.

## Usage

A typical workflow for studying student-level records includes:

- Plan which records, programs, and metrics to use
- Gather relevant blocs of records
- Join appropriate grouping variables
- Compute metrics
- Create tables and charts to display results
- Assess findings and iterate.

In this example, we summarize the graduation status of engineering
students by race/ethnicity and sex.

``` r
# For data manipulation
library(data.table)

# Load the practice data
data(student, term, degree)
```

Reduce initial dimensions of data tables using `select_required()`.

``` r
# Reduce dimensions of source data tables
student <- select_required(student)
term <- select_required(term)
degree <- select_required(degree)
```

Filter for data sufficiency using `add_timely_term()` and
`add_data_sufficiency()`.

``` r
# Initialize the working data frame
DT <- term[, .(mcid, cip6)]

# Filter observations for data sufficiency
DT <- add_timely_term(DT, term)
DT <- add_data_sufficiency(DT, term)
DT <- DT[data_sufficiency == "include"]
```

Determine completion status using `add_completion_status()`.

``` r
# Inner join to filter observations for degree-seeking
cols_we_want <- student[, .(mcid)]
DT <- cols_we_want[DT, on = c("mcid"), nomatch = NULL]

# Filter observations for engineering programs
DT <- DT[cip6 %like% "^14"]

# Filter observations for unique students (first instance)
DT <- DT[, .SD[1], by = c("mcid")]

# Add completion status variable
DT <- add_completion_status(DT, degree)
```

Aggregate observations by groupings and display results.

``` r
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

## Installation

Install with:

``` r
install.packages("midfieldr",
  repos = "https://MIDFIELDR.github.io/drat/",
  type = "source"
)
```

Alternatively, you can install the development version from the MIDFIELD
GitHub repository:

``` r
install.packages("devtools")
devtools::install_github("MIDFIELDR/midfieldr")
```

## More information

[`midfielddata`](https://midfieldr.github.io/midfielddata/)  
A companion `R` package containing a proportionate, stratified sample of
the MIDFIELD database to practice using the tools and methods provided
by `midfieldr`.

[MIDFIELD](https://midfield.online/)  
A database of student-level records for approximately 1.7M
undergraduates at nineteen US institutions from 1987 through 2018, of
which `midfielddata` provides a sample. The full research database is
currently accessible to MIDFIELD partner institutions only.

## Acknowledgments

This work is supported by a grant from the US National Science
Foundation (EEC 1545667).
