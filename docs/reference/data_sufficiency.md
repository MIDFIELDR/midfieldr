# Determine data sufficiency

To a data frame keyed by student ID, add a column indicating that an
institution's data range is sufficient to reliably assess a student's
program completion. Columns of supporting information are also added.
Unrelated columns are dropped.

## Usage

``` r
data_sufficiency(dframe, midfield_rec = term)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble).
  Required variables: `{mcid, term_i, timely_term}`.

- midfield_rec:

  MIDFIELD records *term* data frame or data frame extension. Required
  variables: `{mcid, term, institution}`.

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Rows are filtered for unique `mcid` values.

- Columns `{mcid, term_i, timely_term}` are retained (all other columns
  are dropped). New columns added:

  - `institution.`   Character. Institution in which the student is
    enrolled in the given term. Extracted from `midfield_rec.` The
    limits given in the next two columns are specific to the
    institution.

  - `lower_limit.`   Character. Initial term of an institution's data
    range, encoded `YYYYT`. Extracted from `midfield_rec.` Compared to
    `term_i` to determine the lower-limit exclusion.

  - `upper_limit.`   Character. Final term of an institution's data
    range, encoded `YYYYT`. Extracted from `midfield_rec.` Compared to
    `timely_term` to determine upper-limit exclusion.

  - `data_sufficiency.`   Character. Possible values are "include", if
    the data are sufficient; and "exclude-lower" or "exclude-upper" if
    not, indicating at which boundary of the data range the ambiguity
    occurs.

## Details

Because the time span of MIDFIELD term data varies by institution, each
has their own lower and upper bounds. When assessing a student's program
completion, an unavoidable ambiguity arises for student records at or
near these bounds. Such records must be identified and in most cases
excluded to prevent false summary counts.

The *data sufficiency* criterion states that student records are limited
to those for which available data are sufficient to assess timely
completion without biased counts of completers or non-completers. In
practice, the criteria is implemented via two filters. Rows are labeled
for exclusion when: 1) a student ID is extant in the non-summer lower
limit of an institution's data range; or 2) a student ID has a timely
completion term that exceeds the upper limit of the institution's data
range.

The goal of determining data sufficiency is to refine a population, that
is, obtain a data frame of IDs that satisfy our constraints. Thus
`data_sufficiency()` yields a column of data sufficiency values and
columns of supporting information keyed by ID. All other columns in
`dframe` (if any) are dropped.

The supporting information in the output is provided so that the user
can review the findings. After review, we usually delete all columns
except the IDs, yielding the refined population that was our goal.

## Examples

``` r
# Start with an excerpt from the student data set 
dframe <- toy_student[1:10, .(mcid)]

# Timely term column is required to add data sufficiency column
dframe <- timely_term(dframe, toy_term)

