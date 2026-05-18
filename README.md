
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr <img src="man/figures/logo.png" align="right" height="125K">

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/midfieldr)](https://cran.r-project.org/package=midfieldr)  
[![R CMD
check](https://github.com/MIDFIELDR/midfieldr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MIDFIELDR/midfieldr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

midfieldr is an R package that provides tools and methods for studying
undergraduate student-level records from the MIDFIELD database.

- `filter_cip()` selects rows of program codes that match search terms
- `select_required()` selects columns required by midfieldr functions
- `add_timely_term()` adds a new variable for a timely completion term
- `add_data_sufficiency()` adds a new variable for data sufficiency
  status
- `add_completion_status()` adds a new variable for program completion
  status
- `prep_fye_mice()` conditions data for imputing starting majors of FYE
  students
- `order_multiway()` conditions data for plotting a Cleveland-style
  multiway chart

Suggested packages.

- [data.table](https://CRAN.R-project.org/package=data.table) for
  manipulating data ([Barrett et al.
  2026](#ref-Dowle+Srinivasan:2026:data.table))
- [ggplot2](https://CRAN.R-project.org/package=ggplot2) for charts
  ([Wickham 2016](#ref-Wickham:2016:ggplot2))
- [mice](https://CRAN.R-project.org/package=mice) for imputing starting
  majors of First-Year Engineering students ([<span class="nocase">van
  Buuren and Groothuis-Oudshoorn</span>
  2011](#ref-vanBuuren+Oudshoorn:2011)).

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

midfieldr is designed to operate on the four data tables of the MIDFIELD
research database. A sample of that database is available in the
midfielddata package ([Layton et al.
2026](#ref-Layton+Long+Ohland:2026:midfielddata)). Install from the
MIDFIELDR drat repository with:

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

We would usually load midfielddata as well, but here we can illustrate
usage with the “toy” data sets included in midfieldr.

``` r
# Initialize the working data frame using toy_term
DT <- toy_term[, .(mcid)]
DT <- unique(DT)

# Add variables relating to the timely term
DT <- add_timely_term(DT, toy_term)
DT
#>                mcid term_i       level_i adj_span timely_term
#>              <char> <char>        <char>    <num>      <char>
#>   1: MCID3111145992  19881 01 First-year        6       19933
#>   2: MCID3111159270  19881 01 First-year        6       19933
#>   3: MCID3111160219  19881 01 First-year        6       19933
#>  ---                                                         
#> 148: MCID3112804735  20161 01 First-year        6       20213
#> 149: MCID3112813578  20161 01 First-year        6       20213
#> 150: MCID3112845932  20173 01 First-year        6       20231

# Add variables relating to data sufficiency
DT <- add_data_sufficiency(DT, toy_term)
DT[order(data_sufficiency)]
#>                mcid       level_i adj_span timely_term term_i lower_limit
#>              <char>        <char>    <num>      <char> <char>      <char>
#>   1: MCID3111145992 01 First-year        6       19933  19881       19881
#>   2: MCID3111159270 01 First-year        6       19933  19881       19881
#>   3: MCID3111160219 01 First-year        6       19933  19881       19881
#>  ---                                                                     
#> 148: MCID3112470565 01 First-year        6       20153  20101       19881
#> 149: MCID3112472090 01 First-year        6       20153  20101       19881
#> 150: MCID3112498796 01 First-year        6       20153  20101       19881
#>      upper_limit data_sufficiency
#>           <char>           <char>
#>   1:       20096    exclude-lower
#>   2:       20096    exclude-lower
#>   3:       20096    exclude-lower
#>  ---                             
#> 148:       20181          include
#> 149:       20181          include
#> 150:       20181          include

# Add variables relating to completion status
DT <- add_completion_status(DT, toy_degree)
DT[order(completion_status)]
#>                mcid       level_i adj_span timely_term term_i lower_limit
#>              <char>        <char>    <num>      <char> <char>      <char>
#>   1: MCID3111258790 01 First-year        6       19953  19901       19881
#>   2: MCID3111316257 01 First-year        6       19953  19901       19901
#>   3: MCID3111316435 01 First-year        6       19963  19911       19901
#>  ---                                                                     
#> 148: MCID3112804735 01 First-year        6       20213  20161       19881
#> 149: MCID3112813578 01 First-year        6       20213  20161       19881
#> 150: MCID3112845932 01 First-year        6       20231  20173       19881
#>      upper_limit data_sufficiency term_degree completion_status
#>           <char>           <char>      <char>            <char>
#>   1:       20181          include       19954              late
#>   2:       20153    exclude-lower       19961              late
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
#>  2: MCID3111224601 01 First-year        6       19953  19901       19881
#>  3: MCID3111253227 01 First-year        6       19953  19901       19881
#> ---                                                                     
#> 48: MCID3112470565 01 First-year        6       20153  20101       19881
#> 49: MCID3112472090 01 First-year        6       20153  20101       19881
#> 50: MCID3112498796 01 First-year        6       20153  20101       19881
#>     upper_limit data_sufficiency term_degree completion_status
#>          <char>           <char>      <char>            <char>
#>  1:       20181          include       19903            timely
#>  2:       20181          include       19921            timely
#>  3:       20096          include       19951            timely
#> ---                                                           
#> 48:       20181          include       20133            timely
#> 49:       20181          include       20134            timely
#> 50:       20181          include       20143            timely

# Join demographic data
DT <- toy_student[DT, .(mcid, race, sex), on = "mcid"]

# Label the student bloc
DT[, bloc := "graduate"]
DT
#>               mcid     race    sex     bloc
#>             <char>   <char> <char>   <char>
#>  1: MCID3111213943    White   Male graduate
#>  2: MCID3111224601 Hispanic Female graduate
#>  3: MCID3111253227    White   Male graduate
#> ---                                        
#> 48: MCID3112470565    White Female graduate
#> 49: MCID3112472090    White Female graduate
#> 50: MCID3112498796    White Female graduate
```

*Reminder.*   midfielddata is suitable for learning to work with
student-level data but not for drawing inferences about program
attributes or student experiences. midfielddata supplies practice data,
not research data.

## Acknowledgments

The development of midfieldr and midfielddata was supported by the US
National Science Foundation through grant numbers 1545667 and 2142087.
midfieldr is also designed to interact with the full MIDFIELD database,
the management of which was transferred to the American Society for
Engineering Education in 2023.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-Dowle+Srinivasan:2026:data.table" class="csl-entry">

Barrett, Tyson, Matt Dowle, Arun Srinivasan, et al. 2026.
*<span class="nocase">data.table: Extension of data.frame</span>*. R
package version 1.18.4. <https://CRAN.R-project.org/package=data.table>.

</div>

<div id="ref-Layton+Long+Ohland:2026:midfielddata" class="csl-entry">

Layton, Richard, Russell Long, Susan Lord, Matthew Ohland, and Marisa
Orr. 2026. *<span class="nocase">midfielddata: MIDFIELD Data
Sample</span>*. R package version 0.2.3.
<https://midfieldr.github.io/midfielddata/>.

</div>

<div id="ref-vanBuuren+Oudshoorn:2011" class="csl-entry">

<span class="nocase">van Buuren, Stef, and Karin
Groothuis-Oudshoorn</span>. 2011. “<span class="nocase">mice</span>:
Multivariate Imputation by Chained Equations in R.” *Journal of
Statistical Software* 45 (3): 1–67.
<https://doi.org/10.18637/jss.v045.i03>.

</div>

<div id="ref-Wickham:2016:ggplot2" class="csl-entry">

Wickham, Hadley. 2016. *<span class="nocase">ggplot2: Elegant Graphics
for Data Analysis</span>*. ISBN 978-3-319-24277-4; Springer-Verlag New
York. <https://ggplot2.tidyverse.org>.

</div>

</div>
