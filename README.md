
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
- `post_completion_terms()` identifies rows with post-baccalaureate
  terms to exclude.

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
- `look_at()` for data frames, wraps base `str()` with preset arguments.

``` r
library("midfieldr")
packageVersion("midfieldr")
#> [1] '1.0.3.9023'
Sys.Date()
#> [1] "2026-08-19"
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
structure as the practice data in midfielddata. Academic program names
and codes in dataset `cip` also loads with midfieldr.

``` r
library("midfieldr")
library("data.table")

# Program codes
look_at(cip)
#> Classes 'data.table' and 'data.frame':   1582 obs. of  6 variables:
#>  $ cip6name: chr  "Agriculture, General" "Agricultural Business and Managemen"..
#>  $ cip6    : chr  "010000" "010101" "010102" "010103" ...
#>  $ cip4name: chr  "Agriculture, General" "Agricultural Business and Managemen"..
#>  $ cip4    : chr  "0100" "0101" "0101" "0101" ...
#>  $ cip2name: chr  "Agriculture, Agricultural Operations and Related Sciences""..
#>  $ cip2    : chr  "01" "01" "01" "01" ...

# Search for program 6-digit codes
cip |>
  filter_programs("^14") |>
  filter_programs(c("civil", "mechanical"))
#>                                  cip6name   cip6                      cip4name
#>                                    <char> <char>                        <char>
#> 1:             Civil Engineering, General 140801             Civil Engineering
#> 2:               Geotechnical Engineering 140802             Civil Engineering
#> 3:                 Structural Engineering 140803             Civil Engineering
#> 4: Transportation and Highway Engineering 140804             Civil Engineering
#> 5:            Water Resources Engineering 140805             Civil Engineering
#> 6:               Civil Engineering, Other 140899             Civil Engineering
#> 7:                 Mechanical Engineering 141901        Mechanical Engineering
#> 8:          Electromechanical Engineering 144101 Electromechanical Engineering
#>      cip4    cip2name   cip2
#>    <char>      <char> <char>
#> 1:   1408 Engineering     14
#> 2:   1408 Engineering     14
#> 3:   1408 Engineering     14
#> 4:   1408 Engineering     14
#> 5:   1408 Engineering     14
#> 6:   1408 Engineering     14
#> 7:   1419 Engineering     14
#> 8:   1441 Engineering     14

# Set up program table with convenient labels
programs <- filter_programs(cip, c("^1408", "^1419"))
programs <- programs[, .(cip6name, cip6)]
programs[, program_abbr := fcase(
  cip6 %like% "^1408", "CE",
  cip6 %like% "^1419", "ME"
)]
programs
#>                                  cip6name   cip6 program_abbr
#>                                    <char> <char>       <char>
#> 1:             Civil Engineering, General 140801           CE
#> 2:               Geotechnical Engineering 140802           CE
#> 3:                 Structural Engineering 140803           CE
#> 4: Transportation and Highway Engineering 140804           CE
#> 5:            Water Resources Engineering 140805           CE
#> 6:               Civil Engineering, Other 140899           CE
#> 7:                 Mechanical Engineering 141901           ME

# "Toy" data sets assigned standard names
student <- copy(toy_student)
term <- copy(toy_term)
course <- copy(toy_course)
degree <- copy(toy_degree)

# Data structure
look_at(student)
#> Classes 'data.table' and 'data.frame':   351 obs. of  13 variables:
#>  $ mcid          : chr  "MCID3111142897" "MCID3111157634" "MCID3111158724" "M"..
#>  $ race          : chr  "International" "White" "White" "White" ...
#>  $ sex           : chr  "Male" "Female" "Male" "Male" ...
#>  $ institution   : chr  "Institution B" "Institution J" "Institution J" "Inst"..
#>  $ transfer      : chr  "First-Time Transfer" "First-Time in College" "First-"..
#>  $ hours_transfer: num  NA NA NA NA NA NA NA 78 64 NA ...
#>  $ age_desc      : chr  "Under 25" "Under 25" "Under 25" "Under 25" ...
#>  $ us_citizen    : chr  "No" "Yes" "Yes" "Yes" ...
#>  $ home_zip      : chr  NA "23842" "22026" "22075" ...
#>  $ high_school   : chr  NA "471790" "471345" "471230" ...
#>  $ sat_math      : num  NA 610 760 790 600 600 630 570 NA NA ...
#>  $ sat_verbal    : num  NA 550 560 630 640 660 670 600 NA NA ...
#>  $ act_comp      : num  NA NA NA NA NA NA NA NA NA 17 ...

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

