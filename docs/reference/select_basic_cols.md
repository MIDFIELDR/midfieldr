# Choose columns of student records

Subset one of the four MIDFIELD data tables
`{student, term, course, degree}` by selecting the columns required by
other midfieldr functions.

## Usage

``` r
select_basic_cols(dframe, col_pattern = NULL, ..., type = NULL)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble)
  equivalent to or derived from one of the MIDFIELD data tables:
  `{student, term, course, degree}.`

- col_pattern:

  Character vector containing strings or regular expressions to be
  matched or partially matched to the column names of `dframe.`.

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- type:

  Character identifying the table type. Possible values are "s", "t",
  "c", "d", "a", or NULL (default). See Details.

## Value

Data frame with the following properties:

- Data frame class is preserved.

- Rows are not modified.

- Columns are a subset of the input, appearing in the same order.

- Groups and keys are not preserved.

## Details

A convenience function to reduce the dimensions of a MIDFIELD data table
by selecting only those columns required by other midfieldr functions or
that are required to form a composite key. Particularly useful in
interactive sessions when viewing the data tables at various stages of
an analysis.

Several midfieldr functions require input data frames containing
specific variables (column names) such as `mcid` or `cip6`. In addition,
the MIDFIELD data tables have specific variables that act as keys or
composite keys to the information in that table. If the `type` argument
is NULL (default), one of the following codes is assigned to return the
column names indicated (if present):

- `type = "s"` (student) looks for `{mcid, race, sex}`

- `type = "t"` (term) looks for `{mcid, term, cip6, institution, level}`

- `type = "c"` (course) looks for `{mcid, term_course, abbrev, number}`

- `type = "d"` (degree) looks for `{mcid, term_degree, cip6}`

- `type = "a"` looks for all the above columns

Specifying the type `{s, t, c, d, a}` manually in the argument overrides
the automatic selection. Additional column names can be included by
using the `col_pattern` argument. In all cases, unmatched search strings
are silently ignored.

## Examples

``` r
# Basic usage
select_basic_cols(toy_student[1:5])
#>              mcid          race    sex
#>            <char>        <char> <char>
#> 1: MCID3111142897 International   Male
#> 2: MCID3111157634         White Female
#> 3: MCID3111158724         White   Male
#> 4: MCID3111163443         White   Male
#> 5: MCID3111163894         White   Male
select_basic_cols(toy_term[1:5])
#>              mcid   term   cip6   institution          level
#>            <char> <char> <char>        <char>         <char>
#> 1: MCID3111142897  19881 400801 Institution B  01 First-year
#> 2: MCID3111157634  19881 240102 Institution J  01 First-year
#> 3: MCID3111157634  19883 040201 Institution J  01 First-year
#> 4: MCID3111157634  19891 040201 Institution J 02 Second-year
#> 5: MCID3111157634  19893 040201 Institution J 02 Second-year
select_basic_cols(toy_course[1:5])
#>              mcid term_course abbrev number
#>            <char>      <char> <char> <char>
#> 1: MCID3111142897       19881   APAS   3730
#> 2: MCID3111142897       19881   CSCI   1700
#> 3: MCID3111142897       19881   PHYS   7270
#> 4: MCID3111142897       19881   PHYS   7320
#> 5: MCID3111142897       19883   PHYS   5840
select_basic_cols(toy_degree[1:5])
#>              mcid term_degree   cip6
#>            <char>      <char> <char>
#> 1: MCID3111169601       19903 520201
#> 2: MCID3111169729       19901 520201
#> 3: MCID3111213539       19923 030103
#> 4: MCID3111213856       19911 261399
#> 5: MCID3111254225       19923 270101

# With col_pattern for additional columns
DT <- toy_student[141:146]
select_basic_cols(DT, col_pattern = c("transfer", "hours_tranfer"))
#>              mcid          race    sex              transfer hours_transfer
#>            <char>        <char> <char>                <char>          <num>
#> 1: MCID3111913544         White   Male   First-Time Transfer             NA
#> 2: MCID3111913924         White   Male   First-Time Transfer             NA
#> 3: MCID3111940425         Asian Female   First-Time Transfer             NA
#> 4: MCID3111940814 Other/Unknown   Male   First-Time Transfer             19
#> 5: MCID3111941594         White   Male   First-Time Transfer             77
#> 6: MCID3111943900         White Female First-Time in College             NA

