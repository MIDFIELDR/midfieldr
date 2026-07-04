# Small 'term' dataset for examples

A subset of rows from the midfielddata `term` table matching the IDs in
`toy_student.` A small dataset for use in examples.

## Usage

``` r
toy_term
```

## Format

Data frame with 1821 rows and 13 columns (`data.table` class). Composite
key: `{mcid, term}.`

- `mcid`:

  Character. Anonymized student identifier that connects the four data
  tables, e.g., "MCID3111142897."

- `term`:

  Character. Academic year and term the student attended, encoded
  `YYYYT.`

- `cip6`:

  Character. The 6-digit CIP code of the program in which a student is
  enrolled in this term.

- `institution`:

  Character. The anonymized name of the institution the student attended
  in a given term, e.g., "Institution A", "Institution B", etc.

- `level`:

  Character. Academic level of the student at the end of this term,
  e.g., "01 First-Year", "02-Second Year", etc.

- `standing`:

  Character. Academic standing during the reported term, e.g., "Good
  Standing", "Academic Warning", etc.

- `coop`:

  Character. Cooperative education term, possible values are "Yes",
  "No."

- `hours_term`:

  Numeric. Credit hours earned in the term.

- `hours_term_attempt`:

  Numeric. Credit hours attempted in the term.

- `hours_cumul`:

  Numeric, cumulative credit hours earned.

- `hours_cumul_attempt`:

  Numeric. Cumulative credit hours attempted.

- `gpa_term`:

  Numeric. Term grade point average.

- `gpa_cumul`:

  Numeric. Cumulative grade point average.

## See also

Other toy-data:
[`toy_course`](https://midfieldr.github.io/midfieldr/reference/toy_course.md),
[`toy_degree`](https://midfieldr.github.io/midfieldr/reference/toy_degree.md),
[`toy_student`](https://midfieldr.github.io/midfieldr/reference/toy_student.md)
