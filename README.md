
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr <img src="man/figures/logo.png" align="right" height="125K">

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/midfieldr)](https://cran.r-project.org/package=midfieldr)  
[![R CMD
check](https://github.com/MIDFIELDR/midfieldr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MIDFIELDR/midfieldr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

Provides tools in R for working with undergraduate, longitudinal,
student-level records modeled on the MIDFIELD database.

- `filter_programs()` chooses rows of program data based on search
  terms.
- `select_basic_cols()` chooses columns required by midfieldr
  functions.  
- `post_bacc_terms()` identifies rows of post-baccalaureate terms to
  exclude.
- `timely_term()` estimates a student’s timely graduation term.
- `data_sufficiency()` identifies rows to exclude due to insufficient
  data.
- `completion_status()` determines if a graduation is timely or late.
- `prep_fye_mice()` conditions data for imputing starting majors of FYE
  students.  
- `order_multiway()` conditions data for Cleveland multiway charts.

## Installation

Install from CRAN with:

``` r
install.packages("midfieldr")
```

To get a bug fix or use a new feature, you can install the development
version from GitHub.

``` r
# install.packages("pak")
pak::pak("MIDFIELDR/midfieldr")
```

midfieldr is designed to work with data from MIDFIELD ([Ohland
2023](#ref-ohland:midfield:2023)) or any other database with a similar
structure. A sample of these data (with 98,000 students) is provided in
midfielddata, an R data package you can install from GitHub.

``` r
install.packages("midfielddata",
  repos = "https://MIDFIELDR.github.io/drat/",
  type = "source"
)
```

For information on accessing the MIDFIELD database for research, contact
the American Society for Engineering Education (ASEE).

## Usage

We illustrate usage with a 150-student sample that loads with midfieldr.
These “toy” data frames—`toy_student, toy_term,` and `toy_degree`—have
the same structure as the data frames `student, term,` and `degree` in
midfielddata that we use in package articles.

``` r
library(midfieldr)
library(data.table)

# Choose a minimum set of columns
student <- select_basic_cols(toy_student)
term <- select_basic_cols(toy_term)
degree <- select_basic_cols(toy_degree)

# Display one representative data frame
term
#>                 mcid   term   cip6   institution         level
#>               <char> <char> <char>        <char>        <char>
#>    1: MCID3111142897  19881 400801 Institution B 01 First-year
#>    2: MCID3111157634  19881 240102 Institution J 01 First-year
#>    3: MCID3111157634  19883 040201 Institution J 01 First-year
#>   ---                                                         
#> 1819: MCID3112869843  20173 240199 Institution B 01 First-year
#> 1820: MCID3112869843  20181 240199 Institution B 01 First-year
#> 1821: MCID3112885339  20181 520201 Institution B 01 First-year

# Identify post-baccalaureate terms
term <- post_bacc_terms(term)
degree <- post_bacc_terms(degree)

term
#>                 mcid   term   cip6   institution         level
#>               <char> <char> <char>        <char>        <char>
#>    1: MCID3111142897  19881 400801 Institution B 01 First-year
#>    2: MCID3111157634  19881 240102 Institution J 01 First-year
#>    3: MCID3111157634  19883 040201 Institution J 01 First-year
#>   ---                                                         
#> 1819: MCID3112869843  20173 240199 Institution B 01 First-year
#> 1820: MCID3112869843  20181 240199 Institution B 01 First-year
#> 1821: MCID3112885339  20181 520201 Institution B 01 First-year
#>       first_degree_term term_cluster
#>                  <char>       <char>
#>    1:              <NA>   pre-degree
#>    2:              <NA>   pre-degree
#>    3:              <NA>   pre-degree
#>   ---                               
#> 1819:              <NA>   pre-degree
#> 1820:              <NA>   pre-degree
#> 1821:              <NA>   pre-degree

# Exclude rows after the first degree term
term <- term[term_cluster != "post-first-degree"]
term <- select_basic_cols(term)
degree <- degree[term_cluster != "post-first-degree"]
degree <- select_basic_cols(degree)

term
#>                 mcid   term   cip6   institution         level
#>               <char> <char> <char>        <char>        <char>
#>    1: MCID3111142897  19881 400801 Institution B 01 First-year
#>    2: MCID3111157634  19881 240102 Institution J 01 First-year
#>    3: MCID3111157634  19883 040201 Institution J 01 First-year
#>   ---                                                         
#> 1800: MCID3112869843  20173 240199 Institution B 01 First-year
#> 1801: MCID3112869843  20181 240199 Institution B 01 First-year
#> 1802: MCID3112885339  20181 520201 Institution B 01 First-year

# Data frame of IDs for refining the ppulation
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

# Determine data sufficiency
DT <- timely_term(DT)
DT <- data_sufficiency(DT)

DT
#>                mcid term_i timely_term   institution lower_limit upper_limit
#>              <char> <char>      <char>        <char>      <char>      <char>
#>   1: MCID3111142897  19881       19933 Institution B       19881       20181
#>   2: MCID3111157634  19881       19933 Institution J       19881       20096
#>   3: MCID3111158724  19881       19933 Institution J       19881       20096
#>  ---                                                                        
#> 349: MCID3112868072  20171       20223 Institution B       19881       20181
#> 350: MCID3112869843  20173       20231 Institution B       19881       20181
#> 351: MCID3112885339  20181       20233 Institution B       19881       20181
#>      data_sufficiency
#>                <char>
#>   1:    exclude-lower
#>   2:    exclude-lower
#>   3:    exclude-lower
#>  ---                 
#> 349:    exclude-upper
#> 350:    exclude-upper
#> 351:    exclude-upper

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

# Inner join to retain IDs in the population
student <- population[student, on = "mcid", nomatch = NULL]
term <- population[term, on = "mcid", nomatch = NULL]
degree <- population[degree, on = "mcid", nomatch = NULL]

# Drop temporary columns, records ready for further analysis
select_basic_cols(student)
#>                mcid          race    sex
#>              <char>        <char> <char>
#>   1: MCID3111198701         White   Male
#>   2: MCID3111208924         White   Male
#>   3: MCID3111213539         White Female
#>  ---                                    
#> 238: MCID3112592592         White   Male
#> 239: MCID3112593368         White Female
#> 240: MCID3112617577 International Female

select_basic_cols(term)
#>                 mcid   term   cip6   institution          level
#>               <char> <char> <char>        <char>         <char>
#>    1: MCID3111198701  19891 240102 Institution J  01 First-year
#>    2: MCID3111198701  19893 520301 Institution J  01 First-year
#>    3: MCID3111208924  19891 240102 Institution J  01 First-year
#>   ---                                                          
#> 1328: MCID3112593368  20151 090101 Institution B  03 Third-year
#> 1329: MCID3112593368  20153 090101 Institution B 04 Fourth-year
#> 1330: MCID3112617577  20123 240199 Institution B  01 First-year

select_basic_cols(degree)
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

<a href="#top">▲ top of page</a>

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-ohland:midfield:2023" class="csl-entry">

Ohland, Matthew. 2023. *MIDFIELD, 2004–2023*.
<https://midfield.online/>.

</div>

</div>
