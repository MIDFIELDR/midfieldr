# Label terms as pre- or post-baccalaureate

Distinguishes between pre- and post-baccalaureate terms. Adds columns to
the data frame that support the finding.

## Usage

``` r
pre_or_post_bacc(dframe, midf_table = degree)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble) with
  required variables `{mcid}` and one of the following:
  `{term, term_course, term_degree}.`

- midf_table:

  `degree` data frame with required variables `{mcid, term_degree}.`

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Row order is preserved. Rows with `NA` values in any of the required
  variables are removed. Duplicated rows are removed.

- New columns are added unless they are redundant (see Details). The new
  variables are:

  - `bacc_term` Character. Term of a student's first baccalaureate,
    encoded `YYYYT` or, if no degree recorded, `NA.` Joined from the
    `term_degree` variable in `midf_table.`

  - `pre_or_post` Character. Term label. Possible values are "pre-bacc"
    (pre-baccalaureate/undergraduate) and "post-bacc."

## Details

The dividing event between pre- and post-baccalaureate terms is the
student's first bachelor's degree. Post-baccalaureate records are
usually dropped as a step in constructing baseline records for further
analysis. The data frame for the principal argument is the
`term, course,` or `degree` data table with all columns. Can be applied
however to any data frame containing the required variables.

*Redundant columns.* To prevent overwriting, a variable such as
`bacc_term` is not added to the data frame if it duplicates an existing
variable. The test for redundancy is managed internally by calling
[`rm_redundant_cols()`](https://midfieldr.github.io/midfieldr/reference/rm_redundant_cols.md)
before the final data frame is returned.

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

# Add term ID columns
x <- pre_or_post_bacc(term, midf_table = degree)
x[order(-pre_or_post)]
#>                 mcid   term bacc_term pre_or_post
#>               <char> <char>    <char>      <char>
#>    1: MCID3111142897  19881      <NA>    pre-bacc
#>    2: MCID3111157634  19881      <NA>    pre-bacc
#>    3: MCID3111157634  19883      <NA>    pre-bacc
#>    4: MCID3111157634  19891      <NA>    pre-bacc
#>    5: MCID3111157634  19893      <NA>    pre-bacc
#>   ---                                            
#> 1817: MCID3112212659  20085     20083   post-bacc
#> 1818: MCID3112217217  20091     20083   post-bacc
#> 1819: MCID3112219157  20111     20091   post-bacc
#> 1820: MCID3112291627  20101     20093   post-bacc
#> 1821: MCID3112352960  20121     20114   post-bacc

# No change if added columns duplicate existing
y <- pre_or_post_bacc(x, midf_table = degree)
check_equiv_frames(x, y)
#> [1] TRUE

# Filter to retain "undergrad" rows only
x[pre_or_post == "pre-bacc"]
#>                 mcid   term bacc_term pre_or_post
#>               <char> <char>    <char>      <char>
#>    1: MCID3111142897  19881      <NA>    pre-bacc
#>    2: MCID3111157634  19881      <NA>    pre-bacc
#>    3: MCID3111157634  19883      <NA>    pre-bacc
#>    4: MCID3111157634  19891      <NA>    pre-bacc
#>    5: MCID3111157634  19893      <NA>    pre-bacc
#>   ---                                            
#> 1798: MCID3112868072  20171      <NA>    pre-bacc
#> 1799: MCID3112868072  20173      <NA>    pre-bacc
#> 1800: MCID3112869843  20173      <NA>    pre-bacc
#> 1801: MCID3112869843  20181      <NA>    pre-bacc
#> 1802: MCID3112885339  20181      <NA>    pre-bacc

# Function is applied to all tables containing a term-value
term <- pre_or_post_bacc(term, midf_table = degree)
course <- pre_or_post_bacc(course, midf_table = degree)
degree <- pre_or_post_bacc(degree, midf_table = degree)
```
