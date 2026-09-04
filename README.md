
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr <img src="man/figures/logo.png" align="right" height="125K">

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/midfieldr)](https://cran.r-project.org/package=midfieldr)  
[![R CMD
check](https://github.com/MIDFIELDR/midfieldr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MIDFIELDR/midfieldr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

An R package that supplies tools for working with longitudinal
undergraduate records from the MIDFIELD, or similarly structured,
database.

- `completion_status()` identifies IDs to include for timely completion.
- `data_sufficiency()` identifies IDs to exclude due to insufficient
  data.  
- `filter_programs()` helps you find 6-digit program codes.  
- `order_multiway()` conditions data for Cleveland multiway charts.  
- `prep_fye_mice()` conditions data for imputing starting majors of FYE
  students.
- `qualification_level()` identifies post-first-degree terms to exclude.
- `select_basic_cols()` minimizes columns for interactive sessions.  
- `timely_term()` estimates terms of timely completion.

## Installation

Install from CRAN with:

``` r
install.packages("midfieldr")
```

To get a bug fix or preview a new feature, you can install the
development version from GitHub.

``` r
# install.packages("pak")
pak::pak("MIDFIELDR/midfieldr")
```

midfieldr is designed to operate on the MIDFIELD database ([Ohland
2023](#ref-ohland:midfield:2023)) or similarly structured data such as
the MIDFIELD sample in
[midfielddata](https://midfieldr.github.io/midfielddata/), an R data
package you can download from GitHub. All midfieldr articles use the
data tables from midfielddata.

``` r
install.packages("midfielddata",
  repos = "https://MIDFIELDR.github.io/drat/",
  type = "source"
)
```

For information on accessing the MIDFIELD database for research, contact
the American Society for Engineering Education (ASEE).

## Usage

We illustrate usage with a small sample that loads with midfieldr for
use in such examples. These data frames
`(toy_student, toy_term, toy_course, toy_degree)` have the same
structure as the practice data in midfielddata. Academic program names
and codes in the `cip` dataset also loads with midfieldr.

``` r
library("midfieldr")
library("data.table")

# small sample of student records
student <- copy(toy_student)
term <- copy(toy_term)
course <- copy(toy_course)
degree <- copy(toy_degree)

# identify undergraduate terms
term <- qualification_level(term, midf_table = degree)
course <- qualification_level(course, midf_table = degree)
degree <- qualification_level(degree, midf_table = degree)

# filter to retain undergraduate terms only
term <- term[qual_level == "undergrad"]
course <- course[qual_level == "undergrad"]
degree <- degree[qual_level == "undergrad"]

# remove temporary columns
term[, c("bacc", "qual_level") := NULL]
course[, c("bacc", "qual_level") := NULL]
degree[, c("bacc", "qual_level") := NULL]

# filter for data sufficiency to obtain the population
DT <- unique(term[, .(mcid)])
DT <- timely_term(DT, midf_table = term)
DT <- data_sufficiency(DT, midf_table = term)
population <- DT[sufficiency == "satisfied", .(mcid)]

# filter records to match this population
student <- population[student, on = "mcid", nomatch = NULL]
term <- population[term, on = "mcid", nomatch = NULL]
course <- population[course, on = "mcid", nomatch = NULL]
degree <- population[degree, on = "mcid", nomatch = NULL]

# create program data frame for three programs: Mechanical
# Engineering (CIP code 1419), General Psychology (CIP code 4201),
# and Business, Managerial Operations (CIP code 5202).
programs <- filter_programs(cip, c("^1419", "^4201", "^5202"))
programs <- programs[, .(cip6name, cip6)]

# add custom labels, select 6-digit codes
programs[, program := fcase(
  cip6 %like% "^1419", "Mech Engr",
  cip6 %like% "^4201", "Genl Psych",
  cip6 %like% "^5202", "Bus Mng Op"
)]
programs <- programs[, .(cip6, program)]

# filter records for the study programs
term <- term[programs, on = "cip6", nomatch = NULL]
degree <- degree[programs, on = "cip6", nomatch = NULL]

# filter population to match IDs in the programs
enrolled <- unique(rbindlist(list(term[, .(mcid)], degree[, .(mcid)])))
population <- enrolled[population, on = "mcid", nomatch = NULL]

# filter remaining records for the study programs
student <- population[student, on = "mcid", nomatch = NULL]
course <- population[course, on = "mcid", nomatch = NULL]

# records ready for further analysis (first few columns)
look_at(student[, 1:6])
#> Classes 'data.table' and 'data.frame':   45 obs. of  6 variables:
#>  $ mcid          : chr  "MCID3111265287" "MCID3111312495" "MCID3111391443" "M"..
#>  $ race          : chr  "White" "White" "White" "White" ...
#>  $ sex           : chr  "Male" "Male" "Female" "Male" ...
#>  $ institution   : chr  "Institution B" "Institution B" "Institution J" "Inst"..
#>  $ transfer      : chr  "First-Time Transfer" "First-Time Transfer" "First-Ti"..
#>  $ hours_transfer: num  92 13 NA 1 NA NA 26 NA NA NA ...

look_at(term[, 1:6])
#> Classes 'data.table' and 'data.frame':   214 obs. of  6 variables:
#>  $ mcid       : chr  "MCID3111447797" "MCID3111447797" "MCID3111447797" "MCID"..
#>  $ cip6       : chr  "141901" "141901" "141901" "141901" ...
#>  $ institution: chr  "Institution J" "Institution J" "Institution J" "Institu"..
#>  $ level      : chr  "01 First-year" "02 Second-year" "02 Second-year" "02 Se"..
#>  $ standing   : chr  "Academic Probation" "Academic Probation" "Academic Prob"..
#>  $ coop       : chr  "No" "No" "No" "No" ...

look_at(course[, 1:6])
#> Classes 'data.table' and 'data.frame':   1273 obs. of  6 variables:
#>  $ mcid       : chr  "MCID3111265287" "MCID3111265287" "MCID3111265287" "MCID"..
#>  $ abbrev     : chr  "ECON" "EMUS" "PSYC" "PSYC" ...
#>  $ number     : chr  "2020" "1832" "2012" "2303" ...
#>  $ institution: chr  "Institution B" "Institution B" "Institution B" "Institu"..
#>  $ course     : chr  "Prin Of Macroeconomics" "Appreciation Of Music" "Biolog"..
#>  $ section    : chr  "500" "006" "001" "001" ...

look_at(degree)
#> Classes 'data.table' and 'data.frame':   33 obs. of  6 variables:
#>  $ mcid       : chr  "MCID3111701868" "MCID3111730954" "MCID3111832009" "MCID"..
#>  $ cip6       : chr  "141901" "141901" "141901" "141901" ...
#>  $ institution: chr  "Institution J" "Institution C" "Institution J" "Institu"..
#>  $ degree     : chr  "Bachelor of Science in Mechanical Engineering" "Bachelo"..
#>  $ term_degree: chr  "19993" "20011" "20013" "20033" ...
#>  $ program    : chr  "Mech Engr" "Mech Engr" "Mech Engr" "Mech Engr" ...

look_at(population)
#> Classes 'data.table' and 'data.frame':   45 obs. of  1 variable:
#>  $ mcid: chr  "MCID3111265287" "MCID3111312495" "MCID3111391443" "MCID3111437"..
```

## Acknowledgments

The development of midfieldr and midfielddata was supported by the US
National Science Foundation through grant numbers 1545667 and 2142087.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-ohland:midfield:2023" class="csl-entry">

Ohland, Matthew. 2023. *MIDFIELD, 2004–2023*.
<https://midfield.online/>.

</div>

</div>
