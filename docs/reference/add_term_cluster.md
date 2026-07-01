# Identify term clusters

Add columns to a student-records data frame indicating an observation
should be included (or excluded) because the term is clustered with
pre-degree (or post-first-degree) terms.

## Usage

``` r
add_term_cluster(dframe, midfield_rec = degree)
```

## Arguments

- dframe:

  Student-records data frame to which term-cluster columns are to be
  added. Required variables are `mcid` and a single term variable:
  `term` (when working with the term table), `term_course` (course
  table), or `term_degree` (degree table).

- midfield_rec:

  MIDFIELD `degree` data table or equivalent with required variables
  `mcid` and `term_degree`.

## Value

Data frame `dframe` with added columns. Output has the following
properties:

- Rows are not modified.

- Columns added or updated/overwritten:

  - `first_degree_term.`   Character. Term of a student's first
    baccalaureate, encoded `YYYYT` or, if no degree recorded, `NA`.
    Joined from `midfield_rec$term_degree`.

  - `term_cluster.`   Character, indicating that a term belongs to one
    of three clusters: terms that are prior to ("pre-degree"), equal to
    ("first-degree"), or subsequent to ("post-first-degree") the
    student’s first degree term.

- Columns not listed above are not modified.

- Data frame attributes (except groups) are preserved.

## Details

In a typical analysis, one is interested in a student's progress up to
and including the term in which they earn their first degree or degrees.
Any terms later than the first baccalaureate can usually be excluded
from study.

## See also

Other add\_\*:
[`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md),
[`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md),
[`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)

## Examples

``` r

# Examples TBD
x <- 1
```
