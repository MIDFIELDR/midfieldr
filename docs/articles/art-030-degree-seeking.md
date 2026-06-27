# Degree seeking

Most analyses of student-level records omit records of students not
seeking degrees. We use an *inner join* merging operation as a
degree-seeking filter. This article treats degree seeking and inner
joins generally.

This article in the MIDFIELD workflow:

1.  Planning  
2.  Initial processing
    - Data sufficiency  
    - Degree seeking
    - Identify programs  
3.  Blocs  
4.  Groupings  
5.  Metrics  
6.  Displays

## Definitions

- degree-seeking:

  Describes students advancing toward a bachelor’s degree, accumulating
  credit hours in their program with the goal of graduating from their
  institution.

## Method

By design, the `student` data table contains records of degree-seeking
students only. We use an inner join with `student` to filter our working
data frame for degree-seeking students.

1.  Filter source SURs for data sufficiency.

2.  Filter for degree seeking.

*Reminder.*   midfielddata is for practice, not research.

## Load data

*Start.*   If you are writing your own script to follow along, we use
these packages in this article:

``` r

library(midfieldr)
library(midfielddata)
library(data.table)
```

*Load.*   Practice datasets. View data dictionaries via
[`?student`](https://midfieldr.github.io/midfielddata/reference/student.html),
[`?term`](https://midfieldr.github.io/midfielddata/reference/term.html).

``` r

# Load practice data
data(student, term)
```

## Initial processing

*Select (optional).*   Reduce the number of columns. Code reproduced
from [Getting
started](https://midfieldr.github.io/midfieldr/articles/art-000-getting-started.html#reusable-code).

``` r

# Optional. Copy of source files with all variables
source_student <- copy(student)
source_term <- copy(term)

# Optional. Select variables required by midfieldr functions
student <- select_record_cols(source_student)
term <- select_record_cols(source_term)
```

*Initialize.*   Assign a working data frame.

``` r

# Working data frame
DT <- copy(term)
```

*Data sufficiency.*   Filter to satisfy the data sufficiency criterion.
Code reproduced from [Data
sufficiency](https://midfieldr.github.io/midfieldr/articles/art-020-data-sufficiency.html#reusable-code).

``` r

# Filter for data sufficiency, output unique IDs
DT <- add_timely_term(DT, term)
DT <- add_data_sufficiency(DT, term)
DT <- DT[data_sufficiency == "include", .(mcid)]
DT <- unique(DT)
```

We preserve this data frame as a baseline for examples in the article.

``` r

baseline <- copy(DT)
```

## Inner joins

An *inner join* is a merge operation that returns all observations
(rows) from two data frames that match specified conditions in both.
Using data.table syntax, we have two approaches: `merge(X, Y, by)`
(similar to base R) and `Y[X, j, on]` (native to data.table).

### Using `merge(X, Y, by)`

The general form for an inner join is

        merge(X, Y, by, all = FALSE)

where

- `X` is a data frame, matching rows returned
- `Y` is a data frame, matching rows returned
- by is the vector of shared column names to merge by
- `all = FALSE` ensures the inner join

In this example, the `Y` data frame is `student`, from which we extract
the ID column before joining. Otherwise, all columns from both data
frames would be returned.

``` r

# Select columns in Y
cols_we_want <- student[, .(mcid)]

# merge(X, Y) inner join
merge(DT, cols_we_want, by = c("mcid"), all = FALSE)
#> Key: <mcid>
#>                  mcid
#>                <char>
#>     1: MCID3111142689
#>     2: MCID3111142782
#>     3: MCID3111142881
#>    ---               
#> 76873: MCID3112785480
#> 76874: MCID3112800920
#> 76875: MCID3112870009
```

### Using `Y[X, j, on]`

The second approach—native to data.table and computationally more
efficient—has the form

        Y[X, j, on, nomatch = NULL]

where

- `X` is a data frame, matching rows returned
- `Y` is a data frame, matching rows returned
- `j` selects columns from the joined data frame to retain (default all
  columns)
- `on` is the vector of shared column names to merge by
- `nomatch = NULL` ensures the inner join

``` r

# Y[X] inner join
DT[student, .(mcid), on = c("mcid"), nomatch = NULL]
#>                  mcid
#>                <char>
#>     1: MCID3111142689
#>     2: MCID3111142782
#>     3: MCID3111142881
#>    ---               
#> 76873: MCID3112785480
#> 76874: MCID3112800920
#> 76875: MCID3112870009
```

*Demonstrate equivalence.*   Showing that the two approaches produce the
same result and that, for inner joins, `X` and `Y` are interchangeable.

``` r

# merge(X, Y)
w <- merge(DT, cols_we_want, by = c("mcid"), all = FALSE)
# merge(Y, X)
x <- merge(cols_we_want, DT, by = c("mcid"), all = FALSE)
# X[Y]
y <- DT[student, .(mcid), on = c("mcid"), nomatch = NULL]
# Y[X]
z <- student[DT, .(mcid), on = c("mcid"), nomatch = NULL]

# Demonstrate equivalence
check_equiv_frames(w, x)
#> [1] TRUE
check_equiv_frames(w, y)
#> [1] TRUE
check_equiv_frames(w, z)
#> [1] TRUE
```

### Selecting columns

In either method, we can select columns from both data frames. Using
[`merge()`](https://rdrr.io/r/base/merge.html) we select the columns by
explicitly subsetting the two data frames.

``` r

# Selecting columns from both data frames, merge() inner join
x <- merge(DT[, .(mcid)], student[, .(mcid, institution)], by = c("mcid"), all = FALSE)
setkey(x, NULL)
x
#>                  mcid   institution
#>                <char>        <char>
#>     1: MCID3111142689 Institution B
#>     2: MCID3111142782 Institution J
#>     3: MCID3111142881 Institution B
#>    ---                             
#> 76873: MCID3112785480 Institution C
#> 76874: MCID3112800920 Institution B
#> 76875: MCID3112870009 Institution B
```

In the `X[Y, j]` syntax, however, we can list the columns to be returned
from both data frames in the `j` list, that is, `.(var1, var2, etc.)`,
without subsetting the original two data frames.

``` r

# Selecting columns from both data frames, X[Y] inner join
y <- DT[student, .(mcid, institution), on = c("mcid"), nomatch = NULL]
y
#>                  mcid   institution
#>                <char>        <char>
#>     1: MCID3111142689 Institution B
#>     2: MCID3111142782 Institution J
#>     3: MCID3111142881 Institution B
#>    ---                             
#> 76873: MCID3112785480 Institution C
#> 76874: MCID3112800920 Institution B
#> 76875: MCID3112870009 Institution B
```

*Demonstrate equivalence.*   Showing that the two approaches produce the
same result.

``` r

# Demonstrate equivalence
check_equiv_frames(x, y)
#> [1] TRUE
```

## Degree seeking

*Continue.*   The baseline data frame we preserved earlier is the intake
for this section.

``` r

# Reusable starting state
DT <- copy(baseline)
DT
#>                  mcid
#>                <char>
#>     1: MCID3111142689
#>     2: MCID3111142782
#>     3: MCID3111142881
#>    ---               
#> 76873: MCID3112785480
#> 76874: MCID3112800920
#> 76875: MCID3112870009
```

*Filter.* Use an inner join with `student` to filter `DT` to retain
degree-seeking students.

``` r

# Inner join for degree seeking
DT <- student[DT, .(mcid), on = c("mcid"), nomatch = NULL]
```

*Filter.*   Filter to ensure IDs are unique.

``` r

# One observation per ID
DT <- unique(DT)
DT
#>                  mcid
#>                <char>
#>     1: MCID3111142689
#>     2: MCID3111142782
#>     3: MCID3111142881
#>    ---               
#> 76873: MCID3112785480
#> 76874: MCID3112800920
#> 76875: MCID3112870009
```

## Reusable code

*Preparation.*   The baseline data frame we preserved earlier is the
intake for this section.

``` r

DT <- copy(baseline)
```

*Degree seeking.*   A summary code chunk for ready reference.

``` r

# Filter for degree seeking, output unique IDs
DT <- student[DT, .(mcid), on = c("mcid"), nomatch = NULL]
DT <- unique(DT)
```

------------------------------------------------------------------------

[◁ Data
sufficiency](https://midfieldr.github.io/midfieldr/articles/art-020-data-sufficiency.md)
   [▲ top of page](#top)    [Programs
▷](https://midfieldr.github.io/midfieldr/articles/art-040-programs.md)

------------------------------------------------------------------------

## References
