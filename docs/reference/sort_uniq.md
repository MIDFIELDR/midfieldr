# Extract unique elements and sort

A strict version of [`sort()`](https://rdrr.io/r/base/sort.html) and
[`unique()`](https://rdrr.io/r/base/unique.html) (without ...).

## Usage

``` r
sort_uniq(
  x,
  ...,
  incomparables = FALSE,
  MARGIN = 1,
  fromLast = FALSE,
  decreasing = FALSE,
  na.last = FALSE
)
```

## Arguments

- x:

  Vector of values to be sorted with any duplicate values removed.

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- incomparables:

  A vector of values. See
  [`unique()`](https://rdrr.io/r/base/unique.html).

- MARGIN:

  An integer. The array margin to be held fixed. Passed to
  [`unique()`](https://rdrr.io/r/base/unique.html).

- fromLast:

  Logical. Indicates if duplication should be considered from the last.
  Passed to [`unique()`](https://rdrr.io/r/base/unique.html).

- decreasing:

  Logical. Should the sort be increasing or decreasing? Passed to
  [`sort()`](https://rdrr.io/r/base/sort.html).

- na.last:

  Logical. Position of NA values. Passed to
  [`sort()`](https://rdrr.io/r/base/sort.html).

## Value

A vector of unique values, sorted.

## Examples

``` r
# Character vector
x <- toy_student$race
sort_uniq(x)
#> [1] "Asian"         "Black"         "Hispanic"      "International"
#> [5] "Other/Unknown" "White"        

# Numeric vector
x <- toy_term$hours_term_attempt
sort_uniq(x)
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 21 26
```
