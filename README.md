
<!-- README.md is generated from README.Rmd. Please edit that file -->

<br>midfieldr is an R package that provides tools and methods for
studying undergraduate student-level records from the MIDFIELD database.

<img src="man/figures/logo.png" width="15%" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/midfieldr)](https://CRAN.R-project.org/package=midfieldr)  
[![R-CMD-check](https://github.com/MIDFIELDR/midfieldr/workflows/R-CMD-check/badge.svg)](https://github.com/MIDFIELDR/midfieldr/actions)  
[![codecov](https://codecov.io/gh/MIDFIELDR/midfieldr/branch/main/graph/badge.svg?token=KcuCzBkLBP)](https://app.codecov.io/gh/MIDFIELDR/midfieldr)  
[![status](https://tinyverse.netlify.app/badge/midfieldr)](https://CRAN.R-project.org/package=midfieldr)  
[![downloads](http://cranlogs.r-pkg.org/badges/grand-total/midfieldr?color=blue)](https://cran.r-project.org/package=midfieldr)  
<!-- badges: end -->

## Introduction

Provides tools and demonstrates methods for working with individual
undergraduate student-level records (registrar’s data) in R. Tools
include filters for program codes, data sufficiency, and timely
completion. Methods include gathering blocs of records, computing
quantitative metrics such as graduation rate, and creating charts to
visualize comparisons. midfieldr is designed to work with data from the
MIDFIELD research database, a sample of which is available in the
midfielddata data package.

midfieldr provides these functions for processing student-level data:

- `add_completion_status()` Determine completion status for every
  student
- `add_data_sufficiency()` Determine data sufficiency for every student
- `add_timely_term()` Calculate a timely completion term for every
  student
- `filter_cip()` Filter CIP data to match search strings
- `prep_fye_mice()` Prepare FYE data for multiple imputation
- `select_required()` Select required midfieldr variables

Additional functions for processing intermediate results:

- `order_multiway()` Order categorical variables of multiway data
- `same_content()` Test for equal content between two data tables

*Notes on syntax.*   Throughout this work, we use the data.table package
for data manipulation ([Dowle and Srinivasan
2022](#ref-Dowle+Srinivasan:2022:data.table)) and the ggplot2 package
for charts ([Wickham 2016](#ref-Wickham:2016:ggplot2)). Some users may
prefer base R or dplyr for data ([Wickham et al.
2022](#ref-Wickham:2022:dplyr)), or lattice for charts ([Sarkar
2008](#ref-Sarkar:2008)). Each system has its strengths—users are
welcome to translate our examples to their preferred syntax.

## Usage

In this example, we gather all students ever enrolled in Engineering and
summarize their graduation status (in any major), grouping by
race/ethnicity and sex. If you are writing your own script to follow
along, we use these packages in this example:

``` r
library(midfieldr)
library(midfielddata)
library(data.table)
```

Load the practice data. Reduce initial dimensions of data tables.

``` r
# Load the practice data
data(student, term, degree)

# Reduce dimensions of source data tables
student <- select_required(student)
term <- select_required(term)
degree <- select_required(degree)

# View example result
term
#>                   mcid   institution  term   cip6         level
#>      1: MCID3111142225 Institution B 19881 140901 01 First-year
#>      2: MCID3111142283 Institution J 19881 240102 01 First-year
#>      3: MCID3111142283 Institution J 19883 240102 01 First-year
#>     ---                                                        
#> 639913: MCID3112898894 Institution B 20181 451001 01 First-year
#> 639914: MCID3112898895 Institution B 20181 302001 01 First-year
#> 639915: MCID3112898940 Institution B 20181 050103 01 First-year
```

Filter for data sufficiency.

``` r
# Initialize the working data frame
DT <- term[, .(mcid, cip6)]

# Filter observations for data sufficiency
DT <- add_timely_term(DT, term)
DT <- add_data_sufficiency(DT, term)
DT <- DT[data_sufficiency == "include"]
DT
#>                   mcid   cip6       level_i adj_span timely_term term_i
#>      1: MCID3111142689 090401 01 First-year        6       19941  19883
#>      2: MCID3111142782 260101 01 First-year        6       19941  19883
#>      3: MCID3111142782 260101 01 First-year        6       19941  19883
#>     ---                                                                
#> 531417: MCID3112870009 240102 01 First-year        6       20003  19951
#> 531418: MCID3112870009 240102 01 First-year        6       20003  19951
#> 531419: MCID3112870009 240102 01 First-year        6       20003  19951
#>         lower_limit upper_limit data_sufficiency
#>      1:       19881       20181          include
#>      2:       19881       20096          include
#>      3:       19881       20096          include
#>     ---                                         
#> 531417:       19881       20181          include
#> 531418:       19881       20181          include
#> 531419:       19881       20181          include
```

Filter for degree-seeking students ever enrolled in Engineering.

``` r
# Inner join to filter observations for degree-seeking
cols_we_want <- student[, .(mcid)]
DT <- cols_we_want[DT, on = c("mcid"), nomatch = NULL]

# Filter observations for engineering programs
DT <- DT[cip6 %like% "^14"]

# Filter observations for unique students (first instance)
DT <- DT[, .SD[1], by = c("mcid")]
DT
#>                  mcid   cip6        level_i adj_span timely_term term_i
#>     1: MCID3111142965 140102  01 First-year        6       19941  19883
#>     2: MCID3111145102 140102  01 First-year        6       19941  19883
#>     3: MCID3111146537 141001 02 Second-year        5       19931  19883
#>    ---                                                                 
#> 10399: MCID3112641399 141901  01 First-year        6       20181  20123
#> 10400: MCID3112641535 141901  01 First-year        6       20173  20121
#> 10401: MCID3112698681 141901  01 First-year        6       20171  20113
#>        lower_limit upper_limit data_sufficiency
#>     1:       19881       20096          include
#>     2:       19881       20096          include
#>     3:       19881       20096          include
#>    ---                                         
#> 10399:       19881       20181          include
#> 10400:       19881       20181          include
#> 10401:       19881       20181          include
```

Determine completion status.

``` r
# Add completion status variable
DT <- add_completion_status(DT, degree)
DT
#>                  mcid   cip6        level_i adj_span timely_term term_i
#>     1: MCID3111142965 140102  01 First-year        6       19941  19883
#>     2: MCID3111145102 140102  01 First-year        6       19941  19883
#>     3: MCID3111146537 141001 02 Second-year        5       19931  19883
#>    ---                                                                 
#> 10399: MCID3112641399 141901  01 First-year        6       20181  20123
#> 10400: MCID3112641535 141901  01 First-year        6       20173  20121
#> 10401: MCID3112698681 141901  01 First-year        6       20171  20113
#>        lower_limit upper_limit data_sufficiency term_degree completion_status
#>     1:       19881       20096          include       19901            timely
#>     2:       19881       20096          include       19893            timely
#>     3:       19881       20096          include       19913            timely
#>    ---                                                                       
#> 10399:       19881       20181          include       20163            timely
#> 10400:       19881       20181          include       20143            timely
#> 10401:       19881       20181          include       20181              late
```

Aggregate observations by groupings.

``` r
# Left join to add race/ethnicity and sex variables (omit unknowns)
cols_we_want <- student[, .(mcid, race, sex)]
DT <- student[DT, on = c("mcid")]
DT <- DT[!(race %ilike% "unknown" | sex %ilike% "unknown")]

# Create a variable combining race/ethnicity and sex
DT[, people := paste(race, sex)]

# Aggregate observations by groupings
DT_display <- DT[, .N, by = c("completion_status", "people")]
setorderv(DT_display, c("completion_status", "people"))
DT_display
#>     completion_status               people    N
#>  1:              <NA>         Asian Female   43
#>  2:              <NA>           Asian Male  163
#>  3:              <NA>         Black Female   39
#> ---                                            
#> 33:            timely Native American Male   13
#> 34:            timely         White Female  985
#> 35:            timely           White Male 4100
```

Reshape and display results.

``` r
# Transform to row-record form
DT_display <- dcast(DT_display, people ~ completion_status, value.var = "N", fill = 0)

# Prepare the table for display
setcolorder(DT_display, c("people", "timely", "late"))
setkeyv(DT_display, c("people"))
setnames(DT_display,
  old = c("people", "timely", "late", "NA"),
  new = c("People", "Timely completion", "Late completion", "Did not complete")
)
```

<table class=" lightable-paper" style="font-family: &quot;Arial Narrow&quot;, arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;">
<caption>
Table 1: Completion status of engineering undergraduates in the practice
data
</caption>
<thead>
<tr>
<th style="text-align:left;background-color: #c7eae5 !important;">
People
</th>
<th style="text-align:right;background-color: #c7eae5 !important;">
Timely completion
</th>
<th style="text-align:right;background-color: #c7eae5 !important;">
Late completion
</th>
<th style="text-align:right;background-color: #c7eae5 !important;">
Did not complete
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Asian Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
87
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
4
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
43
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Asian Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
315
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
19
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
163
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Black Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
26
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
3
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
39
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Black Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
80
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
5
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
84
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
International Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
110
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
9
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
51
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
International Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
501
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
41
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
280
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Latine Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
36
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
3
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
31
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Latine Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
181
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
19
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
102
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Native American Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
2
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
0
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
2
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
Native American Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
13
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
3
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
6
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
White Female
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
985
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
51
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
386
</td>
</tr>
<tr>
<td style="text-align:left;color: black !important;background-color: white !important;">
White Male
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
4100
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
269
</td>
<td style="text-align:right;color: black !important;background-color: white !important;">
2034
</td>
</tr>
</tbody>
</table>

“Timely completion” is the count of graduates completing their programs
in no more than 6 years; “Late completion” is the count of those
graduating in more than 6 years; “Did not complete” is the count of
non-graduates.

*Reminder.*   midfielddata is suitable for learning to work with
student-level data but not for drawing inferences about program
attributes or student experiences. midfielddata supplies practice data,
not research data.

## Installation

Install from CRAN with:

``` r
install.packages("midfieldr")
```

Install latest development version from GitHub with:

``` r
install.packages("pak")
pak::pkg_install("MIDFIELDR/midfieldr")
```

midfieldr interacts with practice data provided in the midfielddata data
package. Install midfielddata from its repository with:

``` r
install.packages("midfielddata",
  repos = "https://MIDFIELDR.github.io/drat/",
  type = "source"
)
```

The installed size of midfielddata is about 24 Mb, so the installation
takes some time.

## More information

[MIDFIELD](https://midfield.online/).   A database of anonymized
student-level records for approximately 2.4M undergraduates at 21 US
institutions from 1987-2022. Access to this database requires a
confidentiality agreement and Institutional Review Board (IRB) approval
for human subjects research.

[midfielddata](https://midfieldr.github.io/midfielddata/).   An R data
package that supplies anonymized student-level records for 98,000
undergraduates at three US institutions from 1988-2018. A sample of the
MIDFIELD database, midfielddata provides practice data for the tools and
methods in the midfieldr package.

## Acknowledgments

This work was supported by the US National Science Foundation through
grant numbers 1545667 and 2142087.

## References

<div id="refs">
&#10;
&#10;
&#10;

<style type="text/css">
blockquote {
    padding:     10px 20px;
    margin:      0 0 20px;
    border-left: 0px
}
caption {
    color:       #525252;
    text-align:  left;
    font-weight: normal;
    font-size:   medium;
    line-height: 1.5;
}
</style>

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-Dowle+Srinivasan:2022:data.table" class="csl-entry">

Dowle, Matt, and Arun Srinivasan. 2022.
*<span class="nocase">d</span>ata.table: Extension of ‘Data.frame‘*.
R package version 1.14.6.
<https://CRAN.R-project.org/package=data.table>.

</div>

<div id="ref-Sarkar:2008" class="csl-entry">

Sarkar, Deepayan. 2008. *<span class="nocase">lattice: Multivariate Data
Visualization with R</span>*. New York: Springer.
<http://lmdvr.r-forge.r-project.org>.

</div>

<div id="ref-Wickham:2016:ggplot2" class="csl-entry">

Wickham, Hadley. 2016. *<span class="nocase">ggplot2: Elegant Graphics
for Data Analysis</span>*. ISBN 978-3-319-24277-4; Springer-Verlag New
York. <https://ggplot2.tidyverse.org>.

</div>

<div id="ref-Wickham:2022:dplyr" class="csl-entry">

Wickham, Hadley, Romain François, Lionel Henry, and Kirill Müller. 2022.
*<span class="nocase">dplyr: A Grammar of Data Manipulation</span>*.
R package version 1.0.10. <https://CRAN.R-project.org/package=dplyr>.

</div>

</div>
