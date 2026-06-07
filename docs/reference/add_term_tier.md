# Label terms as pre- or post-baccalaureate

Add a column of labels to a data frame of student-level records
indicating the tier of each term in the record compared to the student's
first degree term, if any. Possible tier values are `post-bacc` for
terms later than a student's first degree term and `bacc` for all
others. Term tier labels are typically used to exclude
post-baccalaureate terms.

## Usage

``` r
add_term_tier(dframe, midfield_degree = degree)
```

## Arguments

- dframe:

  Working data frame of student-level records to which term-tier columns
  are to be added. Required variables are `mcid` and one term variable
  only named `term` or that starts with `term_`.

- midfield_degree:

  MIDFIELD `degree` data table or equivalent with required variables
  `mcid` and one term variable only that starts with `term` such as
  `term_degree.`

## Value

A data frame in `data.table` format with the following properties: rows
are preserved; columns are preserved with the exception that columns
added by the function overwrite existing columns of the same name (if
any); grouping structures are not preserved. The added columns are:

- `term_bacc`:

  Character. Term of a student's first baccalaureate (if any) encoded
  YYYYT. NA if no degree term.

- `term_tier`:

  Character. Possible tier values are `post-bacc` for terms later than a
  student's first degree term and `bacc` for all others.

## Details

For students without a degree, every term tier value is `bacc`. For
students with at least one degree, the term tier value is `bacc` for all
terms leading up to and including the term of their first degree, and
`post-bacc` otherwise.

The usual filtering procedure is to exclude post-baccalaureate terms
from an analysis involving the `course`, `term`, or `degree` data
tables.
