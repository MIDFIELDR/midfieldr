# Build a data sufficiency data frame

Assembles a data frame with one row per student per institution with
columns for student ID, their initial term and timely completion term,
the institution and its data range limits, and the *data sufficiency*
assessment to include (or not) the student in the study population.
Depends on
[`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md)
being run beforehand.

## Usage

``` r
data_sufficiency(dframe, midfield_table = term)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble) with
  required variables `{mcid, term_i, timely_term}.`

- midfield_table:

  `term` data frame with required variables `{mcid, term, institution}.`

## Value

Data frame with the following properties:

- Data frame class is preserved.

- One row per student per institution (accounts for the possibility of a
  student enrolled in more than one institution in the database).

- Columns returned:

  - `mcid`   Pulled from `dframe.`

  - `term_i`   Pulled from `dframe.`

  - `timely_term`   Pulled from `dframe.`

  - `institution.`   Joined from `midfield_table.`

  - `lower_limit.`   Character. Initial term of an institution's data
    range, encoded `YYYYT`. Extracted from `midfield_table.`

  - `upper_limit.`   Character. Final term of an institution's data
    range, encoded `YYYYT`. Extracted from `midfield_table.`

  - `data_sufficiency.`   Character. Possible values are "include",
    "exclude-lower," and "exclude-upper."

## Details

*Data sufficiency* is an assessment whether a student record lies
sufficiently within their institution's data range to unambiguously
assess their completion status and if so include them in the study
population. Not performing the necessary exclusions produces biased
counts of completers and non-completers. Such biases occur at the lower
and upper bounds of an institution's data range.

The student ID, initial term, and timely completion term are pulled from
`dframe`; all other columns are dropped. Institutions and their data
range limits (upper and lower) are extracted and joined from
`midfield_table.` Rows are labeled with data sufficiency values as
follows: "exclude-lower" when the initial term matches the data range
lower limit; "exclude-upper" when the timely completion term exceeds the
data range upper limit; and "include" otherwise.

If a student is enrolled in more than one institution in the database,
an exclusion at any institution is applied to all rows with that ID.

## Examples

``` r
term <- toy_term

# Start with a small population 
x <- toy_student[c(9:15, 342:344), .(mcid)]
x
#>               mcid
#>             <char>
#>  1: MCID3111169729
#>  2: MCID3111170852
#>  3: MCID3111173999
#>  4: MCID3111198701
#>  5: MCID3111208924
#>  6: MCID3111213539
#>  7: MCID3111213856
#>  8: MCID3112727716
#>  9: MCID3112749981
#> 10: MCID3112751130

# Timely term column is required
x <- timely_term(x, midfield_table = term)
x
#>               mcid term_i       level_i adj_span timely_term
#>             <char> <char>        <char>    <num>      <char>
#>  1: MCID3111169729  19881 01 First-year        6       19933
#>  2: MCID3111170852  19881 01 First-year        6       19933
#>  3: MCID3111173999  19881 01 First-year        6       19933
#>  4: MCID3111198701  19891 01 First-year        6       19943
#>  5: MCID3111208924  19891 01 First-year        6       19943
#>  6: MCID3111213539  19891 01 First-year        6       19943
#>  7: MCID3111213856  19891 01 First-year        6       19943
#>  8: MCID3112727716  20143 01 First-year        6       20201
#>  9: MCID3112749981  20151 01 First-year        6       20203
#> 10: MCID3112751130  20151 01 First-year        6       20203

# Build data sufficiency data frame
data_sufficiency(x, midfield_table = term)
#>               mcid term_i timely_term   institution lower_limit upper_limit
#>             <char> <char>      <char>        <char>      <char>      <char>
#>  1: MCID3111169729  19881       19933 Institution B       19881       20181
#>  2: MCID3111170852  19881       19933 Institution B       19881       20181
#>  3: MCID3111173999  19881       19933 Institution B       19881       20181
#>  4: MCID3111198701  19891       19943 Institution J       19881       20096
#>  5: MCID3111208924  19891       19943 Institution J       19881       20096
#>  6: MCID3111213539  19891       19943 Institution B       19881       20181
#>  7: MCID3111213856  19891       19943 Institution B       19881       20181
#>  8: MCID3112727716  20143       20201 Institution B       19881       20181
#>  9: MCID3112749981  20151       20203 Institution B       19881       20181
#> 10: MCID3112751130  20151       20203 Institution B       19881       20181
#>     data_sufficiency
#>               <char>
#>  1:    exclude-lower
#>  2:    exclude-lower
#>  3:    exclude-lower
#>  4:          include
#>  5:          include
#>  6:          include
#>  7:          include
#>  8:    exclude-upper
#>  9:    exclude-upper
#> 10:    exclude-upper
```
