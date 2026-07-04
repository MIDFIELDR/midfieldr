# Calculate timely completion terms

Add a column indicating the term by which a student's program completion
would be considered timely. Columns of supporting information are also
added. Any existing column with the same name as one of the new columns
is dropped.

## Usage

``` r
timely_term(dframe, midfield_table = term, ..., sched_span = NULL, span = NULL)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble).
  Required variable: `{mcid}`.

- midfield_table:

  Data frame or data frame extension of a MIDFIELD *term* table.
  Required variables: `{mcid, term, level}`.

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

- Data frame class is preserved.

- Rows are filtered for uniqueness.

- Columns are not modified except any existing column with the same name
  as one of the new columns is dropped. The new columns are:

  - `term_i.`   Initial term of a student's longitudinal record, encoded
    `YYYYT`. Extracted from `midfield_table.`

  - `level_i.`   Character. Student level (01 Freshman, 02 Sophomore,
    etc.) in their initial term. Extracted from `midfield_table.`

  - `adj_span.`   Numeric. Integer span of years for timely completion
    adjusted for a student's initial level.

  - `timely_term.`   Character. Latest term by which program completion
    would be considered timely for every student. Encoded `YYYYT.`

- Groups and keys are not preserved.

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
our constraints. Thus `timely_term()` yields a column of timely term
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
[`data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/data_sufficiency.md)
and
[`completion_status()`](https://midfieldr.github.io/midfieldr/reference/completion_status.md)
require one or both of the added columns `{term_i, timely_term}.`

## Examples

``` r
term <- toy_term

# Start with a small population 
x <- toy_student[c(51:55, 346:350), .(mcid)]
x
#>               mcid
#>             <char>
#>  1: MCID3111412771
#>  2: MCID3111413518
#>  3: MCID3111417249
#>  4: MCID3111417990
#>  5: MCID3111418880
#>  6: MCID3112799709
#>  7: MCID3112815901
#>  8: MCID3112839623
#>  9: MCID3112868072
#> 10: MCID3112869843

# Add timely term
x <- timely_term(x, term)
x
#>               mcid term_i        level_i adj_span timely_term
#>             <char> <char>         <char>    <num>      <char>
#>  1: MCID3111412771  19931  01 First-year        6       19983
#>  2: MCID3111413518  19931  01 First-year        6       19983
#>  3: MCID3111417249  19941 02 Second-year        5       19983
#>  4: MCID3111417990  19931  01 First-year        6       19983
#>  5: MCID3111418880  19931  01 First-year        6       19983
#>  6: MCID3112799709  20161  01 First-year        6       20213
#>  7: MCID3112815901  20161  01 First-year        6       20213
#>  8: MCID3112839623  20171  01 First-year        6       20223
#>  9: MCID3112868072  20171  01 First-year        6       20223
#> 10: MCID3112869843  20173  01 First-year        6       20231

# Existing timely term column (if any) is replaced
x[, timely_term := NA_character_][]
#>               mcid term_i        level_i adj_span timely_term
#>             <char> <char>         <char>    <num>      <char>
#>  1: MCID3111412771  19931  01 First-year        6        <NA>
#>  2: MCID3111413518  19931  01 First-year        6        <NA>
#>  3: MCID3111417249  19941 02 Second-year        5        <NA>
#>  4: MCID3111417990  19931  01 First-year        6        <NA>
#>  5: MCID3111418880  19931  01 First-year        6        <NA>
#>  6: MCID3112799709  20161  01 First-year        6        <NA>
#>  7: MCID3112815901  20161  01 First-year        6        <NA>
#>  8: MCID3112839623  20171  01 First-year        6        <NA>
#>  9: MCID3112868072  20171  01 First-year        6        <NA>
#> 10: MCID3112869843  20173  01 First-year        6        <NA>
timely_term(x, term)
#>               mcid term_i        level_i adj_span timely_term
#>             <char> <char>         <char>    <num>      <char>
#>  1: MCID3111412771  19931  01 First-year        6       19983
#>  2: MCID3111413518  19931  01 First-year        6       19983
#>  3: MCID3111417249  19941 02 Second-year        5       19983
#>  4: MCID3111417990  19931  01 First-year        6       19983
#>  5: MCID3111418880  19931  01 First-year        6       19983
#>  6: MCID3112799709  20161  01 First-year        6       20213
#>  7: MCID3112815901  20161  01 First-year        6       20213
#>  8: MCID3112839623  20171  01 First-year        6       20223
#>  9: MCID3112868072  20171  01 First-year        6       20223
#> 10: MCID3112869843  20173  01 First-year        6       20231
```
