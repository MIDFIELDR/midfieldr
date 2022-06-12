
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr

Tools for Studying MIDFIELD Student Unit Record Data in R

<!-- badges: start -->

[![R-CMD-check](https://github.com/MIDFIELDR/midfieldr/workflows/R-CMD-check/badge.svg)](https://github.com/MIDFIELDR/midfieldr/actions)
[![codecov](https://codecov.io/gh/MIDFIELDR/midfieldr/branch/main/graph/badge.svg?token=KcuCzBkLBP)](https://codecov.io/gh/MIDFIELDR/midfieldr)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/midfieldr)](http://cran.r-project.org/package=midfieldr)
[![License: GPL
v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
<!-- badges: end -->

The goal of midfieldr is to provide tools for working with MIDFIELD
data, a resource of longitudinal, de-identified, individual student unit
records.

## Overview

<a href="https://engineering.purdue.edu/MIDFIELD"
target="_blank"><strong>MIDFIELD</strong></a> contains individual
Student Unit Record (SUR) data for 1.7M students at 21 US institutions
(as of June 2022). MIDFIELD is large enough to permit grouping and
summarizing by multiple characteristics, enabling researchers to examine
student characteristics (race/ethnicity, sex, prior achievement) and
curricular pathways (including coursework and major) by institution and
over time.

**midfieldr** is an R package that provides tools for working with
MIDFIELD SURs. The tools in midfieldr work equally well with the
research data in MIDFIELD and the practice data in midfielddata.

<a href="https://midfieldr.github.io/midfielddata/"
target="_blank"><strong>midfielddata</strong></a> is an R package that
provides practice data (a proportionate stratified sample of MIDFIELD)
with longitudinal SURs for nearly 98,000 undergraduates at 12
institutions from 1987–2016 organized in four data tables:

<small>

| Practice data table                                                          | Each row is                                | No. of rows | No. of columns |
|:-----------------------------------------------------------------------------|:-------------------------------------------|------------:|---------------:|
| [`student`](https://midfieldr.github.io/midfielddata/reference/student.html) | a student upon admission as degree-seeking |      97,640 |             13 |
| [`course`](https://midfieldr.github.io/midfielddata/reference/course.html)   | a student in a course                      |        3.5M |             12 |
| [`term`](https://midfieldr.github.io/midfielddata/reference/term.html)       | a student in a term                        |     728,000 |             13 |
| [`degree`](https://midfieldr.github.io/midfielddata/reference/degree.html)   | a student upon completion of their program |      48,000 |              5 |

</small>

All four data tables are keyed by student ID. Tables `student` and
`degree` have one observation (row) per student. Tables `course` and
`term` have multiple observations per student because students can be
enrolled in more than one course in a term and more than one term over
their program.

## Usage

In a typical workflow, we filter (subset by row) student unit records to
retain desired observations, assign classifications such as program,
sex, or race/ethnicity, select variables (subset by column), group and
summarize, and display the results in graphs or tables.

Additional filtering is performed as needed at any point in the process.
In outline, the steps are:

-   filter
-   classify
-   count
-   display

In this brief usage example, we compare counts of engineering students
by race/ethnicity, sex, and graduation status. Data manipulation is
performed using data.table syntax.

``` r
# Packages used
library("midfieldr")
library("midfielddata")
suppressPackageStartupMessages(library("data.table"))

# Load the midfielddata practice data
data(student, term, degree)

# Initialize the working data table
DT <- copy(term)
```

**Filter.** We use “filter” to mean subsetting by rows to retain
observations with desired characteristics. In this example, we retain
observations for which: 1) the span of terms in the data are sufficient
for assessing program completion; 2) students are degree-seeking; and 3)
students are enrolled in the programs of interest and in this example
keeping the first instance only .

``` r
# Subset observations for data sufficiency
DT <- add_timely_term(DT, midfield_term = term)
DT <- add_data_sufficiency(DT, midfield_term = term)
DT <- DT[data_sufficiency == TRUE]

# Subset observations for degree-seeking
DT <- filter_match(DT, match_to = student, by_col = "mcid")

# Subset observations for programs
DT <- DT[cip6 %like% "^14"]

# Subset observations for unique students (first instance) 
DT <- DT[, .SD[1], by = c("mcid")]
```

**Classify.** Obtain 1) the students’ graduation status; and 2) student
sex and race/ethnicity.

``` r
# Determine graduation status
DT <- add_completion_timely(DT, midfield_degree = degree)
DT[, grad_status := fifelse(completion_timely, "grad", "non-grad")]

# Obtain sex and race/ethnicity
DT <- add_race_sex(DT, midfield_student = student)
```

**Filter.** Assume that the study design excludes students with
race/ethnicity of “International” and “Other/Unknown”. Now that the
race/ethnicity classification has been added, we can apply this filter.

``` r
# Filter for specific race/ethnicity data  
rows_we_want <- !DT$race %chin% c("International", "Other/Unknown")
DT <- DT[rows_we_want]
```

**Count.** Group and summarize by desired variables.

``` r
# Count by the grouping variables
grouping_variables <- c("grad_status", "sex", "race")
DT <- DT[, .N, by = grouping_variables]
```

**Display.** We use conventional data.table syntax for creating a
readable table. For charts like those shown in the vignettes, we use the
ggplot2 package.

``` r
# Combine two columns to create a wide table
DT[, race_sex := paste(race, sex)]
DT_display <- dcast(DT, race_sex ~ grad_status, value.var = "N")
DT_display[]
#>                   race_sex  grad non-grad
#>                     <char> <int>    <int>
#>  1:           Asian Female   126       81
#>  2:             Asian Male   396      272
#>  3:           Black Female   329      260
#>  4:             Black Male   397      552
#>  5: Hispanic/Latinx Female    64       28
#>  6:   Hispanic/Latinx Male   197      133
#>  7: Native American Female    10        6
#>  8:   Native American Male    27       30
#>  9:           White Female  1280      654
#> 10:             White Male  4739     2974
```

## Documentation

-   <a href="https://midfieldr.github.io/midfieldr/articles/"
    target="_blank">Articles.</a> For a listing of all vignettes.
-   <a href="https://midfieldr.github.io/midfieldr/reference/"
    target="_blank">Reference (midfieldr).</a> For a listing of all
    midfieldr functions and prepared data.
-   <a href="https://midfieldr.github.io/midfielddata/reference/"
    target="_blank">Reference (midfielddata).</a> For a listing of the
    four practice MIDFIELD data tables.

## Requirements

-   <a href="https://www.r-project.org/" target="_blank">R</a> (\>=
    3.5.0)
-   <a href="https://rdatatable.gitlab.io/data.table/"
    target="_blank">data.table</a> (\>= 1.9.8)  
-   <a href="https://ggplot2.tidyverse.org/" target="_blank">ggplot2</a>
    recommended for data graphics, but not required.

## Install midfieldr

midfieldr is not yet available from [CRAN](https://cran.r-project.org/).
To install the development version of midfieldr from its `drat`
repository, type in the Console:

``` r
# install midfieldr from drat repo
install.packages("midfieldr", 
                 repos = "https://MIDFIELDR.github.io/drat/", 
                 type = "source")
```

You can confirm a successful installation by running the following lines
to bring up the package help page in the Help window.

``` r
library("midfieldr")
help("midfieldr-package")
```

<img src="man/figures/README-midfieldr-help-page-1.png" width="75%" style="display: block; margin: auto;" />

## Install midfielddata

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

<img src="man/figures/README-midfielddata-help-page-1.png" width="75%" style="display: block; margin: auto;" />

## Contributing

To contribute to midfieldr,

-   Please clone this repo locally.  
-   Commit your code on a separate branch.
-   Use the *checkmate* package to include runtime argument checks in
    functions.
-   Use the *tinytest* package to write unit tests for your code. Save
    tests in the `inst/tinytest/` directory.

To provide feedback or report a bug,

-   Use the GitHub
    <a href="https://github.com/MIDFIELDR/midfieldr/issues"
    target="_blank">Issues</a> page.
-   Please run the package unit tests and report the results with your
    bug report. Any user can run the package tests by installing the
    *tinytest* package and running:

``` r
    test_results <- tinytest::test_package("midfieldr")
    as.data.frame(test_results)
```

Participation in this open source project is subject to a [Code of
Conduct](CONDUCT.html).

## Related work

-   [MIDFIELD](https://midfield.online/) a partnership of US higher
    education institutions with engineering programs.
-   [MIDFIELD
    workshops](https://midfieldr.github.io/2022-midfield-institute/) for
    additional information and tutorials.

## Acknowledgments

This work is supported by a grant from the US National Science
Foundation (EEC 1545667).

## License

midfieldr is licensed under GPL (\>= 2.0)  
© 2018–2022 Richard Layton, Russell Long, Matthew Ohland, Susan Lord,
and Marisa Orr
