# Select basic columns of student-level records

Subset a data frame, selecting columns by matching a vector of character
strings. A convenience function to reduce the dimensions of a MIDFIELD
data table by selecting only those columns required by other midfieldr
functions or that are required to form a composite key. Particularly
useful in interactive sessions when viewing the data tables at various
stages of an analysis.

## Usage

``` r
select_basic_cols(dframe, ..., patternv = NULL)
```

## Arguments

- dframe:

  Data frame from which columns are selected.

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- patternv:

  Character vector of additional search terms. Can include regular
  expressions.

## Value

A subset of `dframe` with the following properties: rows are preserved;
columns are selected that exactly match the built-in set of column names
or that partially match any search strings in `patternv`. Grouping
structures are not necessarily preserved.

An attempt is made to return data frames of the same class as the input,
so a data.table input should produce a data.table output, a tibble input
should produce a tibble output, etc. Grouped tibbles, however, are
returned as data.frames. To help ensure a tibble output, try ungrouping
a tibble before using it as an input argument.

## Details

Several midfieldr functions require that their input data frames contain
specific variables (column names) such as `mcid` or `cip6`. In addition,
the MIDFIELD data tables have specific variables that act as keys or
composite keys to the information in that table. All such are assembled
in a character vector that comprises the default set of column names
returned by `select_basic_cols()`. The default column set is
`c(mcid, institution, race, sex, term, term_course, term_degree, cip6, level, abbrev, number)`.

The column names of `dframe` are searched for exact matches to the
default set of names. Additional column names can be included by using
the `patternv` argument—a vector of search terms for matches or partial
matches to the patterns. Regular expressions are permitted. Column names
and search terms not found are silently ignored.

## Examples

``` r
# Basic usage
select_basic_cols(toy_student[1:5])
#>              mcid   institution   race    sex
#>            <char>        <char> <char> <char>
#> 1: MCID3111158953 Institution J  White Female
#> 2: MCID3111159270 Institution J  White   Male
#> 3: MCID3111160513 Institution J  White   Male
#> 4: MCID3111162677 Institution J  White Female
#> 5: MCID3111164287 Institution J  White   Male
select_basic_cols(toy_course[1:5])
#>              mcid   institution term_course abbrev number
#>            <char>        <char>      <char> <char> <char>
#> 1: MCID3111158953 Institution J       19881   EDCI   2984
#> 2: MCID3111158953 Institution J       19881   MATH   1215
#> 3: MCID3111158953 Institution J       19881     MN   1004
#> 4: MCID3111158953 Institution J       19881   CHEM   1035
#> 5: MCID3111158953 Institution J       19881   CHEM   1045
select_basic_cols(toy_term[1:5])
#>              mcid   institution   term   cip6          level
#>            <char>        <char> <char> <char>         <char>
#> 1: MCID3111158953 Institution J  19881 240102  01 First-year
#> 2: MCID3111158953 Institution J  19883 240102  01 First-year
#> 3: MCID3111158953 Institution J  19891 240102 02 Second-year
#> 4: MCID3111158953 Institution J  19893 240102 02 Second-year
#> 5: MCID3111158953 Institution J  19901 240102  03 Third-year
select_basic_cols(toy_degree[1:5])
#>              mcid   institution term_degree   cip6
#>            <char>        <char>      <char> <char>
#> 1: MCID3111159270 Institution J       19913 141001
#> 2: MCID3111162677 Institution J       19913 140701
#> 3: MCID3111164287 Institution J       19913 141001
#> 4: MCID3111171205 Institution B       19913 270101
#> 5: MCID3111172083 Institution B       19913 520201

# With patterns for additional columns
DT <- toy_student[141:146]
select_basic_cols(DT, patternv = c("transfer", "hours_tranfer"))
#>              mcid   institution          race    sex              transfer
#>            <char>        <char>        <char> <char>                <char>
#> 1: MCID3112802165 Institution B      Hispanic   Male First-Time in College
#> 2: MCID3112803670 Institution B         White   Male First-Time in College
#> 3: MCID3112804805 Institution B         White   Male First-Time in College
#> 4: MCID3112839822 Institution B International   Male   First-Time Transfer
#> 5: MCID3112845932 Institution B         Asian   Male First-Time in College
#> 6: MCID3112846308 Institution B      Hispanic Female First-Time in College
#>    hours_transfer
#>             <num>
#> 1:             NA
#> 2:             NA
#> 3:             NA
#> 4:             NA
#> 5:             NA
#> 6:             NA

# Using regular expressions
these_IDs <- DT$mcid
DT <- toy_term[mcid %chin% these_IDs]
select_basic_cols(DT, patternv = c("^gpa"))
#>               mcid   institution   term   cip6          level gpa_term
#>             <char>        <char> <char> <char>         <char>    <num>
#>  1: MCID3112802165 Institution B  20161 500702  01 First-year     3.88
#>  2: MCID3112802165 Institution B  20163 500702 02 Second-year     3.68
#>  3: MCID3112802165 Institution B  20171 500601 02 Second-year     3.80
#>  4: MCID3112802165 Institution B  20173 500601  03 Third-year     3.57
#>  5: MCID3112802165 Institution B  20181 500702  03 Third-year     3.88
#>  6: MCID3112803670 Institution B  20161 240199  01 First-year     3.63
#>  7: MCID3112804805 Institution B  20161 240199  01 First-year     2.31
#>  8: MCID3112804805 Institution B  20171 240199 02 Second-year     3.70
#>  9: MCID3112804805 Institution B  20173 030103 02 Second-year     3.27
#> 10: MCID3112804805 Institution B  20181 030103 02 Second-year     3.00
#> 11: MCID3112839822 Institution B  20171 400501  01 First-year     2.75
#> 12: MCID3112845932 Institution B  20173 240199  01 First-year     3.12
#> 13: MCID3112845932 Institution B  20181 110701 02 Second-year     3.44
#> 14: MCID3112846308 Institution B  20171 260202  01 First-year     3.49
#> 15: MCID3112846308 Institution B  20173 510201  01 First-year     3.68
#> 16: MCID3112846308 Institution B  20181 510201 02 Second-year     3.81
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
