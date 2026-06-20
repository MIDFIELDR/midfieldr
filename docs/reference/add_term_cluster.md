# Identify rows of post-baccalaureate terms

Provides a means of excluding post-baccalaureate terms by adding a
column of term-status labels identifying pre- and post-baccalaureate
terms.

## Usage

``` r
add_term_cluster(dframe, midfield_degree = degree)
```

## Arguments

- dframe:

  Working data frame of student-level records to which a term-status
  column is to be added. Required variables are `mcid` and a single term
  variable.

- midfield_degree:

  MIDFIELD `degree` data table or equivalent with required variables
  `mcid` and `term_degree.`

## Value

A data frame with the following properties: rows are preserved; columns
`first_degree_term` and `term_status` are added or overwritten; all
other columns are preserved. Grouping structures are not necessarily
preserved. The added columns are:

- `first_degree_term`:

  Character. Term of a student's first baccalaureate, encoded `YYYYT` —
  or NA if no degree recorded.

- `term_cluster`:

  Character. Possible values are "pre-degree", "first-degree", and
  "post-first-degree".

An attempt is made to return data frames of the same class as the input,
so a data.table input should produce a data.table output, a tibble input
should produce a tibble output, etc. Grouped tibbles, however, are
returned as data.frames. To help ensure a tibble output, try ungrouping
a tibble before using it as an input argument.

## Details

In a typical analysis, one is interested in a student's progress up to
and including the term in which they earn their first degree or degrees.
Any terms later than the first baccalaureate can usually be excluded
from study.

The input `dframe` must have a term variable with one of three possible
names: `term` (from the term data table), `term_course` (from the course
data table), or `term_degree` (from the degree data table).

`add_term_cluster()` determines a student's first degree term (if any)
from `midfield_degree`, adds that column to `dframe`, and adds a second
column of term-status labels identifying pre- and post-baccalaureate
terms.

## Examples

``` r

# Examples TBD
x <- 1
```
