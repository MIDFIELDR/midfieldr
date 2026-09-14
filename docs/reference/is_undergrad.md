# Categorize qualification level by term

Categorize the qualification level towards which a student is working in
each term. Two levels are used: “undergrad” for terms before a student's
first degree and “post-bacc” (post-baccalaureate) for terms after the
first degree. Added columns support the findings. Post-baccalaureate
terms are typically excluded from the `term, course,` and `degree` data
tables.

## Usage

``` r
is_undergrad(dframe, midf_table = degree)
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

- New columns are added and all unique columns are preserved. If
  required to prevent overwriting, new column names are suffixed
  (`.1, .2,` etc.). Duplicate columns, differing by suffix only, are
  dropped. The new variables are:

  - `bacc_term`   Character. Term of a student's first baccalaureate,
    encoded `YYYYT` or, if no degree recorded, `NA`. Joined from the
    `term_degree` variable in `midf_table.`

  - `term_focus`   Character. Indicating a term contributes to study
    before or after a student's first baccalaureate. Possible values are
    "undergrad" and "post-bacc."

## Examples

``` r
# select min required columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# labeling terms by group: undergrad & grad
term <- is_undergrad(term, midf_table = degree)
course <- is_undergrad(course, midf_table = degree)
degree <- is_undergrad(degree, midf_table = degree)

# results
term[order(-term_focus)]
#>                 mcid   term bacc_term term_focus
#>               <char> <char>    <char>     <char>
#>    1: MCID3111142897  19881      <NA>  undergrad
#>    2: MCID3111157634  19881      <NA>  undergrad
#>    3: MCID3111157634  19883      <NA>  undergrad
#>   ---                                           
#> 1819: MCID3112219157  20111     20091  post-bacc
#> 1820: MCID3112291627  20101     20093  post-bacc
#> 1821: MCID3112352960  20121     20114  post-bacc
term[, .N, by = "term_focus"][order(-N)]
#>    term_focus     N
#>        <char> <int>
#> 1:  undergrad  1802
#> 2:  post-bacc    19

course[order(-term_focus)]
#>                 mcid term_course bacc_term term_focus
#>               <char>      <char>    <char>     <char>
#>    1: MCID3111142897       19881      <NA>  undergrad
#>    2: MCID3111142897       19883      <NA>  undergrad
#>    3: MCID3111157634       19881      <NA>  undergrad
#>   ---                                                
#> 2025: MCID3112219157       20111     20091  post-bacc
#> 2026: MCID3112291627       20101     20093  post-bacc
#> 2027: MCID3112352960       20121     20114  post-bacc
course[, .N, by = "term_focus"][order(-N)]
#>    term_focus     N
#>        <char> <int>
#> 1:  undergrad  2004
#> 2:  post-bacc    23

degree[order(-term_focus)]
#>                mcid term_degree bacc_term term_focus
#>              <char>      <char>    <char>     <char>
#>   1: MCID3111169601       19903     19903  undergrad
#>   2: MCID3111169729       19901     19901  undergrad
#>   3: MCID3111213539       19923     19923  undergrad
#>  ---                                                
#> 191: MCID3112751130       20171     20171  undergrad
#> 192: MCID3112839623       20181     20181  undergrad
#> 193: MCID3112012180       20151     20043  post-bacc
degree[, .N, by = "term_focus"][order(-N)]
#>    term_focus     N
#>        <char> <int>
#> 1:  undergrad   192
#> 2:  post-bacc     1
```
