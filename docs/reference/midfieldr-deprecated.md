# midfieldr deprecated functions

These functions were deprecated in midfieldr 1.0.4.

## Usage

``` r
add_completion_status(dframe, midfield_degree = degree)

add_data_sufficiency(dframe, midfield_term = term)

filter_cip(keep_text = NULL, drop_text = NULL, cip = NULL, select = NULL)

select_required(midfield_x, select_add = NULL)

add_timely_term(
  dframe,
  midfield_term = term,
  ...,
  sched_span = NULL,
  span = NULL
)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble).

- midfield_degree:

  MIDFIELD records *degree* data frame or data frame extension.

- midfield_term:

  MIDFIELD records *term* data frame or data frame extension.

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

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- sched_span:

  Integer scalar

- span:

  Integer scalar

## Details

- `add_completion_status()`:

  is deprecated in favor of
  [`completion_status()`](https://midfieldr.github.io/midfieldr/reference/completion_status.md).
  Update midfieldr file names and argument names, dropping columns not
  used by the function, and preserving data frame class.

- `add_data_sufficiency()`:

  is deprecated in favor of
  [`data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/data_sufficiency.md).
  Update midfieldr file names and argument names, dropping columns not
  used by the function, and preserving data frame class.

- `add_timely_term()`:

  is deprecated in favor of
  [`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md).
  Update midfieldr file names and argument names, dropping columns not
  used by the function, and preserving data frame class.

- `filter_cip()`:

  is deprecated in favor of
  [`filter_programs()`](https://midfieldr.github.io/midfieldr/reference/filter_programs.md).
  The new function is similar but with the CIP data frame as the first
  argument, enabling chained functions like those encountered using
  dplyr and friends.

- `select_required()`:

  is deprecated in favor of
  [`select_records()`](https://midfieldr.github.io/midfieldr/reference/select_records.md).
  The new functionality is similar but with exact matching to the
  default column names plus preserving data frame class.
