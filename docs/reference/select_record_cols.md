# Select record columns

Subset a data frame, selecting columns by matching a vector of character
strings. A convenience function to reduce the dimensions of a MIDFIELD
data table by selecting only those columns required by other midfieldr
functions or that are required to form a composite key. Particularly
useful in interactive sessions when viewing the data tables at various
stages of an analysis.

## Usage

``` r
select_record_cols(dframe, type = NULL, ..., col_pattern = NULL)
```

## Arguments

- dframe:

  Data frame of student records from which columns are selected.
  Expected choices are `student`, `term`, `course`, `degree` or their
  equivalent.

- type:

  Character identifying the record type. Possible values are "s", "t",
  "c", "d", or "a". See Details.

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- col_pattern:

  Character vector containing strings or regular expressions to be
  matched or partially matched to the column names of `dframe`.

## Value

A data frame of the same type as `dframe`. The output has the following
properties:

- Rows are not modified.

- Columns are a subset of the input, but appear in the same order.

- Groups are not necessarily preserved.

- Data frame attributes are preserved with the exception of grouped
  tibbles.

## Details

Several midfieldr functions require input data frames containing
specific variables (column names) such as `mcid` or `cip6`. In addition,
the MIDFIELD data tables have specific variables that act as keys or
composite keys to the information in that table. The `type` argument
determines which columns are returned, if those columns exist in
`dframe`:

- `type = "s"` (student table) returns columns `mcid, race, sex`

- `type = "t"` (term table) returns columns
  `mcid, term, cip6, institution, level`

- `type = "c"` (course table) returns columns
  `mcid, term_course, abbrev, number`

- `type = "d"` (degree table) returns columns `mcid, term_degree, cip6`

- `type = "a"` (default) returns all the above

Additional column names can be included by using the `col_pattern`
argument. In all cases, unmatched search strings are silently ignored.

## Examples

