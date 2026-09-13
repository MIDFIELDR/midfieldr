
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr <img src="man/figures/logo.png" align="right" height="125K">

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/midfieldr)](https://cran.r-project.org/package=midfieldr)  
[![R CMD
check](https://github.com/MIDFIELDR/midfieldr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MIDFIELDR/midfieldr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

midfieldr is an R package that supplies tools for working with
longitudinal undergraduate records from the MIDFIELD database ([Ohland
2023](#ref-ohland:midfield:2023)) or similarly structured data tables.
These tools help you develop credible populations, subset records to
calculate quantitative metrics, and prepare results for dissemination.

- `completion_status()` Identifies IDs to include for timely completion.
- `data_sufficiency()` Identifies IDs to exclude due to insufficient
  data.  
- `filter_programs()` Helps in finding 6-digit program codes.  
- `order_multiway()` Conditions data for Cleveland multiway charts.  
- `prep_fye_mice()` Conditions data for imputing starting majors of FYE
  students.
- `is_undergrad()` Identifies undergraduate terms to include.
- `timely_term()` Determines the latest term for timely completion.

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

# Categorize records for data sufficiency
DT <- timely_term(DT, midf_table = term)
DT <- data_sufficiency(DT, midf_table = term)
# -- result summary
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

# Categorize pre- and post-baccalaureate terms
term <- is_undergrad(term, midf_table = degree)
course <- is_undergrad(course, midf_table = degree)
degree <- is_undergrad(degree, midf_table = degree)
# -- example summary
term[, .N, by = "term_focus"]
#>    term_focus     N
#>        <char> <int>
#> 1:  undergrad  1330
#> 2:  post-bacc    17

# Filter records to exclude post-baccalaureate terms
term <- term[term_focus == "undergrad"]
course <- course[term_focus == "undergrad"]
degree <- degree[term_focus == "undergrad"]

# Omit temporary columns to obtain baseline records
term[, c("bacc_term", "term_focus") := NULL]
course[, c("bacc_term", "term_focus") := NULL]
degree[, c("bacc_term", "term_focus") := NULL]

# Obtain 6-digit CIP codes for Engineering (14), Psychology (42),
# and Business (52)
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

# Categorize completion status
pop <- copy(population)
pop <- timely_term(pop, midf_table = term)
pop <- completion_status(pop, midf_table = degree)
# -- result summary
pop[, .N, by = "completion"][order(-N)]
#>    completion     N
#>        <char> <int>
#> 1:     timely   161
#> 2:       <NA>    71
#> 3:       late     8

# Filter population for timely completion
pop <- unique(pop[completion == "timely", .(mcid)])
pop
#>                mcid
#>              <char>
#>   1: MCID3111213539
#>   2: MCID3111213856
#>   3: MCID3111254225
#>  ---               
#> 159: MCID3112587501
#> 160: MCID3112592592
#> 161: MCID3112593368

# Join degree CIP codes
DT <- degree[, .(mcid, cip6)][pop, on = "mcid"]

# Inner join to filter graduates by program
DT <- programs[, .(cip6, program)][DT, on = "cip6", nomatch = NULL]
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
DT <- student[, .(mcid, sex)][DT, on = "mcid"]

# Group and summarize timely graduates
DT <- DT[, .(grad = .N), by = c("program", "sex")]
DT[order(program, sex)]
#>        program    sex  grad
#>         <char> <char> <int>
#> 1:    Business Female     8
#> 2:    Business   Male    12
#> 3: Engineering Female     3
#> 4: Engineering   Male    16
#> 5:  Psychology Female    12
#> 6:  Psychology   Male     4
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
