# Determine completion status

Determine the *completion status* for each student in a data frame and
add columns that support the findings.

## Usage

``` r
completion_status(dframe, midf_table = degree)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble) with
  required variables `{mcid, timely_term}.`

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
    encoded `YYYYT` or, if no degree recorded, `NA.` Joined from the
    `term_degree` variable in `midf_table.`

  - `completion`   Character. Completion status, possible values of
    "timely", "late", and "NA".

## Details

If a population has been filtered for data sufficiency, then determining
every student's *completion status* is feasible. Completing an academic
program in a timely manner means that a student completes the
requirements for a degree within a set time span, typically 4, 6, or 8
years after admission depending on the definition adopted in a
particular study. The term at the end of that span is the *timely
completion term.*

If the student's degree term is no later than their timely completion
term, then their completion status is "timely"; if later, their status
is "late". For students with no degree, completion status is NA.

## Examples

``` r
# Assign toy data sets
student <- toy_student
term <- toy_term
degree <- toy_degree

# Start with a selected population
x <- student[c(9:11, 21:30, 344:345), .(mcid)]
x
#>               mcid
#>             <char>
#>  1: MCID3111169729
#>  2: MCID3111170852
#>  3: MCID3111173999
#> ---               
#> 13: MCID3111277081
#> 14: MCID3112751130
#> 15: MCID3112754537

# Add the required columns from timely_term()
x <- timely_term(x, midf_table = term)
x <- x[, .(mcid, timely_term)]
x
#>               mcid timely_term
#>             <char>      <char>
#>  1: MCID3111169729       19933
#>  2: MCID3111170852       19933
#>  3: MCID3111173999       19933
#> ---                           
#> 13: MCID3111277081       19961
#> 14: MCID3112751130       20203
#> 15: MCID3112754537       20203

# Add completion status columns
x <- completion_status(x, midf_table = degree)
x
#>               mcid timely_term bacc_term completion
#>             <char>      <char>    <char>     <char>
#>  1: MCID3111169729       19933     19901     timely
#>  2: MCID3111170852       19933      <NA>       <NA>
#>  3: MCID3111173999       19933      <NA>       <NA>
#> ---                                                
#> 13: MCID3111277081       19961     19963       late
#> 14: MCID3112751130       20203     20171     timely
#> 15: MCID3112754537       20203      <NA>       <NA>

# No change if new columns match existing columns
y = completion_status(x, midf_table = degree)

# If new column should match existing but does not,
# new column with suffix .1, .2, etc., is added. 
# Indicates an error has occurred somewhere. 
y$bacc_term[1] <- "19893"
z = completion_status(y, midf_table = degree)
z
#>               mcid timely_term bacc_term completion bacc_term.1
#>             <char>      <char>    <char>     <char>      <char>
#>  1: MCID3111169729       19933     19893     timely       19901
#>  2: MCID3111170852       19933      <NA>       <NA>        <NA>
#>  3: MCID3111173999       19933      <NA>       <NA>        <NA>
#> ---                                                            
#> 13: MCID3111277081       19961     19963       late       19963
#> 14: MCID3112751130       20203     20171     timely       20171
#> 15: MCID3112754537       20203      <NA>       <NA>        <NA>

# Typical application retains "timely" rows only
x[completion == "timely"]
#>               mcid timely_term bacc_term completion
#>             <char>      <char>    <char>     <char>
#>  1: MCID3111169729       19933     19901     timely
#>  2: MCID3111258275       19953     19921     timely
#>  3: MCID3111258347       19953     19923     timely
#> ---                                                
#>  8: MCID3111272691       19953     19914     timely
#>  9: MCID3111272880       19953     19934     timely
#> 10: MCID3112751130       20203     20171     timely
```
