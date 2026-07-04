# Determine data sufficiency

To a data frame keyed by student ID, add a column indicating that an
institution's data range is sufficient to reliably assess a student's
program completion. Columns of supporting information are also added.
Columns not related to the task are dropped.

## Usage

``` r
data_sufficiency(dframe, midfield_table = term)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble).
  Required variables: `{mcid, term_i, timely_term}`.

- midfield_table:

  Data frame or data frame extension of a MIDFIELD *term* table.
  Required variables: `{mcid, term, institution}`.

## Value

Data frame with the following properties:

- Data frame class is preserved.

- Rows are filtered for unique `mcid` values.

- Columns `{mcid, term_i, timely_term}` are retained. All other columns
  are dropped and the following columns are added:

  - `institution.`   Character. Institution in which the student is
    enrolled in the given term. Extracted from `midfield_table.` The
    limits given in the next two columns are specific to the
    institution.

  - `lower_limit.`   Character. Initial term of an institution's data
    range, encoded `YYYYT`. Extracted from `midfield_table.` Compared to
    `term_i` to determine the lower-limit exclusion.

  - `upper_limit.`   Character. Final term of an institution's data
    range, encoded `YYYYT`. Extracted from `midfield_table.` Compared to
    `timely_term` to determine upper-limit exclusion.

  - `data_sufficiency.`   Character. Possible values are "include", if
    the data are sufficient; and "exclude-lower" or "exclude-upper" if
    not, indicating at which boundary of the data range the ambiguity
    occurs.

- Groups and keys are not preserved.

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
x <- timely_term(x, term)
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

# Add data sufficiency column, columns not used are dropped
x <- data_sufficiency(x, term)
x
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

# Existing data sufficiency column (if any) is replaced
x[, data_sufficiency := NA_character_][]
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
#>  1:             <NA>
#>  2:             <NA>
#>  3:             <NA>
#>  4:             <NA>
#>  5:             <NA>
#>  6:             <NA>
#>  7:             <NA>
#>  8:             <NA>
#>  9:             <NA>
#> 10:             <NA>
data_sufficiency(x, term)
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
