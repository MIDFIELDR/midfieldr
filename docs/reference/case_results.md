# Case-study results

Data table of longitudinal stickiness for the four programs of the case
study (Civil, Electrical, Industrial/Systems, and Mechanical
Engineering) grouped by program, race/ethnicity, and sex. Provided for
the convenience of vignette users.

## Usage

``` r
case_results
```

## Format

`data.table` with 43 rows and 4 columns:

- `program`:

  Character. Academic program label.

- `people`:

  Character. Race/ethnicity and sex as self-reported by the student,
  e.g., "Asian Male", "Black Female", etc.

- `ever`:

  Numerical. The number of students ever enrolled in a program.

- `grad`:

  Numerical. Number of students completing a program.

- `stick`:

  Numerical. Program stickiness, the ratio of the number of graduates to
  the number ever enrolled, in percent.

## Details

Longitudinal stickiness is the ratio of the number of students
graduating from a program to the number of students ever enrolled in the
program over the time span of available data. Results are based on data
that have been filtered for data sufficiency, degree seeking,
undergraduate terms, and timely completion.

## See also

Other case-study-data:
[`baseline_mcid`](https://midfieldr.github.io/midfieldr/reference/baseline_mcid.md),
[`study_observations`](https://midfieldr.github.io/midfieldr/reference/study_observations.md),
[`study_programs`](https://midfieldr.github.io/midfieldr/reference/study_programs.md),
[`study_results`](https://midfieldr.github.io/midfieldr/reference/study_results.md)
