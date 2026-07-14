# Determine completion status

Determine the *completion status* for each student in a data frame and
add columns that support the findings.

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

- Data frame class is preserved. Groups and keys are not preserved.

- Row order is preserved. Rows with `NA` values in any of the required
  variables are removed. Duplicated rows are removed.

- Columns with names different from the new columns (named below) are
  not modified; columns with matching names are replaced. The new
  columns added are:

  - `term_degree`   Joined from `midfield_table.`

  - `completion_status`   Character. Possible values of "timely", "late"
    and "NA".

## Details

If a population has been filtered for data sufficiency, then determining
every student's *completion status* is feasible. Completing an academic
program in a timely manner means that a student completes the
requirements for a degree within a set time span, typically 4, 6, or 8
years after admission depending on the definition adopted in a
particular study. The term at the end of that span is the *timely
completion term.*

If the student's degree term is no later than their timely completion
term, then their completion status is "timely"; if later, their status
is "late". For students with no degree, completion status is NA.

## Examples

``` r
term <- toy_term
degree <- toy_degree

# Start with a selected population. 
x <- toy_student[21:36, .(mcid, sex)]
x
#>               mcid    sex
#>             <char> <char>
#>  1: MCID3111257807 Female
#>  2: MCID3111258275   Male
#>  3: MCID3111258347 Female
#>  4: MCID3111259642   Male
#>  5: MCID3111262210   Male
#>  6: MCID3111265287   Male
#>  7: MCID3111269576   Male
#>  8: MCID3111272691 Female
#>  9: MCID3111272880 Female
#> 10: MCID3111277081   Male
#> 11: MCID3111278815   Male
#> 12: MCID3111282337 Female
#> 13: MCID3111296595   Male
#> 14: MCID3111301718 Female
#> 15: MCID3111310842 Female
#> 16: MCID3111311799 Female

# Add the required columns from timely_term().
x <- timely_term(x, midfield_table = term)
x <- x[, .(mcid, sex, timely_term)]
x
#>               mcid    sex timely_term
#>             <char> <char>      <char>
#>  1: MCID3111257807 Female       19953
#>  2: MCID3111258275   Male       19953
#>  3: MCID3111258347 Female       19953
#>  4: MCID3111259642   Male       19953
#>  5: MCID3111262210   Male       19953
#>  6: MCID3111265287   Male       19953
#>  7: MCID3111269576   Male       19953
#>  8: MCID3111272691 Female       19953
#>  9: MCID3111272880 Female       19953
#> 10: MCID3111277081   Male       19961
#> 11: MCID3111278815   Male       19961
#> 12: MCID3111282337 Female       19963
#> 13: MCID3111296595   Male       19963
#> 14: MCID3111301718 Female       19963
#> 15: MCID3111310842 Female       19963
#> 16: MCID3111311799 Female       19963

# Add completion status columns. Unrelated columns (sex) are unaffected.
x <- completion_status(x, midfield_table = degree)
x
#>               mcid    sex timely_term term_degree completion_status
#>             <char> <char>      <char>      <char>            <char>
#>  1: MCID3111257807 Female       19953       19964              late
#>  2: MCID3111258275   Male       19953       19921            timely
#>  3: MCID3111258347 Female       19953       19923            timely
#>  4: MCID3111259642   Male       19953       19934            timely
#>  5: MCID3111262210   Male       19953       19951            timely
#>  6: MCID3111265287   Male       19953       19904            timely
#>  7: MCID3111269576   Male       19953       19943            timely
#>  8: MCID3111272691 Female       19953       19914            timely
#>  9: MCID3111272880 Female       19953       19934            timely
#> 10: MCID3111277081   Male       19961       19963              late
#> 11: MCID3111278815   Male       19961        <NA>              <NA>
#> 12: MCID3111282337 Female       19963       19924            timely
#> 13: MCID3111296595   Male       19963        <NA>              <NA>
#> 14: MCID3111301718 Female       19963        <NA>              <NA>
#> 15: MCID3111310842 Female       19963        <NA>              <NA>
#> 16: MCID3111311799 Female       19963        <NA>              <NA>

# Repeat. New columns silently replace existing columns of the same name.
y <- completion_status(x, midfield_table = degree)
y
#>               mcid    sex timely_term term_degree completion_status
#>             <char> <char>      <char>      <char>            <char>
#>  1: MCID3111257807 Female       19953       19964              late
#>  2: MCID3111258275   Male       19953       19921            timely
#>  3: MCID3111258347 Female       19953       19923            timely
#>  4: MCID3111259642   Male       19953       19934            timely
#>  5: MCID3111262210   Male       19953       19951            timely
#>  6: MCID3111265287   Male       19953       19904            timely
#>  7: MCID3111269576   Male       19953       19943            timely
#>  8: MCID3111272691 Female       19953       19914            timely
#>  9: MCID3111272880 Female       19953       19934            timely
#> 10: MCID3111277081   Male       19961       19963              late
#> 11: MCID3111278815   Male       19961        <NA>              <NA>
#> 12: MCID3111282337 Female       19963       19924            timely
#> 13: MCID3111296595   Male       19963        <NA>              <NA>
#> 14: MCID3111301718 Female       19963        <NA>              <NA>
#> 15: MCID3111310842 Female       19963        <NA>              <NA>
#> 16: MCID3111311799 Female       19963        <NA>              <NA>
```
