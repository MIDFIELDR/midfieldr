# midfieldr

## Overview

Provides tools in for working with undergraduate, longitudinal,
student-level records (registrar’s data) in R.

- [`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md)
  chooses columns required by midfieldr functions.  
- [`add_post_bacc()`](https://midfieldr.github.io/midfieldr/reference/add_post_bacc.md)
  identifies rows of post-baccalaureate terms to exclude.
- [`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)
  estimates a student’s timely graduation term.
- [`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md)
  identifies rows to exclude due to insufficient data.
- [`filter_cip()`](https://midfieldr.github.io/midfieldr/reference/filter_cip.md)
  chooses rows of program data based on search terms.
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
These are small data sets of 150 unique students used in examples.

``` r

# Packages
library(midfieldr)
library(data.table)

# Initialize records
student <- select_basic_cols(toy_student)
term <- select_basic_cols(toy_term)
degree <- select_basic_cols(toy_degree)

# View a representative result
term
#>                 mcid   institution   term   cip6          level
#>               <char>        <char> <char> <char>         <char>
#>    1: MCID3111158953 Institution J  19881 240102  01 First-year
#>    2: MCID3111158953 Institution J  19883 240102  01 First-year
#>    3: MCID3111158953 Institution J  19891 240102 02 Second-year
#>    4: MCID3111158953 Institution J  19893 240102 02 Second-year
#>    5: MCID3111158953 Institution J  19901 240102  03 Third-year
#>   ---                                                          
#> 1091: MCID3112846308 Institution B  20181 510201 02 Second-year
#> 1092: MCID3112877403 Institution B  20181 050200  01 First-year
#> 1093: MCID3112881399 Institution B  20181 260901  01 First-year
#> 1094: MCID3112882995 Institution B  20181 141901  01 First-year
#> 1095: MCID3112884375 Institution B  20181 520201  01 First-year

# Label pre- and post-baccalaureate terms
term <- add_post_bacc(term, midfield_degree = degree)
degree <- add_post_bacc(degree, midfield_degree = degree)

# View selected columns of a result
term[order(term_status), .(mcid, term_status)]
#>                 mcid  term_status
#>               <char>       <char>
#>    1: MCID3111159270 first-degree
#>    2: MCID3111162677 first-degree
#>    3: MCID3111171205 first-degree
#>    4: MCID3111172083 first-degree
#>    5: MCID3111213943 first-degree
#>   ---                            
#> 1091: MCID3112846308     pre-bacc
#> 1092: MCID3112877403     pre-bacc
#> 1093: MCID3112881399     pre-bacc
#> 1094: MCID3112882995     pre-bacc
#> 1095: MCID3112884375     pre-bacc

# Exclude post-baccalaureate terms
term <- term[term_status != "post-first-degree"]
degree <- degree[term_status != "post-first-degree"]

# View selected columns of a result
term[order(term_status), .(mcid, term_status)]
#>                 mcid  term_status
#>               <char>       <char>
#>    1: MCID3111159270 first-degree
#>    2: MCID3111162677 first-degree
#>    3: MCID3111171205 first-degree
#>    4: MCID3111172083 first-degree
#>    5: MCID3111213943 first-degree
#>   ---                            
#> 1066: MCID3112846308     pre-bacc
#> 1067: MCID3112877403     pre-bacc
#> 1068: MCID3112881399     pre-bacc
#> 1069: MCID3112882995     pre-bacc
#> 1070: MCID3112884375     pre-bacc

# Extract the student IDs
DT <- term[, .(mcid)]
DT <- unique(DT)
setorderv(DT, "mcid")
DT
#>                mcid
#>              <char>
#>   1: MCID3111158953
#>   2: MCID3111159270
#>   3: MCID3111160513
#>   4: MCID3111162677
#>   5: MCID3111164287
#>  ---               
#> 146: MCID3112846308
#> 147: MCID3112877403
#> 148: MCID3112881399
#> 149: MCID3112882995
#> 150: MCID3112884375

# Determine timely completion terms
DT <- add_timely_term(DT, midfield_term = term)
DT
#>                mcid term_i       level_i adj_span timely_term
#>              <char> <char>        <char>    <num>      <char>
#>   1: MCID3111158953  19881 01 First-year        6       19933
#>   2: MCID3111159270  19881 01 First-year        6       19933
#>   3: MCID3111160513  19881 01 First-year        6       19933
#>   4: MCID3111162677  19881 01 First-year        6       19933
#>   5: MCID3111164287  19881 01 First-year        6       19933
#>  ---                                                         
#> 146: MCID3112846308  20171 01 First-year        6       20223
#> 147: MCID3112877403  20181 01 First-year        6       20233
#> 148: MCID3112881399  20181 01 First-year        6       20233
#> 149: MCID3112882995  20181 01 First-year        6       20233
#> 150: MCID3112884375  20181 01 First-year        6       20233

# With timely term, determine data sufficiency
DT <- DT[, .(mcid, timely_term)]
DT <- add_data_sufficiency(DT, midfield_term = term)
DT[order(data_sufficiency)]
#>                mcid timely_term term_i lower_limit upper_limit data_sufficiency
#>              <char>      <char> <char>      <char>      <char>           <char>
#>   1: MCID3111158953       19933  19881       19881       20096    exclude-lower
#>   2: MCID3111159270       19933  19881       19881       20096    exclude-lower
#>   3: MCID3111160513       19933  19881       19881       20096    exclude-lower
#>   4: MCID3111162677       19933  19881       19881       20096    exclude-lower
#>   5: MCID3111164287       19933  19881       19881       20096    exclude-lower
#>  ---                                                                           
#> 146: MCID3112354970       20133  20081       19881       20181          include
#> 147: MCID3112406332       20143  20091       19881       20181          include
#> 148: MCID3112409179       20143  20091       19881       20181          include
#> 149: MCID3112411629       20143  20091       19881       20181          include
#> 150: MCID3112498796       20153  20101       19881       20181          include

# Filter for data sufficiency, select columns
DT <- DT[data_sufficiency == "include", .(mcid, timely_term, data_sufficiency)]
DT
#>                mcid timely_term data_sufficiency
#>              <char>      <char>           <char>
#>   1: MCID3111213943       19943          include
#>   2: MCID3111248941       19953          include
#>   3: MCID3111250695       19953          include
#>   4: MCID3111253227       19953          include
#>   5: MCID3111258790       19953          include
#>  ---                                            
#>  98: MCID3112354970       20133          include
#>  99: MCID3112406332       20143          include
#> 100: MCID3112409179       20143          include
#> 101: MCID3112411629       20143          include
#> 102: MCID3112498796       20153          include

# With timely term, determine completion status
DT <- add_completion_status(DT, midfield_degree = degree)
DT
#>                mcid timely_term data_sufficiency term_degree completion_status
#>              <char>      <char>           <char>      <char>            <char>
#>   1: MCID3111213943       19943          include       19903            timely
#>   2: MCID3111248941       19953          include       19943            timely
#>   3: MCID3111250695       19953          include        <NA>              <NA>
#>   4: MCID3111253227       19953          include       19951            timely
#>   5: MCID3111258790       19953          include       19954              late
#>  ---                                                                          
#>  98: MCID3112354970       20133          include       20163              late
#>  99: MCID3112406332       20143          include       20131            timely
#> 100: MCID3112409179       20143          include       20123            timely
#> 101: MCID3112411629       20143          include       20124            timely
#> 102: MCID3112498796       20153          include       20143            timely

# Filter for timely completion, select columns, add bloc label
DT <- DT[completion_status %chin% "timely", .(mcid, data_sufficiency, completion_status)]
DT[, bloc := "grad"]
DT
#>               mcid data_sufficiency completion_status   bloc
#>             <char>           <char>            <char> <char>
#>  1: MCID3111213943          include            timely   grad
#>  2: MCID3111248941          include            timely   grad
#>  3: MCID3111253227          include            timely   grad
#>  4: MCID3111263510          include            timely   grad
#>  5: MCID3111315508          include            timely   grad
#> ---                                                         
#> 50: MCID3112352869          include            timely   grad
#> 51: MCID3112406332          include            timely   grad
#> 52: MCID3112409179          include            timely   grad
#> 53: MCID3112411629          include            timely   grad
#> 54: MCID3112498796          include            timely   grad

# Join the degree program code, select columns
DT <- degree[DT, .(mcid, bloc, program_code = cip6), on = "mcid"]
DT
#>               mcid   bloc program_code
#>             <char> <char>       <char>
#>  1: MCID3111213943   grad       420101
#>  2: MCID3111248941   grad       140901
#>  3: MCID3111253227   grad       141901
#>  4: MCID3111263510   grad       040401
#>  5: MCID3111315508   grad       260101
#> ---                                   
#> 50: MCID3112352869   grad       500601
#> 51: MCID3112406332   grad       380201
#> 52: MCID3112409179   grad       090401
#> 53: MCID3112411629   grad       500601
#> 54: MCID3112498796   grad       090101

# Join demographic data, select columns
DT <- student[DT, .(mcid, bloc, program_code, race, sex), on = "mcid"]
setorderv(DT, c("sex", "race"))
DT
#>               mcid   bloc program_code          race    sex
#>             <char> <char>       <char>        <char> <char>
#>  1: MCID3112133617   grad       141001         Asian Female
#>  2: MCID3111871132   grad       520201         Black Female
#>  3: MCID3111767121   grad       090401 International Female
#>  4: MCID3111367250   grad       520101 Other/Unknown Female
#>  5: MCID3111316936   grad       141901         White Female
#> ---                                                        
#> 50: MCID3112296580   grad       450701         White   Male
#> 51: MCID3112317359   grad       260901         White   Male
#> 52: MCID3112352869   grad       500601         White   Male
#> 53: MCID3112406332   grad       380201         White   Male
#> 54: MCID3112411629   grad       500601         White   Male
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
