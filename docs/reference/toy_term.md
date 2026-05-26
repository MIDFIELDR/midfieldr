# Term data for examples

Selected variables modeled on those in the `term` practice data for use
in package examples and articles. Sampled from an early version of the
practice data, the toy data are not a current practice data sample.

## Usage

``` r
toy_term
```

## Format

`data.table` with 1114 rows and 13 columns keyed by student ID:

- `mcid`:

  Character, de-identified student ID. Key column.

- `institution`:

  Character, de-identified institution name, e.g., Institution A,
  Institution B, etc.

- `term`:

  Character, academic year and term, format YYYYT. Key column.

- `cip6`:

  Character, 6-digit CIP code of program in which a student is enrolled
  in a term, e.g., `090101`, `141201`, `260901`, `420101`, etc.

- `level`:

  Character, 01 Freshman, 02 Sophomore, etc. The equivalent values in
  the current practice data are 01 First-Year, 02-Second Year, etc.

- `standing`:

  Character, academic standing, e.g., `Good Standing`,
  `Academic Warning`, etc.

- `coop`:

  Character, cooperative education term, possible values are `Yes`,
  `No`.

- `hours_term`:

  Numeric, credit hours earned in the term.

- `hours_term_attempt`:

  Numeric, credit hours attempted in the term.

- `hours_cumul`:

  Numeric, cumulative credit hours earned.

- `hours_cumul_attempt`:

  Numeric, cumulative credit hours attempted.

- `gpa_term`:

  Numeric, term grade point average.

- `gpa_cumul`:

  Numeric, cumulative grade point average.

## See also

Other toy-data:
[`toy_course`](https://midfieldr.github.io/midfieldr/reference/toy_course.md),
[`toy_degree`](https://midfieldr.github.io/midfieldr/reference/toy_degree.md),
[`toy_student`](https://midfieldr.github.io/midfieldr/reference/toy_student.md)
