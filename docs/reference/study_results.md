# Case-study results

Data table of longitudinal stickiness for the four programs of the case
study (Civil, Electrical, Industrial/Systems, and Mechanical
Engineering) grouped by program, race/ethnicity, and sex. Provided for
the convenience of vignette users.

## Usage

``` r
data(study_results)
```

## Format

`data.table` with 50 rows and 6 columns:

- `program`:

  Character, academic program label.

- `sex`:

  Character, sex as self-reported by the student, possible values are
  Female, Male, and Unknown.

- `race`:

  Character, race/ethnicity as self-reported by the student, e.g.,
  Asian, Black, Latine, etc.

- `ever_enrolled`:

  Numerical, number of students ever enrolled in a program.

- `graduates`:

  Numerical, number of students completing a program.

- `stickiness`:

  Numerical, program stickiness, the ratio of `graduates` to
  `ever_enrolled`, in percent.

## Details

Longitudinal stickiness is the ratio of the number of students
graduating from a program to the number of students ever enrolled in the
program over the time span of available data. Results are based on data
that have been filtered for data sufficiency, degree seeking, and timely
completion.

## See also

Other case-study-data:
[`baseline_mcid`](https://midfieldr.github.io/midfieldr/reference/baseline_mcid.md),
[`study_observations`](https://midfieldr.github.io/midfieldr/reference/study_observations.md),
[`study_programs`](https://midfieldr.github.io/midfieldr/reference/study_programs.md)
