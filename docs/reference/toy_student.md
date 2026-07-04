# Small 'student' dataset for examples

A subset of rows from the midfielddata `student` table. A small dataset
for use in examples.

## Usage

``` r
toy_student
```

## Format

Data frame with 351 rows and 13 columns (`data.table` class). Key:
`{mcid}.`

- `mcid`:

  Character. Anonymized student identifier that connects the four data
  tables, e.g., "MCID3111142897."

- `race`:

  Character. Race/ethnicity as self-reported by the student, e.g.,
  "Asian", "Black", "Hispanic", etc.

- `sex`:

  Character. Sex as self-reported by the student, possible values are
  "Female", "Male", and "Unknown."

- `institution`:

  Character. The anonymized name of the institution the student attended
  in a given term, e.g., "Institution A", "Institution B", etc.

- `transfer`:

  Character. Transfer status, possible values are "First-Time in
  College", "First-Time Transfer."

- `hours_transfer`:

  Numeric. Number of credit hours transferred (or NA).

- `age_desc`:

  Character. Age group, possible values are "25 and Older", "Under 25."

- `us_citizen`:

  Character. US citizenship, possible values are "No", "Yes."

- `home_zip`:

  Character. Home ZIP code (or NA), e.g., "02056", "20170", "51301",
  "80129", etc.

- `high_school`:

  Character. Code for the last high school attended before admission (or
  NA), e.g., "060075", "210512", "431800", "502195", etc.

- `sat_math`:

  Numeric. SAT mathematics test score (or NA).

- `sat_verbal`:

  Numeric. SAT reading test score (or NA).

- `act_comp`:

  Numeric. ACT composite test score (or NA).

## See also

Other toy-data:
[`toy_course`](https://midfieldr.github.io/midfieldr/reference/toy_course.md),
[`toy_degree`](https://midfieldr.github.io/midfieldr/reference/toy_degree.md),
[`toy_term`](https://midfieldr.github.io/midfieldr/reference/toy_term.md)
