# Identify post-baccalaureate terms

To a data frame keyed by student ID and containing an academic term
variable, add a column that clusters terms with respect to a student's
first degree term. Post-baccalaureate terms are typically excluded from
the term, course, and degree data tables.

## Usage

``` r
post_bacc_terms(dframe, midfield_rec = degree)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble).
  Required variables: `{mcid}` and one of
  `{term, term_course, term_degree}.`

- midfield_rec:

  MIDFIELD records *degree* data frame or data frame extension. Required
  variables: `{mcid, term_degree}.`

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Rows are not modified.

- Columns are not modified except new columns overwrite old columns of
  the same name. New columns:

  - `first_degree_term.`   Character. Term of a student's first
    baccalaureate, encoded `YYYYT` or, if no degree recorded, `NA`.
    Joined from `midfield_rec$term_degree`.

  - `term_cluster.`   Character, indicating that a term belongs to one
    of three clusters: terms that are prior to ("pre-degree"), equal to
    ("first-degree"), or subsequent to ("post-first-degree") the
    student’s first degree term.

## Details

In a typical analysis, one is interested in a student's progress up to
and including the term in which they earn their first degree or degrees.
Any terms later than the first baccalaureate can usually be excluded
from study.

## Examples

``` r

# Examples TBD
x <- 1
```
