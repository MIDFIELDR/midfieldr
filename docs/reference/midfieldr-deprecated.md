# midfieldr deprecated functions

These functions were deprecated in midfieldr 1.0.4.

## Usage

``` r
filter_cip(keep_text = NULL, drop_text = NULL, cip = NULL, select = NULL)

select_required(midfield_x, select_add = NULL)
```

## Arguments

- keep_text:

  Deprecated `filter_cip()`. Character vector of search text to keep.

- drop_text:

  Deprecated `filter_cip()`. Character vector of search text to drop.

- cip:

  Deprecated `filter_cip()`. Data frame of programs to be searched.

- select:

  Deprecated `filter_cip()`. Character vector of column names to select.

- midfield_x:

  Deprecated `select_required()`. Data frame from which columns are
  selected.

- select_add:

  Deprecated `select_required()`. Character vector of col_patterns to
  search `dframe` column names.

## Details

- `filter_cip()`:

  is deprecated in favor of
  [`filter_cip_rows()`](https://midfieldr.github.io/midfieldr/reference/filter_cip_rows.md).
  The new function is similar but with the CIP data frame as the first
  argument, enabling chained functions like those encountered using
  dplyr and friends.

- `select_required()`:

  is deprecated in favor of
  [`select_record_cols()`](https://midfieldr.github.io/midfieldr/reference/select_record_cols.md).
  The new functionality is similar but with exact matching to the
  default column names plus preserving data frame class.
