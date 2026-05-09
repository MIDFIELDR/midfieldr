# Test for equal content between two data tables

This function is deprecated in favor of
[`wrapr::check_equiv_frames()`](https://winvector.github.io/wrapr//reference/check_equiv_frames.html)
imported from the wrapr package, accessible by loading 'midfieldr'.

## Usage

``` r
same_content(x, y)
```

## Arguments

- x:

  Data frame to be compared. Same as `target` argument in
  [`all.equal()`](https://rdrr.io/r/base/all.equal.html)

- y:

  Data frame to be compared. Same as `current` argument in
  [`all.equal()`](https://rdrr.io/r/base/all.equal.html)

## Value

Either TRUE or a description of the differences between `x` and `y`.

## Details

Test of data equality between data.table objects. Convenience function
used in 'midfieldr' articles.

Wrapper around [`all.equal()`](https://rdrr.io/r/base/all.equal.html)
for class data.table that ignores row order, column order, and
data.table keys. Both inputs must be date frames. Equivalent to:

`all.equal(target, current, ignore.row.order = TRUE, ignore.col.order = TRUE)`

## See also

[`midfieldr-deprecated`](https://midfieldr.github.io/midfieldr/reference/midfieldr-deprecated.md)
