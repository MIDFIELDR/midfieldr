# Small 'degree' dataset for examples

A subset of rows from the midfielddata `degree` table that comprises
those students from the `toy_student` dataset who complete a program. A
small dataset used in examples.

## Usage

``` r
toy_degree
```

## Format

Data frame with 193 rows and 4 columns (`data.table` class). Composite
key: `{mcid, term_degree, cip6}.`

- `mcid`:

  Character. Anonymized student identifier that connects the four data
  tables, e.g., "MCID3111142897."

- `term_degree`:

  Character. Academic year and term in which a student completes their
  program, encoded `YYYYT.`

- `cip6`:

  Character. The 6-digit CIP code of the program that the student
  completes in this term.

- `institution`:

  Character. The anonymized name of the institution the student attended
  in a given term, e.g., "Institution A", "Institution B", etc.

- `degree`:

  Character. Type of degree awarded, e.g., "Bachelor of Arts in
  Geography", "Bachelor of Science in Finance," etc.

## See also

Other toy-data:
[`toy_course`](https://midfieldr.github.io/midfieldr/reference/toy_course.md),
[`toy_student`](https://midfieldr.github.io/midfieldr/reference/toy_student.md),
[`toy_term`](https://midfieldr.github.io/midfieldr/reference/toy_term.md)