# Using regular expressions
these_IDs <- DT$mcid
DT <- toy_term[mcid %chin% these_IDs]
select_basic_cols(DT, col_pattern = c("^gpa"))
#>               mcid   term   cip6   institution          level gpa_term
#>             <char> <char> <char>        <char>         <char>    <num>
#>  1: MCID3111913544  20011 450901 Institution J  01 First-year     3.77
#>  2: MCID3111913544  20013 450901 Institution J  01 First-year     3.31
#>  3: MCID3111913544  20021 450901 Institution J 02 Second-year     3.82
#>  4: MCID3111913544  20023 450901 Institution J 02 Second-year     4.00
#>  5: MCID3111913544  20031 450901 Institution J  03 Third-year     3.90
#>  6: MCID3111913544  20033 450901 Institution J  03 Third-year     4.00
#>  7: MCID3111913544  20043 450901 Institution J  03 Third-year     3.52
#>  8: MCID3111913544  20045 450901 Institution J  03 Third-year     3.70
#>  9: MCID3111913924  20011 260202 Institution J  01 First-year     3.71
#> 10: MCID3111913924  20013 260202 Institution J 02 Second-year     3.50
#> 11: MCID3111913924  20023 260202 Institution J  03 Third-year     3.46
#> 12: MCID3111940425  20011 050103 Institution B  01 First-year     3.21
#> 13: MCID3111940425  20013 050103 Institution B  01 First-year     3.25
#> 14: MCID3111940425  20023 050103 Institution B 02 Second-year     3.44
#> 15: MCID3111940425  20031 050103 Institution B 02 Second-year     3.54
#> 16: MCID3111940814  20011 520201 Institution B  01 First-year     3.22
#> 17: MCID3111940814  20013 520201 Institution B 02 Second-year     2.32
#> 18: MCID3111940814  20021 520201 Institution B 02 Second-year     2.12
#> 19: MCID3111940814  20023 520201 Institution B 02 Second-year     3.00
#> 20: MCID3111940814  20053 520201 Institution B  03 Third-year     3.46
#> 21: MCID3111940814  20054 520201 Institution B  03 Third-year     2.50
#> 22: MCID3111940814  20061 520201 Institution B  03 Third-year     2.57
#> 23: MCID3111941594  20011 040401 Institution B  01 First-year     3.15
#> 24: MCID3111941594  20013 040401 Institution B  01 First-year     3.42
#> 25: MCID3111941594  20021 040401 Institution B  01 First-year     3.50
#> 26: MCID3111941594  20023 040401 Institution B  01 First-year     2.70
#> 27: MCID3111941594  20024 040401 Institution B  01 First-year     3.70
#> 28: MCID3111941594  20031 040401 Institution B 02 Second-year     3.30
#> 29: MCID3111941594  20033 040401 Institution B 02 Second-year     4.00
#> 30: MCID3111941594  20034 040401 Institution B 02 Second-year     2.70
#> 31: MCID3111941594  20041 040401 Institution B 02 Second-year     3.65
#> 32: MCID3111941594  20043 040401 Institution B 02 Second-year     3.33
#> 33: MCID3111941594  20051 040401 Institution B 02 Second-year     4.00
#> 34: MCID3111941594  20053 040401 Institution B  03 Third-year     4.00
#> 35: MCID3111941594  20061 040401 Institution B  03 Third-year     3.53
#> 36: MCID3111941594  20063 040401 Institution B  03 Third-year     3.53
#> 37: MCID3111941594  20071 040401 Institution B  03 Third-year     3.80
#> 38: MCID3111941594  20073 040401 Institution B 04 Fourth-year     4.00
#> 39: MCID3111941594  20081 040401 Institution B 04 Fourth-year     3.53
#> 40: MCID3111943900  20011 240102 Institution C  01 First-year     2.00
#> 41: MCID3111943900  20013 240102 Institution C  01 First-year     1.00
#> 42: MCID3111943900  20033 240102 Institution C  01 First-year     3.00
#> 43: MCID3111943900  20133 230101 Institution C 02 Second-year     2.93
#> 44: MCID3111943900  20141 230101 Institution C 02 Second-year     3.67
#> 45: MCID3111943900  20143 230101 Institution C 02 Second-year     3.53
#> 46: MCID3111943900  20151 230101 Institution C  03 Third-year     3.85
#> 47: MCID3111943900  20153 230101 Institution C  03 Third-year     3.37
#>               mcid   term   cip6   institution          level gpa_term
#>             <char> <char> <char>        <char>         <char>    <num>
#>     gpa_cumul
#>         <num>
#>  1:      3.77
#>  2:      3.54
#>  3:      3.65
#>  4:      3.75
#>  5:      3.77
#>  6:      3.79
#>  7:      3.76
#>  8:      3.76
#>  9:      3.71
#> 10:      3.61
#> 11:      3.52
#> 12:      3.21
#> 13:      3.23
#> 14:      3.30
#> 15:      3.37
#> 16:      3.22
#> 17:      2.77
#> 18:      2.54
#> 19:      2.62
#> 20:      2.80
#> 21:      2.78
#> 22:      2.75
#> 23:      3.15
#> 24:      3.32
#> 25:      3.37
#> 26:      3.29
#> 27:      3.33
#> 28:      3.33
#> 29:      3.38
#> 30:      3.30
#> 31:      3.34
#> 32:      3.34
#> 33:      3.38
#> 34:      3.41
#> 35:      3.42
#> 36:      3.44
#> 37:      3.47
#> 38:      3.52
#> 39:      3.52
#> 40:      2.00
#> 41:      1.80
#> 42:      2.14
#> 43:      2.43
#> 44:      2.69
#> 45:      2.88
#> 46:      3.05
#> 47:      3.13
#>     gpa_cumul
#>         <num>
```
