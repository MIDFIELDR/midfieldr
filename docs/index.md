# midfieldr

## Overview

Provides tools in R for working with undergraduate, longitudinal,
student-level records modeled on the MIDFIELD database.

- [`filter_cip()`](https://midfieldr.github.io/midfieldr/reference/filter_cip.md)
  chooses rows of program data based on search terms.
- [`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md)
  chooses columns required by midfieldr functions.  
- [`add_post_bacc()`](https://midfieldr.github.io/midfieldr/reference/add_post_bacc.md)
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

midfieldr interacts with practice data provided in the midfielddata
package ([Layton et al.
2026](#ref-Layton+Long+Ohland:2026:midfielddata)) or with any data
structure modeled on MIDFIELD ([Ohland
2023](#ref-ohland:midfield:2023)), a database managed since 2023 by the
American Society for Engineering Education. midfielddata is installed
from the MIDFIELDR drat repository with:

``` r

install.packages("midfielddata",
  repos = "https://MIDFIELDR.github.io/drat/",
  type = "source"
)
```

## Usage

We illustrate usage with the “toy” data sets included in midfieldr.
These are small (150 students) data tables structured, like the MIDFIELD
database, in four tables: `student`, `course`, `term`, and `degree`.

``` r

library(midfieldr)
library(data.table)

# Initialize student records
student <- select_basic_cols(toy_student)
term <- select_basic_cols(toy_term)
degree <- select_basic_cols(toy_degree)

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

# Label pre/post-baccalaureate term status
term <- add_post_bacc(term, midfield_degree = degree)
degree <- add_post_bacc(degree, midfield_degree = degree)

term
#>                 mcid   institution   cip6          level   term
#>               <char>        <char> <char>         <char> <char>
#>    1: MCID3111158953 Institution J 240102  01 First-year  19881
#>    2: MCID3111158953 Institution J 240102  01 First-year  19883
#>    3: MCID3111158953 Institution J 240102 02 Second-year  19891
#>   ---                                                          
#> 1093: MCID3112881399 Institution B 260901  01 First-year  20181
#> 1094: MCID3112882995 Institution B 141901  01 First-year  20181
#> 1095: MCID3112884375 Institution B 520201  01 First-year  20181
#>       first_degree_term term_status
#>                  <char>      <char>
#>    1:              <NA>    pre-bacc
#>    2:              <NA>    pre-bacc
#>    3:              <NA>    pre-bacc
#>   ---                              
#> 1093:              <NA>    pre-bacc
#> 1094:              <NA>    pre-bacc
#> 1095:              <NA>    pre-bacc

# Term status values
sort_uniq(term$term_status)
#> [1] "first-degree"      "post-first-degree" "pre-bacc"

# Exclude post-baccalaureate terms
term <- term[term_status != "post-first-degree"]
degree <- degree[term_status != "post-first-degree"]

# Drop temporary columns to finalize records
term <- select_basic_cols(term)
degree <- select_basic_cols(degree)

term
#>                 mcid   institution   cip6          level   term
#>               <char>        <char> <char>         <char> <char>
#>    1: MCID3111158953 Institution J 240102  01 First-year  19881
#>    2: MCID3111158953 Institution J 240102  01 First-year  19883
#>    3: MCID3111158953 Institution J 240102 02 Second-year  19891
#>   ---                                                          
#> 1068: MCID3112881399 Institution B 260901  01 First-year  20181
#> 1069: MCID3112882995 Institution B 141901  01 First-year  20181
#> 1070: MCID3112884375 Institution B 520201  01 First-year  20181

# Initialize population
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
DT <- add_timely_term(DT, midfield_term = term)
DT <- add_data_sufficiency(DT, midfield_term = term)
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

# Data sufficiency values
sort_uniq(DT$data_sufficiency)
#> [1] "exclude-lower" "exclude-upper" "include"

# Exclude insufficient data to finalize population
DT <- DT[data_sufficiency == "include"]
DT <- DT[, .(mcid)]
DT
#>                mcid
#>              <char>
#>   1: MCID3111213943
#>   2: MCID3111248941
#>   3: MCID3111250695
#>  ---               
#> 100: MCID3112409179
#> 101: MCID3112411629
#> 102: MCID3112498796

# Determine completion status to initialize grad bloc
DT <- add_timely_term(DT, midfield_term = term)
DT <- add_completion_status(DT, midfield_degree = degree)
DT
#>                mcid term_i       level_i adj_span timely_term term_degree
#>              <char> <char>        <char>    <num>      <char>      <char>
#>   1: MCID3111213943  19891 01 First-year        6       19943       19903
#>   2: MCID3111248941  19901 01 First-year        6       19953       19943
#>   3: MCID3111250695  19901 01 First-year        6       19953        <NA>
#>  ---                                                                     
#> 100: MCID3112409179  20091 01 First-year        6       20143       20123
#> 101: MCID3112411629  20091 01 First-year        6       20143       20124
#> 102: MCID3112498796  20101 01 First-year        6       20153       20143
#>      completion_status
#>                 <char>
#>   1:            timely
#>   2:            timely
#>   3:              <NA>
#>  ---                  
#> 100:            timely
#> 101:            timely
#> 102:            timely

# Completion status values
sort_uniq(DT$completion_status)
#> [1] NA       "late"   "timely"

# Exclude all but timely graduates, label the bloc
DT <- DT[completion_status == "timely", .(mcid)]
DT[, bloc := "grad"]
DT
#>               mcid   bloc
#>             <char> <char>
#>  1: MCID3111213943   grad
#>  2: MCID3111248941   grad
#>  3: MCID3111253227   grad
#> ---                      
#> 52: MCID3112409179   grad
#> 53: MCID3112411629   grad
#> 54: MCID3112498796   grad

# Join program codes and demographics to finalize graduates bloc
DT <- degree[DT, on = "mcid", .(mcid, bloc, cip6)]
DT <- student[DT, on = "mcid", .(mcid, bloc, cip6, race, sex)]
DT
#>               mcid   bloc   cip6   race    sex
#>             <char> <char> <char> <char> <char>
#>  1: MCID3111213943   grad 420101  White   Male
#>  2: MCID3111248941   grad 140901  White   Male
#>  3: MCID3111253227   grad 141901  White   Male
#> ---                                           
#> 52: MCID3112409179   grad 090401  Asian   Male
#> 53: MCID3112411629   grad 500601  White   Male
#> 54: MCID3112498796   grad 090101  White Female
```

## Acknowledgments

The development of midfieldr and midfielddata was supported by the US
National Science Foundation through grant numbers 1545667 and 2142087.

## References

Layton, Richard, Russell Long, Susan Lord, Matthew Ohland, and Marisa
Orr. 2026. *midfielddata: MIDFIELD Data Sample*. R package
version 0.2.3. <https://midfieldr.github.io/midfielddata/>.

Ohland, Matthew. 2023. *MIDFIELD, 2004–2023*.
<https://midfield.online/>.
