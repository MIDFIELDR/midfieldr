# SAT-ACT conversion scale

Data frame for converting between ACT and SAT scores. A range of SAT
scores converts to a single ACT score; an ACT score converts to a single
value equivalent SAT score.

## Usage

``` r
data(sat_act_scale)
```

## Format

`data.table` with 28 rows and 4 columns:

- `act_comp`:

  Numerical, ACT composite score.

- `sat_lower`:

  Numerical, total SAT, lower limit of range corresponding to the ACT
  composite score.

- `sat_equiv`:

  Numerical, total SAT, value to use when converting ACT score to a
  single SAT score.

- `sat_upper`:

  Numerical, total SAT, upper limit of range corresponding to the ACT
  composite score.

## Source

ACT/SAT Concordance (2018) ACT Education Corp.
<https://www.act.org/content/dam/act/unsecured/documents/ACT-SAT-Concordance-Tables.pdf>

## See also

Other scales:
[`grade_scale`](https://midfieldr.github.io/midfieldr/reference/grade_scale.md)
