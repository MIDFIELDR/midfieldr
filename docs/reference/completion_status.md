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

- Columns with names different from the new columns (named below) are
  not modified; columns with matching names are replaced. The new
  columns added are:

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
#>  4: MCID3111257807
#>  5: MCID3111258275
#>  6: MCID3111258347
#>  7: MCID3111259642
#>  8: MCID3111262210
#>  9: MCID3111265287
#> 10: MCID3111269576
#> 11: MCID3111272691
#> 12: MCID3111272880
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
#>  4: MCID3111257807       19953
#>  5: MCID3111258275       19953
#>  6: MCID3111258347       19953
#>  7: MCID3111259642       19953
#>  8: MCID3111262210       19953
#>  9: MCID3111265287       19953
#> 10: MCID3111269576       19953
#> 11: MCID3111272691       19953
#> 12: MCID3111272880       19953
#> 13: MCID3111277081       19961
#> 14: MCID3112751130       20203
#> 15: MCID3112754537       20203

# Add completion status columns
x <- completion_status(x, midf_table = degree)
x
#>               mcid bacc_term timely_term completion
#>             <char>    <char>      <char>     <char>
#>  1: MCID3111169729     19901       19933     timely
#>  2: MCID3111170852      <NA>       19933       <NA>
#>  3: MCID3111173999      <NA>       19933       <NA>
#>  4: MCID3111257807     19964       19953       late
#>  5: MCID3111258275     19921       19953     timely
#>  6: MCID3111258347     19923       19953     timely
#>  7: MCID3111259642     19934       19953     timely
#>  8: MCID3111262210     19951       19953     timely
#>  9: MCID3111265287     19904       19953     timely
#> 10: MCID3111269576     19943       19953     timely
#> 11: MCID3111272691     19914       19953     timely
#> 12: MCID3111272880     19934       19953     timely
#> 13: MCID3111277081     19963       19961       late
#> 14: MCID3112751130     20171       20203     timely
#> 15: MCID3112754537      <NA>       20203       <NA>

# If you repeat, the new columns are overwritten
y = completion_status(x, midf_table = degree)

# Typical application retains "timely" rows only
x[completion == "timely"]
#>               mcid bacc_term timely_term completion
#>             <char>    <char>      <char>     <char>
#>  1: MCID3111169729     19901       19933     timely
#>  2: MCID3111258275     19921       19953     timely
#>  3: MCID3111258347     19923       19953     timely
#>  4: MCID3111259642     19934       19953     timely
#>  5: MCID3111262210     19951       19953     timely
#>  6: MCID3111265287     19904       19953     timely
#>  7: MCID3111269576     19943       19953     timely
#>  8: MCID3111272691     19914       19953     timely
#>  9: MCID3111272880     19934       19953     timely
#> 10: MCID3112751130     20171       20203     timely
```
