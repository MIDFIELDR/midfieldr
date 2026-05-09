# Student data for examples

Selected variables modeled on those in the `student` practice data for
use in package examples and articles. Sampled from an early version of
the practice data, the toy data are not a current practice data sample.

## Usage

``` r
data(toy_student)
```

## Format

`data.table` with 99 rows and 4 columns keyed by student ID:

- `mcid`:

  Character, de-identified student ID. Key column.

- `institution`:

  Character, de-identified institution name, e.g., Institution A,
  Institution B, etc.

- `race`:

  Character, race/ethnicity as self-reported by the student, e.g.,
  Asian, Black, Latine, etc.

- `sex`:

  Character, sex as self-reported by the student, possible values are
  Female, Male, and Unknown.

## See also

Other toy-data:
[`toy_course`](https://midfieldr.github.io/midfieldr/reference/toy_course.md),
[`toy_degree`](https://midfieldr.github.io/midfieldr/reference/toy_degree.md),
[`toy_term`](https://midfieldr.github.io/midfieldr/reference/toy_term.md)
