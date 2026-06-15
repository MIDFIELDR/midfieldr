# midfieldr

## Overview

Provides tools in ‘R’ for working with undergraduate, longitudinal,
student-level records modeled on the MIDFIELD database.

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
- [`filter_cip()`](https://midfieldr.github.io/midfieldr/reference/filter_cip.md)
  chooses rows of program data based on search terms.
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

# Packages
library(midfieldr)
library(data.table)

# Start with student records, select basic columns
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

# Determine pre- and post-baccalaureate terms
term <- add_post_bacc(term, midfield_degree = degree)
degree <- add_post_bacc(degree, midfield_degree = degree)

# View selected variables
term[order(term_status), .(mcid, term, first_degree_term, term_status)]
#>                 mcid   term first_degree_term  term_status
#>               <char> <char>            <char>       <char>
#>    1: MCID3111159270  19913             19913 first-degree
#>    2: MCID3111162677  19913             19913 first-degree
#>    3: MCID3111171205  19913             19913 first-degree
#>    4: MCID3111172083  19913             19913 first-degree
#>    5: MCID3111213943  19903             19903 first-degree
#>   ---                                                     
#> 1091: MCID3112846308  20181              <NA>     pre-bacc
#> 1092: MCID3112877403  20181              <NA>     pre-bacc
#> 1093: MCID3112881399  20181              <NA>     pre-bacc
#> 1094: MCID3112882995  20181              <NA>     pre-bacc
#> 1095: MCID3112884375  20181              <NA>     pre-bacc

# Filter to exclude post-baccalaureate terms
term <- term[term_status != "post-first-degree"]
degree <- degree[term_status != "post-first-degree"]

# View selected variables
term[order(term_status), .(mcid, term, first_degree_term, term_status)]
#>                 mcid   term first_degree_term  term_status
#>               <char> <char>            <char>       <char>
#>    1: MCID3111159270  19913             19913 first-degree
#>    2: MCID3111162677  19913             19913 first-degree
#>    3: MCID3111171205  19913             19913 first-degree
#>    4: MCID3111172083  19913             19913 first-degree
#>    5: MCID3111213943  19903             19903 first-degree
#>   ---                                                     
#> 1066: MCID3112846308  20181              <NA>     pre-bacc
#> 1067: MCID3112877403  20181              <NA>     pre-bacc
#> 1068: MCID3112881399  20181              <NA>     pre-bacc
#> 1069: MCID3112882995  20181              <NA>     pre-bacc
#> 1070: MCID3112884375  20181              <NA>     pre-bacc

# Start working on the population
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

# Determine data sufficiency
DT <- add_data_sufficiency(DT, midfield_term = term)

# View selected variables
DT[order(data_sufficiency), .(mcid, timely_term, data_sufficiency)]
#>                mcid timely_term data_sufficiency
#>              <char>      <char>           <char>
#>   1: MCID3111158953       19933    exclude-lower
#>   2: MCID3111159270       19933    exclude-lower
#>   3: MCID3111160513       19933    exclude-lower
#>   4: MCID3111162677       19933    exclude-lower
#>   5: MCID3111164287       19933    exclude-lower
#>  ---                                            
#> 146: MCID3112354970       20133          include
#> 147: MCID3112406332       20143          include
#> 148: MCID3112409179       20143          include
#> 149: MCID3112411629       20143          include
#> 150: MCID3112498796       20153          include

# Filter for data sufficiency
DT <- DT[data_sufficiency == "include"]

# View selected variables
DT[order(mcid), .(mcid, timely_term, data_sufficiency)]
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

# Determine completion status
DT <- add_completion_status(DT, midfield_degree = degree)

# View selected variables
DT[, .(mcid, term_degree, timely_term, completion_status)]
#>                mcid term_degree timely_term completion_status
#>              <char>      <char>      <char>            <char>
#>   1: MCID3111213943       19903       19943            timely
#>   2: MCID3111248941       19943       19953            timely
#>   3: MCID3111250695        <NA>       19953              <NA>
#>   4: MCID3111253227       19951       19953            timely
#>   5: MCID3111258790       19954       19953              late
#>  ---                                                         
#>  98: MCID3112354970       20163       20133              late
#>  99: MCID3112406332       20131       20143            timely
#> 100: MCID3112409179       20123       20143            timely
#> 101: MCID3112411629       20124       20143            timely
#> 102: MCID3112498796       20143       20153            timely

# Filter for timely completion
DT <- DT[completion_status %chin% "timely"]

# View selected variables
DT[, .(mcid, data_sufficiency, completion_status)]
#>               mcid data_sufficiency completion_status
#>             <char>           <char>            <char>
#>  1: MCID3111213943          include            timely
#>  2: MCID3111248941          include            timely
#>  3: MCID3111253227          include            timely
#>  4: MCID3111263510          include            timely
#>  5: MCID3111315508          include            timely
#> ---                                                  
#> 50: MCID3112352869          include            timely
#> 51: MCID3112406332          include            timely
#> 52: MCID3112409179          include            timely
#> 53: MCID3112411629          include            timely
#> 54: MCID3112498796          include            timely

# Define this bloc
DT[, bloc := "grad"]

# Join the degree program code
DT <- degree[DT, on = "mcid"]

# Join demographic data
DT <- student[DT, on = "mcid"]

# Typical data set prior to grouping and summarizing
setorderv(DT, c("sex", "race"))
DT[, .(mcid, bloc, cip6, race, sex)]
#>               mcid   bloc   cip6          race    sex
#>             <char> <char> <char>        <char> <char>
#>  1: MCID3112133617   grad 141001         Asian Female
#>  2: MCID3111871132   grad 520201         Black Female
#>  3: MCID3111767121   grad 090401 International Female
#>  4: MCID3111367250   grad 520101 Other/Unknown Female
#>  5: MCID3111316936   grad 141901         White Female
#> ---                                                  
#> 50: MCID3112296580   grad 450701         White   Male
#> 51: MCID3112317359   grad 260901         White   Male
#> 52: MCID3112352869   grad 500601         White   Male
#> 53: MCID3112406332   grad 380201         White   Male
#> 54: MCID3112411629   grad 500601         White   Male
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
