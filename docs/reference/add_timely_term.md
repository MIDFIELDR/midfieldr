# Calculate a timely completion term for every student

Add columns to a data frame of student-level records that indicate each
student's timely completion term, that is, the term by which program
completion would be considered timely. By "completion" we mean an
undergraduate earning their first baccalaureate degree (or degrees, for
students earning more than one degree in the same term). The timely
completion term is usually defined as 4-, 6-, or 8-years after
admission. Our default is 6 years.

## Usage

``` r
add_timely_term(
  dframe,
  midfield_term = term,
  ...,
  span = NULL,
  sched_span = NULL
)
```

## Arguments

- dframe:

  Working data frame of student-level records to which timely-term
  columns are to be added. Required variable is `mcid`.

- midfield_term:

  MIDFIELD `term` data table or equivalent with required variables
  `mcid`, `term`, and `level`.

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- span:

  Optional integer scalar, number of years to define timely completion.
  Commonly used values are are 100%, 150%, and 200% of `sched_span.`
  Default 6 years.

- sched_span:

  Optional integer scalar, the number of years an institution officially
  schedules for completing a program. Default 4 years.

## Value

A data frame of the same type as `dframe`. The output has the following
properties:

- Rows are not modified.

- Columns are added, overwriting existing columns (if any) of the same
  name. Other columns are not modified.

- Groups are not preserved.

- Data frame attributes are preserved for classes `data.frame`,
  `data.table`, or `tbl_df`.

## Details

In many studies, students must complete their programs in a specified
time span to be considered "timely", for example 4-, 6-, or 8-years
after admission. If they do not, their completion is "late" and they are
grouped with the non-completers when computing a metric such as
graduation rate.

Our heuristic assigns `span` number of years (default is 6 years) to
every student. For students admitted at second-year level or higher, the
span is reduced by one year for each full year the student is assumed to
have completed. For example, a student admitted at the second-year level
is assumed to have completed one year of a program, so their span is
reduced by one year. The adjusted span is added to the initial term to
create the timely completion term in the `timely_term` column.

The new columns are:

- `term_i` Initial term of a student's longitudinal record, encoded
  `YYYYT`. Extracted from `term`.

- `level_i`. Character. Student level (01 Freshman, 02 Sophomore, etc.)
  in their initial term. Extracted from `term`.

- `adj_span`. Numeric. Integer span of years for timely completion
  adjusted for a student's initial level.

- `timely_term`. Character. Latest term by which program completion
  would be considered timely for every student. Encoded `YYYYT`.

## See also

Other add\_\*:
[`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md),
[`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md)

## Examples

``` r
# Start with an excerpt from the student data set 
dframe <- toy_student[1:10, .(mcid)]

# Add timely completion term column
add_timely_term(dframe, midfield_term = toy_term)
#>               mcid term_i       level_i adj_span timely_term
#>             <char> <char>        <char>    <num>      <char>
#>  1: MCID3111158953  19881 01 First-year        6       19933
#>  2: MCID3111159270  19881 01 First-year        6       19933
#>  3: MCID3111160513  19881 01 First-year        6       19933
#>  4: MCID3111162677  19881 01 First-year        6       19933
#>  5: MCID3111164287  19881 01 First-year        6       19933
#>  6: MCID3111171205  19881 01 First-year        6       19933
#>  7: MCID3111172083  19881 01 First-year        6       19933
#>  8: MCID3111213943  19891 01 First-year        6       19943
#>  9: MCID3111248941  19901 01 First-year        6       19953
#> 10: MCID3111250695  19901 01 First-year        6       19953

# Define timely completion as 200% of scheduled span (8 years)
add_timely_term(dframe, midfield_term = toy_term, span = 8)
#>               mcid term_i       level_i adj_span timely_term
#>             <char> <char>        <char>    <num>      <char>
#>  1: MCID3111158953  19881 01 First-year        8       19953
#>  2: MCID3111159270  19881 01 First-year        8       19953
#>  3: MCID3111160513  19881 01 First-year        8       19953
#>  4: MCID3111162677  19881 01 First-year        8       19953
#>  5: MCID3111164287  19881 01 First-year        8       19953
#>  6: MCID3111171205  19881 01 First-year        8       19953
#>  7: MCID3111172083  19881 01 First-year        8       19953
#>  8: MCID3111213943  19891 01 First-year        8       19963
#>  9: MCID3111248941  19901 01 First-year        8       19973
#> 10: MCID3111250695  19901 01 First-year        8       19973

# Existing timely_term column, if any, is overwritten
dframe[, timely_term := NA_character_][]
#>               mcid timely_term
#>             <char>      <char>
#>  1: MCID3111158953        <NA>
#>  2: MCID3111159270        <NA>
#>  3: MCID3111160513        <NA>
#>  4: MCID3111162677        <NA>
#>  5: MCID3111164287        <NA>
#>  6: MCID3111171205        <NA>
#>  7: MCID3111172083        <NA>
#>  8: MCID3111213943        <NA>
#>  9: MCID3111248941        <NA>
#> 10: MCID3111250695        <NA>
add_timely_term(dframe, midfield_term = toy_term)
#>               mcid term_i       level_i adj_span timely_term
#>             <char> <char>        <char>    <num>      <char>
#>  1: MCID3111158953  19881 01 First-year        6       19933
#>  2: MCID3111159270  19881 01 First-year        6       19933
#>  3: MCID3111160513  19881 01 First-year        6       19933
#>  4: MCID3111162677  19881 01 First-year        6       19933
#>  5: MCID3111164287  19881 01 First-year        6       19933
#>  6: MCID3111171205  19881 01 First-year        6       19933
#>  7: MCID3111172083  19881 01 First-year        6       19933
#>  8: MCID3111213943  19891 01 First-year        6       19943
#>  9: MCID3111248941  19901 01 First-year        6       19953
#> 10: MCID3111250695  19901 01 First-year        6       19953

```