# Add data sufficiency column
data_sufficiency(dframe, toy_term)
#>               mcid term_i timely_term   institution lower_limit upper_limit
#>             <char> <char>      <char>        <char>      <char>      <char>
#>  1: MCID3111158953  19881       19933 Institution J       19881       20096
#>  2: MCID3111158953  19881       19933 Institution J       19881       20096
#>  3: MCID3111158953  19881       19933 Institution J       19881       20096
#>  4: MCID3111158953  19881       19933 Institution J       19881       20096
#>  5: MCID3111158953  19881       19933 Institution J       19881       20096
#>  6: MCID3111158953  19881       19933 Institution J       19881       20096
#>  7: MCID3111158953  19881       19933 Institution J       19881       20096
#>  8: MCID3111158953  19881       19933 Institution J       19881       20096
#>  9: MCID3111158953  19881       19933 Institution J       19881       20096
#> 10: MCID3111158953  19881       19933 Institution J       19881       20096
#> 11: MCID3111159270  19881       19933 Institution J       19881       20096
#> 12: MCID3111159270  19881       19933 Institution J       19881       20096
#> 13: MCID3111159270  19881       19933 Institution J       19881       20096
#> 14: MCID3111159270  19881       19933 Institution J       19881       20096
#> 15: MCID3111159270  19881       19933 Institution J       19881       20096
#> 16: MCID3111159270  19881       19933 Institution J       19881       20096
#> 17: MCID3111159270  19881       19933 Institution J       19881       20096
#> 18: MCID3111159270  19881       19933 Institution J       19881       20096
#> 19: MCID3111160513  19881       19933 Institution J       19881       20096
#> 20: MCID3111160513  19881       19933 Institution J       19881       20096
#> 21: MCID3111160513  19881       19933 Institution J       19881       20096
#> 22: MCID3111160513  19881       19933 Institution J       19881       20096
#> 23: MCID3111160513  19881       19933 Institution J       19881       20096
#> 24: MCID3111160513  19881       19933 Institution J       19881       20096
#> 25: MCID3111160513  19881       19933 Institution J       19881       20096
#> 26: MCID3111160513  19881       19933 Institution J       19881       20096
#> 27: MCID3111160513  19881       19933 Institution J       19881       20096
#> 28: MCID3111160513  19881       19933 Institution J       19881       20096
#> 29: MCID3111162677  19881       19933 Institution J       19881       20096
#> 30: MCID3111162677  19881       19933 Institution J       19881       20096
#> 31: MCID3111162677  19881       19933 Institution J       19881       20096
#> 32: MCID3111162677  19881       19933 Institution J       19881       20096
#> 33: MCID3111162677  19881       19933 Institution J       19881       20096
#> 34: MCID3111162677  19881       19933 Institution J       19881       20096
#> 35: MCID3111162677  19881       19933 Institution J       19881       20096
#> 36: MCID3111162677  19881       19933 Institution J       19881       20096
#> 37: MCID3111162677  19881       19933 Institution J       19881       20096
#> 38: MCID3111162677  19881       19933 Institution J       19881       20096
#> 39: MCID3111164287  19881       19933 Institution J       19881       20096
#> 40: MCID3111164287  19881       19933 Institution J       19881       20096
#> 41: MCID3111164287  19881       19933 Institution J       19881       20096
#> 42: MCID3111164287  19881       19933 Institution J       19881       20096
#> 43: MCID3111164287  19881       19933 Institution J       19881       20096
#> 44: MCID3111164287  19881       19933 Institution J       19881       20096
#> 45: MCID3111164287  19881       19933 Institution J       19881       20096
#> 46: MCID3111171205  19881       19933 Institution B       19881       20181
#> 47: MCID3111171205  19881       19933 Institution B       19881       20181
#> 48: MCID3111171205  19881       19933 Institution B       19881       20181
#> 49: MCID3111171205  19881       19933 Institution B       19881       20181
#> 50: MCID3111171205  19881       19933 Institution B       19881       20181
#> 51: MCID3111171205  19881       19933 Institution B       19881       20181
#> 52: MCID3111171205  19881       19933 Institution B       19881       20181
#> 53: MCID3111171205  19881       19933 Institution B       19881       20181
#> 54: MCID3111172083  19881       19933 Institution B       19881       20181
#> 55: MCID3111172083  19881       19933 Institution B       19881       20181
#> 56: MCID3111172083  19881       19933 Institution B       19881       20181
#> 57: MCID3111172083  19881       19933 Institution B       19881       20181
#> 58: MCID3111172083  19881       19933 Institution B       19881       20181
#> 59: MCID3111172083  19881       19933 Institution B       19881       20181
#> 60: MCID3111172083  19881       19933 Institution B       19881       20181
#> 61: MCID3111172083  19881       19933 Institution B       19881       20181
#> 62: MCID3111213943  19891       19943 Institution B       19881       20181
#> 63: MCID3111213943  19891       19943 Institution B       19881       20181
#> 64: MCID3111213943  19891       19943 Institution B       19881       20181
#> 65: MCID3111213943  19891       19943 Institution B       19881       20181
#> 66: MCID3111248941  19901       19953 Institution J       19881       20096
#> 67: MCID3111248941  19901       19953 Institution J       19881       20096
#> 68: MCID3111248941  19901       19953 Institution J       19881       20096
#> 69: MCID3111248941  19901       19953 Institution J       19881       20096
#> 70: MCID3111248941  19901       19953 Institution J       19881       20096
#> 71: MCID3111248941  19901       19953 Institution J       19881       20096
#> 72: MCID3111248941  19901       19953 Institution J       19881       20096
#> 73: MCID3111248941  19901       19953 Institution J       19881       20096
#> 74: MCID3111248941  19901       19953 Institution J       19881       20096
#> 75: MCID3111248941  19901       19953 Institution J       19881       20096
#> 76: MCID3111248941  19901       19953 Institution J       19881       20096
#> 77: MCID3111250695  19901       19953 Institution J       19881       20096
#> 78: MCID3111250695  19901       19953 Institution J       19881       20096
#> 79: MCID3111250695  19901       19953 Institution J       19881       20096
#>               mcid term_i timely_term   institution lower_limit upper_limit
#>             <char> <char>      <char>        <char>      <char>      <char>
#>     data_sufficiency
#>               <char>
#>  1:    exclude-lower
#>  2:    exclude-lower
#>  3:    exclude-lower
#>  4:    exclude-lower
#>  5:    exclude-lower
#>  6:    exclude-lower
#>  7:    exclude-lower
#>  8:    exclude-lower
#>  9:    exclude-lower
#> 10:    exclude-lower
#> 11:    exclude-lower
#> 12:    exclude-lower
#> 13:    exclude-lower
#> 14:    exclude-lower
#> 15:    exclude-lower
#> 16:    exclude-lower
#> 17:    exclude-lower
#> 18:    exclude-lower
#> 19:    exclude-lower
#> 20:    exclude-lower
#> 21:    exclude-lower
#> 22:    exclude-lower
#> 23:    exclude-lower
#> 24:    exclude-lower
#> 25:    exclude-lower
#> 26:    exclude-lower
#> 27:    exclude-lower
#> 28:    exclude-lower
#> 29:    exclude-lower
#> 30:    exclude-lower
#> 31:    exclude-lower
#> 32:    exclude-lower
#> 33:    exclude-lower
#> 34:    exclude-lower
#> 35:    exclude-lower
#> 36:    exclude-lower
#> 37:    exclude-lower
#> 38:    exclude-lower
#> 39:    exclude-lower
#> 40:    exclude-lower
#> 41:    exclude-lower
#> 42:    exclude-lower
#> 43:    exclude-lower
#> 44:    exclude-lower
#> 45:    exclude-lower
#> 46:    exclude-lower
#> 47:    exclude-lower
#> 48:    exclude-lower
#> 49:    exclude-lower
#> 50:    exclude-lower
#> 51:    exclude-lower
#> 52:    exclude-lower
#> 53:    exclude-lower
#> 54:    exclude-lower
#> 55:    exclude-lower
#> 56:    exclude-lower
#> 57:    exclude-lower
#> 58:    exclude-lower
#> 59:    exclude-lower
#> 60:    exclude-lower
#> 61:    exclude-lower
#> 62:          include
#> 63:          include
#> 64:          include
#> 65:          include
#> 66:          include
#> 67:          include
#> 68:          include
#> 69:          include
#> 70:          include
#> 71:          include
#> 72:          include
#> 73:          include
#> 74:          include
#> 75:          include
#> 76:          include
#> 77:          include
#> 78:          include
#> 79:          include
#>     data_sufficiency
#>               <char>

