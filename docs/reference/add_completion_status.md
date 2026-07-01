# Determine completion status

To a data frame keyed by student ID, add a column indicating if a
student completed their program, and if so, whether their completion was
timely or late. Columns of supporting information are also added.

## Usage

``` r
add_completion_status(dframe, midfield_rec = degree)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble).
  Required variables: `{mcid, timely_term}`.

- midfield_rec:

  MIDFIELD records *degree* data frame or data frame extension. Required
  variables: `{mcid, term_degree}`.

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Rows are filtered for unique `mcid` values.

- Columns `{mcid, timely_term}` are retained (all other columns are
  dropped). New columns added:

  - `term_degree.`   Character. Term in which the first degree(s) are
    completed, encoded `YYYYT`. Joined from `midfield_rec.`

  - `completion_status.`   Character. Possible values are "timely" for
    students completing a degree no later than their timely completion
    terms; "late" for students completing their program after their
    timely completion term; and "NA" for non-completers.

## Details

In many studies, students must complete their programs in a specified
time span to be considered "timely", for example 4, 6, or 8 years after
admission. By "completion" we mean an undergraduate earning their first
baccalaureate degree (or degrees, for students earning more than one
degree in the same term).

The goal of determining timely completion is to refine a population,
that is, obtain a data frame of IDs that satisfy our constraints. Thus
`add_completion_status()` yields a column of completion status values
and columns of supporting information keyed by ID. All other columns in
`dframe` (if any) are dropped.

The supporting information in the output is provided so that the user
can review the findings. After review, we usually delete all columns
except the IDs, yielding the refined population that was our goal.

## See also

Other add\_\*:
[`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md),
[`add_term_cluster()`](https://midfieldr.github.io/midfieldr/reference/add_term_cluster.md),
[`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)

## Examples

``` r
# Start with an excerpt from the student data set 
dframe <- toy_student[1:10, .(mcid)]

# Timely term column is required to add completion status column
dframe <- add_timely_term(dframe, toy_term)

# Add completion status column
add_completion_status(dframe, toy_degree)
#>               mcid timely_term term_degree completion_status
#>             <char>      <char>      <char>            <char>
#>  1: MCID3111158953       19933        <NA>              <NA>
#>  2: MCID3111159270       19933       19913            timely
#>  3: MCID3111160513       19933        <NA>              <NA>
#>  4: MCID3111162677       19933       19913            timely
#>  5: MCID3111164287       19933       19913            timely
#>  6: MCID3111171205       19933       19913            timely
#>  7: MCID3111172083       19933       19913            timely
#>  8: MCID3111213943       19943       19903            timely
#>  9: MCID3111248941       19953       19943            timely
#> 10: MCID3111250695       19953        <NA>              <NA>

# Existing completion_status column, if any, is overwritten
dframe[, completion_status := NA_character_][]
#>               mcid term_i       level_i adj_span timely_term completion_status
#>             <char> <char>        <char>    <num>      <char>            <char>
#>  1: MCID3111158953  19881 01 First-year        6       19933              <NA>
#>  2: MCID3111159270  19881 01 First-year        6       19933              <NA>
#>  3: MCID3111160513  19881 01 First-year        6       19933              <NA>
#>  4: MCID3111162677  19881 01 First-year        6       19933              <NA>
#>  5: MCID3111164287  19881 01 First-year        6       19933              <NA>
#>  6: MCID3111171205  19881 01 First-year        6       19933              <NA>
#>  7: MCID3111172083  19881 01 First-year        6       19933              <NA>
#>  8: MCID3111213943  19891 01 First-year        6       19943              <NA>
#>  9: MCID3111248941  19901 01 First-year        6       19953              <NA>
#> 10: MCID3111250695  19901 01 First-year        6       19953              <NA>
add_completion_status(dframe, toy_degree)
#>               mcid timely_term term_degree completion_status
#>             <char>      <char>      <char>            <char>
#>  1: MCID3111158953       19933        <NA>              <NA>
#>  2: MCID3111159270       19933       19913            timely
#>  3: MCID3111160513       19933        <NA>              <NA>
#>  4: MCID3111162677       19933       19913            timely
#>  5: MCID3111164287       19933       19913            timely
#>  6: MCID3111171205       19933       19913            timely
#>  7: MCID3111172083       19933       19913            timely
#>  8: MCID3111213943       19943       19903            timely
#>  9: MCID3111248941       19953       19943            timely
#> 10: MCID3111250695       19953        <NA>              <NA>
```
