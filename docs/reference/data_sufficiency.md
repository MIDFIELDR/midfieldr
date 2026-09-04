# Determine data sufficiency

Determine institutional *data sufficiency* for each student in a data
frame and add columns that support the findings.

## Usage

``` r
data_sufficiency(dframe, midf_table = term)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble) with
  required variables `{mcid, entry_term, timely_term}.`

- midf_table:

  `term` data frame with required variables `{mcid, term, institution}.`

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Row order is preserved. Rows with `NA` values in any of the required
  variables are removed. Duplicated rows are removed.

- Columns with names different from the new columns (named below) are
  not modified; columns with matching names are replaced. The new
  columns added are:

  - `data_range`   Character. Institution data range, encoded
    `YYYYT-YYYYT,` indicating the institution's first and last term in
    the database. Extracted from `midf_table.`

  - `sufficiency`   Character. Data sufficiency results. Possible values
    are "satisfied", "fail-lower," and "fail-upper."

## Details

In most studies, the population must satisfy the *data sufficiency*
criterion, developed as follows:

- Program *completion* means satisfying the requirements for a first
  baccalaureate degree.

- Completion *status* is "timely" if accomplished within a set time
  span, typically 4, 6, or 8 years after admission depending on the
  definition one adopts. The *timely-completion term* is the term at the
  end of that span.

- The *data sufficiency* test identifies students whose actual admission
  term and projected timely completion term both lie within their
  institution's data range. These are the students for whom completion
  status—timely or otherwise—can be positively asserted, and are
  therefore the only students included a population.

To apply this criterion, our heuristic labels a row (keyed by student
ID) "exclude-upper" when a student's timely completion term exceeds the
upper limit of their institution's data range; "exclude-lower" when
their initial term matches the non-summer, lower limit of the data
range; and "include" otherwise. The rationale for these specific filters
is explained in our data sufficiency article (see references).

## References

R. Layton, R. Long, M. Ohland, M. Orr, and S. Lord (2026), "Data
sufficiency,"
<https://midfieldr.github.io/midfieldr/articles/art-020-data-sufficiency.html>

## Examples

``` r
# Assign toy data sets
student <- toy_student
term <- toy_term

# Start with a selected population
x <- student[c(9:11, 21:30, 344:345), .(mcid)]
x
#>               mcid
#>             <char>
#>  1: MCID3111169729
#>  2: MCID3111170852
#>  3: MCID3111173999
#>  4: MCID3111257807
#>  5: MCID3111258275
#>  6: MCID3111258347
#>  7: MCID3111259642
#>  8: MCID3111262210
#>  9: MCID3111265287
#> 10: MCID3111269576
#> 11: MCID3111272691
#> 12: MCID3111272880
#> 13: MCID3111277081
#> 14: MCID3112751130
#> 15: MCID3112754537

# Add the required columns from timely_term()
x <- timely_term(x, midf_table = term)
x <- x[, .(mcid, entry_term, timely_term)]
x
#>               mcid entry_term timely_term
#>             <char>     <char>      <char>
#>  1: MCID3111169729      19881       19933
#>  2: MCID3111170852      19881       19933
#>  3: MCID3111173999      19881       19933
#>  4: MCID3111257807      19901       19953
#>  5: MCID3111258275      19901       19953
#>  6: MCID3111258347      19901       19953
#>  7: MCID3111259642      19901       19953
#>  8: MCID3111262210      19901       19953
#>  9: MCID3111265287      19901       19953
#> 10: MCID3111269576      19901       19953
#> 11: MCID3111272691      19901       19953
#> 12: MCID3111272880      19901       19953
#> 13: MCID3111277081      19903       19961
#> 14: MCID3112751130      20151       20203
#> 15: MCID3112754537      20151       20203

# Add data sufficiency columns
x <- data_sufficiency(x, midf_table = term)
x
#>               mcid entry_term timely_term  data_range sufficiency
#>             <char>     <char>      <char>      <char>      <char>
#>  1: MCID3111169729      19881       19933 19881-20181  fail-lower
#>  2: MCID3111170852      19881       19933 19881-20181  fail-lower
#>  3: MCID3111173999      19881       19933 19881-20181  fail-lower
#>  4: MCID3111257807      19901       19953 19881-20181   satisfied
#>  5: MCID3111258275      19901       19953 19881-20181   satisfied
#>  6: MCID3111258347      19901       19953 19881-20181   satisfied
#>  7: MCID3111259642      19901       19953 19901-20153  fail-lower
#>  8: MCID3111262210      19901       19953 19881-20181   satisfied
#>  9: MCID3111265287      19901       19953 19881-20181   satisfied
#> 10: MCID3111269576      19901       19953 19881-20181   satisfied
#> 11: MCID3111272691      19901       19953 19881-20181   satisfied
#> 12: MCID3111272880      19901       19953 19881-20181   satisfied
#> 13: MCID3111277081      19903       19961 19881-20181   satisfied
#> 14: MCID3112751130      20151       20203 19881-20181  fail-upper
#> 15: MCID3112754537      20151       20203 19881-20181  fail-upper

# If you repeat, the new columns are overwritten
data_sufficiency(x, midf_table = term)
#>               mcid entry_term timely_term  data_range sufficiency
#>             <char>     <char>      <char>      <char>      <char>
#>  1: MCID3111169729      19881       19933 19881-20181  fail-lower
#>  2: MCID3111170852      19881       19933 19881-20181  fail-lower
#>  3: MCID3111173999      19881       19933 19881-20181  fail-lower
#>  4: MCID3111257807      19901       19953 19881-20181   satisfied
#>  5: MCID3111258275      19901       19953 19881-20181   satisfied
#>  6: MCID3111258347      19901       19953 19881-20181   satisfied
#>  7: MCID3111259642      19901       19953 19901-20153  fail-lower
#>  8: MCID3111262210      19901       19953 19881-20181   satisfied
#>  9: MCID3111265287      19901       19953 19881-20181   satisfied
#> 10: MCID3111269576      19901       19953 19881-20181   satisfied
#> 11: MCID3111272691      19901       19953 19881-20181   satisfied
#> 12: MCID3111272880      19901       19953 19881-20181   satisfied
#> 13: MCID3111277081      19903       19961 19881-20181   satisfied
#> 14: MCID3112751130      20151       20203 19881-20181  fail-upper
#> 15: MCID3112754537      20151       20203 19881-20181  fail-upper

# Typical application retains "include" rows only
x[sufficiency == "satisfied"]
#>              mcid entry_term timely_term  data_range sufficiency
#>            <char>     <char>      <char>      <char>      <char>
#> 1: MCID3111257807      19901       19953 19881-20181   satisfied
#> 2: MCID3111258275      19901       19953 19881-20181   satisfied
#> 3: MCID3111258347      19901       19953 19881-20181   satisfied
#> 4: MCID3111262210      19901       19953 19881-20181   satisfied
#> 5: MCID3111265287      19901       19953 19881-20181   satisfied
#> 6: MCID3111269576      19901       19953 19881-20181   satisfied
#> 7: MCID3111272691      19901       19953 19881-20181   satisfied
#> 8: MCID3111272880      19901       19953 19881-20181   satisfied
#> 9: MCID3111277081      19903       19961 19881-20181   satisfied
```
