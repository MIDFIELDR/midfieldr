# Determine completion status for every student

Add columns to a data frame of student-level records that indicate
whether a student completed a degree, and if so, whether their
completion was timely.

## Usage

``` r
add_completion_status(dframe, midfield_degree = degree)
```

## Arguments

- dframe:

  Working data frame of student-level records to which completion-status
  columns are to be added. Required variables are `mcid` and
  `timely_term.` See also
  [`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md).

- midfield_degree:

  MIDFIELD `degree` data table or equivalent with required variables
  `mcid` and `term_degree.`

## Value

A data frame in `data.table` format with the following properties: rows
are preserved; columns are preserved with the exception that columns
added by the function overwrite existing columns of the same name (if
any); grouping structures are not preserved. The added columns are:

- `term_degree`:

  Character. Term in which the first degree(s) are completed. Encoded
  YYYYT. Joined from `midfield_degree` data table.

- `completion_status`:

  Character. Label each observation to indicate completion status.
  Possible values are: "timely", indicating completion no later than the
  timely completion term; "late", indicating completion after the timely
  completion term; and "NA" indicating non-completion.

## Details

By "completion" we mean an undergraduate earning their first
baccalaureate degree (or degrees, for students earning more than one
degree in the same term). Additional degrees, if any, earned later than
the term of the first degree are ignored.

In many studies, students must complete a degree in a specified time
span, for example 4-, 6-, or 8-years after admission. If they do, their
completion is timely; if not, their completion is late and they are
grouped with the non-completers when computing a metric such as
graduation rate.

Completion status is "timely" for students completing a degree no later
than their timely completion terms. See also
[`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md).

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
#>            mcid term_i      level_i adj_span timely_term term_degree
#>          <char> <char>       <char>    <num>      <char>      <char>
#>  1: MID25784187  19885  01 Freshman        6       19943       19946
#>  2: MID25784974  19883 02 Sophomore        5       19931        <NA>
#>  3: MID25816209  19881 02 Sophomore        5       19923        <NA>
#>  4: MID25819358  19946 02 Sophomore        5       19993       19963
#>  5: MID25828870  19881  01 Freshman        6       19933       19923
#>  6: MID25829749  19995    03 Junior        4       20033        <NA>
#>  7: MID25841418  19981    03 Junior        4       20013       19993
#>  8: MID25845197  19905    03 Junior        4       19943       19921
#>  9: MID25846316  19911  01 Freshman        6       19963       19951
#> 10: MID25847220  19891  01 Freshman        6       19943       19933
#>     completion_status
#>                <char>
#>  1:              late
#>  2:              <NA>
#>  3:              <NA>
#>  4:            timely
#>  5:            timely
#>  6:              <NA>
#>  7:            timely
#>  8:            timely
#>  9:            timely
#> 10:            timely

# Existing completion_status column, if any, is overwritten
dframe[, completion_status := NA_character_]
#>            mcid term_i      level_i adj_span timely_term completion_status
#>          <char> <char>       <char>    <num>      <char>            <char>
#>  1: MID25784187  19885  01 Freshman        6       19943              <NA>
#>  2: MID25784974  19883 02 Sophomore        5       19931              <NA>
#>  3: MID25816209  19881 02 Sophomore        5       19923              <NA>
#>  4: MID25819358  19946 02 Sophomore        5       19993              <NA>
#>  5: MID25828870  19881  01 Freshman        6       19933              <NA>
#>  6: MID25829749  19995    03 Junior        4       20033              <NA>
#>  7: MID25841418  19981    03 Junior        4       20013              <NA>
#>  8: MID25845197  19905    03 Junior        4       19943              <NA>
#>  9: MID25846316  19911  01 Freshman        6       19963              <NA>
#> 10: MID25847220  19891  01 Freshman        6       19943              <NA>
add_completion_status(dframe, toy_degree)
#>            mcid term_i      level_i adj_span timely_term term_degree
#>          <char> <char>       <char>    <num>      <char>      <char>
#>  1: MID25784187  19885  01 Freshman        6       19943       19946
#>  2: MID25784974  19883 02 Sophomore        5       19931        <NA>
#>  3: MID25816209  19881 02 Sophomore        5       19923        <NA>
#>  4: MID25819358  19946 02 Sophomore        5       19993       19963
#>  5: MID25828870  19881  01 Freshman        6       19933       19923
#>  6: MID25829749  19995    03 Junior        4       20033        <NA>
#>  7: MID25841418  19981    03 Junior        4       20013       19993
#>  8: MID25845197  19905    03 Junior        4       19943       19921
#>  9: MID25846316  19911  01 Freshman        6       19963       19951
#> 10: MID25847220  19891  01 Freshman        6       19943       19933
#>     completion_status
#>                <char>
#>  1:              late
#>  2:              <NA>
#>  3:              <NA>
#>  4:            timely
#>  5:            timely
#>  6:              <NA>
#>  7:            timely
#>  8:            timely
#>  9:            timely
#> 10:            timely
```
