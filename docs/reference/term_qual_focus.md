# Categorize the qualification focus of a term

Determine the qualification focus (undergraduate or post-baccalaureate)
of every term for each student in a data frame and add columns to the
data frame to support the finding.

## Usage

``` r
term_qual_focus(dframe, midf_table = degree)
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

- New columns are added unless they are redundant (see Details). The new
  variables are:

  - `bacc_term`   Character. Term of a student's first baccalaureate,
    encoded `YYYYT` or, if no degree recorded, `NA`. Joined from the
    `term_degree` variable in `midf_table.`

  - `term_focus`   Character. Indicating a term contributes to study
    before or after a student's first baccalaureate. Possible values are
    "undergrad" and "post-bacc."

## Details

Every term in a student's record can be categorized as "undergraduate"
if the term predates their first degree and "post-baccalaureate" if it
postdates the degree. Post-baccalaureate terms are typically excluded
from the `term, course,` and `degree` data tables.

*Redundant columns.* To prevent overwriting, a variable such as
`bacc_term` is not added to the data frame if it duplicates an existing
variable. The test for redundancy is managed internally by calling
[`rm_redundant_cols()`](https://midfieldr.github.io/midfieldr/reference/rm_redundant_cols.md)
before the final data frame is returned. For documentation, see
[`?rm_redundant_cols`](https://midfieldr.github.io/midfieldr/reference/rm_redundant_cols.md).

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
#>   ---                      
#> 1819: MCID3112869843  20173
#> 1820: MCID3112869843  20181
#> 1821: MCID3112885339  20181

# Labeling terms by group: undergrad & grad
term <- term_qual_focus(term, midf_table = degree)
course <- term_qual_focus(course, midf_table = degree)
degree <- term_qual_focus(degree, midf_table = degree)

# Example result
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

# No change if added columns duplicate existing
x <- term_qual_focus(term, midf_table = degree)
check_equiv_frames(term, x)
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
#>   ---                                           
#> 1800: MCID3112869843  20173      <NA>  undergrad
#> 1801: MCID3112869843  20181      <NA>  undergrad
#> 1802: MCID3112885339  20181      <NA>  undergrad
```
