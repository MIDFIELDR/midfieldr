# Table of academic programs

A data table based on the US National Center for Education Statistics
(NCES), Integrated Postsecondary Education Data System (IPEDS), 2010
CIP. The data are codes and names for 1582 instructional programs
organized on three levels: a 2-digit series, a 4-digit series, and a
6-digit series.

## Usage

``` r
cip
```

## Format

A `data.table` with 1582 rows and 6 columns keyed by the 6-digit CIP
code:

- `cip6name`:

  Character, program name at the 6-digit level

- `cip6`:

  Character, 6-digit code representing "specific instructional programs"
  (US National Center for Education Statistics).

- `cip4name`:

  Character, program name at the 4-digit level.

- `cip4`:

  Character, 4-digit code (the first 4 digits of `cip6`) representing
  "intermediate groupings of programs that have comparable content and
  objectives."

- `cip2name`:

  Character, program name at the 2-digit level.

- `cip2`:

  Character, 2-digit code (the first 2 digits of `cip6`) representing
  "the most general groupings of related programs."

## Source

<https://nces.ed.gov/ipeds/cipcode/>

## Details

The midfielddata taxonomy includes one non-IPEDS code (999999) for
Undecided or Unspecified, instances in which institutions reported no
program information or that students were not enrolled in a program.

## See also

Other cip-data:
[`cip2010`](https://midfieldr.github.io/midfieldr/reference/cip2010.md),
[`fye_proxy`](https://midfieldr.github.io/midfieldr/reference/fye_proxy.md)
