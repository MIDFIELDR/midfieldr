# Identify terms after the first completion term

For each student's term in a data frame, determine its relationship to
the student's first degree term (pre-degree, first-degree, or
post-first-degree) and add columns that support the findings.
Post-first-baccalaureate terms are typically excluded from the
`term, course,` and `degree` data tables.

## Usage

``` r
post_completion_terms(dframe, midf_table = degree)
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

  - `first_degree_term.`   Character. Term of a student's first
    baccalaureate, encoded `YYYYT` or, if no degree recorded, `NA`.
    Joined from the `term_degree` variable in `midf_table.`

  - `term_cluster.`   Character, indicating that a term belongs to one
    of three clusters: terms that are prior to ("pre-degree"), equal to
    ("first-degree"), or subsequent to ("post-first-degree") the
    student’s first degree term.

- Groups and keys are not preserved.

## Details

In a typical analysis, one is interested in a student's progress up to
and including the term in which they earn their first degree or degrees.
Any terms later than the first baccalaureate can usually be excluded
from study.

## Examples

``` r
# reduce number of columns
term <- select_basic_cols(toy_term)
degree <- select_basic_cols(toy_degree)

# identify term-clusters in a 'term' table
x <- post_completion_terms(term, degree)
x[, .N, by = "term_cluster"][order(-N)]
#>         term_cluster     N
#>               <char> <int>
#> 1:        pre-degree  1675
#> 2:      first-degree   127
#> 3: post-first-degree    19
x
#>                 mcid   term   cip6   institution          level
#>               <char> <char> <char>        <char>         <char>
#>    1: MCID3111142897  19881 400801 Institution B  01 First-year
#>    2: MCID3111157634  19881 240102 Institution J  01 First-year
#>    3: MCID3111157634  19883 040201 Institution J  01 First-year
#>    4: MCID3111157634  19891 040201 Institution J 02 Second-year
#>    5: MCID3111157634  19893 040201 Institution J 02 Second-year
#>   ---                                                          
#> 1817: MCID3112868072  20171 240199 Institution B  01 First-year
#> 1818: MCID3112868072  20173 380101 Institution B 02 Second-year
#> 1819: MCID3112869843  20173 240199 Institution B  01 First-year
#> 1820: MCID3112869843  20181 240199 Institution B  01 First-year
#> 1821: MCID3112885339  20181 520201 Institution B  01 First-year
#>       first_degree_term term_cluster
#>                  <char>       <char>
#>    1:              <NA>   pre-degree
#>    2:              <NA>   pre-degree
#>    3:              <NA>   pre-degree
#>    4:              <NA>   pre-degree
#>    5:              <NA>   pre-degree
#>   ---                               
#> 1817:              <NA>   pre-degree
#> 1818:              <NA>   pre-degree
#> 1819:              <NA>   pre-degree
#> 1820:              <NA>   pre-degree
#> 1821:              <NA>   pre-degree

# identify term-clusters in a 'degree' table
x <- post_completion_terms(degree, degree)
x[, .N, by = "term_cluster"][order(-N)]
#>         term_cluster     N
#>               <char> <int>
#> 1:      first-degree   192
#> 2: post-first-degree     1
x
#>                mcid term_degree   cip6 first_degree_term term_cluster
#>              <char>      <char> <char>            <char>       <char>
#>   1: MCID3111169601       19903 520201             19903 first-degree
#>   2: MCID3111169729       19901 520201             19901 first-degree
#>   3: MCID3111213539       19923 030103             19923 first-degree
#>   4: MCID3111213856       19911 261399             19911 first-degree
#>   5: MCID3111254225       19923 270101             19923 first-degree
#>  ---                                                                 
#> 189: MCID3112701643       20173 090900             20173 first-degree
#> 190: MCID3112727716       20171 090101             20171 first-degree
#> 191: MCID3112749981       20173 110701             20173 first-degree
#> 192: MCID3112751130       20171 110701             20171 first-degree
#> 193: MCID3112839623       20181 160102             20181 first-degree

# post-first-degree terms are usually dropped
x[term_cluster != "post-first-degree"]
#>                mcid term_degree   cip6 first_degree_term term_cluster
#>              <char>      <char> <char>            <char>       <char>
#>   1: MCID3111169601       19903 520201             19903 first-degree
#>   2: MCID3111169729       19901 520201             19901 first-degree
#>   3: MCID3111213539       19923 030103             19923 first-degree
#>   4: MCID3111213856       19911 261399             19911 first-degree
#>   5: MCID3111254225       19923 270101             19923 first-degree
#>  ---                                                                 
#> 188: MCID3112701643       20173 090900             20173 first-degree
#> 189: MCID3112727716       20171 090101             20171 first-degree
#> 190: MCID3112749981       20173 110701             20173 first-degree
#> 191: MCID3112751130       20171 110701             20171 first-degree
#> 192: MCID3112839623       20181 160102             20181 first-degree
```
