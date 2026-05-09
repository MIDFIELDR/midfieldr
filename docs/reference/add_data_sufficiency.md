# Determine data sufficiency for every student

Add a column to a data frame of student-level records that labels each
row for inclusion or exclusion based on data sufficiency near the upper
and lower bounds of an institution's data range.

## Usage

``` r
add_data_sufficiency(dframe, midfield_term = term)
```

## Arguments

- dframe:

  Working data frame of student-level records to which data-sufficiency
  columns are to be added. Required variables are `mcid` and
  `timely_term.` See also
  [`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md).

- midfield_term:

  MIDFIELD `term` data table or equivalent with required variables
  `mcid`, `institution`, and `term`.

## Value

A data frame in `data.table` format with the following properties: rows
are preserved; columns are preserved with the exception that columns
added by the function overwrite existing columns of the same name (if
any); grouping structures are not preserved. The added columns are:

- `term_i`:

  Character. Initial term of a student's longitudinal record, encoded
  YYYYT. Not overwritten if present in `dframe.`

- `lower_limit`:

  Character. Initial term of an institution's data range, encoded YYYYT

- `upper_limit`:

  Character. Final term of an institution's data range, encoded YYYYT

- `data_sufficiency`:

  Character. Label each observation for inclusion or exclusion based on
  data sufficiency. Possible values are: `include`, indicating that
  available data are sufficient for estimating timely completion;
  `exclude-upper`, indicating that data are insufficient at the upper
  limit of a data range; and `exclude`-lower, indicating that data are
  insufficient at the lower limit.

## Details

The time span of MIDFIELD term data varies by institution, each having
their own lower and upper bounds. For some student records, being at or
near these bounds creates unavoidable ambiguity when trying to assess
degree completion. Such records must be identified and in most cases
excluded to prevent false summary counts.

## See also

Other add\_\*:
[`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md),
[`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)

## Examples

``` r
# Start with an excerpt from the student data set 
dframe <- toy_student[1:10, .(mcid)]

# Timely term column is required to add data sufficiency column
dframe <- add_timely_term(dframe, midfield_term = toy_term)

# Add data sufficiency column
add_data_sufficiency(dframe, midfield_term = toy_term)
#>            mcid      level_i adj_span timely_term term_i lower_limit
#>          <char>       <char>    <num>      <char> <char>      <char>
#>  1: MID25784187  01 Freshman        6       19943  19885       19881
#>  2: MID25784974 02 Sophomore        5       19931  19883       19881
#>  3: MID25816209 02 Sophomore        5       19923  19881       19881
#>  4: MID25819358 02 Sophomore        5       19993  19946       19881
#>  5: MID25828870  01 Freshman        6       19933  19881       19881
#>  6: MID25829749    03 Junior        4       20033  19995       19881
#>  7: MID25841418    03 Junior        4       20013  19981       19881
#>  8: MID25845197    03 Junior        4       19943  19905       19881
#>  9: MID25846316  01 Freshman        6       19963  19911       19881
#> 10: MID25847220  01 Freshman        6       19943  19891       19881
#>     upper_limit data_sufficiency
#>          <char>           <char>
#>  1:       19995          include
#>  2:       19995          include
#>  3:       19995    exclude-lower
#>  4:       19995          include
#>  5:       19995    exclude-lower
#>  6:       19995    exclude-upper
#>  7:       19995    exclude-upper
#>  8:       19995          include
#>  9:       19995          include
#> 10:       19995          include

# Existing data_sufficiency column, if any, is overwritten
dframe[, data_sufficiency := NA_character_]
#>            mcid term_i      level_i adj_span timely_term data_sufficiency
#>          <char> <char>       <char>    <num>      <char>           <char>
#>  1: MID25784187  19885  01 Freshman        6       19943             <NA>
#>  2: MID25784974  19883 02 Sophomore        5       19931             <NA>
#>  3: MID25816209  19881 02 Sophomore        5       19923             <NA>
#>  4: MID25819358  19946 02 Sophomore        5       19993             <NA>
#>  5: MID25828870  19881  01 Freshman        6       19933             <NA>
#>  6: MID25829749  19995    03 Junior        4       20033             <NA>
#>  7: MID25841418  19981    03 Junior        4       20013             <NA>
#>  8: MID25845197  19905    03 Junior        4       19943             <NA>
#>  9: MID25846316  19911  01 Freshman        6       19963             <NA>
#> 10: MID25847220  19891  01 Freshman        6       19943             <NA>
add_data_sufficiency(dframe, midfield_term = toy_term)
#>            mcid      level_i adj_span timely_term term_i lower_limit
#>          <char>       <char>    <num>      <char> <char>      <char>
#>  1: MID25784187  01 Freshman        6       19943  19885       19881
#>  2: MID25784974 02 Sophomore        5       19931  19883       19881
#>  3: MID25816209 02 Sophomore        5       19923  19881       19881
#>  4: MID25819358 02 Sophomore        5       19993  19946       19881
#>  5: MID25828870  01 Freshman        6       19933  19881       19881
#>  6: MID25829749    03 Junior        4       20033  19995       19881
#>  7: MID25841418    03 Junior        4       20013  19981       19881
#>  8: MID25845197    03 Junior        4       19943  19905       19881
#>  9: MID25846316  01 Freshman        6       19963  19911       19881
#> 10: MID25847220  01 Freshman        6       19943  19891       19881
#>     upper_limit data_sufficiency
#>          <char>           <char>
#>  1:       19995          include
#>  2:       19995          include
#>  3:       19995    exclude-lower
#>  4:       19995          include
#>  5:       19995    exclude-lower
#>  6:       19995    exclude-upper
#>  7:       19995    exclude-upper
#>  8:       19995          include
#>  9:       19995          include
#> 10:       19995          include
```
