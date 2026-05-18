# Calculate a timely completion term for every student

Add a column to a data frame of student-level records that indicates the
latest term by which degree completion would be considered timely for
every student.

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
  `mcid`, `term`, and `level.`

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- span:

  Optional integer scalar, number of years to define timely completion.
  Commonly used values are are 100, 150, and 200 percent of
  `sched_span.` Default 6 years.

- sched_span:

  Optional integer scalar, the number of years an institution officially
  schedules for completing a program. Default 4 years.

## Value

A data frame in `data.table` format with the following properties: rows
are preserved; columns are preserved with the exception that columns
added by the function overwrite existing columns of the same name (if
any); grouping structures are not preserved. The added columns are:

- `term_i`:

  Character. Initial term of a student's longitudinal record, encoded
  YYYYT

- `level_i`:

  Character. Student level (01 Freshman, 02 Sophomore, etc.) in their
  initial term

- `adj_span`:

  Numeric. Integer span of years for timely completion adjusted for a
  student's initial level.

- `timely_term`:

  Character. Latest term by which program completion would be considered
  timely for every student. Encoded YYYYT.

## Details

By "completion" we mean an undergraduate earning their first
baccalaureate degree (or degrees, for students earning more than one
degree in the same term).

In many studies, students must complete their programs in a specified
time span, for example 4-, 6-, or 8-years after admission. If they do,
their completion is timely; if not, their completion is late and they
are grouped with the non-completers when computing a metric such as
graduation rate.

Our heuristic assigns `span` number of years (default is 6 years) to
every student. For students admitted at second-year level or higher, the
span is reduced by one year for each full year the student is assumed to
have completed. For example, a student admitted at the second-year level
is assumed to have completed one year of a program, so their span is
reduced by one year.

The adjusted span is added to the initial term to create the timely
completion term in the `timely_term` column.

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
#>  1: MCID3111145992  19881 01 First-year        6       19933
#>  2: MCID3111159270  19881 01 First-year        6       19933
#>  3: MCID3111160219  19881 01 First-year        6       19933
#>  4: MCID3111160513  19881 01 First-year        6       19933
#>  5: MCID3111162677  19881 01 First-year        6       19933
#>  6: MCID3111164287  19881 01 First-year        6       19933
#>  7: MCID3111166148  19881 01 First-year        6       19933
#>  8: MCID3111170298  19881 01 First-year        6       19933
#>  9: MCID3111170338  19881 01 First-year        6       19933
#> 10: MCID3111213943  19891 01 First-year        6       19943

# Define timely completion as 200% of scheduled span (8 years)
add_timely_term(dframe, midfield_term = toy_term, span = 8)
#>               mcid term_i       level_i adj_span timely_term
#>             <char> <char>        <char>    <num>      <char>
#>  1: MCID3111145992  19881 01 First-year        8       19953
#>  2: MCID3111159270  19881 01 First-year        8       19953
#>  3: MCID3111160219  19881 01 First-year        8       19953
#>  4: MCID3111160513  19881 01 First-year        8       19953
#>  5: MCID3111162677  19881 01 First-year        8       19953
#>  6: MCID3111164287  19881 01 First-year        8       19953
#>  7: MCID3111166148  19881 01 First-year        8       19953
#>  8: MCID3111170298  19881 01 First-year        8       19953
#>  9: MCID3111170338  19881 01 First-year        8       19953
#> 10: MCID3111213943  19891 01 First-year        8       19963

# Existing timely_term column, if any, is overwritten
dframe[, timely_term := NA_character_][]
#>               mcid timely_term
#>             <char>      <char>
#>  1: MCID3111145992        <NA>
#>  2: MCID3111159270        <NA>
#>  3: MCID3111160219        <NA>
#>  4: MCID3111160513        <NA>
#>  5: MCID3111162677        <NA>
#>  6: MCID3111164287        <NA>
#>  7: MCID3111166148        <NA>
#>  8: MCID3111170298        <NA>
#>  9: MCID3111170338        <NA>
#> 10: MCID3111213943        <NA>
add_timely_term(dframe, midfield_term = toy_term)
#>               mcid term_i       level_i adj_span timely_term
#>             <char> <char>        <char>    <num>      <char>
#>  1: MCID3111145992  19881 01 First-year        6       19933
#>  2: MCID3111159270  19881 01 First-year        6       19933
#>  3: MCID3111160219  19881 01 First-year        6       19933
#>  4: MCID3111160513  19881 01 First-year        6       19933
#>  5: MCID3111162677  19881 01 First-year        6       19933
#>  6: MCID3111164287  19881 01 First-year        6       19933
#>  7: MCID3111166148  19881 01 First-year        6       19933
#>  8: MCID3111170298  19881 01 First-year        6       19933
#>  9: MCID3111170338  19881 01 First-year        6       19933
#> 10: MCID3111213943  19891 01 First-year        6       19943

```
