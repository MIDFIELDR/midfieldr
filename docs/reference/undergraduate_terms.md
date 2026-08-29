# Identify terms after the first completion term

For each student's term in a data frame, determine its relationship to
the student's first degree term (pre-degree, first-degree, or
post-first-degree) and add columns that support the findings.
Post-first-baccalaureate terms are typically excluded from the
`term, course,` and `degree` data tables.

## Usage

``` r
undergraduate_terms(dframe, midf_table = degree)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble) with
  required variables `{mcid}` and one of
  `{term, term_course, term_degree}.`

- midf_table:

  `degree` data frame with required variables `{mcid, term_degree}.`

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Row order is preserved. Rows with `NA` values in any of the required
  variables are removed. Duplicated rows are removed.

- New columns are added or replace existing columns of the same name (if
  any). Other columns are not modified. The following variables are
  added:

  - `first_degree`   Character. Term of a student's first baccalaureate,
    encoded `YYYYT` or, if no degree recorded, `NA`. Joined from the
    `term_degree` variable in `midf_table.`

  - `term_group`   Character, indicating that a term belongs to one of
    two categories: "undergrad" terms are those leading up to and
    including the term in which s a student completes their first
    degree; and "grad" for all terms after the first degree.

- Groups and keys are not preserved.

## Details

In a typical analysis, one is interested in a student's progress up to
and including the term in which they earn their first degree or degrees.
Any terms later than the first baccalaureate can usually be excluded
from study.

## Examples

``` r
# select min required columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# labeling terms by group: undergrad & grad
term <- undergraduate_terms(term, midf_table = degree)
course <- undergraduate_terms(course, midf_table = degree)
degree <- undergraduate_terms(degree, midf_table = degree)

# results
term[order(-term_group)]
#>                 mcid   term first_degree term_group
#>               <char> <char>       <char>     <char>
#>    1: MCID3111142897  19881         <NA>  undergrad
#>    2: MCID3111157634  19881         <NA>  undergrad
#>    3: MCID3111157634  19883         <NA>  undergrad
#>    4: MCID3111157634  19891         <NA>  undergrad
#>    5: MCID3111157634  19893         <NA>  undergrad
#>   ---                                              
#> 1817: MCID3112212659  20085        20083   graduate
#> 1818: MCID3112217217  20091        20083   graduate
#> 1819: MCID3112219157  20111        20091   graduate
#> 1820: MCID3112291627  20101        20093   graduate
#> 1821: MCID3112352960  20121        20114   graduate
term[, .N, by = "term_group"][order(-N)]
#>    term_group     N
#>        <char> <int>
#> 1:  undergrad  1802
#> 2:   graduate    19

course[order(-term_group)]
#>                 mcid term_course first_degree term_group
#>               <char>      <char>       <char>     <char>
#>    1: MCID3111142897       19881         <NA>  undergrad
#>    2: MCID3111142897       19883         <NA>  undergrad
#>    3: MCID3111157634       19881         <NA>  undergrad
#>    4: MCID3111157634       19883         <NA>  undergrad
#>    5: MCID3111157634       19891         <NA>  undergrad
#>   ---                                                   
#> 2023: MCID3112217217       20085        20083   graduate
#> 2024: MCID3112217217       20091        20083   graduate
#> 2025: MCID3112219157       20111        20091   graduate
#> 2026: MCID3112291627       20101        20093   graduate
#> 2027: MCID3112352960       20121        20114   graduate
course[, .N, by = "term_group"][order(-N)]
#>    term_group     N
#>        <char> <int>
#> 1:  undergrad  2004
#> 2:   graduate    23

degree[order(-term_group)]
#>                mcid term_degree first_degree term_group
#>              <char>      <char>       <char>     <char>
#>   1: MCID3111169601       19903        19903  undergrad
#>   2: MCID3111169729       19901        19901  undergrad
#>   3: MCID3111213539       19923        19923  undergrad
#>   4: MCID3111213856       19911        19911  undergrad
#>   5: MCID3111254225       19923        19923  undergrad
#>  ---                                                   
#> 189: MCID3112727716       20171        20171  undergrad
#> 190: MCID3112749981       20173        20173  undergrad
#> 191: MCID3112751130       20171        20171  undergrad
#> 192: MCID3112839623       20181        20181  undergrad
#> 193: MCID3112012180       20151        20043   graduate
degree[, .N, by = "term_group"][order(-N)]
#>    term_group     N
#>        <char> <int>
#> 1:  undergrad   192
#> 2:   graduate     1
```
