# midfieldr

## Overview

Provides tools in R for working with undergraduate, longitudinal,
student-level records modeled on the MIDFIELD database.

- [`filter_cip_rows()`](https://midfieldr.github.io/midfieldr/reference/filter_cip_rows.md)
  chooses rows of program data based on search terms.
- [`select_record_cols()`](https://midfieldr.github.io/midfieldr/reference/select_record_cols.md)
  chooses columns required by midfieldr functions.  
- [`add_term_cluster()`](https://midfieldr.github.io/midfieldr/reference/add_term_cluster.md)
  identifies rows of post-baccalaureate terms to exclude.
- [`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)
  estimates a student’s timely graduation term.
- [`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md)
  identifies rows to exclude due to insufficient data.
- [`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md)
  determines if a graduation is timely or late.
- [`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)
  conditions data for imputing starting majors of FYE students.  
- [`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)
  conditions data for Cleveland multiway charts.

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
student <- select_record_cols(toy_student, type = "s")
term <- select_record_cols(toy_term, "t")
degree <- select_record_cols(toy_degree, "d")

# Display one representative data frame
term
#>                 mcid   institution   term   cip6          level
#>               <char>        <char> <char> <char>         <char>
#>    1: MCID3111158953 Institution J  19881 240102  01 First-year
#>    2: MCID3111158953 Institution J  19883 240102  01 First-year
#>    3: MCID3111158953 Institution J  19891 240102 02 Second-year
#>   ---                                                          
#> 1093: MCID3112881399 Institution B  20181 260901  01 First-year
#> 1094: MCID3112882995 Institution B  20181 141901  01 First-year
#> 1095: MCID3112884375 Institution B  20181 520201  01 First-year

# Add a column to label term clusters
term <- add_term_cluster(term)
degree <- add_term_cluster(degree)

term
#>                 mcid   institution   term   cip6          level
#>               <char>        <char> <char> <char>         <char>
#>    1: MCID3111158953 Institution J  19881 240102  01 First-year
#>    2: MCID3111158953 Institution J  19883 240102  01 First-year
#>    3: MCID3111158953 Institution J  19891 240102 02 Second-year
#>   ---                                                          
#> 1093: MCID3112881399 Institution B  20181 260901  01 First-year
#> 1094: MCID3112882995 Institution B  20181 141901  01 First-year
#> 1095: MCID3112884375 Institution B  20181 520201  01 First-year
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
#>                 mcid   institution   term   cip6          level
#>               <char>        <char> <char> <char>         <char>
#>    1: MCID3111158953 Institution J  19881 240102  01 First-year
#>    2: MCID3111158953 Institution J  19883 240102  01 First-year
#>    3: MCID3111158953 Institution J  19891 240102 02 Second-year
#>   ---                                                          
#> 1068: MCID3112881399 Institution B  20181 260901  01 First-year
#> 1069: MCID3112882995 Institution B  20181 141901  01 First-year
#> 1070: MCID3112884375 Institution B  20181 520201  01 First-year
#>       first_degree_term term_cluster
#>                  <char>       <char>
#>    1:              <NA>   pre-degree
#>    2:              <NA>   pre-degree
#>    3:              <NA>   pre-degree
#>   ---                               
#> 1068:              <NA>   pre-degree
#> 1069:              <NA>   pre-degree
#> 1070:              <NA>   pre-degree

# Drop the temporary columns
term <- select_record_cols(term, type = "t")
degree <- select_record_cols(degree, type = "d")

term
#>                 mcid   institution   term   cip6          level
#>               <char>        <char> <char> <char>         <char>
#>    1: MCID3111158953 Institution J  19881 240102  01 First-year
#>    2: MCID3111158953 Institution J  19883 240102  01 First-year
#>    3: MCID3111158953 Institution J  19891 240102 02 Second-year
#>   ---                                                          
#> 1068: MCID3112881399 Institution B  20181 260901  01 First-year
#> 1069: MCID3112882995 Institution B  20181 141901  01 First-year
#> 1070: MCID3112884375 Institution B  20181 520201  01 First-year

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
#>                mcid       level_i adj_span timely_term term_i lower_limit
#>              <char>        <char>    <num>      <char> <char>      <char>
#>   1: MCID3111158953 01 First-year        6       19933  19881       19881
#>   2: MCID3111159270 01 First-year        6       19933  19881       19881
#>   3: MCID3111160513 01 First-year        6       19933  19881       19881
#>  ---                                                                     
#> 148: MCID3112881399 01 First-year        6       20233  20181       19881
#> 149: MCID3112882995 01 First-year        6       20233  20181       19881
#> 150: MCID3112884375 01 First-year        6       20233  20181       19881
#>      upper_limit data_sufficiency
#>           <char>           <char>
#>   1:       20096    exclude-lower
#>   2:       20096    exclude-lower
#>   3:       20096    exclude-lower
#>  ---                             
#> 148:       20181    exclude-upper
#> 149:       20181    exclude-upper
#> 150:       20181    exclude-upper

# Retain rows with sufficient institutional data
population <- DT[data_sufficiency == "include", .(mcid)]

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

# Records ready for grouping, summarizing, calculating metrics, etc.
student
#>                mcid   race    sex
#>              <char> <char> <char>
#>   1: MCID3111213943  White   Male
#>   2: MCID3111248941  White   Male
#>   3: MCID3111250695  White   Male
#>  ---                             
#> 100: MCID3112409179  Asian   Male
#> 101: MCID3112411629  White   Male
#> 102: MCID3112498796  White Female

term
#>                mcid   institution   term   cip6          level
#>              <char>        <char> <char> <char>         <char>
#>   1: MCID3111213943 Institution B  19891 420101  01 First-year
#>   2: MCID3111213943 Institution B  19893 420101  01 First-year
#>   3: MCID3111213943 Institution B  19901 420101 02 Second-year
#>  ---                                                          
#> 806: MCID3112498796 Institution B  20131 090101  03 Third-year
#> 807: MCID3112498796 Institution B  20133 090101 04 Fourth-year
#> 808: MCID3112498796 Institution B  20134 090101 04 Fourth-year

degree
#>               mcid term_degree   cip6
#>             <char>      <char> <char>
#>  1: MCID3111213943       19903 420101
#>  2: MCID3111248941       19943 140901
#>  3: MCID3111253227       19951 141901
#> ---                                  
#> 76: MCID3112409179       20123 090401
#> 77: MCID3112411629       20124 500601
#> 78: MCID3112498796       20143 090101
```

## Acknowledgments

The development of midfieldr and midfielddata was supported by the US
National Science Foundation through grant numbers 1545667 and 2142087.

## References

Ohland, Matthew. 2023. *MIDFIELD, 2004–2023*.
<https://midfield.online/>.
