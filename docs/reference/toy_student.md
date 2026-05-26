# Student data for examples

Selected variables modeled on those in the `student` practice data for
use in package examples and articles. Sampled from an early version of
the practice data, the toy data are not a current practice data sample.

## Usage

``` r
toy_student
```

## Format

`data.table` with 15 rows and 13 columns keyed by student ID:

- `mcid`:

  Character, de-identified student ID. Key column.

- `institution`:

  Character, de-identified institution name, e.g., Institution A,
  Institution B, etc.

- `transfer`:

  Character, transfer status, possible values are
  `First-Time in College`, `First-Time Transfer`.

- `hours_transfer`:

  Numeric, number of credit hours transferred (or NA).

- `race`:

  Character, race/ethnicity as self-reported by the student, e.g.,
  Asian, Black, Hispanic, etc.

- `sex`:

  Character, sex as self-reported by the student, possible values are
  Female, Male, and Unknown.

- `age_desc`:

  Character, age group, possible values are `25 and Older`, `Under 25`.

- `us_citizen`:

  Character, US citizenship, possible values are `No`, `Yes`.

- `home_zip`:

  Character, home ZIP code (or `NA`), e.g., `02056`, `20170`, `51301`,
  `80129`, etc.

- `high_school`:

  Character, code for the last high school attended before admission (or
  `NA`), e.g., `060075`, `210512`, `431800`, `502195`, etc.

- `sat_math`:

  Numeric, SAT mathematics test score (or `NA`).

- `sat_verbal`:

  Numeric, SAT reading test score (or `NA`).

- `act_comp`:

  Numeric, ACT composite test score (or `NA`).

## See also

Other toy-data:
[`toy_course`](https://midfieldr.github.io/midfieldr/reference/toy_course.md),
[`toy_degree`](https://midfieldr.github.io/midfieldr/reference/toy_degree.md),
[`toy_term`](https://midfieldr.github.io/midfieldr/reference/toy_term.md)
