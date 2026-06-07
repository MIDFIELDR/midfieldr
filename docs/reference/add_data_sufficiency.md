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
#>               mcid       level_i adj_span timely_term term_i lower_limit
#>             <char>        <char>    <num>      <char> <char>      <char>
#>  1: MCID3111158953 01 First-year        6       19933  19881       19881
#>  2: MCID3111159270 01 First-year        6       19933  19881       19881
#>  3: MCID3111160513 01 First-year        6       19933  19881       19881
#>  4: MCID3111162677 01 First-year        6       19933  19881       19881
#>  5: MCID3111164287 01 First-year        6       19933  19881       19881
#>  6: MCID3111171205 01 First-year        6       19933  19881       19881
#>  7: MCID3111172083 01 First-year        6       19933  19881       19881
#>  8: MCID3111213943 01 First-year        6       19943  19891       19881
#>  9: MCID3111248941 01 First-year        6       19953  19901       19881
#> 10: MCID3111250695 01 First-year        6       19953  19901       19881
#>     upper_limit data_sufficiency
#>          <char>           <char>
#>  1:       20096    exclude-lower
#>  2:       20096    exclude-lower
#>  3:       20096    exclude-lower
#>  4:       20096    exclude-lower
#>  5:       20096    exclude-lower
#>  6:       20181    exclude-lower
#>  7:       20181    exclude-lower
#>  8:       20181          include
#>  9:       20096          include
#> 10:       20096          include

# Existing data_sufficiency column, if any, is overwritten
dframe[, data_sufficiency := NA_character_][]
#>               mcid term_i       level_i adj_span timely_term data_sufficiency
#>             <char> <char>        <char>    <num>      <char>           <char>
#>  1: MCID3111158953  19881 01 First-year        6       19933             <NA>
#>  2: MCID3111159270  19881 01 First-year        6       19933             <NA>
#>  3: MCID3111160513  19881 01 First-year        6       19933             <NA>
#>  4: MCID3111162677  19881 01 First-year        6       19933             <NA>
#>  5: MCID3111164287  19881 01 First-year        6       19933             <NA>
#>  6: MCID3111171205  19881 01 First-year        6       19933             <NA>
#>  7: MCID3111172083  19881 01 First-year        6       19933             <NA>
#>  8: MCID3111213943  19891 01 First-year        6       19943             <NA>
#>  9: MCID3111248941  19901 01 First-year        6       19953             <NA>
#> 10: MCID3111250695  19901 01 First-year        6       19953             <NA>
add_data_sufficiency(dframe, midfield_term = toy_term)
#>               mcid       level_i adj_span timely_term term_i lower_limit
#>             <char>        <char>    <num>      <char> <char>      <char>
#>  1: MCID3111158953 01 First-year        6       19933  19881       19881
#>  2: MCID3111159270 01 First-year        6       19933  19881       19881
#>  3: MCID3111160513 01 First-year        6       19933  19881       19881
#>  4: MCID3111162677 01 First-year        6       19933  19881       19881
#>  5: MCID3111164287 01 First-year        6       19933  19881       19881
#>  6: MCID3111171205 01 First-year        6       19933  19881       19881
#>  7: MCID3111172083 01 First-year        6       19933  19881       19881
#>  8: MCID3111213943 01 First-year        6       19943  19891       19881
#>  9: MCID3111248941 01 First-year        6       19953  19901       19881
#> 10: MCID3111250695 01 First-year        6       19953  19901       19881
#>     upper_limit data_sufficiency
#>          <char>           <char>
#>  1:       20096    exclude-lower
#>  2:       20096    exclude-lower
#>  3:       20096    exclude-lower
#>  4:       20096    exclude-lower
#>  5:       20096    exclude-lower
#>  6:       20181    exclude-lower
#>  7:       20181    exclude-lower
#>  8:       20181          include
#>  9:       20096          include
#> 10:       20096          include
```
