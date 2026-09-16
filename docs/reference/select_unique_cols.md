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

## Examples

``` r
# Construct a sample data frame
mcid <- paste0("mc_", c("01", "02", "03"))
term <- c("19911", "19912", "19913")
dframe <- data.frame(mcid, term)
dframe
#>    mcid  term
#> 1 mc_01 19911
#> 2 mc_02 19912
#> 3 mc_03 19913
 
# No effect if all columns are distinct
select_unique_cols(dframe)
#>    mcid  term
#> 1 mc_01 19911
#> 2 mc_02 19912
#> 3 mc_03 19913

# No effect if names are distinct even if values are the same
x <- dframe
x$case <- x$term
x
#>    mcid  term  case
#> 1 mc_01 19911 19911
#> 2 mc_02 19912 19912
#> 3 mc_03 19913 19913
select_unique_cols(x)
#>    mcid  term  case
#> 1 mc_01 19911 19911
#> 2 mc_02 19912 19912
#> 3 mc_03 19913 19913

# Suffix-variable remains if there is no root-variable
x$case <- NULL
x$temp.1 <- c("abc", "def", "ghi")
x
#>    mcid  term temp.1
#> 1 mc_01 19911    abc
#> 2 mc_02 19912    def
#> 3 mc_03 19913    ghi
select_unique_cols(x)
#>    mcid  term temp.1
#> 1 mc_01 19911    abc
#> 2 mc_02 19912    def
#> 3 mc_03 19913    ghi

# Suffix-variable remains if values different from root-variable
x$temp.1 <- NULL
x$case.1 <- c("abc", "def", "ghi")
x
#>    mcid  term case.1
#> 1 mc_01 19911    abc
#> 2 mc_02 19912    def
#> 3 mc_03 19913    ghi
select_unique_cols(x)
#>    mcid  term case.1
#> 1 mc_01 19911    abc
#> 2 mc_02 19912    def
#> 3 mc_03 19913    ghi

# Suffix-variable dropped if otherwise identical to root-variable
x$case.1 <- NULL
x$term.1 <- x$term
x
#>    mcid  term term.1
#> 1 mc_01 19911  19911
#> 2 mc_02 19912  19912
#> 3 mc_03 19913  19913
select_unique_cols(x)
#>    mcid  term
#> 1 mc_01 19911
#> 2 mc_02 19912
#> 3 mc_03 19913

# Multiple redundant columns are dropped 
x$term.1 <- x$term
x$term.abc <- x$term
x
#>    mcid  term term.1 term.abc
#> 1 mc_01 19911  19911    19911
#> 2 mc_02 19912  19912    19912
#> 3 mc_03 19913  19913    19913
select_unique_cols(x)
#>    mcid  term
#> 1 mc_01 19911
#> 2 mc_02 19912
#> 3 mc_03 19913

# If a midfieldr function introduces a column with a 
# suffix ".1", ".2", etc., this points to a potential 
# error. The two columns with the same root name 
# are expected to be identical.
x <- dframe
x$term.1 <- c("19922", "19912", "19913")
x
#>    mcid  term term.1
#> 1 mc_01 19911  19922
#> 2 mc_02 19912  19912
#> 3 mc_03 19913  19913
select_unique_cols(x)
#>    mcid  term term.1
#> 1 mc_01 19911  19922
#> 2 mc_02 19912  19912
#> 3 mc_03 19913  19913

# Names with other separators are treated as unique
x$term.1 <- NULL
x$term_1 <- x$term
x
#>    mcid  term term_1
#> 1 mc_01 19911  19911
#> 2 mc_02 19912  19912
#> 3 mc_03 19913  19913
select_unique_cols(x)
#>    mcid  term term_1
#> 1 mc_01 19911  19911
#> 2 mc_02 19912  19912
#> 3 mc_03 19913  19913

# In removing a redundant column, the leftmost is retained
x <- data.frame(mcid.1 = mcid, term, mcid)
x
#>   mcid.1  term  mcid
#> 1  mc_01 19911 mc_01
#> 2  mc_02 19912 mc_02
#> 3  mc_03 19913 mc_03
select_unique_cols(x)
#>   mcid.1  term
#> 1  mc_01 19911
#> 2  mc_02 19912
#> 3  mc_03 19913
```