``` r
# Basic usage
select_record_cols(toy_student[1:5])
#>              mcid   race    sex   institution
#>            <char> <char> <char>        <char>
#> 1: MCID3111158953  White Female Institution J
#> 2: MCID3111159270  White   Male Institution J
#> 3: MCID3111160513  White   Male Institution J
#> 4: MCID3111162677  White Female Institution J
#> 5: MCID3111164287  White   Male Institution J
select_record_cols(toy_term[1:5])
#>              mcid   term   cip6   institution          level
#>            <char> <char> <char>        <char>         <char>
#> 1: MCID3111158953  19881 240102 Institution J  01 First-year
#> 2: MCID3111158953  19883 240102 Institution J  01 First-year
#> 3: MCID3111158953  19891 240102 Institution J 02 Second-year
#> 4: MCID3111158953  19893 240102 Institution J 02 Second-year
#> 5: MCID3111158953  19901 240102 Institution J  03 Third-year
select_record_cols(toy_course[1:5])
#>              mcid term_course abbrev number   institution
#>            <char>      <char> <char> <char>        <char>
#> 1: MCID3111158953       19881   EDCI   2984 Institution J
#> 2: MCID3111158953       19881   MATH   1215 Institution J
#> 3: MCID3111158953       19881     MN   1004 Institution J
#> 4: MCID3111158953       19881   CHEM   1035 Institution J
#> 5: MCID3111158953       19881   CHEM   1045 Institution J
select_record_cols(toy_degree[1:5])
#>              mcid term_degree   cip6   institution
#>            <char>      <char> <char>        <char>
#> 1: MCID3111159270       19913 141001 Institution J
#> 2: MCID3111162677       19913 140701 Institution J
#> 3: MCID3111164287       19913 141001 Institution J
#> 4: MCID3111171205       19913 270101 Institution B
#> 5: MCID3111172083       19913 520201 Institution B

# Return columns by record type
select_record_cols(toy_student[1:5], type = "s")
#>              mcid   race    sex
#>            <char> <char> <char>
#> 1: MCID3111158953  White Female
#> 2: MCID3111159270  White   Male
#> 3: MCID3111160513  White   Male
#> 4: MCID3111162677  White Female
#> 5: MCID3111164287  White   Male
select_record_cols(toy_term[1:5], "t")
#>              mcid   term   cip6   institution          level
#>            <char> <char> <char>        <char>         <char>
#> 1: MCID3111158953  19881 240102 Institution J  01 First-year
#> 2: MCID3111158953  19883 240102 Institution J  01 First-year
#> 3: MCID3111158953  19891 240102 Institution J 02 Second-year
#> 4: MCID3111158953  19893 240102 Institution J 02 Second-year
#> 5: MCID3111158953  19901 240102 Institution J  03 Third-year
select_record_cols(toy_course[1:5], "c")
#>              mcid term_course abbrev number
#>            <char>      <char> <char> <char>
#> 1: MCID3111158953       19881   EDCI   2984
#> 2: MCID3111158953       19881   MATH   1215
#> 3: MCID3111158953       19881     MN   1004
#> 4: MCID3111158953       19881   CHEM   1035
#> 5: MCID3111158953       19881   CHEM   1045
select_record_cols(toy_degree[1:5], "d")
#>              mcid term_degree   cip6
#>            <char>      <char> <char>
#> 1: MCID3111159270       19913 141001
#> 2: MCID3111162677       19913 140701
#> 3: MCID3111164287       19913 141001
#> 4: MCID3111171205       19913 270101
#> 5: MCID3111172083       19913 520201

# With col_patterns for additional columns
DT <- toy_student[141:146]
select_record_cols(DT, "t", col_pattern = c("transfer", "hours_tranfer"))
#>              mcid   institution              transfer hours_transfer
#>            <char>        <char>                <char>          <num>
#> 1: MCID3112802165 Institution B First-Time in College             NA
#> 2: MCID3112803670 Institution B First-Time in College             NA
#> 3: MCID3112804805 Institution B First-Time in College             NA
#> 4: MCID3112839822 Institution B   First-Time Transfer             NA
#> 5: MCID3112845932 Institution B First-Time in College             NA
#> 6: MCID3112846308 Institution B First-Time in College             NA

# Using regular expressions
these_IDs <- DT$mcid
DT <- toy_term[mcid %chin% these_IDs]
select_record_cols(DT, "t", col_pattern = c("^gpa"))
#>               mcid   term   cip6   institution          level gpa_term
#>             <char> <char> <char>        <char>         <char>    <num>
#>  1: MCID3112802165  20161 500702 Institution B  01 First-year     3.88
#>  2: MCID3112802165  20163 500702 Institution B 02 Second-year     3.68
#>  3: MCID3112802165  20171 500601 Institution B 02 Second-year     3.80
#>  4: MCID3112802165  20173 500601 Institution B  03 Third-year     3.57
#>  5: MCID3112802165  20181 500702 Institution B  03 Third-year     3.88
#>  6: MCID3112803670  20161 240199 Institution B  01 First-year     3.63
#>  7: MCID3112804805  20161 240199 Institution B  01 First-year     2.31
#>  8: MCID3112804805  20171 240199 Institution B 02 Second-year     3.70
#>  9: MCID3112804805  20173 030103 Institution B 02 Second-year     3.27
#> 10: MCID3112804805  20181 030103 Institution B 02 Second-year     3.00
#> 11: MCID3112839822  20171 400501 Institution B  01 First-year     2.75
#> 12: MCID3112845932  20173 240199 Institution B  01 First-year     3.12
#> 13: MCID3112845932  20181 110701 Institution B 02 Second-year     3.44
#> 14: MCID3112846308  20171 260202 Institution B  01 First-year     3.49
#> 15: MCID3112846308  20173 510201 Institution B  01 First-year     3.68
#> 16: MCID3112846308  20181 510201 Institution B 02 Second-year     3.81
#>     gpa_cumul
#>         <num>
#>  1:      3.88
#>  2:      3.78
#>  3:      3.79
#>  4:      3.73
#>  5:      3.76
#>  6:      3.63
#>  7:      2.31
#>  8:      2.89
#>  9:      3.01
#> 10:      3.01
#> 11:      2.75
#> 12:      2.89
#> 13:      3.08
#> 14:      3.49
#> 15:      3.58
#> 16:      3.67
```
