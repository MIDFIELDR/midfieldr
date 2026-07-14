# Determine timely completion terms

Determine the *timely completion term* for each student in a data frame
and add columns that support the findings.

## Usage

``` r
timely_term(dframe, midfield_table = term, ..., sched_span = NULL, span = NULL)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble) with
  required variable `{mcid}.`

- midfield_table:

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
    record, encoded `YYYYT`. Extracted from `midfield_table.`

  - `level_i`   Character. Student level (01 Freshman, 02 Sophomore,
    etc.) in their initial term. Extracted from `midfield_table.`

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
term <- toy_term

# Start with a selected population. 
x <- toy_student[c(51:55, 346:350), .(mcid, sex)]
x
#>               mcid    sex
#>             <char> <char>
#>  1: MCID3111412771   Male
#>  2: MCID3111413518   Male
#>  3: MCID3111417249   Male
#>  4: MCID3111417990 Female
#>  5: MCID3111418880 Female
#>  6: MCID3112799709   Male
#>  7: MCID3112815901 Female
#>  8: MCID3112839623 Female
#>  9: MCID3112868072   Male
#> 10: MCID3112869843 Female

# Add timely term columns. Unrelated columns (sex) are unaffected.
x <- timely_term(x, midfield_table = term)
x
#>               mcid    sex term_i        level_i adj_span timely_term
#>             <char> <char> <char>         <char>    <num>      <char>
#>  1: MCID3111412771   Male  19931  01 First-year        6       19983
#>  2: MCID3111413518   Male  19931  01 First-year        6       19983
#>  3: MCID3111417249   Male  19941 02 Second-year        5       19983
#>  4: MCID3111417990 Female  19931  01 First-year        6       19983
#>  5: MCID3111418880 Female  19931  01 First-year        6       19983
#>  6: MCID3112799709   Male  20161  01 First-year        6       20213
#>  7: MCID3112815901 Female  20161  01 First-year        6       20213
#>  8: MCID3112839623 Female  20171  01 First-year        6       20223
#>  9: MCID3112868072   Male  20171  01 First-year        6       20223
#> 10: MCID3112869843 Female  20173  01 First-year        6       20231

# Repeat. New columns silently replace existing columns of the same name.
y <- timely_term(x, midfield_table = term)
y
#>               mcid    sex term_i        level_i adj_span timely_term
#>             <char> <char> <char>         <char>    <num>      <char>
#>  1: MCID3111412771   Male  19931  01 First-year        6       19983
#>  2: MCID3111413518   Male  19931  01 First-year        6       19983
#>  3: MCID3111417249   Male  19941 02 Second-year        5       19983
#>  4: MCID3111417990 Female  19931  01 First-year        6       19983
#>  5: MCID3111418880 Female  19931  01 First-year        6       19983
#>  6: MCID3112799709   Male  20161  01 First-year        6       20213
#>  7: MCID3112815901 Female  20161  01 First-year        6       20213
#>  8: MCID3112839623 Female  20171  01 First-year        6       20223
#>  9: MCID3112868072   Male  20171  01 First-year        6       20223
#> 10: MCID3112869843 Female  20173  01 First-year        6       20231
```
