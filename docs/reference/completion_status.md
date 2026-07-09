# Build a completion status data frame

Assembles a data frame with one row per student and with columns for
student ID, timely completion term, first degree term (if any), and
*completion status*—timely, late, or NA. Depends on
[`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md)
being run beforehand.

## Usage

``` r
completion_status(dframe, midfield_table = degree)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble) with
  required variables `{mcid, timely_term}.`

- midfield_table:

  `degree` data frame with required variables `{mcid, term_degree}.`

## Value

Data frame with the following properties:

- Data frame class is preserved.

- One row per student.

- Columns returned:

  - `mcid`   Pulled from `dframe.`

  - `timely_term`   Pulled from `dframe.`

  - `term_degree`   Joined from `midfield_table.`

  - `completion_status`   Character. Possible values of "timely", "late"
    and "NA".

## Details

Program *completion* means graduating with a first baccalaureate degree.
Completion is *timely* if it occurs within a specified span, typically
4, 6, or 8 years after admission. The term at the end of that span is
the *timely completion term.*

The student ID and timely completion term are pulled from `dframe`; all
other columns are dropped. The first degree term is joined from
`midfield_table.` For students with a degree, completion no later than
the timely term is "timely"; completion after the timely term is "late."
For students with no degree, completion status is NA.

## Examples

``` r
term <- toy_term
degree <- toy_degree

# Start with a selected population 
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
x <- timely_term(x, midfield_table = term)
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

# Build completion status data frame
completion_status(x, midfield_table = degree)
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
