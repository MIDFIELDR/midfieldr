# Choose unique columns

Subset a data frame to retain unique columns. A variable in a data frame
is dropped if, after splitting its name at a period separator ("."), its
name and values are identical to those of another variable. Primarily
used internally in midfieldr functions that add columns to a data frame.

## Usage

``` r
select_unique_cols(dframe)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble)

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Rows are preserved.

- Unique columns preserved. Redundant columns dropped.

## Details

Several midfieldr functions add columns to a working data frame. The
goal of this function is to prevent overwriting existing columns in the
data frame that happen to have the same name as one of the added
columns. At the same time, if both the name and values of a new column
duplicate an existing column, the new column is redundant and can be
dropped.

If the name of an existing column happens to match that of a new
variable, the new variable name is made unique by adding a suffix such
as ".1", ".2", etc. Before the final data frame is returned, all
variable names are temporarily split from their dot suffixes. Columns
are dropped if their values and dot-split name duplicate a previous
column. Columns are not dropped if their split names are unique nor if
the row-wise values differ.
