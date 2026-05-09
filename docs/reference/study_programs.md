# Case-study program labels and codes

Data table of program CIP codes and labels of the four programs of the
case study. Keyed by 6-digit CIPs. Provided for the convenience of
vignette users.

## Usage

``` r
data(study_programs)
```

## Format

`data.table` with 15 rows and 2 columns. The variables are:

- `cip6`:

  Character, 6-digit CIP code of program in which a student is enrolled
  in a term.

- `program`:

  Character, abbreviated labels for four engineering programs. Values
  are "CE" (Civil Engineering), "EE" (Electrical Engineering), "ISE"
  (Industrial/Systems Engineering), and "ME" (Mechanical Engineering).

## Details

Starting with the midfieldr `cip` data set, we extracted the CIPs of the
four programs of the case study and assigned them a custom label to be
used for grouping and summarizing.

## See also

Other case-study-data:
[`baseline_mcid`](https://midfieldr.github.io/midfieldr/reference/baseline_mcid.md),
[`study_observations`](https://midfieldr.github.io/midfieldr/reference/study_observations.md),
[`study_results`](https://midfieldr.github.io/midfieldr/reference/study_results.md)
