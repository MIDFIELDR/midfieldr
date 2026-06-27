# Determine completion status for every student

Add columns to a data frame of student-level records that indicate
whether a student completed a degree, and if so, whether their
completion was timely. By "completion" we mean an undergraduate earning
their first baccalaureate degree (or degrees, for students earning more
than one degree in the same term). The term by which a student's
completion would be considered timely (the "timely completion term") is
usually defined as 4-, 6-, or 8-years after admission. Our default is 6
years.

## Usage

``` r
add_completion_status(dframe, midfield_degree = degree)
```

## Arguments

- dframe:

  Working data frame of student-level records to which completion-status
  columns are to be added. Required variables are `mcid` and
  `timely_term`.

- midfield_degree:

  MIDFIELD `degree` data table or equivalent with required variables
  `mcid` and `term_degree.`

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

The new columns are:

- `term_degree` Character. Term in which the first degree(s) are
  completed, encoded `YYYYT`. Joined from `midfield_degree`.

- `completion_status` Character. Possible values are "timely","late",
  and "NA". Completion status is "timely" for students completing a
  degree no later than their timely completion terms; "late" for
  students completing their program after their timely completion term;
  and "NA" for non-completers.

## See also

Other add\_\*:
[`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md),
[`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)

## Examples

``` r
# Start with an excerpt from the student data set 
dframe <- toy_student[1:10, .(mcid)]

# Timely term column is required to add completion status column
dframe <- add_timely_term(dframe, toy_term)

# Add completion status column
add_completion_status(dframe, toy_degree)
#>               mcid term_i       level_i adj_span timely_term term_degree
#>             <char> <char>        <char>    <num>      <char>      <char>
#>  1: MCID3111158953  19881 01 First-year        6       19933        <NA>
#>  2: MCID3111159270  19881 01 First-year        6       19933       19913
#>  3: MCID3111160513  19881 01 First-year        6       19933        <NA>
#>  4: MCID3111162677  19881 01 First-year        6       19933       19913
#>  5: MCID3111164287  19881 01 First-year        6       19933       19913
#>  6: MCID3111171205  19881 01 First-year        6       19933       19913
#>  7: MCID3111172083  19881 01 First-year        6       19933       19913
#>  8: MCID3111213943  19891 01 First-year        6       19943       19903
#>  9: MCID3111248941  19901 01 First-year        6       19953       19943
#> 10: MCID3111250695  19901 01 First-year        6       19953        <NA>
#>     completion_status
#>                <char>
#>  1:              <NA>
#>  2:            timely
#>  3:              <NA>
#>  4:            timely
#>  5:            timely
#>  6:            timely
#>  7:            timely
#>  8:            timely
#>  9:            timely
#> 10:              <NA>

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
#>               mcid term_i       level_i adj_span timely_term term_degree
#>             <char> <char>        <char>    <num>      <char>      <char>
#>  1: MCID3111158953  19881 01 First-year        6       19933        <NA>
#>  2: MCID3111159270  19881 01 First-year        6       19933       19913
#>  3: MCID3111160513  19881 01 First-year        6       19933        <NA>
#>  4: MCID3111162677  19881 01 First-year        6       19933       19913
#>  5: MCID3111164287  19881 01 First-year        6       19933       19913
#>  6: MCID3111171205  19881 01 First-year        6       19933       19913
#>  7: MCID3111172083  19881 01 First-year        6       19933       19913
#>  8: MCID3111213943  19891 01 First-year        6       19943       19903
#>  9: MCID3111248941  19901 01 First-year        6       19953       19943
#> 10: MCID3111250695  19901 01 First-year        6       19953        <NA>
#>     completion_status
#>                <char>
#>  1:              <NA>
#>  2:            timely
#>  3:              <NA>
#>  4:            timely
#>  5:            timely
#>  6:            timely
#>  7:            timely
#>  8:            timely
#>  9:            timely
#> 10:              <NA>
```
