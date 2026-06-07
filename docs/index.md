# midfieldr

## Overview

Provides tools and demonstrates methods for working with individual
undergraduate student-level records (registrar’s data) in R.

- [`filter_cip()`](https://midfieldr.github.io/midfieldr/reference/filter_cip.md)
  selects rows of program codes that match search terms
- [`select_required()`](https://midfieldr.github.io/midfieldr/reference/select_required.md)
  selects a minimum set of columns required by midfieldr functions
- [`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)
  adds a new timely completion term variable
- [`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md)
  adds a new data sufficiency status variable
- [`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md)
  adds a new program completion status variable
- [`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)
  conditions data for imputing starting majors of FYE students
- [`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)
  conditions data for plotting a Cleveland-style multiway chart

Suggested packages.

- [data.table](https://CRAN.R-project.org/package=data.table) for
  manipulating data ([Barrett et al.
  2026](#ref-Dowle+Srinivasan:2026:data.table))
- [ggplot2](https://CRAN.R-project.org/package=ggplot2) for charts
  ([Wickham 2016](#ref-Wickham:2016:ggplot2))
- [mice](https://CRAN.R-project.org/package=mice) for imputing starting
  majors of First-Year Engineering students ([van Buuren and
  Groothuis-Oudshoorn 2011](#ref-vanBuuren+Oudshoorn:2011)).

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

The installed size of midfielddata is about 24 Mb, so installation will
take longer than that of a conventional CRAN package.

## Usage

``` r

library(midfieldr)
library(data.table)
```

We illustrate usage with the “toy” data sets included in midfieldr.
These are small data sets of 150 unique students used in examples.

``` r

# Initialize the working data frame using toy_term
DT <- toy_term[, .(mcid)]
DT <- unique(DT)

# Add variables relating to the timely term
DT <- add_timely_term(DT, toy_term)
DT
#>                mcid term_i       level_i adj_span timely_term
#>              <char> <char>        <char>    <num>      <char>
#>   1: MCID3111158953  19881 01 First-year        6       19933
#>   2: MCID3111159270  19881 01 First-year        6       19933
#>   3: MCID3111160513  19881 01 First-year        6       19933
#>  ---                                                         
#> 148: MCID3112881399  20181 01 First-year        6       20233
#> 149: MCID3112882995  20181 01 First-year        6       20233
#> 150: MCID3112884375  20181 01 First-year        6       20233

# Add variables relating to data sufficiency
DT <- add_data_sufficiency(DT, toy_term)
DT[order(data_sufficiency)]
#>                mcid       level_i adj_span timely_term term_i lower_limit
#>              <char>        <char>    <num>      <char> <char>      <char>
#>   1: MCID3111158953 01 First-year        6       19933  19881       19881
#>   2: MCID3111159270 01 First-year        6       19933  19881       19881
#>   3: MCID3111160513 01 First-year        6       19933  19881       19881
#>  ---                                                                     
#> 148: MCID3112413521 01 First-year        6       20143  20091       19901
#> 149: MCID3112471930 01 First-year        6       20153  20101       19901
#> 150: MCID3112498796 01 First-year        6       20153  20101       19881
#>      upper_limit data_sufficiency
#>           <char>           <char>
#>   1:       20096    exclude-lower
#>   2:       20096    exclude-lower
#>   3:       20096    exclude-lower
#>  ---                             
#> 148:       20153          include
#> 149:       20153          include
#> 150:       20181          include

# Add variables relating to completion status
DT <- add_completion_status(DT, toy_degree)
DT[order(completion_status)]
#>                mcid       level_i adj_span timely_term term_i lower_limit
#>              <char>        <char>    <num>      <char> <char>      <char>
#>   1: MCID3111258790 01 First-year        6       19953  19901       19881
#>   2: MCID3111282492 01 First-year        6       19963  19904       19901
#>   3: MCID3111316435 01 First-year        6       19963  19911       19901
#>  ---                                                                     
#> 148: MCID3112881399 01 First-year        6       20233  20181       19881
#> 149: MCID3112882995 01 First-year        6       20233  20181       19881
#> 150: MCID3112884375 01 First-year        6       20233  20181       19881
#>      upper_limit data_sufficiency term_degree completion_status
#>           <char>           <char>      <char>            <char>
#>   1:       20181          include       19954              late
#>   2:       20153          include       19991              late
#>   3:       20153          include       19964              late
#>  ---                                                           
#> 148:       20181    exclude-upper        <NA>              <NA>
#> 149:       20181    exclude-upper        <NA>              <NA>
#> 150:       20181    exclude-upper        <NA>              <NA>

# Filter for data sufficiency and timely completion
rows_we_want <- DT$data_sufficiency == "include" & DT$completion_status == "timely"
DT <- DT[rows_we_want]
DT
#>               mcid       level_i adj_span timely_term term_i lower_limit
#>             <char>        <char>    <num>      <char> <char>      <char>
#>  1: MCID3111213943 01 First-year        6       19943  19891       19881
#>  2: MCID3111248941 01 First-year        6       19953  19901       19881
#>  3: MCID3111253227 01 First-year        6       19953  19901       19881
#> ---                                                                     
#> 53: MCID3112411629 01 First-year        6       20143  20091       19881
#> 54: MCID3112412904 01 First-year        6       20143  20091       19901
#> 55: MCID3112498796 01 First-year        6       20153  20101       19881
#>     upper_limit data_sufficiency term_degree completion_status
#>          <char>           <char>      <char>            <char>
#>  1:       20181          include       19903            timely
#>  2:       20096          include       19943            timely
#>  3:       20096          include       19951            timely
#> ---                                                           
#> 53:       20181          include       20124            timely
#> 54:       20153          include       20123            timely
#> 55:       20181          include       20143            timely

# Join demographic data
DT <- toy_student[DT, .(mcid, race, sex), on = "mcid"]

# Label the student bloc
DT[, bloc := "graduate"]
DT
#>               mcid   race    sex     bloc
#>             <char> <char> <char>   <char>
#>  1: MCID3111213943  White   Male graduate
#>  2: MCID3111248941  White   Male graduate
#>  3: MCID3111253227  White   Male graduate
#> ---                                      
#> 53: MCID3112411629  White   Male graduate
#> 54: MCID3112412904  White   Male graduate
#> 55: MCID3112498796  White Female graduate
```

## Acknowledgments

The development of midfieldr and midfielddata was supported by the US
National Science Foundation through grant numbers 1545667 and 2142087.

## References

Barrett, Tyson, Matt Dowle, Arun Srinivasan, et al. 2026. *data.table:
Extension of data.frame*. R package version 1.18.4.
<https://CRAN.R-project.org/package=data.table>.

Layton, Richard, Russell Long, Susan Lord, Matthew Ohland, and Marisa
Orr. 2026. *midfielddata: MIDFIELD Data Sample*. R package
version 0.2.3. <https://midfieldr.github.io/midfielddata/>.

Ohland, Matthew. 2023. *MIDFIELD, 2004–2023*.
<https://midfield.online/>.

van Buuren, Stef, and Karin Groothuis-Oudshoorn. 2011. “mice:
Multivariate Imputation by Chained Equations in R.” *Journal of
Statistical Software* 45 (3): 1–67.
<https://doi.org/10.18637/jss.v045.i03>.

Wickham, Hadley. 2016. *ggplot2: Elegant Graphics for Data Analysis*.
ISBN 978-3-319-24277-4; Springer-Verlag New York.
<https://ggplot2.tidyverse.org>.
