# Select required midfieldr variables

Subset a data frame, selecting columns by matching or partially matching
a vector of character strings. A convenience function to reduce the
dimensions of a MIDFIELD data table at the start of a session by
selecting only those columns required by other midfieldr functions or
that are required to form a composite key. Particularly useful in
interactive sessions when viewing the data tables at various stages of
an analysis.

## Usage

``` r
select_required(midfield_x, ..., select_add = NULL)
```

## Arguments

- midfield_x:

  Data frame from which columns are selected.

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- select_add:

  Character vector of additional column names to return.

## Value

A data frame in `data.table` format with the following properties: rows
are preserved; columns with names that match or partially match values
in the default set plus any in `select_add` are retained; grouping
structures are not preserved.

## Details

Several midfieldr functions require one or more of the variables `mcid`,
`institution`, `race`, `sex`, `^term`, `cip6`, and `level`. And if one
requires a composite key to uniquely identify rows, course variables
`abbrev`, `number` and degree variable `degree` are also required. A
vector of these names comprises the default subset.

Additional column names or partial names can be included by using the
`select_add` argument.

The column names of `midfield_x` are searched for matches or partial
matches using [`grep()`](https://rdrr.io/r/base/grep.html), thus search
terms can include regular expressions. Variables with names that match
or partially match the search terms are returned; all other columns are
dropped. Rows are unaffected. Search terms not present are silently
ignored.

One could use this function to select columns from a non-MIDFIELD data
frame, but with no benefit to the user—conventional column selection
syntax is better suited to that task. Here, we specialize the column
selection to serve midfieldr functions.

## Examples

``` r
# Default character vector for selecting columns
default_cols<- c("mcid", "institution", "race", "sex", "^term", "cip6", "level")

# Create one string separated by OR
search_pattern <- paste(default_cols, collapse = "|")

# Find names of columns matching or partially matching 
x <- select_required(toy_student) 
names(x)
#> [1] "mcid"        "institution" "race"        "sex"        
grepl(search_pattern, names(x))
#> [1] TRUE TRUE TRUE TRUE

x <- select_required(toy_term) 
names(x)
#> [1] "mcid"        "institution" "term"        "cip6"        "level"      
grepl(search_pattern, names(x))
#> [1] TRUE TRUE TRUE TRUE TRUE

x <- select_required(toy_degree) 
names(x)
#> [1] "mcid"        "institution" "term_degree" "cip6"       
grepl(search_pattern, names(x))
#> [1] TRUE TRUE TRUE TRUE

x <- select_required(toy_course) 
names(x)
#> [1] "mcid"        "institution" "term"        "abbrev"      "number"     
grepl(search_pattern, names(x))
#> [1]  TRUE  TRUE  TRUE FALSE FALSE

# Adding search terms
x <- select_required(toy_course, select_add = c("abbrev", "number", "grade")) 
names(x)
#> [1] "mcid"        "institution" "term"        "abbrev"      "number"     
#> [6] "grade"      


```
