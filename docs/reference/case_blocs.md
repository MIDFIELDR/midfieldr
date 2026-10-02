# Case-study outcome by ID and grouping variables

Data table of student IDs, program, race/ethnicity, sex, and bloc
(graduates or ever-enrolled) of the case study (Civil, Electrical,
Industrial/Systems, and Mechanical Engineering) just prior to grouping
and summarizing to develop the stickiness metric.

## Usage

``` r
case_blocs
```

## Format

`data.table` with 8868 rows and 4 columns:

- `mcid`:

  Character. Anonymized student identifier that connects the four data
  tables, e.g., "MCID3111142897."

- `people`:

  Character. Merged values of race/ethnicity and sex.

- `program`:

  Character. Abbreviation of the case-study program name.

- `bloc`:

  Character. Distinguish between program graduates and those ever
  enrolled in the programs.

## See also

Other case-study-data:
[`case_results`](https://midfieldr.github.io/midfieldr/reference/case_results.md),
[`population_baseline`](https://midfieldr.github.io/midfieldr/reference/population_baseline.md)
