# Identify rows of post-baccalaureate terms

Provides a means of excluding post-baccalaureate terms by adding a
column of term-cluster labels identifying pre- and post-baccalaureate
terms. In a typical analysis, one is interested in a student's progress
up to and including the term in which they earn their first degree or
degrees. Any terms later than the first baccalaureate can usually be
excluded from study.

## Usage

``` r
add_term_cluster(dframe, midfield_degree = degree)
```

## Arguments

- dframe:

  Working data frame of student-level records to which a term-cluster
  column is to be added. Required variables are `mcid` and a single term
  variable: `term` (when working with the term table), `term_course`
  (course table), or `term_degree` (degree table).

- midfield_degree:

  MIDFIELD `degree` data table or equivalent with required variables
  `mcid` and `term_degree`.

## Value

A data frame of the same type as `dframe`. The output has the following
properties:

- Rows are not modified.

- Columns are added, overwriting existing columns (if any) of the same
  name. Other columns are not modified.

- Groups are not preserved.

- Data frame attributes are preserved for classes `data.frame`,
  `data.table`, or `tbl_df`.

## Details

The new columns are :

- `first_degree_term` Character. Term of a student's first
  baccalaureate, encoded `YYYYT` or, if no degree recorded, `NA`. Joined
  from `midfield_degree$term_degree`.

- `term_cluster` Character, indicating that a term belongs to one of
  three clusters: terms that are prior to ("pre-degree"), equal to
  ("first-degree"), or subsequent to ("post-first-degree") the student’s
  first degree term.

## Examples

``` r

# Examples TBD
x <- 1
```
