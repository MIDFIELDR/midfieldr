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

- New columns are added unless they duplicate existing
  variables—redundant columns, whether new or existing, are dropped (see
  Details). The new variables are:

  - `bacc_term`   Character. Term of a student's first baccalaureate,
    encoded `YYYYT` or, if no degree recorded, `NA`. Joined from the
    `term_degree` variable in `midf_table.`

  - `term_focus`   Character. Indicating a term contributes to study
    before or after a student's first baccalaureate. Possible values are
    "undergrad" and "post-bacc."

## Details

*Redundant columns.* To prevent overwriting, the name of an added
variable such as `bacc_term` that matches that of an existing variable
is made unique by adding a suffix, e.g., `bacc_term.1.` An added
variable that otherwise duplicates the existing variable is redundant
and dropped. If not, the presence of the suffixed variable indicates a
potential error. The variables added by midfieldr functions depend on
fixed quantities, e.g., a student's admission term or an institution's
data range, and do not change during an analysis.

## Examples

``` r
# Select min required columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# Example of starting data frame
term
#>                 mcid   term
#>               <char> <char>
#>    1: MCID3111142897  19881
#>    2: MCID3111157634  19881
#>    3: MCID3111157634  19883
#>    4: MCID3111157634  19891
#>    5: MCID3111157634  19893
#>   ---                      
#> 1817: MCID3112868072  20171
#> 1818: MCID3112868072  20173
#> 1819: MCID3112869843  20173
#> 1820: MCID3112869843  20181
#> 1821: MCID3112885339  20181

# Labeling terms by group: undergrad & grad
term <- is_undergrad(term, midf_table = degree)
course <- is_undergrad(course, midf_table = degree)
degree <- is_undergrad(degree, midf_table = degree)

# Example result
term[order(-term_focus)]
#>                 mcid   term bacc_term term_focus
#>               <char> <char>    <char>     <char>
#>    1: MCID3111142897  19881      <NA>  undergrad
#>    2: MCID3111157634  19881      <NA>  undergrad
#>    3: MCID3111157634  19883      <NA>  undergrad
#>    4: MCID3111157634  19891      <NA>  undergrad
#>    5: MCID3111157634  19893      <NA>  undergrad
#>   ---                                           
#> 1817: MCID3112212659  20085     20083  post-bacc
#> 1818: MCID3112217217  20091     20083  post-bacc
#> 1819: MCID3112219157  20111     20091  post-bacc
#> 1820: MCID3112291627  20101     20093  post-bacc
#> 1821: MCID3112352960  20121     20114  post-bacc

# No change if added columns duplicate existing
x <- copy(term)
y <- is_undergrad(x, midf_table = degree)
check_equiv_frames(x, y)
#> [1] TRUE

# Filter to retain "undergraduate" rows only
term <- term[term_focus == "undergrad"]
course <- course[term_focus == "undergrad"]
degree <- degree[term_focus == "undergrad"]

# Example result
term
#>                 mcid   term bacc_term term_focus
#>               <char> <char>    <char>     <char>
#>    1: MCID3111142897  19881      <NA>  undergrad
#>    2: MCID3111157634  19881      <NA>  undergrad
#>    3: MCID3111157634  19883      <NA>  undergrad
#>    4: MCID3111157634  19891      <NA>  undergrad
#>    5: MCID3111157634  19893      <NA>  undergrad
#>   ---                                           
#> 1798: MCID3112868072  20171      <NA>  undergrad
#> 1799: MCID3112868072  20173      <NA>  undergrad
#> 1800: MCID3112869843  20173      <NA>  undergrad
#> 1801: MCID3112869843  20181      <NA>  undergrad
#> 1802: MCID3112885339  20181      <NA>  undergrad
```
