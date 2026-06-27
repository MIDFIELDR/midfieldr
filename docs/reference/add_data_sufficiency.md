# Determine data sufficiency for every student

Add columns to a data frame of student-level records that indicate
whether an observation should be included or excluded based on
sufficient information from the institution. Because the time span of
MIDFIELD term data varies by institution, each has their own lower and
upper bounds. For some student records, being at or near these bounds
creates unavoidable ambiguity when trying to assess degree completion.
Such records must be identified and in most cases excluded to prevent
false summary counts.

## Usage

``` r
add_data_sufficiency(dframe, midfield_term = term)
```

## Arguments

- dframe:

  Working data frame of student-level records to which data-sufficiency
  columns are to be added. Required variables are `mcid` and
  `timely_term`.

- midfield_term:

  MIDFIELD `term` data table or equivalent with required variables
  `mcid`, `institution`, and `term`.

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

The data sufficiency criterion states that student records are limited
to those for which available data are sufficient to assess timely
completion without biased counts of completers or non-completers. In
practice, the criteria is implemented via two filters. Rows are labeled
for exclusion when: 1) a student ID is extant in the non-summer lower
limit of an institution's data range; or 2) a student ID has a timely
completion term that exceeds the upper limit of the institution's data
range.

The new columns are:

- `term_i` Initial term of a student's longitudinal record, encoded
  `YYYYT`. Extracted from `term`.

- `lower_limit` Character. Initial term of an institution's data range,
  encoded `YYYYT`. Extracted from `term`.

- `upper_limit` Character. Final term of an institution's data range,
  encoded `YYYYT`. Extracted from `term`.

- `data_sufficiency` Character. Possible values are "include",
  "exclude_lower", and "exclude-upper". A row is labeled "include" if
  the data are sufficient; and "exclude-lower" or "exclude-upper" if
  not, indicating at which boundary of the data range the ambiguity
  occurs.

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