look_at(course)
#> Classes 'data.table' and 'data.frame':   8950 obs. of  12 variables:
#>  $ mcid               : chr  "MCID3111142897" "MCID3111142897" "MCID311114289"..
#>  $ term_course        : chr  "19881" "19881" "19881" "19881" ...
#>  $ abbrev             : chr  "APAS" "CSCI" "PHYS" "PHYS" ...
#>  $ number             : chr  "3730" "1700" "7270" "7320" ...
#>  $ institution        : chr  "Institution B" "Institution B" "Institution B" "..
#>  $ course             : chr  "Astrophysics" "Intro To Scientific Prog" "Quant"..
#>  $ section            : chr  "001" "010" "001" "001" ...
#>  $ type               : chr  NA NA NA NA ...
#>  $ faculty_rank       : chr  NA NA NA NA ...
#>  $ hours_course       : num  3 0 3 3 3 3 0 0 6 3 ...
#>  $ grade              : chr  "A-" "CR" "B" "A" ...
#>  $ discipline_midfield: chr  "Physical Sciences: Atmospheric Sciences and Met"..

look_at(degree)
#> Classes 'data.table' and 'data.frame':   193 obs. of  5 variables:
#>  $ mcid       : chr  "MCID3111169601" "MCID3111169729" "MCID3111213539" "MCID"..
#>  $ term_degree: chr  "19903" "19901" "19923" "19911" ...
#>  $ cip6       : chr  "520201" "520201" "030103" "261399" ...
#>  $ institution: chr  "Institution B" "Institution B" "Institution B" "Institu"..
#>  $ degree     : chr  "Bachelor of Science in Business Administration and Mana"..

# Begin with the population
DT <- term[, .(mcid)]
DT <- unique(DT)
DT
#>                mcid
#>              <char>
#>   1: MCID3111142897
#>   2: MCID3111157634
#>   3: MCID3111158724
#>   4: MCID3111163443
#>   5: MCID3111163894
#>  ---               
#> 347: MCID3112815901
#> 348: MCID3112839623
#> 349: MCID3112868072
#> 350: MCID3112869843
#> 351: MCID3112885339

# Add timely-completion columns
DT <- timely_term(DT, midf_table = term)
DT
#>                mcid term_i       level_i adj_span timely_term
#>              <char> <char>        <char>    <num>      <char>
#>   1: MCID3111142897  19881 01 First-year        6       19933
#>   2: MCID3111157634  19881 01 First-year        6       19933
#>   3: MCID3111158724  19881 01 First-year        6       19933
#>   4: MCID3111163443  19881 01 First-year        6       19933
#>   5: MCID3111163894  19881 01 First-year        6       19933
#>  ---                                                         
#> 347: MCID3112815901  20161 01 First-year        6       20213
#> 348: MCID3112839623  20171 01 First-year        6       20223
#> 349: MCID3112868072  20171 01 First-year        6       20223
#> 350: MCID3112869843  20173 01 First-year        6       20231
#> 351: MCID3112885339  20181 01 First-year        6       20233

# Add data sufficiency columns
DT <- DT[, .(mcid, term_i, timely_term)]
DT <- data_sufficiency(DT, midf_table = term)
DT[order(data_sufficiency)]
#>                mcid term_i timely_term  data_range data_sufficiency
#>              <char> <char>      <char>      <char>           <char>
#>   1: MCID3111142897  19881       19933 19881-20181    exclude-lower
#>   2: MCID3111157634  19881       19933 19881-20096    exclude-lower
#>   3: MCID3111158724  19881       19933 19881-20096    exclude-lower
#>   4: MCID3111163443  19881       19933 19881-20096    exclude-lower
#>   5: MCID3111163894  19881       19933 19881-20096    exclude-lower
#>  ---                                                               
#> 347: MCID3112486054  20101       20153 19881-20181          include
#> 348: MCID3112587501  20121       20173 19881-20181          include
#> 349: MCID3112592592  20121       20173 19881-20181          include
#> 350: MCID3112593368  20121       20173 19881-20181          include
#> 351: MCID3112617577  20123       20181 19881-20181          include

# Initial population labeled "include", drop all others
population <- DT[data_sufficiency == "include", .(mcid)]
population <- unique(population)
population
#>                mcid
#>              <char>
#>   1: MCID3111198701
#>   2: MCID3111208924
#>   3: MCID3111213539
#>   4: MCID3111213856
#>   5: MCID3111246563
#>  ---               
#> 236: MCID3112486054
#> 237: MCID3112587501
#> 238: MCID3112592592
#> 239: MCID3112593368
#> 240: MCID3112617577

# Inner join to restrict source data to this population
student <- population[student, on = "mcid", nomatch = NULL]
term <- population[term, on = "mcid", nomatch = NULL]
course <- population[course, on = "mcid", nomatch = NULL]
degree <- population[degree, on = "mcid", nomatch = NULL]

dim(student)
#> [1] 240  13
dim(term)
#> [1] 1347   13
dim(course)
#> [1] 6421   12
dim(degree)
#> [1] 170   5

# Identify post-baccalaureate terms
term <- post_completion_terms(term, midf_table = degree)
course <- post_completion_terms(course, midf_table = degree)
degree <- post_completion_terms(degree, midf_table = degree)

