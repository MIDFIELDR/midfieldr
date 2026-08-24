# Determine timely completion terms

Determine the *timely completion term* for each student in a data frame
and add columns that support the findings.

## Usage

``` r
timely_term(dframe, midf_table = term, ..., sched_span = NULL, span = NULL)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble) with
  required variable `{mcid}.`

- midf_table:

  `term` data frame with required variables `{mcid, term, level}.`

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- sched_span:

  Integer scalar (default 4), the number of years an institution
  officially schedules for completing a program.

- span:

  Integer scalar (default 6), number of years to define timely
  completion, typically 4, 6, or 8 years (100%, 150%, 200% respectively
  of `sched_span`).

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Row order is preserved. Rows with `NA` values in any of the required
  variables are removed. Duplicated rows are removed.

- Columns with names different from the new columns (named below) are
  not modified; columns with matching names are replaced. The new
  columns added are:

  - `term_i`   Character. Initial term of a student's longitudinal
    record, encoded `YYYYT`. Extracted from `midf_table.`

  - `level_i`   Character. Student level (01 Freshman, 02 Sophomore,
    etc.) in their initial term. Extracted from `midf_table.`

  - `adj_span`   Numeric. Integer span of years for timely completion
    adjusted for a student's initial level.

  - `timely_term`   Character. Latest term by which program completion
    would be considered timely. Encoded `YYYYT.`

## Details

Completing an academic program in a timely manner means that a student
completes the requirements for a degree within a set time span,
typically 4, 6, or 8 years after admission depending on the definition
adopted in a particular study. The term at the end of that span is the
*timely completion term.*

Our heuristic assigns a time span for timely completion to every student
(default is 6 academic years). For students admitted at second-year
level or higher, the span is reduced by one academic year for each full
year the student is assumed to have completed. The adjusted span is
added to their initial term at an institution to create the
`timely_term` value for each observation.

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

# Add timely term columns
x <- timely_term(x, midf_table = term)
x
#>               mcid term_i       level_i adj_span timely_term
#>             <char> <char>        <char>    <num>      <char>
#>  1: MCID3111169729  19881 01 First-year        6       19933
#>  2: MCID3111170852  19881 01 First-year        6       19933
#>  3: MCID3111173999  19881 01 First-year        6       19933
#>  4: MCID3111257807  19901 01 First-year        6       19953
#>  5: MCID3111258275  19901 01 First-year        6       19953
#>  6: MCID3111258347  19901 01 First-year        6       19953
#>  7: MCID3111259642  19901 01 First-year        6       19953
#>  8: MCID3111262210  19901 01 First-year        6       19953
#>  9: MCID3111265287  19901 01 First-year        6       19953
#> 10: MCID3111269576  19901 01 First-year        6       19953
#> 11: MCID3111272691  19901 01 First-year        6       19953
#> 12: MCID3111272880  19901 01 First-year        6       19953
#> 13: MCID3111277081  19903 01 First-year        6       19961
#> 14: MCID3112751130  20151 01 First-year        6       20203
#> 15: MCID3112754537  20151 01 First-year        6       20203

# If you repeat, the new columns are overwritten
timely_term(x, midf_table = term)
#>               mcid term_i       level_i adj_span timely_term
#>             <char> <char>        <char>    <num>      <char>
#>  1: MCID3111169729  19881 01 First-year        6       19933
#>  2: MCID3111170852  19881 01 First-year        6       19933
#>  3: MCID3111173999  19881 01 First-year        6       19933
#>  4: MCID3111257807  19901 01 First-year        6       19953
#>  5: MCID3111258275  19901 01 First-year        6       19953
#>  6: MCID3111258347  19901 01 First-year        6       19953
#>  7: MCID3111259642  19901 01 First-year        6       19953
#>  8: MCID3111262210  19901 01 First-year        6       19953
#>  9: MCID3111265287  19901 01 First-year        6       19953
#> 10: MCID3111269576  19901 01 First-year        6       19953
#> 11: MCID3111272691  19901 01 First-year        6       19953
#> 12: MCID3111272880  19901 01 First-year        6       19953
#> 13: MCID3111277081  19903 01 First-year        6       19961
#> 14: MCID3112751130  20151 01 First-year        6       20203
#> 15: MCID3112754537  20151 01 First-year        6       20203

# Application: data_sufficiency() requires term_i and timely_term
data_sufficiency(x[, .(mcid, term_i, timely_term)], midf_table = term)
#>               mcid term_i timely_term  data_range data_sufficiency
#>             <char> <char>      <char>      <char>           <char>
#>  1: MCID3111169729  19881       19933 19881-20181    exclude-lower
#>  2: MCID3111170852  19881       19933 19881-20181    exclude-lower
#>  3: MCID3111173999  19881       19933 19881-20181    exclude-lower
#>  4: MCID3111257807  19901       19953 19881-20181          include
#>  5: MCID3111258275  19901       19953 19881-20181          include
#>  6: MCID3111258347  19901       19953 19881-20181          include
#>  7: MCID3111259642  19901       19953 19901-20153    exclude-lower
#>  8: MCID3111262210  19901       19953 19881-20181          include
#>  9: MCID3111265287  19901       19953 19881-20181          include
#> 10: MCID3111269576  19901       19953 19881-20181          include
#> 11: MCID3111272691  19901       19953 19881-20181          include
#> 12: MCID3111272880  19901       19953 19881-20181          include
#> 13: MCID3111277081  19903       19961 19881-20181          include
#> 14: MCID3112751130  20151       20203 19881-20181    exclude-upper
#> 15: MCID3112754537  20151       20203 19881-20181    exclude-upper

# Application: completion_status() requires timely_term
completion_status(x[, .(mcid, timely_term)], midf_table = degree)
#>               mcid timely_term completion_term completion_status
#>             <char>      <char>          <char>            <char>
#>  1: MCID3111169729       19933           19901            timely
#>  2: MCID3111170852       19933            <NA>              <NA>
#>  3: MCID3111173999       19933            <NA>              <NA>
#>  4: MCID3111257807       19953           19964              late
#>  5: MCID3111258275       19953           19921            timely
#>  6: MCID3111258347       19953           19923            timely
#>  7: MCID3111259642       19953           19934            timely
#>  8: MCID3111262210       19953           19951            timely
#>  9: MCID3111265287       19953           19904            timely
#> 10: MCID3111269576       19953           19943            timely
#> 11: MCID3111272691       19953           19914            timely
#> 12: MCID3111272880       19953           19934            timely
#> 13: MCID3111277081       19961           19963              late
#> 14: MCID3112751130       20203           20171            timely
#> 15: MCID3112754537       20203            <NA>              <NA>
```
