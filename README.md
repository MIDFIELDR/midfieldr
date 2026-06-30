
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

- `filter_cip_rows()` chooses rows of program data based on search
  terms.
- `select_record_cols()` chooses columns required by midfieldr
  functions.  
- `add_term_cluster()` identifies rows of post-baccalaureate terms to
  exclude.
- `add_timely_term()` estimates a student’s timely graduation term.
- `add_data_sufficiency()` identifies rows to exclude due to
  insufficient data.
- `add_completion_status()` determines if a graduation is timely or
  late.
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
student <- select_record_cols(toy_student)
term <- select_record_cols(toy_term)
degree <- select_record_cols(toy_degree)

# Display one representative data frame
term
#>                 mcid   term   cip6   institution          level
#>               <char> <char> <char>        <char>         <char>
#>    1: MCID3111158953  19881 240102 Institution J  01 First-year
#>    2: MCID3111158953  19883 240102 Institution J  01 First-year
#>    3: MCID3111158953  19891 240102 Institution J 02 Second-year
#>   ---                                                          
#> 1093: MCID3112881399  20181 260901 Institution B  01 First-year
#> 1094: MCID3112882995  20181 141901 Institution B  01 First-year
#> 1095: MCID3112884375  20181 520201 Institution B  01 First-year

# Add a column to label term clusters
term <- add_term_cluster(term)
degree <- add_term_cluster(degree)

term
#>                 mcid   term   cip6   institution          level
#>               <char> <char> <char>        <char>         <char>
#>    1: MCID3111158953  19881 240102 Institution J  01 First-year
#>    2: MCID3111158953  19883 240102 Institution J  01 First-year
#>    3: MCID3111158953  19891 240102 Institution J 02 Second-year
#>   ---                                                          
#> 1093: MCID3112881399  20181 260901 Institution B  01 First-year
#> 1094: MCID3112882995  20181 141901 Institution B  01 First-year
#> 1095: MCID3112884375  20181 520201 Institution B  01 First-year
#>       first_degree_term term_cluster
#>                  <char>       <char>
#>    1:              <NA>   pre-degree
#>    2:              <NA>   pre-degree
#>    3:              <NA>   pre-degree
#>   ---                               
#> 1093:              <NA>   pre-degree
#> 1094:              <NA>   pre-degree
#> 1095:              <NA>   pre-degree

# Exclude rows after the first degree term
term <- term[term_cluster != "post-first-degree"]
degree <- degree[term_cluster != "post-first-degree"]

term
#>                 mcid   term   cip6   institution          level
#>               <char> <char> <char>        <char>         <char>
#>    1: MCID3111158953  19881 240102 Institution J  01 First-year
#>    2: MCID3111158953  19883 240102 Institution J  01 First-year
#>    3: MCID3111158953  19891 240102 Institution J 02 Second-year
#>   ---                                                          
#> 1068: MCID3112881399  20181 260901 Institution B  01 First-year
#> 1069: MCID3112882995  20181 141901 Institution B  01 First-year
#> 1070: MCID3112884375  20181 520201 Institution B  01 First-year
#>       first_degree_term term_cluster
#>                  <char>       <char>
#>    1:              <NA>   pre-degree
#>    2:              <NA>   pre-degree
#>    3:              <NA>   pre-degree
#>   ---                               
#> 1068:              <NA>   pre-degree
#> 1069:              <NA>   pre-degree
#> 1070:              <NA>   pre-degree

# Population at this point, for next filter
DT <- term[, .(mcid)]
DT <- unique(DT)

DT
#>                mcid
#>              <char>
#>   1: MCID3111158953
#>   2: MCID3111159270
#>   3: MCID3111160513
#>  ---               
#> 148: MCID3112881399
#> 149: MCID3112882995
#> 150: MCID3112884375

# Determine data sufficiency
DT <- add_timely_term(DT)
DT <- add_data_sufficiency(DT)

DT
#>                 mcid term_i timely_term   institution lower_limit upper_limit
#>               <char> <char>      <char>        <char>      <char>      <char>
#>    1: MCID3111158953  19881       19933 Institution J       19881       20096
#>    2: MCID3111158953  19881       19933 Institution J       19881       20096
#>    3: MCID3111158953  19881       19933 Institution J       19881       20096
#>   ---                                                                        
#> 1068: MCID3112881399  20181       20233 Institution B       19881       20181
#> 1069: MCID3112882995  20181       20233 Institution B       19881       20181
#> 1070: MCID3112884375  20181       20233 Institution B       19881       20181
#>       data_sufficiency
#>                 <char>
#>    1:    exclude-lower
#>    2:    exclude-lower
#>    3:    exclude-lower
#>   ---                 
#> 1068:    exclude-upper
#> 1069:    exclude-upper
#> 1070:    exclude-upper

# Retain rows with sufficient institutional data
population <- DT[data_sufficiency == "include", .(mcid)]
population <- unique(population)
population
#>                mcid
#>              <char>
#>   1: MCID3111213943
#>   2: MCID3111248941
#>   3: MCID3111250695
#>  ---               
#> 100: MCID3112409179
#> 101: MCID3112411629
#> 102: MCID3112498796

# Filter records using inner join with population
student <- population[student, on = "mcid", nomatch = NULL]
term <- population[term, on = "mcid", nomatch = NULL]
degree <- population[degree, on = "mcid", nomatch = NULL]

# Drop temporary columns, records ready for further analysis
select_record_cols(student)
#>                mcid   race    sex   institution
#>              <char> <char> <char>        <char>
#>   1: MCID3111213943  White   Male Institution B
#>   2: MCID3111248941  White   Male Institution J
#>   3: MCID3111250695  White   Male Institution J
#>  ---                                           
#> 100: MCID3112409179  Asian   Male Institution B
#> 101: MCID3112411629  White   Male Institution B
#> 102: MCID3112498796  White Female Institution B

select_record_cols(term)
#>                mcid   term   cip6   institution          level
#>              <char> <char> <char>        <char>         <char>
#>   1: MCID3111213943  19891 420101 Institution B  01 First-year
#>   2: MCID3111213943  19893 420101 Institution B  01 First-year
#>   3: MCID3111213943  19901 420101 Institution B 02 Second-year
#>  ---                                                          
#> 806: MCID3112498796  20131 090101 Institution B  03 Third-year
#> 807: MCID3112498796  20133 090101 Institution B 04 Fourth-year
#> 808: MCID3112498796  20134 090101 Institution B 04 Fourth-year

select_record_cols(degree)
#>               mcid term_degree   cip6   institution
#>             <char>      <char> <char>        <char>
#>  1: MCID3111213943       19903 420101 Institution B
#>  2: MCID3111248941       19943 140901 Institution J
#>  3: MCID3111253227       19951 141901 Institution J
#> ---                                                
#> 76: MCID3112409179       20123 090401 Institution B
#> 77: MCID3112411629       20124 500601 Institution B
#> 78: MCID3112498796       20143 090101 Institution B
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
