# Calculate timely completion terms

To a data frame keyed by student ID, add a column indicating the
student's timely completion term. Columns of supporting information are
also added.

## Usage

``` r
add_timely_term(
  dframe,
  midfield_rec = term,
  ...,
  sched_span = NULL,
  span = NULL
)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble).
  Required variable: `{mcid}`.

- midfield_rec:

  MIDFIELD records *term* data frame or data frame extension. Required
  variables: `{mcid, term, level}`.

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

- Rows are filtered for unique `mcid` values.

- Column `{mcid}` is retained (all other columns are dropped). New
  columns added:

  - `term_i.`   Initial term of a student's longitudinal record, encoded
    `YYYYT`. Extracted from `midfield_rec.`

  - `level_i.`   Character. Student level (01 Freshman, 02 Sophomore,
    etc.) in their initial term. Extracted from `midfield_rec.`

  - `adj_span.`   Numeric. Integer span of years for timely completion
    adjusted for a student's initial level.

  - `timely_term.`   Character. Latest term by which program completion
    would be considered timely for every student. Encoded `YYYYT.`

## Details

In many studies, students must complete their programs in a specified
time span to be considered "timely", for example 4, 6, or 8 years after
admission. The latest term by which program completion would be
considered timely is the *timely completion term.* By "completion" we
mean an undergraduate earning their first baccalaureate degree (or
degrees, for students earning more than one degree in the same term).

The timely completion term is required for determining data sufficiency
as well as timely completion status. The goal in either case is to
refine a population, that is, obtain a data frame of IDs that satisfy
our constraints. Thus `add_timely_term()` yields a column of timely term
values and columns of supporting information keyed by ID. All other
columns in `dframe` (if any) are dropped.

Our heuristic assigns `span` number of years (default 6) to every
student. For students admitted at second-year level or higher, the span
is reduced by one year for each full year the student is assumed to have
completed. For example, a student admitted at the second-year level is
assumed to have completed one year of a program, so their span is
reduced by one year. The adjusted span is added to their initial term to
create the `timely_term` values.

The supporting information in the output is provided so that the user
can review the findings. Moreover,
[`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md)
and
[`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md)
require one or both of the added columns `{term_i, timely_term}.`

## See also

Other add\_\*:
[`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md),
[`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md),
[`add_term_cluster()`](https://midfieldr.github.io/midfieldr/reference/add_term_cluster.md)

## Examples

``` r
# Start with an excerpt from the student data set 
dframe <- toy_student[1:10, .(mcid)]

# Add timely completion term column
add_timely_term(dframe, toy_term)
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
add_timely_term(dframe, toy_term, span = 8)
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
add_timely_term(dframe, toy_term)
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
