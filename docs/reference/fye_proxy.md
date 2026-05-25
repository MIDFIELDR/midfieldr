# Starting program proxies for FYE students

Proxies are the degree-granting engineering programs we estimate that
First-Year Engineering (FYE) students would have declared had they not
been required to enroll in FYE. Keyed by student ID. Proxies are
provided for all students in the midfielddata practice data who enroll
in FYE in their first term.

## Usage

``` r
data(fye_proxy)
```

## Format

`data.table` with 4623 rows and 2 columns keyed by student ID:

- `mcid`:

  Character, de-identified student ID. Key column.

- `proxy`:

  Character, 6-digit CIP code of the estimated proxy program.

## Details

The proxy variable contains 6-digit CIP codes of degree-granting
engineering programs, e.g., Electrical Engineering, Mechanical
Engineering, etc., that are substituted for the FYE CIP code when an
analysis requires degree-granting starting programs. The most common
application is a graduation rate calculation.

The estimation is based on students' first post-FYE programs and a
multiple imputation suitable for categorical variables using the mice
package. The predictor variables are institution, race, and sex. The
estimated variable is the 6-digit CIP code of a degree-granting
engineering program at their institution.

`fye_proxy` holds only for the practice data in midfielddata—these
values cannot be commingled with the MIDFIELD research database.

## See also

Other cip-data:
[`cip`](https://midfieldr.github.io/midfieldr/reference/cip.md),
[`cip2010`](https://midfieldr.github.io/midfieldr/reference/cip2010.md)
