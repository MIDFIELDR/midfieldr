# Estimate timely completion terms

For each student in a data frame, estimate their *timely completion
term*—the term by which their program completion would be considered
timely—and add columns to the data frame that support the findings.

## Usage

``` r
timely_term(dframe, midfield_table = term, ..., sched_span = NULL, span = NULL)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble) with
  required variable `{mcid}.`

- midfield_table:

  `term` data frame with required variables `{mcid, term, level}.`

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- sched_span:

  Integer scalar (default 4), the number of years an institution
  officially schedules for completing a program.

- span:

  Integer scalar (default 6), number of years to define timely
  completion, typically 4, 6, or 8 years (100%, 150%, 200% respectively
  of `sched_span`).

## Value

Data frame with the following properties:

- Data frame class is preserved.

- Row order is preserved. Duplicated rows are removed.

- Variable `{mcid}` is retained. All other columns (if any) are dropped
  and the following variables are added:

  - `term_i`   Initial term of a student's longitudinal record, encoded
    `YYYYT`. Extracted from `midfield_table.`

  - `level_i`   Character. Student level (01 Freshman, 02 Sophomore,
    etc.) in their initial term. Extracted from `midfield_table.`

  - `adj_span`   Numeric. Integer span of years for timely completion
    adjusted for a student's initial level.

  - `timely_term`   Character. Latest term by which program completion
    would be considered timely for every student. Encoded `YYYYT.`

- Groups and keys are not preserved.

## Details

By *completing a program* we mean an undergraduate earning their first
baccalaureate degree or degrees. *Timely* completion is typically 4, 6,
or 8 years after admission depending on the definition adopted in a
particular study. The term at the upper limit of that span is the
*timely completion term.*

Our heuristic assigns `span` number of years (default 6) to every
student. For students admitted at second-year level or higher, the span
is reduced by one year for each full year the student is assumed to have
completed. The adjusted span is added to their initial term to create
the `timely_term` values. These results are documented in the output.

Determining completion status requires output variable `{timely_term}`;
determining data sufficiency requires output variables
`{term_i, timely_term}.`

## Examples

``` r
term <- toy_term

# Start with a small population 
x <- toy_student[c(51:55, 346:350), .(mcid, sex)]
x
#>               mcid    sex
#>             <char> <char>
#>  1: MCID3111412771   Male
#>  2: MCID3111413518   Male
#>  3: MCID3111417249   Male
#>  4: MCID3111417990 Female
#>  5: MCID3111418880 Female
#>  6: MCID3112799709   Male
#>  7: MCID3112815901 Female
#>  8: MCID3112839623 Female
#>  9: MCID3112868072   Male
#> 10: MCID3112869843 Female

# Add timely term, unrelated variables (sex) are dropped
x <- timely_term(x, midfield_table = term)
x
#>               mcid term_i        level_i adj_span timely_term
#>             <char> <char>         <char>    <num>      <char>
#>  1: MCID3111412771  19931  01 First-year        6       19983
#>  2: MCID3111413518  19931  01 First-year        6       19983
#>  3: MCID3111417249  19941 02 Second-year        5       19983
#>  4: MCID3111417990  19931  01 First-year        6       19983
#>  5: MCID3111418880  19931  01 First-year        6       19983
#>  6: MCID3112799709  20161  01 First-year        6       20213
#>  7: MCID3112815901  20161  01 First-year        6       20213
#>  8: MCID3112839623  20171  01 First-year        6       20223
#>  9: MCID3112868072  20171  01 First-year        6       20223
#> 10: MCID3112869843  20173  01 First-year        6       20231

# Existing column with same name as added column is replaced
x[, adj_span := 0L][]
#>               mcid term_i        level_i adj_span timely_term
#>             <char> <char>         <char>    <num>      <char>
#>  1: MCID3111412771  19931  01 First-year        0       19983
#>  2: MCID3111413518  19931  01 First-year        0       19983
#>  3: MCID3111417249  19941 02 Second-year        0       19983
#>  4: MCID3111417990  19931  01 First-year        0       19983
#>  5: MCID3111418880  19931  01 First-year        0       19983
#>  6: MCID3112799709  20161  01 First-year        0       20213
#>  7: MCID3112815901  20161  01 First-year        0       20213
#>  8: MCID3112839623  20171  01 First-year        0       20223
#>  9: MCID3112868072  20171  01 First-year        0       20223
#> 10: MCID3112869843  20173  01 First-year        0       20231
timely_term(x, midfield_table = term)
#>               mcid term_i        level_i adj_span timely_term
#>             <char> <char>         <char>    <num>      <char>
#>  1: MCID3111412771  19931  01 First-year        6       19983
#>  2: MCID3111413518  19931  01 First-year        6       19983
#>  3: MCID3111417249  19941 02 Second-year        5       19983
#>  4: MCID3111417990  19931  01 First-year        6       19983
#>  5: MCID3111418880  19931  01 First-year        6       19983
#>  6: MCID3112799709  20161  01 First-year        6       20213
#>  7: MCID3112815901  20161  01 First-year        6       20213
#>  8: MCID3112839623  20171  01 First-year        6       20223
#>  9: MCID3112868072  20171  01 First-year        6       20223
#> 10: MCID3112869843  20173  01 First-year        6       20231
```