# Existing data_sufficiency column, if any, is replaced
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
data_sufficiency(dframe, toy_term)
#>               mcid term_i timely_term   institution lower_limit upper_limit
#>             <char> <char>      <char>        <char>      <char>      <char>
#>  1: MCID3111158953  19881       19933 Institution J       19881       20096
#>  2: MCID3111158953  19881       19933 Institution J       19881       20096
#>  3: MCID3111158953  19881       19933 Institution J       19881       20096
#>  4: MCID3111158953  19881       19933 Institution J       19881       20096
#>  5: MCID3111158953  19881       19933 Institution J       19881       20096
#>  6: MCID3111158953  19881       19933 Institution J       19881       20096
#>  7: MCID3111158953  19881       19933 Institution J       19881       20096
#>  8: MCID3111158953  19881       19933 Institution J       19881       20096
#>  9: MCID3111158953  19881       19933 Institution J       19881       20096
#> 10: MCID3111158953  19881       19933 Institution J       19881       20096
#> 11: MCID3111159270  19881       19933 Institution J       19881       20096
#> 12: MCID3111159270  19881       19933 Institution J       19881       20096
#> 13: MCID3111159270  19881       19933 Institution J       19881       20096
#> 14: MCID3111159270  19881       19933 Institution J       19881       20096
#> 15: MCID3111159270  19881       19933 Institution J       19881       20096
#> 16: MCID3111159270  19881       19933 Institution J       19881       20096
#> 17: MCID3111159270  19881       19933 Institution J       19881       20096
#> 18: MCID3111159270  19881       19933 Institution J       19881       20096
#> 19: MCID3111160513  19881       19933 Institution J       19881       20096
#> 20: MCID3111160513  19881       19933 Institution J       19881       20096
#> 21: MCID3111160513  19881       19933 Institution J       19881       20096
#> 22: MCID3111160513  19881       19933 Institution J       19881       20096
#> 23: MCID3111160513  19881       19933 Institution J       19881       20096
#> 24: MCID3111160513  19881       19933 Institution J       19881       20096
#> 25: MCID3111160513  19881       19933 Institution J       19881       20096
#> 26: MCID3111160513  19881       19933 Institution J       19881       20096
#> 27: MCID3111160513  19881       19933 Institution J       19881       20096
#> 28: MCID3111160513  19881       19933 Institution J       19881       20096
#> 29: MCID3111162677  19881       19933 Institution J       19881       20096
#> 30: MCID3111162677  19881       19933 Institution J       19881       20096
#> 31: MCID3111162677  19881       19933 Institution J       19881       20096
#> 32: MCID3111162677  19881       19933 Institution J       19881       20096
#> 33: MCID3111162677  19881       19933 Institution J       19881       20096
#> 34: MCID3111162677  19881       19933 Institution J       19881       20096
#> 35: MCID3111162677  19881       19933 Institution J       19881       20096
#> 36: MCID3111162677  19881       19933 Institution J       19881       20096
#> 37: MCID3111162677  19881       19933 Institution J       19881       20096
#> 38: MCID3111162677  19881       19933 Institution J       19881       20096
#> 39: MCID3111164287  19881       19933 Institution J       19881       20096
#> 40: MCID3111164287  19881       19933 Institution J       19881       20096
#> 41: MCID3111164287  19881       19933 Institution J       19881       20096
#> 42: MCID3111164287  19881       19933 Institution J       19881       20096
#> 43: MCID3111164287  19881       19933 Institution J       19881       20096
#> 44: MCID3111164287  19881       19933 Institution J       19881       20096
#> 45: MCID3111164287  19881       19933 Institution J       19881       20096
#> 46: MCID3111171205  19881       19933 Institution B       19881       20181
#> 47: MCID3111171205  19881       19933 Institution B       19881       20181
#> 48: MCID3111171205  19881       19933 Institution B       19881       20181
#> 49: MCID3111171205  19881       19933 Institution B       19881       20181
#> 50: MCID3111171205  19881       19933 Institution B       19881       20181
#> 51: MCID3111171205  19881       19933 Institution B       19881       20181
#> 52: MCID3111171205  19881       19933 Institution B       19881       20181
#> 53: MCID3111171205  19881       19933 Institution B       19881       20181
#> 54: MCID3111172083  19881       19933 Institution B       19881       20181
#> 55: MCID3111172083  19881       19933 Institution B       19881       20181
#> 56: MCID3111172083  19881       19933 Institution B       19881       20181
#> 57: MCID3111172083  19881       19933 Institution B       19881       20181
#> 58: MCID3111172083  19881       19933 Institution B       19881       20181
#> 59: MCID3111172083  19881       19933 Institution B       19881       20181
#> 60: MCID3111172083  19881       19933 Institution B       19881       20181
#> 61: MCID3111172083  19881       19933 Institution B       19881       20181
#> 62: MCID3111213943  19891       19943 Institution B       19881       20181
#> 63: MCID3111213943  19891       19943 Institution B       19881       20181
#> 64: MCID3111213943  19891       19943 Institution B       19881       20181
#> 65: MCID3111213943  19891       19943 Institution B       19881       20181
#> 66: MCID3111248941  19901       19953 Institution J       19881       20096
#> 67: MCID3111248941  19901       19953 Institution J       19881       20096
#> 68: MCID3111248941  19901       19953 Institution J       19881       20096
#> 69: MCID3111248941  19901       19953 Institution J       19881       20096
#> 70: MCID3111248941  19901       19953 Institution J       19881       20096
#> 71: MCID3111248941  19901       19953 Institution J       19881       20096
#> 72: MCID3111248941  19901       19953 Institution J       19881       20096
#> 73: MCID3111248941  19901       19953 Institution J       19881       20096
#> 74: MCID3111248941  19901       19953 Institution J       19881       20096
#> 75: MCID3111248941  19901       19953 Institution J       19881       20096
#> 76: MCID3111248941  19901       19953 Institution J       19881       20096
#> 77: MCID3111250695  19901       19953 Institution J       19881       20096
#> 78: MCID3111250695  19901       19953 Institution J       19881       20096
#> 79: MCID3111250695  19901       19953 Institution J       19881       20096
#>               mcid term_i timely_term   institution lower_limit upper_limit
#>             <char> <char>      <char>        <char>      <char>      <char>
#>     data_sufficiency
#>               <char>
#>  1:    exclude-lower
#>  2:    exclude-lower
#>  3:    exclude-lower
#>  4:    exclude-lower
#>  5:    exclude-lower
#>  6:    exclude-lower
#>  7:    exclude-lower
#>  8:    exclude-lower
#>  9:    exclude-lower
#> 10:    exclude-lower
#> 11:    exclude-lower
#> 12:    exclude-lower
#> 13:    exclude-lower
#> 14:    exclude-lower
#> 15:    exclude-lower
#> 16:    exclude-lower
#> 17:    exclude-lower
#> 18:    exclude-lower
#> 19:    exclude-lower
#> 20:    exclude-lower
#> 21:    exclude-lower
#> 22:    exclude-lower
#> 23:    exclude-lower
#> 24:    exclude-lower
#> 25:    exclude-lower
#> 26:    exclude-lower
#> 27:    exclude-lower
#> 28:    exclude-lower
#> 29:    exclude-lower
#> 30:    exclude-lower
#> 31:    exclude-lower
#> 32:    exclude-lower
#> 33:    exclude-lower
#> 34:    exclude-lower
#> 35:    exclude-lower
#> 36:    exclude-lower
#> 37:    exclude-lower
#> 38:    exclude-lower
#> 39:    exclude-lower
#> 40:    exclude-lower
#> 41:    exclude-lower
#> 42:    exclude-lower
#> 43:    exclude-lower
#> 44:    exclude-lower
#> 45:    exclude-lower
#> 46:    exclude-lower
#> 47:    exclude-lower
#> 48:    exclude-lower
#> 49:    exclude-lower
#> 50:    exclude-lower
#> 51:    exclude-lower
#> 52:    exclude-lower
#> 53:    exclude-lower
#> 54:    exclude-lower
#> 55:    exclude-lower
#> 56:    exclude-lower
#> 57:    exclude-lower
#> 58:    exclude-lower
#> 59:    exclude-lower
#> 60:    exclude-lower
#> 61:    exclude-lower
#> 62:          include
#> 63:          include
#> 64:          include
#> 65:          include
#> 66:          include
#> 67:          include
#> 68:          include
#> 69:          include
#> 70:          include
#> 71:          include
#> 72:          include
#> 73:          include
#> 74:          include
#> 75:          include
#> 76:          include
#> 77:          include
#> 78:          include
#> 79:          include
#>     data_sufficiency
#>               <char>
```
