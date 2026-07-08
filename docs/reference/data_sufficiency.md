# Determine data sufficiency

For each student in a data frame, determine whether or not their record
lies sufficiently within their institution's data range to unambiguously
assess their completion status and if so include them in the study
population. Label each row with this *data sufficiency* result (include
or exclude) and add columns that support the findings.

## Usage

``` r
data_sufficiency(dframe, midfield_table = term)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble) with
  required variables `{mcid, term_i, timely_term}.` The latter two
  variables are provided by `timely_term().`

- midfield_table:

  `term` data frame with required variables `{mcid, term, institution}.`

## Value

Data frame with the following properties:

- Data frame class is preserved.

- Rows are not modified except duplicated rows are removed. Row order is
  preserved.

- Variables `{mcid, term_i, timely_term}` are retained. All other
  columns (if any) are dropped and the following variables are added:

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

*Timely completion* means completing a program no later than a specified
interval—typical values are 4, 6, or 8 years after admission. The *data
sufficiency* criterion states that student records must be limited to
those for which available data from an institution are sufficient to
assess timely completion without biased counts of completers or
non-completers. Such biases occur at the lower and upper bounds of an
institution's data range. Affected students must be identified and
excluded to prevent false summary counts.

In our heuristic, the criteria is implemented via two filters. Rows are
labeled for exclusion when: 1) a student ID is extant in the non-summer
lower limit of an institution's data range; or 2) a student ID has a
timely completion term that exceeds the upper limit of the institution's
data range. The results are documented in the output.

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
