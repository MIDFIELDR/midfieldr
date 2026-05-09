# Course data for examples

Selected variables modeled on those in the `course` practice data for
use in package examples and articles. Sampled from an early version of
the practice data, the toy data are not a current practice data sample.

## Usage

``` r
data(toy_course)
```

## Format

`data.table` with 4616 rows and 6 columns keyed by student ID:

- `mcid`:

  Character, de-identified student ID. Key column.

- `institution`:

  Character, de-identified institution name, e.g., Institution A,
  Institution B, etc.

- `term`:

  Character, academic year and term, format YYYYT. Key column.

- `abbrev`:

  Character, course alphabetical identifier, e.g. ENGR, MATH, ENGL. Key
  column.

- `number`:

  Character, course numeric identifier, e.g. 101, 3429. Key column.

- `grade`:

  Character, course grade, e.g., A+, A, A-, B+, I, NG, etc.

## See also

Other toy-data:
[`toy_degree`](https://midfieldr.github.io/midfieldr/reference/toy_degree.md),
[`toy_student`](https://midfieldr.github.io/midfieldr/reference/toy_student.md),
[`toy_term`](https://midfieldr.github.io/midfieldr/reference/toy_term.md)
