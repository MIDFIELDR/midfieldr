# Term data for examples

Selected variables modeled on those in the `term` practice data for use
in package examples and articles. Sampled from an early version of the
practice data, the toy data are not a current practice data sample.

## Usage

``` r
data(toy_term)
```

## Format

`data.table` with 150 rows and 5 columns keyed by student ID. The
variables are:

- `mcid`:

  Character, de-identified student ID. Key column.

- `institution`:

  Character, de-identified institution name, e.g., Institution A,
  Institution B, etc.

- `term`:

  Character, academic year and term, format YYYYT. Key column.

- `cip6`:

  Character, 6-digit CIP code of program in which a student is enrolled
  in a term.

- `level`:

  Character, 01 Freshman, 02 Sophomore, etc. The equivalent values in
  the current practice data are 01 First-Year, 02-Second Year, etc.

## See also

Other toy-data:
[`toy_course`](https://midfieldr.github.io/midfieldr/reference/toy_course.md),
[`toy_degree`](https://midfieldr.github.io/midfieldr/reference/toy_degree.md),
[`toy_student`](https://midfieldr.github.io/midfieldr/reference/toy_student.md)
