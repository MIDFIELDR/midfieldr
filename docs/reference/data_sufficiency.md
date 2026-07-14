# Determine data sufficiency

Determine *data sufficiency* for each student in a data frame and add
columns that support the findings.

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

- Data frame class is preserved. Groups and keys are not preserved.

- Row order is preserved. Rows with `NA` values in any of the required
  variables are removed. Duplicated rows are removed.

- Columns with names different from the new columns (named below) are
  not modified; columns with matching names are replaced. The new
  columns added are:

  - `institution`   Character. Name of the institution at which a
    student is enrolled in a term.

  - `lower_limit`   Character. Initial term of an institution's data
    range, encoded `YYYYT`. Extracted from `midfield_table.`

  - `upper_limit`   Character. Final term of an institution's data
    range, encoded `YYYYT`. Extracted from `midfield_table.`

  - `data_sufficiency`   Character. Possible values are "include",
    "exclude-lower," and "exclude-upper."

## Details

*Data sufficiency* is a criterion for including or excluding a student
record based on the feasibility of determining their completion status
given the range of data available from their institution. If determining
completion status is feasible, the student record is included in the
study population; if not, they must be excluded to avoid biased counts
of completers and non-completers. Such biases occur at the upper and
lower bounds of an institution's data range.

To apply this criterion, our heuristic labels a row "exclude-upper" when
a student's timely completion term exceeds the upper limit of their
institution's data range; "exclude-lower" when their initial term
matches the lowest non-summer limit of the data range; and "include"
otherwise. The rationale for these specific filters is explained in our
data sufficiency article (see references). In most studies, the
population must satisfy the data sufficiency requirement.

## References

Richard Layton, Russell Long, Matthew Ohland, Marisa Orr, and Susan Lord
(2026) Data sufficiency,
https://midfieldr.github.io/midfieldr/articles/art-020-data-sufficiency.html

## Examples

``` r
term <- toy_term

# Start with a selected population.
x <- toy_student[c(9:15, 342:344), .(mcid, sex)]
x
#>               mcid    sex
#>             <char> <char>
#>  1: MCID3111169729 Female
#>  2: MCID3111170852   Male
#>  3: MCID3111173999 Female
#>  4: MCID3111198701   Male
#>  5: MCID3111208924   Male
#>  6: MCID3111213539 Female
#>  7: MCID3111213856 Female
#>  8: MCID3112727716   Male
#>  9: MCID3112749981 Female
#> 10: MCID3112751130   Male

# Add the required columns from timely_term().
x <- timely_term(x, midfield_table = term)
x <- x[, .(mcid, sex, term_i, timely_term)]
x
#>               mcid    sex term_i timely_term
#>             <char> <char> <char>      <char>
#>  1: MCID3111169729 Female  19881       19933
#>  2: MCID3111170852   Male  19881       19933
#>  3: MCID3111173999 Female  19881       19933
#>  4: MCID3111198701   Male  19891       19943
#>  5: MCID3111208924   Male  19891       19943
#>  6: MCID3111213539 Female  19891       19943
#>  7: MCID3111213856 Female  19891       19943
#>  8: MCID3112727716   Male  20143       20201
#>  9: MCID3112749981 Female  20151       20203
#> 10: MCID3112751130   Male  20151       20203

# Add data sufficiency columns. Unrelated columns (sex) are unaffected.
x <- data_sufficiency(x, midfield_table = term)
x
#>               mcid    sex term_i timely_term   institution lower_limit
#>             <char> <char> <char>      <char>        <char>      <char>
#>  1: MCID3111169729 Female  19881       19933 Institution B       19881
#>  2: MCID3111170852   Male  19881       19933 Institution B       19881
#>  3: MCID3111173999 Female  19881       19933 Institution B       19881
#>  4: MCID3111198701   Male  19891       19943 Institution J       19881
#>  5: MCID3111208924   Male  19891       19943 Institution J       19881
#>  6: MCID3111213539 Female  19891       19943 Institution B       19881
#>  7: MCID3111213856 Female  19891       19943 Institution B       19881
#>  8: MCID3112727716   Male  20143       20201 Institution B       19881
#>  9: MCID3112749981 Female  20151       20203 Institution B       19881
#> 10: MCID3112751130   Male  20151       20203 Institution B       19881
#>     upper_limit data_sufficiency
#>          <char>           <char>
#>  1:       20181    exclude-lower
#>  2:       20181    exclude-lower
#>  3:       20181    exclude-lower
#>  4:       20096          include
#>  5:       20096          include
#>  6:       20181          include
#>  7:       20181          include
#>  8:       20181    exclude-upper
#>  9:       20181    exclude-upper
#> 10:       20181    exclude-upper

# Repeat. New columns silently replace existing columns of the same name.
y <- data_sufficiency(x, midfield_table = term)
y
#>               mcid    sex term_i timely_term   institution lower_limit
#>             <char> <char> <char>      <char>        <char>      <char>
#>  1: MCID3111169729 Female  19881       19933 Institution B       19881
#>  2: MCID3111170852   Male  19881       19933 Institution B       19881
#>  3: MCID3111173999 Female  19881       19933 Institution B       19881
#>  4: MCID3111198701   Male  19891       19943 Institution J       19881
#>  5: MCID3111208924   Male  19891       19943 Institution J       19881
#>  6: MCID3111213539 Female  19891       19943 Institution B       19881
#>  7: MCID3111213856 Female  19891       19943 Institution B       19881
#>  8: MCID3112727716   Male  20143       20201 Institution B       19881
#>  9: MCID3112749981 Female  20151       20203 Institution B       19881
#> 10: MCID3112751130   Male  20151       20203 Institution B       19881
#>     upper_limit data_sufficiency
#>          <char>           <char>
#>  1:       20181    exclude-lower
#>  2:       20181    exclude-lower
#>  3:       20181    exclude-lower
#>  4:       20096          include
#>  5:       20096          include
#>  6:       20181          include
#>  7:       20181          include
#>  8:       20181    exclude-upper
#>  9:       20181    exclude-upper
#> 10:       20181    exclude-upper
```
