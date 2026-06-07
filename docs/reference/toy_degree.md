# Degree data for examples

Selected variables modeled on those in the `degree` practice data for
use in package examples and articles. Sampled from an early version of
the practice data, the toy data are not a current practice data sample.

## Usage

``` r
toy_degree
```

## Format

`data.table` with 96 rows and 4 columns keyed by student ID, term, and
program (CIP code or degree label).

- `mcid`:

  Character, de-identified student ID. Key column.

- `institution`:

  Character, de-identified institution name, e.g., Institution A,
  Institution B, etc.

- `term_degree`:

  Character, academic year and term in which a student completes their
  program, format YYYYT.

- `cip6`:

  Character, 6-digit CIP code of program in which a student is enrolled
  in a term. Key column.

- `degree`:

  Character, type of degree awarded, e.g., Bachelor of Arts in
  Geography, Bachelor of Science in Finance, etc.

## See also

Other toy-data:
[`toy_course`](https://midfieldr.github.io/midfieldr/reference/toy_course.md),
[`toy_student`](https://midfieldr.github.io/midfieldr/reference/toy_student.md),
[`toy_term`](https://midfieldr.github.io/midfieldr/reference/toy_term.md)