# View partial results
term[, .(mcid, first_degree_term, term_cluster)][order(term_cluster)]
#>                 mcid first_degree_term term_cluster
#>               <char>            <char>       <char>
#>    1: MCID3111213539             19923 first-degree
#>    2: MCID3111254225             19923 first-degree
#>    3: MCID3111254412             19933 first-degree
#>    4: MCID3111257675             19931 first-degree
#>    5: MCID3111257677             19923 first-degree
#>   ---                                              
#> 1343: MCID3112593368             20153   pre-degree
#> 1344: MCID3112593368             20153   pre-degree
#> 1345: MCID3112593368             20153   pre-degree
#> 1346: MCID3112593368             20153   pre-degree
#> 1347: MCID3112617577              <NA>   pre-degree

course[, .(mcid, first_degree_term, term_cluster)][order(term_cluster)]
#>                 mcid first_degree_term term_cluster
#>               <char>            <char>       <char>
#>    1: MCID3111213539             19923 first-degree
#>    2: MCID3111213539             19923 first-degree
#>    3: MCID3111213539             19923 first-degree
#>    4: MCID3111213539             19923 first-degree
#>    5: MCID3111213539             19923 first-degree
#>   ---                                              
#> 6417: MCID3112617577              <NA>   pre-degree
#> 6418: MCID3112617577              <NA>   pre-degree
#> 6419: MCID3112617577              <NA>   pre-degree
#> 6420: MCID3112617577              <NA>   pre-degree
#> 6421: MCID3112617577              <NA>   pre-degree

degree[, .(mcid, first_degree_term, term_cluster)][order(term_cluster)]
#>                mcid first_degree_term      term_cluster
#>              <char>            <char>            <char>
#>   1: MCID3111213539             19923      first-degree
#>   2: MCID3111213856             19911      first-degree
#>   3: MCID3111254225             19923      first-degree
#>   4: MCID3111254412             19933      first-degree
#>   5: MCID3111257675             19931      first-degree
#>  ---                                                   
#> 166: MCID3112486054             20143      first-degree
#> 167: MCID3112587501             20141      first-degree
#> 168: MCID3112592592             20153      first-degree
#> 169: MCID3112593368             20153      first-degree
#> 170: MCID3112012180             20043 post-first-degree

# Exclude rows after the first degree term
term <- term[term_cluster != "post-first-degree"]
course <- course[term_cluster != "post-first-degree"]
degree <- degree[term_cluster != "post-first-degree"]

# Choose a minimum set of columns to proceed
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
#>   4: MCID3111213856         White Female
#>   5: MCID3111246563         White   Male
#>  ---                                    
#> 236: MCID3112486054         White Female
#> 237: MCID3112587501      Hispanic Female
#> 238: MCID3112592592         White   Male
#> 239: MCID3112593368         White Female
#> 240: MCID3112617577 International Female

term
#>                 mcid   term   cip6   institution          level
#>               <char> <char> <char>        <char>         <char>
#>    1: MCID3111198701  19891 240102 Institution J  01 First-year
#>    2: MCID3111198701  19893 520301 Institution J  01 First-year
#>    3: MCID3111208924  19891 240102 Institution J  01 First-year
#>    4: MCID3111208924  19893 140102 Institution J  01 First-year
#>    5: MCID3111208924  19895 140102 Institution J  01 First-year
#>   ---                                                          
#> 1326: MCID3112593368  20133 090101 Institution B  03 Third-year
#> 1327: MCID3112593368  20141 090101 Institution B  03 Third-year
#> 1328: MCID3112593368  20151 090101 Institution B  03 Third-year
#> 1329: MCID3112593368  20153 090101 Institution B 04 Fourth-year
#> 1330: MCID3112617577  20123 240199 Institution B  01 First-year

course
#>                 mcid term_course abbrev number
#>               <char>      <char> <char> <char>
#>    1: MCID3111198701       19891   ACCT   1504
#>    2: MCID3111198701       19891   CHEM   1015
#>    3: MCID3111198701       19891   CHEM   1025
#>    4: MCID3111198701       19891   ENGL   1105
#>    5: MCID3111198701       19891   MATH   1525
#>   ---                                         
#> 6376: MCID3112617577       20121   NCIE   4175
#> 6377: MCID3112617577       20123   GEOG   1992
#> 6378: MCID3112617577       20123   LING   1000
#> 6379: MCID3112617577       20123   PSYC   1001
#> 6380: MCID3112617577       20123   WRTG   1150

degree
#>                mcid term_degree   cip6
#>              <char>      <char> <char>
#>   1: MCID3111213539       19923 030103
#>   2: MCID3111213856       19911 261399
#>   3: MCID3111254225       19923 270101
#>   4: MCID3111254412       19933 140901
#>   5: MCID3111257675       19931 451001
#>  ---                                  
#> 165: MCID3112485250       20121 451101
#> 166: MCID3112486054       20143 040401
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
