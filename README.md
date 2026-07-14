
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
undergraduate records from the MIDFIELD database—or similarly structured
data tables—in the following areas.

Programs  
- `filter_programs()` helps you find program names and CIP codes.

Records and population  
- `timely_term()` estimates timely completion terms.  
- `data_sufficiency()` identifies IDs to exclude due to insufficient
data.  
- `post_bacc_terms()` identifies rows with post-baccalaureate terms to
exclude.

Blocs  
- `completion_status()` labels program completion as timely, late, or
NA.

Special conditioning  
- `prep_fye_mice()` conditions data for imputing starting majors of FYE
students.  
- `order_multiway()` conditions data for Cleveland multiway charts.

Convenience  
- `select_basic_cols()` minimizes the number of columns viewed for
interactive sessions.  
- `look_at()` wraps `base::str()` with our preferred arguments.

``` r
library("midfieldr")
packageVersion("midfieldr")
#> [1] '1.0.3.9021'
Sys.Date()
#> [1] "2026-07-13"
```

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
package you can download from GitHub.

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
structure as the tables in midfielddata.

``` r
library("midfieldr")
library("data.table")

# Assign data tables to the expected names
student <- copy(toy_student)
term <- copy(toy_term)
course <- copy(toy_course)
degree <- copy(toy_degree)

look_at(term)
#> Classes 'data.table' and 'data.frame':   1821 obs. of  13 variables:
#>  $ mcid               : chr  "MCID3111142897" "MCID3111157634" "MCID311115763"..
#>  $ term               : chr  "19881" "19881" "19883" "19891" ...
#>  $ cip6               : chr  "400801" "240102" "040201" "040201" ...
#>  $ institution        : chr  "Institution B" "Institution J" "Institution J" "..
#>  $ level              : chr  "01 First-year" "01 First-year" "01 First-year" "..
#>  $ standing           : chr  "Good Standing" "Good Standing" "Good Standing" "..
#>  $ coop               : chr  "No" "No" "No" "No" ...
#>  $ hours_term         : num  9 13 10 18 15 14 3 13 16 17 ...
#>  $ hours_term_attempt : num  9 13 10 18 15 14 4 13 16 17 ...
#>  $ hours_cumul        : num  9 13 23 41 56 14 17 13 29 46 ...
#>  $ hours_cumul_attempt: num  9 13 23 41 56 14 18 13 29 46 ...
#>  $ gpa_term           : num  3.57 2.1 2.75 2.28 1.6 2.1 2 2.16 3 2.23 ...
#>  $ gpa_cumul          : num  3.57 2.1 2.38 2.34 2.14 2.1 2.08 2.16 2.62 2.48 ...

# Identify post-baccalaureate terms
term <- post_bacc_terms(term, midfield_table = degree)
course <- post_bacc_terms(course, midfield_table = degree)
degree <- post_bacc_terms(degree, midfield_table = degree)

look_at(term)
#> Classes 'data.table' and 'data.frame':   1821 obs. of  15 variables:
#>  $ mcid               : chr  "MCID3111142897" "MCID3111157634" "MCID311115763"..
#>  $ term               : chr  "19881" "19881" "19883" "19891" ...
#>  $ cip6               : chr  "400801" "240102" "040201" "040201" ...
#>  $ institution        : chr  "Institution B" "Institution J" "Institution J" "..
#>  $ level              : chr  "01 First-year" "01 First-year" "01 First-year" "..
#>  $ standing           : chr  "Good Standing" "Good Standing" "Good Standing" "..
#>  $ coop               : chr  "No" "No" "No" "No" ...
#>  $ hours_term         : num  9 13 10 18 15 14 3 13 16 17 ...
#>  $ hours_term_attempt : num  9 13 10 18 15 14 4 13 16 17 ...
#>  $ hours_cumul        : num  9 13 23 41 56 14 17 13 29 46 ...
#>  $ hours_cumul_attempt: num  9 13 23 41 56 14 18 13 29 46 ...
#>  $ gpa_term           : num  3.57 2.1 2.75 2.28 1.6 2.1 2 2.16 3 2.23 ...
#>  $ gpa_cumul          : num  3.57 2.1 2.38 2.34 2.14 2.1 2.08 2.16 2.62 2.48 ...
#>  $ first_degree_term  : chr  NA NA NA NA ...
#>  $ term_cluster       : chr  "pre-degree" "pre-degree" "pre-degree" "pre-degr"..

# Exclude rows after the first degree term
term <- term[term_cluster != "post-first-degree"]
course <- course[term_cluster != "post-first-degree"]
degree <- degree[term_cluster != "post-first-degree"]

look_at(term)
#> Classes 'data.table' and 'data.frame':   1802 obs. of  15 variables:
#>  $ mcid               : chr  "MCID3111142897" "MCID3111157634" "MCID311115763"..
#>  $ term               : chr  "19881" "19881" "19883" "19891" ...
#>  $ cip6               : chr  "400801" "240102" "040201" "040201" ...
#>  $ institution        : chr  "Institution B" "Institution J" "Institution J" "..
#>  $ level              : chr  "01 First-year" "01 First-year" "01 First-year" "..
#>  $ standing           : chr  "Good Standing" "Good Standing" "Good Standing" "..
#>  $ coop               : chr  "No" "No" "No" "No" ...
#>  $ hours_term         : num  9 13 10 18 15 14 3 13 16 17 ...
#>  $ hours_term_attempt : num  9 13 10 18 15 14 4 13 16 17 ...
#>  $ hours_cumul        : num  9 13 23 41 56 14 17 13 29 46 ...
#>  $ hours_cumul_attempt: num  9 13 23 41 56 14 18 13 29 46 ...
#>  $ gpa_term           : num  3.57 2.1 2.75 2.28 1.6 2.1 2 2.16 3 2.23 ...
#>  $ gpa_cumul          : num  3.57 2.1 2.38 2.34 2.14 2.1 2.08 2.16 2.62 2.48 ...
#>  $ first_degree_term  : chr  NA NA NA NA ...
#>  $ term_cluster       : chr  "pre-degree" "pre-degree" "pre-degree" "pre-degr"..

# Begin refining the population
DT <- term[, .(mcid)]
DT <- unique(DT)

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

# Build data sufficiency data frame
DT <- timely_term(DT, midfield_table = term)
DT <- data_sufficiency(DT, midfield_table = term)

DT
#>                mcid term_i       level_i adj_span timely_term   institution
#>              <char> <char>        <char>    <num>      <char>        <char>
#>   1: MCID3111142897  19881 01 First-year        6       19933 Institution B
#>   2: MCID3111157634  19881 01 First-year        6       19933 Institution J
#>   3: MCID3111158724  19881 01 First-year        6       19933 Institution J
#>  ---                                                                       
#> 349: MCID3112868072  20171 01 First-year        6       20223 Institution B
#> 350: MCID3112869843  20173 01 First-year        6       20231 Institution B
#> 351: MCID3112885339  20181 01 First-year        6       20233 Institution B
#>      lower_limit upper_limit data_sufficiency
#>           <char>      <char>           <char>
#>   1:       19881       20181    exclude-lower
#>   2:       19881       20096    exclude-lower
#>   3:       19881       20096    exclude-lower
#>  ---                                         
#> 349:       19881       20181    exclude-upper
#> 350:       19881       20181    exclude-upper
#> 351:       19881       20181    exclude-upper

# Retain rows with sufficient institutional data
population <- DT[data_sufficiency == "include", .(mcid)]
population <- unique(population)

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

# Inner join to filter data tables to match population
student <- population[student, on = "mcid", nomatch = NULL]
term <- population[term, on = "mcid", nomatch = NULL]
course <- population[course, on = "mcid", nomatch = NULL]
degree <- population[degree, on = "mcid", nomatch = NULL]

look_at(term)
#> Classes 'data.table' and 'data.frame':   1330 obs. of  15 variables:
#>  $ mcid               : chr  "MCID3111198701" "MCID3111198701" "MCID311120892"..
#>  $ term               : chr  "19891" "19893" "19891" "19893" ...
#>  $ cip6               : chr  "240102" "520301" "240102" "140102" ...
#>  $ institution        : chr  "Institution J" "Institution J" "Institution J" "..
#>  $ level              : chr  "01 First-year" "01 First-year" "01 First-year" "..
#>  $ standing           : chr  "Good Standing" "Academic Warning" "Good Standin"..
#>  $ coop               : chr  "No" "No" "No" "No" ...
#>  $ hours_term         : num  16 10 13 6 5 5 15 14 15 17 ...
#>  $ hours_term_attempt : num  16 13 13 11 5 5 15 14 15 17 ...
#>  $ hours_cumul        : num  16 26 13 19 24 29 15 29 44 61 ...
#>  $ hours_cumul_attempt: num  16 29 13 24 24 29 15 29 44 61 ...
#>  $ gpa_term           : num  2.08 1.87 2 1.85 1.88 1 3 2.67 2.55 2.84 ...
#>  $ gpa_cumul          : num  2.08 2 2 1.95 1.94 1.78 3 2.84 2.74 2.77 ...
#>  $ first_degree_term  : chr  NA NA NA NA ...
#>  $ term_cluster       : chr  "pre-degree" "pre-degree" "pre-degree" "pre-degr"..

# Choose a minimum set of columns
student <- select_basic_cols(student)
term <- select_basic_cols(term)
course <- select_basic_cols(course)
degree <- select_basic_cols(degree)

student
#>                mcid          race    sex
#>              <char>        <char> <char>
#>   1: MCID3111198701         White   Male
#>   2: MCID3111208924         White   Male
#>   3: MCID3111213539         White Female
#>  ---                                    
#> 238: MCID3112592592         White   Male
#> 239: MCID3112593368         White Female
#> 240: MCID3112617577 International Female

term
#>                 mcid   term   cip6   institution          level
#>               <char> <char> <char>        <char>         <char>
#>    1: MCID3111198701  19891 240102 Institution J  01 First-year
#>    2: MCID3111198701  19893 520301 Institution J  01 First-year
#>    3: MCID3111208924  19891 240102 Institution J  01 First-year
#>   ---                                                          
#> 1328: MCID3112593368  20151 090101 Institution B  03 Third-year
#> 1329: MCID3112593368  20153 090101 Institution B 04 Fourth-year
#> 1330: MCID3112617577  20123 240199 Institution B  01 First-year

course
#>                 mcid term_course abbrev number
#>               <char>      <char> <char> <char>
#>    1: MCID3111198701       19891   ACCT   1504
#>    2: MCID3111198701       19891   CHEM   1015
#>    3: MCID3111198701       19891   CHEM   1025
#>   ---                                         
#> 6378: MCID3112617577       20123   LING   1000
#> 6379: MCID3112617577       20123   PSYC   1001
#> 6380: MCID3112617577       20123   WRTG   1150

degree
#>                mcid term_degree   cip6
#>              <char>      <char> <char>
#>   1: MCID3111213539       19923 030103
#>   2: MCID3111213856       19911 261399
#>   3: MCID3111254225       19923 270101
#>  ---                                  
#> 167: MCID3112587501       20141 420101
#> 168: MCID3112592592       20153 520201
#> 169: MCID3112593368       20153 090101
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
