
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr <img src="man/figures/logo.png" align="right" height="125K">

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/midfieldr)](https://cran.r-project.org/package=midfieldr)\
[![R CMD
check](https://github.com/MIDFIELDR/midfieldr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MIDFIELDR/midfieldr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

midfieldr is an R package that supplies tools for working with
longitudinal undergraduate records from the MIDFIELD database ([Ohland
2023](#ref-ohland:midfield:2023)) or similarly structured data tables.
These tools help you develop credible populations, subset records to
calculate quantitative metrics, and prepare results for dissemination.

- `completion_status()` Identifies students completing a program in a
  timely manner.
- `data_sufficiency()` Identifies records to exclude due to insufficient
  data.
- `filter_programs()` Helps in finding 6-digit program codes.
- `initialize_fye_proxies()` Conditions data for imputing starting
  majors of First-Year Engineering (FYE) students.
- `order_multiway()` Conditions multiway data for Cleveland multiway
  charts.
- `timely_term()` Determines the latest term by which program completion
  would be considered timely.
- `undergrad_term_id()` Distinguishes between undergraduate and
  post-baccalaureate terms.

## Installation

``` r
# Install from CRAN:
install.packages("midfieldr")

# Or install the development version from GitHub:
pak::pak("MIDFIELDR/midfieldr")

# Also install the midfielddata package for practice data
install.packages("midfielddata",
  repos = "https://MIDFIELDR.github.io/drat/",
  type = "source"
)
```

## Usage

Data that load with midfieldr include `cip` for program codes and small
samples of the four data tables (prefix `toy_`) for terse examples.

``` r
library("midfieldr")
library("data.table")

# Assign preferred names to example tables
student <- copy(toy_student)
term <- copy(toy_term)
course <- copy(toy_course)
degree <- copy(toy_degree)

# Pull IDs of degree-seeking students
DT <- student[, .(mcid)]
DT
#>                mcid
#>              <char>
#>   1: MCID3111142897
#>   2: MCID3111157634
#>   3: MCID3111158724
#>  ---               
#> 349: MCID3112868072
#> 350: MCID3112869843
#> 351: MCID3112885339

# Determine data sufficiency
DT <- timely_term(DT, midf_table = term)
DT <- data_sufficiency(DT, midf_table = term)

# Summarize data sufficiency
DT[, .N, by = "sufficiency"][order(-N)]
#>    sufficiency     N
#>         <char> <int>
#> 1:   satisfied   240
#> 2:  fail-upper    99
#> 3:  fail-lower    12

# Subset to obtain baseline population
population <- DT[sufficiency == "satisfied", .(mcid)]
population
#>                mcid
#>              <char>
#>   1: MCID3111198701
#>   2: MCID3111208924
#>   3: MCID3111213539
#>  ---               
#> 238: MCID3112592592
#> 239: MCID3112593368
#> 240: MCID3112617577

# Inner join to filter records to match the population
student <- population[student, on = "mcid", nomatch = NULL]
term <- population[term, on = "mcid", nomatch = NULL]
course <- population[course, on = "mcid", nomatch = NULL]
degree <- population[degree, on = "mcid", nomatch = NULL]

# Distinguish undergraduate and post-baccalaureate terms
term <- undergrad_term_id(term, midf_table = degree)
course <- undergrad_term_id(course, midf_table = degree)
degree <- undergrad_term_id(degree, midf_table = degree)

# Summarize term types
term[, .N, by = "term_id"][order(-term_id)]
#>      term_id     N
#>       <char> <int>
#> 1: undergrad  1330
#> 2: post-bacc    17
course[, .N, by = "term_id"][order(-term_id)]
#>      term_id     N
#>       <char> <int>
#> 1: undergrad  6380
#> 2: post-bacc    41
degree[, .N, by = "term_id"][order(-term_id)]
#>      term_id     N
#>       <char> <int>
#> 1: undergrad   169
#> 2: post-bacc     1

# Retain undergraduate terms
term <- term[term_id == "undergrad"]
course <- course[term_id == "undergrad"]
degree <- degree[term_id == "undergrad"]

# Obtain 6-digit CIP codes, e.g., Engineering (14), 
# Psychology (42), and Business (52).
programs <- filter_programs(cip, c("^14", "^42", "^52"))
programs <- programs[, .(cip6name, cip6)]

# Construct the programs table
programs[, program := fcase(
  cip6 %like% "^14", "Engineering",
  cip6 %like% "^42", "Psychology",
  cip6 %like% "^52", "Business"
)]
programs <- programs[, .(cip6, program)]
programs
#>        cip6     program
#>      <char>      <char>
#>   1: 140101 Engineering
#>   2: 140102 Engineering
#>   3: 140201 Engineering
#>  ---                   
#> 173: 522001    Business
#> 174: 522101    Business
#> 175: 529999    Business

# Determine completion status
DT <- timely_term(population, midf_table = term)
DT <- completion_status(DT, midf_table = degree)

# Summarize completion status
DT[, .N, by = "completion"][order(-N)]
#>    completion     N
#>        <char> <int>
#> 1:     timely   161
#> 2:       <NA>    71
#> 3:       late     8

# Filter for timely graduates
DT <- unique(DT[completion == "timely", .(mcid)])

# Join degree CIP codes
degree_codes <- degree[, .(mcid, cip6)]
DT <- degree_codes[DT, on = "mcid"]
DT
#>                mcid   cip6
#>              <char> <char>
#>   1: MCID3111213539 030103
#>   2: MCID3111213856 261399
#>   3: MCID3111254225 270101
#>  ---                      
#> 159: MCID3112587501 420101
#> 160: MCID3112592592 520201
#> 161: MCID3112593368 090101

# Inner join to filter graduates by program
program_labels <- programs[, .(cip6, program)]
DT <- program_labels[DT, on = "cip6", nomatch = NULL]
DT <- DT[, .(mcid, program, cip6 = NULL)]
DT
#>               mcid     program
#>             <char>      <char>
#>  1: MCID3111254412 Engineering
#>  2: MCID3111262210 Engineering
#>  3: MCID3111265287  Psychology
#> ---                           
#> 53: MCID3112467463  Psychology
#> 54: MCID3112587501  Psychology
#> 55: MCID3112592592    Business

# Join demographics
demographics <- student[, .(mcid, sex)]
DT <- demographics[DT, on = "mcid"]
DT
#>               mcid    sex     program
#>             <char> <char>      <char>
#>  1: MCID3111254412   Male Engineering
#>  2: MCID3111262210   Male Engineering
#>  3: MCID3111265287   Male  Psychology
#> ---                                  
#> 53: MCID3112467463 Female  Psychology
#> 54: MCID3112587501 Female  Psychology
#> 55: MCID3112592592   Male    Business

# Group and summarize timely graduates
DT <- DT[, .(grad = .N), by = c("sex", "program")]
DT[order(sex, program)]
#>       sex     program  grad
#>    <char>      <char> <int>
#> 1: Female    Business     8
#> 2: Female Engineering     3
#> 3: Female  Psychology    12
#> 4:   Male    Business    12
#> 5:   Male Engineering    16
#> 6:   Male  Psychology     4
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
