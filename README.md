
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

The `cip` dataset of program codes loads with midfieldr. Small samples
of student records `(toy_student, toy_term, toy_course, toy_degree)`
also load with midfieldr, containing the same variables found in the
midfielddata practice data as well as the MIDFIELD research data tables.

``` r
library("midfieldr")
library("data.table")

# Assign record samples 
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

# Filter population for data sufficiency
DT <- timely_term(DT, midf_table = term)
DT <- data_sufficiency(DT, midf_table = term)
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
term <- qualification_level(term, midf_table = degree)
course <- qualification_level(course, midf_table = degree)
degree <- qualification_level(degree, midf_table = degree)
# -- example summary
term[, .N, by = "qual_level"]
#>    qual_level     N
#>        <char> <int>
#> 1:  undergrad  1330
#> 2:  post-bacc    17

# Filter records to exclude post-baccalaureate terms
term <- term[qual_level == "undergrad"]
course <- course[qual_level == "undergrad"]
degree <- degree[qual_level == "undergrad"]

# Omit temporary columns to finalize baseline records
term[, c("bacc", "qual_level") := NULL]
course[, c("bacc", "qual_level") := NULL]
degree[, c("bacc", "qual_level") := NULL]

# Obtain set of 6-digit CIP codes for three programs
# -- Engineering (14)
# -- Psychology (42)
# -- Business (52)
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
DT <- copy(population)
DT <- timely_term(DT, midf_table = term)
DT <- completion_status(DT, midf_table = degree)
# -- summary
DT[, .N, by = "completion"][order(-N)]
#>    completion     N
#>        <char> <int>
#> 1:     timely   161
#> 2:       <NA>    71
#> 3:       late     8

# Filter population for timely completion
DT <- unique(DT[completion == "timely", .(mcid)])
DT
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
DT <- degree[, .(mcid, cip6)][DT, on = "mcid"]

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
