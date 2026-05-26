# Case-study observations

Data table of post-processed observations of students ever enrolled in,
and students graduating from, the four programs of the case study. Keyed
by student ID. Provided for the convenience of vignette users.

## Usage

``` r
study_observations
```

## Format

`data.table` with 8919 rows and 5 columns. The variables are:

- `mcid`:

  Character, de-identified student ID. Key column.

- `race`:

  Character, race/ethnicity as self-reported by the student, e.g.,
  Asian, Black, Hispanic, etc.

- `sex`:

  Character, sex as self-reported by the student, possible values are
  Female, Male, and Unknown.

- `program`:

  Character, academic program label.

- `bloc`:

  Character, indicating the grouping (`ever_enrolled` or `graduates`) to
  which an observation belongs.

## Details

Starting with the case-study starting pool of students ever enrolled in
the four programs of the study (Civil, Electrical, Industrial/Systems,
and Mechanical Engineering), we filtered the data for data sufficiency,
degree seeking, program, and timely completion.

A data frame of "ever enrolled" and a data frame of "timely graduates"
were bound using shared column names and are distinguished in the `bloc`
variable. This data structure facilitates grouping and summarizing by
race, sex, program, and group.

## See also

Other case-study-data:
[`baseline_mcid`](https://midfieldr.github.io/midfieldr/reference/baseline_mcid.md),
[`study_programs`](https://midfieldr.github.io/midfieldr/reference/study_programs.md),
[`study_results`](https://midfieldr.github.io/midfieldr/reference/study_results.md)
