# midfieldr

## Overview

Provides tools for working with undergraduate student-level records
(registrar’s data) in R, supporting longitudinal studies in particular.

- [`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md)
  chooses columns required by midfieldr functions.  
- [`add_post_bacc()`](https://midfieldr.github.io/midfieldr/reference/add_post_bacc.md)
  identifies rows of post-baccalaureate terms to exclude.
- [`filter_cip()`](https://midfieldr.github.io/midfieldr/reference/filter_cip.md)
  chooses rows of CIP data based on search terms.  
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

Frequently used packages.

- [data.table](https://CRAN.R-project.org/package=data.table) for
  manipulating data ([Barrett et al.
  2026](#ref-Dowle+Srinivasan:2026:data.table))
- [ggplot2](https://CRAN.R-project.org/package=ggplot2) for charts
  ([Wickham 2016](#ref-Wickham:2016:ggplot2))

Other packages, used infrequently.

- [mice](https://CRAN.R-project.org/package=mice) for imputing starting
  majors of First-Year Engineering students ([van Buuren and
  Groothuis-Oudshoorn 2011](#ref-vanBuuren+Oudshoorn:2011)).
- [stringr](https://CRAN.R-project.org/package=stringr) for manipulation
  of character strings ([Wickham 2025](#ref-stringr)).

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
DT
#>                mcid
#>              <char>
#>   1: MCID3111158953
#>   2: MCID3111159270
#>   3: MCID3111160513
#>   4: MCID3111162677
#>   5: MCID3111164287
#>   6: MCID3111171205
#>   7: MCID3111172083
#>   8: MCID3111213943
#>   9: MCID3111248941
#>  10: MCID3111250695
#>  ---               
#> 141: MCID3112802165
#> 142: MCID3112803670
#> 143: MCID3112804805
#> 144: MCID3112839822
#> 145: MCID3112845932
#> 146: MCID3112846308
#> 147: MCID3112877403
#> 148: MCID3112881399
#> 149: MCID3112882995
#> 150: MCID3112884375

# Add variables relating to the timely term
DT <- add_timely_term(DT, toy_term)

# Order the rows for viewing 
DT <- DT[order(timely_term)]
DT
#>                mcid term_i       level_i adj_span timely_term
#>              <char> <char>        <char>    <num>      <char>
#>   1: MCID3111158953  19881 01 First-year        6       19933
#>   2: MCID3111159270  19881 01 First-year        6       19933
#>   3: MCID3111160513  19881 01 First-year        6       19933
#>   4: MCID3111162677  19881 01 First-year        6       19933
#>   5: MCID3111164287  19881 01 First-year        6       19933
#>   6: MCID3111171205  19881 01 First-year        6       19933
#>   7: MCID3111172083  19881 01 First-year        6       19933
#>   8: MCID3111213943  19891 01 First-year        6       19943
#>   9: MCID3111248941  19901 01 First-year        6       19953
#>  10: MCID3111250695  19901 01 First-year        6       19953
#>  ---                                                         
#> 141: MCID3112802165  20161 01 First-year        6       20213
#> 142: MCID3112803670  20161 01 First-year        6       20213
#> 143: MCID3112804805  20161 01 First-year        6       20213
#> 144: MCID3112839822  20171 01 First-year        6       20223
#> 145: MCID3112846308  20171 01 First-year        6       20223
#> 146: MCID3112845932  20173 01 First-year        6       20231
#> 147: MCID3112877403  20181 01 First-year        6       20233
#> 148: MCID3112881399  20181 01 First-year        6       20233
#> 149: MCID3112882995  20181 01 First-year        6       20233
#> 150: MCID3112884375  20181 01 First-year        6       20233

# Optional: reduce number of columns
DT <- DT[, .(mcid, timely_term)]

# Add variables relating to data sufficiency
DT <- add_data_sufficiency(DT, toy_term)
DT
#>                mcid timely_term term_i lower_limit upper_limit data_sufficiency
#>              <char>      <char> <char>      <char>      <char>           <char>
#>   1: MCID3111158953       19933  19881       19881       20096    exclude-lower
#>   2: MCID3111159270       19933  19881       19881       20096    exclude-lower
#>   3: MCID3111160513       19933  19881       19881       20096    exclude-lower
#>   4: MCID3111162677       19933  19881       19881       20096    exclude-lower
#>   5: MCID3111164287       19933  19881       19881       20096    exclude-lower
#>   6: MCID3111171205       19933  19881       19881       20181    exclude-lower
#>   7: MCID3111172083       19933  19881       19881       20181    exclude-lower
#>   8: MCID3111213943       19943  19891       19881       20181          include
#>   9: MCID3111248941       19953  19901       19881       20096          include
#>  10: MCID3111250695       19953  19901       19881       20096          include
#>  ---                                                                           
#> 141: MCID3112802165       20213  20161       19881       20181    exclude-upper
#> 142: MCID3112803670       20213  20161       19881       20181    exclude-upper
#> 143: MCID3112804805       20213  20161       19881       20181    exclude-upper
#> 144: MCID3112839822       20223  20171       19881       20181    exclude-upper
#> 145: MCID3112845932       20231  20173       19881       20181    exclude-upper
#> 146: MCID3112846308       20223  20171       19881       20181    exclude-upper
#> 147: MCID3112877403       20233  20181       19881       20181    exclude-upper
#> 148: MCID3112881399       20233  20181       19881       20181    exclude-upper
#> 149: MCID3112882995       20233  20181       19881       20181    exclude-upper
#> 150: MCID3112884375       20233  20181       19881       20181    exclude-upper

# Filter for data sufficiency
DT <- DT[data_sufficiency %chin% "include"]
DT
#>                mcid timely_term term_i lower_limit upper_limit data_sufficiency
#>              <char>      <char> <char>      <char>      <char>           <char>
#>   1: MCID3111213943       19943  19891       19881       20181          include
#>   2: MCID3111248941       19953  19901       19881       20096          include
#>   3: MCID3111250695       19953  19901       19881       20096          include
#>   4: MCID3111253227       19953  19901       19881       20096          include
#>   5: MCID3111258790       19953  19901       19881       20181          include
#>   6: MCID3111263510       19953  19901       19881       20181          include
#>   7: MCID3111282492       19963  19904       19901       20153          include
#>   8: MCID3111304195       19963  19911       19881       20096          include
#>   9: MCID3111315508       19963  19911       19901       20153          include
#>  10: MCID3111316435       19963  19911       19901       20153          include
#>  ---                                                                           
#>  96: MCID3112317359       20123  20071       19881       20181          include
#>  97: MCID3112352869       20133  20081       19881       20181          include
#>  98: MCID3112354970       20133  20081       19881       20181          include
#>  99: MCID3112406332       20143  20091       19881       20181          include
#> 100: MCID3112409179       20143  20091       19881       20181          include
#> 101: MCID3112411629       20143  20091       19881       20181          include
#> 102: MCID3112412904       20143  20091       19901       20153          include
#> 103: MCID3112413521       20143  20091       19901       20153          include
#> 104: MCID3112471930       20153  20101       19901       20153          include
#> 105: MCID3112498796       20153  20101       19881       20181          include

# Optional: reduce number of columns
DT <- DT[, .(mcid, timely_term)]

# Add variables relating to completion status
DT <- add_completion_status(DT, toy_degree)
DT
#>                mcid timely_term term_degree completion_status
#>              <char>      <char>      <char>            <char>
#>   1: MCID3111213943       19943       19903            timely
#>   2: MCID3111248941       19953       19943            timely
#>   3: MCID3111250695       19953        <NA>              <NA>
#>   4: MCID3111253227       19953       19951            timely
#>   5: MCID3111258790       19953       19954              late
#>   6: MCID3111263510       19953       19933            timely
#>   7: MCID3111282492       19963       19991              late
#>   8: MCID3111304195       19963        <NA>              <NA>
#>   9: MCID3111315508       19963       19961            timely
#>  10: MCID3111316435       19963       19964              late
#>  ---                                                         
#>  96: MCID3112317359       20123       20111            timely
#>  97: MCID3112352869       20133       20121            timely
#>  98: MCID3112354970       20133       20163              late
#>  99: MCID3112406332       20143       20131            timely
#> 100: MCID3112409179       20143       20123            timely
#> 101: MCID3112411629       20143       20124            timely
#> 102: MCID3112412904       20143       20123            timely
#> 103: MCID3112413521       20143       20173              late
#> 104: MCID3112471930       20153        <NA>              <NA>
#> 105: MCID3112498796       20153       20143            timely

# Filter for timely completion
DT <- DT[completion_status %chin% "timely"]
DT
#>               mcid timely_term term_degree completion_status
#>             <char>      <char>      <char>            <char>
#>  1: MCID3111213943       19943       19903            timely
#>  2: MCID3111248941       19953       19943            timely
#>  3: MCID3111253227       19953       19951            timely
#>  4: MCID3111263510       19953       19933            timely
#>  5: MCID3111315508       19963       19961            timely
#>  6: MCID3111316936       19963       19953            timely
#>  7: MCID3111354376       19973       19953            timely
#>  8: MCID3111355374       19973       19961            timely
#>  9: MCID3111356562       19973       19963            timely
#> 10: MCID3111357512       19973       19953            timely
#> ---                                                         
#> 46: MCID3112196380       20103       20083            timely
#> 47: MCID3112196966       20103       20093            timely
#> 48: MCID3112296580       20123       20103            timely
#> 49: MCID3112317359       20123       20111            timely
#> 50: MCID3112352869       20133       20121            timely
#> 51: MCID3112406332       20143       20131            timely
#> 52: MCID3112409179       20143       20123            timely
#> 53: MCID3112411629       20143       20124            timely
#> 54: MCID3112412904       20143       20123            timely
#> 55: MCID3112498796       20153       20143            timely

# Join demographic data, reduce number of columns
DT <- toy_student[DT, .(mcid, race, sex), on = "mcid"]

# Label the student bloc
DT[, bloc := "graduate"]
DT
#>               mcid          race    sex     bloc
#>             <char>        <char> <char>   <char>
#>  1: MCID3111213943         White   Male graduate
#>  2: MCID3111248941         White   Male graduate
#>  3: MCID3111253227         White   Male graduate
#>  4: MCID3111263510         White   Male graduate
#>  5: MCID3111315508 Other/Unknown   Male graduate
#>  6: MCID3111316936         White Female graduate
#>  7: MCID3111354376         White   Male graduate
#>  8: MCID3111355374         White   Male graduate
#>  9: MCID3111356562         White   Male graduate
#> 10: MCID3111357512         White   Male graduate
#> ---                                             
#> 46: MCID3112196380         White   Male graduate
#> 47: MCID3112196966         White Female graduate
#> 48: MCID3112296580         White   Male graduate
#> 49: MCID3112317359         White   Male graduate
#> 50: MCID3112352869         White   Male graduate
#> 51: MCID3112406332         White   Male graduate
#> 52: MCID3112409179         Asian   Male graduate
#> 53: MCID3112411629         White   Male graduate
#> 54: MCID3112412904         White   Male graduate
#> 55: MCID3112498796         White Female graduate
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

Wickham, Hadley. 2025. *stringr: Simple, consistent wrappers for common
string operations*. <https://doi.org/10.32614/CRAN.package.stringr>.
