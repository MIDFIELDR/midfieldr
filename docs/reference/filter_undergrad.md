# Choose rows of undergraduate terms only

Distinguish post-baccalaureate terms from undergraduate terms for each
student in a data frame and retain the undergraduate terms. Applied to a
data table having an academic term variable, e.g., the `term, course,`
and `degree` tables.

## Usage

``` r
filter_undergrad(dframe, midf_table = degree, ..., add_bacc_term = NULL)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble) with
  required variables `{mcid}` and one of the following:
  `{term, term_course, term_degree}.`

- midf_table:

  `degree` data frame with required variables `{mcid, term_degree}.`

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- add_bacc_term:

  Logical, default false. If true, a column for the first degree term is
  added and post-baccalaureate rows are not removed.

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Post-baccalaureate rows are removed (default) unless `add_bacc_term`
  is true. In all cases, duplicated rows are removed.

- Columns are not modified (default). When `add_bacc_term` true, one new
  column is added unless it is redundant (see Details). The new variable
  is:

  - `bacc_term`   Character. Term of a student's first baccalaureate,
    encoded `YYYYT` or, if no degree recorded, `NA.` Joined from the
    `term_degree` variable in `midf_table.`

## Details

*Redundant columns.* To prevent overwriting, a variable such as
`bacc_term` is not added to the data frame if it duplicates an existing
variable. The test for redundancy is managed internally by calling
[`rm_redundant_cols()`](https://midfieldr.github.io/midfieldr/reference/rm_redundant_cols.md)
before the final data frame is returned. For documentation, see
[`?rm_redundant_cols`](https://midfieldr.github.io/midfieldr/reference/rm_redundant_cols.md).

## Examples

``` r
# For illustration only, choose a minimum set of columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# Example result
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

# Filter to retain undergrad terms only
x <- filter_undergrad(term, midf_table = degree)
x
#>                 mcid   term
#>               <char> <char>
#>    1: MCID3111142897  19881
#>    2: MCID3111157634  19881
#>    3: MCID3111157634  19883
#>    4: MCID3111157634  19891
#>    5: MCID3111157634  19893
#>   ---                      
#> 1798: MCID3112868072  20171
#> 1799: MCID3112868072  20173
#> 1800: MCID3112869843  20173
#> 1801: MCID3112869843  20181
#> 1802: MCID3112885339  20181

# `add_bacc_term` argument adds the first degree term and rows are not removed
y <- filter_undergrad(term, midf_table = degree, add_bacc_term = TRUE)
y[order(bacc_term)]
#>                 mcid   term bacc_term
#>               <char> <char>    <char>
#>    1: MCID3111169729  19881     19901
#>    2: MCID3111169729  19891     19901
#>    3: MCID3111169729  19893     19901
#>    4: MCID3111169729  19901     19901
#>    5: MCID3111169601  19881     19903
#>   ---                                
#> 1817: MCID3112868072  20171      <NA>
#> 1818: MCID3112868072  20173      <NA>
#> 1819: MCID3112869843  20173      <NA>
#> 1820: MCID3112869843  20181      <NA>
#> 1821: MCID3112885339  20181      <NA>

# Filtering for undergraduate terms can be done manually
y <- y[bacc_term >= term | is.na(bacc_term)]
y[, bacc_term := NULL]
#>                 mcid   term
#>               <char> <char>
#>    1: MCID3111142897  19881
#>    2: MCID3111157634  19881
#>    3: MCID3111157634  19883
#>    4: MCID3111157634  19891
#>    5: MCID3111157634  19893
#>   ---                      
#> 1798: MCID3112868072  20171
#> 1799: MCID3112868072  20173
#> 1800: MCID3112869843  20173
#> 1801: MCID3112869843  20181
#> 1802: MCID3112885339  20181
y
#>                 mcid   term
#>               <char> <char>
#>    1: MCID3111142897  19881
#>    2: MCID3111157634  19881
#>    3: MCID3111157634  19883
#>    4: MCID3111157634  19891
#>    5: MCID3111157634  19893
#>   ---                      
#> 1798: MCID3112868072  20171
#> 1799: MCID3112868072  20173
#> 1800: MCID3112869843  20173
#> 1801: MCID3112869843  20181
#> 1802: MCID3112885339  20181

# Verify result
check_equiv_frames(x, y)
#> [1] TRUE


# Function is applied to all tables containing a term-value
term <- filter_undergrad(term, midf_table = degree)
course <- filter_undergrad(course, midf_table = degree)
degree <- filter_undergrad(degree, midf_table = degree)
```
