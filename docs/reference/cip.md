# Table of academic programs

A data table based on the US National Center for Education Statistics
(NCES), Integrated Postsecondary Education Data System (IPEDS), 2010
CIP, <http://nces.ed.gov/ipeds/cipcode/>. The data are codes and names
for 1582 instructional programs organized on three levels: a 2-digit
series, a 4-digit series, and a 6-digit series.

## Usage

``` r
data(cip)
```

## Format

`data.table` with 1582 rows and 6 columns keyed by the 6-digit CIP code:

- `cip6`:

  Character 6-digit code representing "specific instructional programs"
  (US National Center for Education Statistics).

- `cip6name`:

  Character program name at the 6-digit level

- `cip4`:

  Character 4-digit code (the first 4 digits of `cip6`) representing
  "intermediate groupings of programs that have comparable content and
  objectives."

- `cip4name`:

  Character program name at the 4-digit level.

- `cip2`:

  Character 2-digit code (the first 2 digits of `cip6`) representing
  "the most general groupings of related programs."

- `cip2name`:

  Character program name at the 2-digit level.

## Details

The midfielddata taxonomy includes one non-IPEDS code (999999) for
Undecided or Unspecified, instances in which institutions reported no
program information or that students were not enrolled in a program.

The MIDFIELD research database include CIPs for undergraduate pre-majors
such as pre-med (511102), pre-law (220001), and pre-vet (511104).

## See also

Other cip-data:
[`fye_proxy`](https://midfieldr.github.io/midfieldr/reference/fye_proxy.md)
