# Determine timely completion terms

Determine the *timely completion term* for each student in a data frame
and add columns that support the findings.

## Usage

``` r
timely_term(dframe, midf_table = term, ..., span = NULL, sched_span = NULL)
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

- span:

  Integer scalar (default 6), number of years to define timely
  completion, typically 4, 6, or 8 years (100%, 150%, 200% respectively
  of `sched_span`).#'

- sched_span:

  Integer scalar (default 4), the number of years an institution
  officially schedules for completing a program.

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Row order is preserved. Rows with `NA` values in any of the required
  variables are removed. Duplicated rows are removed.

- New columns are added and all unique columns are preserved. If
  required to prevent overwriting, new column names are suffixed
  (`.1, .2,` etc.). Duplicate columns, differing by suffix only, are
  dropped. The new variables are:

  - `entry_term`   Character. Initial term of a student's longitudinal
    record, encoded `YYYYT`. Extracted from `midf_table.`

  - `entry_level`   Character. Student level (01 Freshman, 02 Sophomore,
    etc.) in their initial term. Extracted from `midf_table.`

  - `adj_span`   Numeric. Integer span of years for timely completion
    adjusted for a student's initial level.

  - `timely_term`   Character. Latest term by which program completion
    would be considered timely. Encoded `YYYYT.`

## Details

Completing an academic program in a "timely" manner means that a student
completes the requirements for a degree within a set time span,
typically 4, 6, or 8 years after admission depending on the definition
adopted in a particular study. The final term of that span is the
*timely completion term.*

Our heuristic assigns a time span of 6 academic years for timely
completion (other values can be assigned via the `span` argument). For
students admitted at second-year level or higher, the span value is
reduced by one academic year for each full year the student is assumed
to have completed. The adjusted span is added to their initial term at
an institution to create the `timely_term` value for each observation.

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

# Add timely term columns
x <- timely_term(x, midf_table = term)
x
#>               mcid entry_term   entry_level adj_span timely_term
#>             <char>     <char>        <char>    <num>      <char>
#>  1: MCID3111169729      19881 01 First-year        6       19933
#>  2: MCID3111170852      19881 01 First-year        6       19933
#>  3: MCID3111173999      19881 01 First-year        6       19933
#> ---                                                             
#> 13: MCID3111277081      19903 01 First-year        6       19961
#> 14: MCID3112751130      20151 01 First-year        6       20203
#> 15: MCID3112754537      20151 01 First-year        6       20203

# If you repeat, the new columns are overwritten
timely_term(x, midf_table = term)
#>               mcid entry_term   entry_level adj_span timely_term
#>             <char>     <char>        <char>    <num>      <char>
#>  1: MCID3111169729      19881 01 First-year        6       19933
#>  2: MCID3111170852      19881 01 First-year        6       19933
#>  3: MCID3111173999      19881 01 First-year        6       19933
#> ---                                                             
#> 13: MCID3111277081      19903 01 First-year        6       19961
#> 14: MCID3112751130      20151 01 First-year        6       20203
#> 15: MCID3112754537      20151 01 First-year        6       20203

# Application: data_sufficiency() requires entry_term and timely_term
data_sufficiency(x[, .(mcid, entry_term, timely_term)], midf_table = term)
#>               mcid entry_term timely_term  data_range sufficiency
#>             <char>     <char>      <char>      <char>      <char>
#>  1: MCID3111169729      19881       19933 19881-20181  fail-lower
#>  2: MCID3111170852      19881       19933 19881-20181  fail-lower
#>  3: MCID3111173999      19881       19933 19881-20181  fail-lower
#> ---                                                              
#> 13: MCID3111277081      19903       19961 19881-20181   satisfied
#> 14: MCID3112751130      20151       20203 19881-20181  fail-upper
#> 15: MCID3112754537      20151       20203 19881-20181  fail-upper

# Application: completion_status() requires timely_term
completion_status(x[, .(mcid, timely_term)], midf_table = degree)
#>               mcid timely_term bacc_term completion
#>             <char>      <char>    <char>     <char>
#>  1: MCID3111169729       19933     19901     timely
#>  2: MCID3111170852       19933      <NA>       <NA>
#>  3: MCID3111173999       19933      <NA>       <NA>
#> ---                                                
#> 13: MCID3111277081       19961     19963       late
#> 14: MCID3112751130       20203     20171     timely
#> 15: MCID3112754537       20203      <NA>       <NA>
```
