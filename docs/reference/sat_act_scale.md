# SAT-ACT conversion scale

Data frame of SAT total scores and corresponding ACT composite scores.
Converting from SAT to ACT, a range of SAT scores convert to a single
ACT value. Converting from ACT to SAT, a single-value SAT equivalent is
provided.

## Usage

``` r
data(sat_act_scale)
```

## Format

`data.table` with 28 rows and 4 columns:

- `sat_upper`:

  Numerical, total SAT, upper limit of range corresponding to the ACT
  composite score.

- `sat_equiv`:

  Numerical, total SAT, value to use when converting ACT score to a
  single SAT score.

- `sat_lower`:

  Numerical, total SAT, lower limit of range corresponding to the ACT
  composite score.

- `act_comp`:

  Numerical, ACT composite score.

## Source

ACT/SAT Concordance (2018) ACT Education Corp.
<https://www.act.org/content/dam/act/unsecured/documents/ACT-SAT-Concordance-Tables.pdf>

## See also

Other scales:
[`grade_scale`](https://midfieldr.github.io/midfieldr/reference/grade_scale.md)
