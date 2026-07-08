# Determine completion status

For each student in a data frame, determine their *completion status*
(timely, late, or NA) and add columns that support the findings.

## Usage

``` r
completion_status(dframe, midfield_table = degree)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble) with
  required variables `{mcid, timely_term}.` The latter variable is
  provided by `timely_term().`

- midfield_table:

  `degree` data frame with required variables `{mcid, term_degree}.`

## Value

Data frame with the following properties:

- Data frame class is preserved.

- Rows are not modified except duplicated rows are removed. Row order is
  preserved.

- Columns `{mcid, timely_term}` are retained. All other columns (if any)
  are dropped and the following variables are added:

  - `term_degree.`   Character. Term in which the first degree(s) are
    completed, encoded `YYYYT`. Joined from `midfield_table.`

  - `completion_status.`   Character. Possible values are "timely",
    "late" and "NA".

- Groups and keys are not preserved.

## Details

By *completing a program* we mean an undergraduate earning their first
baccalaureate degree or degrees. *Timely* completion is typically 4, 6,
or 8 years after admission depending on the definition adopted in a
particular study. The term at the upper limit of that span is the
*timely completion term.*

Our heuristic obtains a student's first degree term (if any) from
`midfield_table`. Completion status is "timely" for students completing
a degree no later than their timely completion terms; "late" for
students completing their program after their timely completion term;
and "NA" for non-completers. These results are documented in the output.

## Examples

``` r
term <- toy_term
degree <- toy_degree

# Start with a small population 
x <- toy_student[21:36, .(mcid)]
x
#>               mcid
#>             <char>
#>  1: MCID3111257807
#>  2: MCID3111258275
#>  3: MCID3111258347
#>  4: MCID3111259642
#>  5: MCID3111262210
#>  6: MCID3111265287
#>  7: MCID3111269576
#>  8: MCID3111272691
#>  9: MCID3111272880
#> 10: MCID3111277081
#> 11: MCID3111278815
#> 12: MCID3111282337
#> 13: MCID3111296595
#> 14: MCID3111301718
#> 15: MCID3111310842
#> 16: MCID3111311799

# Timely term column is required
x <- timely_term(x, term)
x
#>               mcid term_i       level_i adj_span timely_term
#>             <char> <char>        <char>    <num>      <char>
#>  1: MCID3111257807  19901 01 First-year        6       19953
#>  2: MCID3111258275  19901 01 First-year        6       19953
#>  3: MCID3111258347  19901 01 First-year        6       19953
#>  4: MCID3111259642  19901 01 First-year        6       19953
#>  5: MCID3111262210  19901 01 First-year        6       19953
#>  6: MCID3111265287  19901 01 First-year        6       19953
#>  7: MCID3111269576  19901 01 First-year        6       19953
#>  8: MCID3111272691  19901 01 First-year        6       19953
#>  9: MCID3111272880  19901 01 First-year        6       19953
#> 10: MCID3111277081  19903 01 First-year        6       19961
#> 11: MCID3111278815  19903 01 First-year        6       19961
#> 12: MCID3111282337  19904 01 First-year        6       19963
#> 13: MCID3111296595  19911 01 First-year        6       19963
#> 14: MCID3111301718  19911 01 First-year        6       19963
#> 15: MCID3111310842  19911 01 First-year        6       19963
#> 16: MCID3111311799  19911 01 First-year        6       19963

# Add completion status column, columns not used are dropped
x <- completion_status(x, degree)
x
#>               mcid timely_term term_degree completion_status
#>             <char>      <char>      <char>            <char>
#>  1: MCID3111257807       19953       19964              late
#>  2: MCID3111258275       19953       19921            timely
#>  3: MCID3111258347       19953       19923            timely
#>  4: MCID3111259642       19953       19934            timely
#>  5: MCID3111262210       19953       19951            timely
#>  6: MCID3111265287       19953       19904            timely
#>  7: MCID3111269576       19953       19943            timely
#>  8: MCID3111272691       19953       19914            timely
#>  9: MCID3111272880       19953       19934            timely
#> 10: MCID3111277081       19961       19963              late
#> 11: MCID3111278815       19961        <NA>              <NA>
#> 12: MCID3111282337       19963       19924            timely
#> 13: MCID3111296595       19963        <NA>              <NA>
#> 14: MCID3111301718       19963        <NA>              <NA>
#> 15: MCID3111310842       19963        <NA>              <NA>
#> 16: MCID3111311799       19963        <NA>              <NA>

# Existing completion status column (if any) is replaced
x[, completion_status := NA_character_][]
#>               mcid timely_term term_degree completion_status
#>             <char>      <char>      <char>            <char>
#>  1: MCID3111257807       19953       19964              <NA>
#>  2: MCID3111258275       19953       19921              <NA>
#>  3: MCID3111258347       19953       19923              <NA>
#>  4: MCID3111259642       19953       19934              <NA>
#>  5: MCID3111262210       19953       19951              <NA>
#>  6: MCID3111265287       19953       19904              <NA>
#>  7: MCID3111269576       19953       19943              <NA>
#>  8: MCID3111272691       19953       19914              <NA>
#>  9: MCID3111272880       19953       19934              <NA>
#> 10: MCID3111277081       19961       19963              <NA>
#> 11: MCID3111278815       19961        <NA>              <NA>
#> 12: MCID3111282337       19963       19924              <NA>
#> 13: MCID3111296595       19963        <NA>              <NA>
#> 14: MCID3111301718       19963        <NA>              <NA>
#> 15: MCID3111310842       19963        <NA>              <NA>
#> 16: MCID3111311799       19963        <NA>              <NA>
completion_status(x, degree)
#>               mcid timely_term term_degree completion_status
#>             <char>      <char>      <char>            <char>
#>  1: MCID3111257807       19953       19964              late
#>  2: MCID3111258275       19953       19921            timely
#>  3: MCID3111258347       19953       19923            timely
#>  4: MCID3111259642       19953       19934            timely
#>  5: MCID3111262210       19953       19951            timely
#>  6: MCID3111265287       19953       19904            timely
#>  7: MCID3111269576       19953       19943            timely
#>  8: MCID3111272691       19953       19914            timely
#>  9: MCID3111272880       19953       19934            timely
#> 10: MCID3111277081       19961       19963              late
#> 11: MCID3111278815       19961        <NA>              <NA>
#> 12: MCID3111282337       19963       19924            timely
#> 13: MCID3111296595       19963        <NA>              <NA>
#> 14: MCID3111301718       19963        <NA>              <NA>
#> 15: MCID3111310842       19963        <NA>              <NA>
#> 16: MCID3111311799       19963        <NA>              <NA>
```
