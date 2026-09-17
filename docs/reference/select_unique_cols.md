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
mcid <- c("mc_01", "mc_02", "mc_03")
term <- c("19911", "19912", "19913")
x <- data.frame(mcid, term)

# In the following, column names "var" and "var.i" 
# represent identical names except for the suffix ".i"
 
# No effect if columns are unique
x
#>    mcid  term
#> 1 mc_01 19911
#> 2 mc_02 19912
#> 3 mc_03 19913
x <- select_unique_cols(x)
x
#>    mcid  term
#> 1 mc_01 19911
#> 2 mc_02 19912
#> 3 mc_03 19913

# Desired effect: drop new "var.i" if it duplicates existing "var"
x$term.1 <- x$term
x
#>    mcid  term term.1
#> 1 mc_01 19911  19911
#> 2 mc_02 19912  19912
#> 3 mc_03 19913  19913
x <- select_unique_cols(x)
x
#>    mcid  term
#> 1 mc_01 19911
#> 2 mc_02 19912
#> 3 mc_03 19913

# Retain "var.i" when "var" does not exist
x <- data.frame(mcid, term.1 = term)
x
#>    mcid term.1
#> 1 mc_01  19911
#> 2 mc_02  19912
#> 3 mc_03  19913
x <- select_unique_cols(x)
x
#>    mcid term.1
#> 1 mc_01  19911
#> 2 mc_02  19912
#> 3 mc_03  19913

# The leftmost of the redundant columns is retained
x$term <- term
x
#>    mcid term.1  term
#> 1 mc_01  19911 19911
#> 2 mc_02  19912 19912
#> 3 mc_03  19913 19913
x <- select_unique_cols(x)
x
#>    mcid term.1
#> 1 mc_01  19911
#> 2 mc_02  19912
#> 3 mc_03  19913

# Redundancy is checked for the dot-separator only
x <- data.frame(mcid, term, term_1 = term, term.1 = term)
x
#>    mcid  term term_1 term.1
#> 1 mc_01 19911  19911  19911
#> 2 mc_02 19912  19912  19912
#> 3 mc_03 19913  19913  19913
x <- select_unique_cols(x)
x
#>    mcid  term term_1
#> 1 mc_01 19911  19911
#> 2 mc_02 19912  19912
#> 3 mc_03 19913  19913

# When a midfieldr function adds a variable, e.g., `bacc_term`, and
# a subsequent operation adds it again, `bacc_term.1`, the second 
# addition is usually expected to be redundant and dropped.
x$term_1 <- NULL
x$bacc_term <- c("19951", "19951", "19951")
x$bacc_term.1 <- c("19951", "19951", "19951")
x
#>    mcid  term bacc_term bacc_term.1
#> 1 mc_01 19911     19951       19951
#> 2 mc_02 19912     19951       19951
#> 3 mc_03 19913     19951       19951
x <- select_unique_cols(x)
x
#>    mcid  term bacc_term
#> 1 mc_01 19911     19951
#> 2 mc_02 19912     19951
#> 3 mc_03 19913     19951

# However, if the suffixed column remains, then the two columns 
# have different values---likely indicating an error in the 
# operations leading up to this point. 
x$bacc_term.1 <- c("19953", "19951", "19951")
x
#>    mcid  term bacc_term bacc_term.1
#> 1 mc_01 19911     19951       19953
#> 2 mc_02 19912     19951       19951
#> 3 mc_03 19913     19951       19951
x <- select_unique_cols(x)
x
#>    mcid  term bacc_term bacc_term.1
#> 1 mc_01 19911     19951       19953
#> 2 mc_02 19912     19951       19951
#> 3 mc_03 19913     19951       19951
```
