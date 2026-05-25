# Blocs

A *bloc* is a grouping of student-level records dealt with as a unit,
for example, a grouping of starters in a program, graduates of a
program, or ever enrolled in a program. We often use a *left join*
merging operation to add one or more variables to a working data frame
and filter on those variables to construct the desired bloc.

Different metrics require different blocs. Graduation rate, for example,
requires starters and their graduating subset; stickiness requires
ever-enrolled and their graduating subset. Subsequent articles describe
[FYE
proxies](https://midfieldr.github.io/midfieldr/articles/art-060-fye-proxies.md)
(special case of starters),
[Starters](https://midfieldr.github.io/midfieldr/articles/art-070-starters.md),
and
[Graduates](https://midfieldr.github.io/midfieldr/articles/art-080-graduates.md).
This article treats the *ever-enrolled* bloc and left joins generally.

Because a bloc is usually defined for specific programs, the final
filter applied in gathering a bloc is often an *inner join* to filter by
program labels, as derived in
[Programs](https://midfieldr.github.io/midfieldr/articles/art-040-programs.html#reusable-code).

This article in the MIDFIELD workflow:

1.  Planning  
2.  Initial processing  
3.  Blocs
    - Ever-enrolled
    - FYE proxies  
    - Starters  
    - Graduates  
4.  Groupings  
5.  Metrics  
6.  Displays

## Definitions

- bloc:

  A grouping of student-level data dealt with as a unit, for example,
  starters, students ever-enrolled, graduates, transfer students,
  traditional and non-traditional students, migrators, etc.

- degree-seeking:

  Describes students advancing toward a bachelor’s degree, accumulating
  credit hours in their program with the goal of graduating from their
  institution.

- ever-enrolled:

  Bloc of students whose term records include a specified program in at
  least one term.

- migrators:

  Bloc of students who leave one program to enroll in another. Also
  called *switchers.*

## Method

We use left joins to add variables to a working data frame and filter
for students ever-enrolled in the case study programs. Migrators (if
any) yield more than one observation (program) for the same ID.

1.  Filter source student-level data for data sufficiency and
    degree-seeking.

2.  Gather ever-enrolled

3.  Filter by program.

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
[`?term`](https://midfieldr.github.io/midfielddata/reference/term.html),
[`?degree`](https://midfieldr.github.io/midfielddata/reference/degree.html).

``` r

# Load practice data
data(student, term, degree)
```

*Loads with midfieldr.*   Prepared data. View data dictionary via
[`?study_programs`](https://midfieldr.github.io/midfieldr/reference/study_programs.md).

- `study_programs` (derived in
  [Programs](https://midfieldr.github.io/midfieldr/articles/art-040-programs.html#assigning-program-names)).

## Initial processing

*Select (optional).*   Reduce the number of columns. Code reproduced
from [Getting
started](https://midfieldr.github.io/midfieldr/articles/art-000-getting-started.html#reusable-code).

``` r

# Optional. Copy of source files with all variables
source_student <- copy(student)
source_term <- copy(term)
source_degree <- copy(degree)

# Optional. Select variables required by midfieldr functions
student <- select_required(source_student)
term <- select_required(source_term)
degree <- select_required(source_degree)
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

*Degree seeking.*   Filter to retain degree seeking students via an
inner join with `student`. Code reproduced from [Degree
seeking](https://midfieldr.github.io/midfieldr/articles/art-030-degree-seeking.html#reusable-code).

``` r

# Filter for degree seeking, output unique IDs
DT <- student[DT, .(mcid), on = c("mcid"), nomatch = NULL]
DT <- unique(DT)
```

*Verify prepared data.*   Many analyses begin, as we do here, by
filtering for data sufficiency and degree-seeking. For our convenience
in subsequent articles, this set of IDs is included with midfieldr in
the data set `baseline_mcid`. Here we verify that the two data frames
have the same content.

``` r

# Demonstrate equivalence
check_equiv_frames(DT, baseline_mcid)
#> [1] TRUE
```

We preserve this data frame as a baseline for examples in the article.

``` r

baseline <- copy(DT)
```

## Left joins

An left join is a merge operation between two data frames which returns
all observations (rows) of the “left” data frame `X` and all the
matching rows in the “right” data frame `Y`. Using data.table syntax, we
have two approaches: `merge(X, Y, by)` (similar to base R) and
`Y[X, j, on]` (native to data.table).

### Using `merge(X, Y, by)`

The general form for a left join is

        merge(X, Y, by, all.x = TRUE)

where

- `X` is the “left” data frame, all rows returned  
- `Y` is the “right” data frame, matching rows returned
- `by` is the vector of shared column names to merge by  
- `all.x = TRUE` ensures the left join

In this example, the `Y` data frame is `term`, from which we extract the
ID and CIP columns before the join.

``` r

# Subset of term data frame to join
cols_we_want <- term[, .(mcid, cip6)]

# merge(X, Y, by) left join
merge(DT, cols_we_want, by = c("mcid"), all.x = TRUE)
#> Key: <mcid>
#>                   mcid   cip6
#>                 <char> <char>
#>      1: MCID3111142689 090401
#>      2: MCID3111142782 260101
#>      3: MCID3111142782 260101
#>     ---                      
#> 531417: MCID3112870009 240102
#> 531418: MCID3112870009 240102
#> 531419: MCID3112870009 240102
```

Alternatively, one can select `Y` columns within the merge operation.

``` r

# merge(X, Y, by) left join
merge(DT, term[, .(mcid, cip6)], by = c("mcid"), all.x = TRUE)
#> Key: <mcid>
#>                   mcid   cip6
#>                 <char> <char>
#>      1: MCID3111142689 090401
#>      2: MCID3111142782 260101
#>      3: MCID3111142782 260101
#>     ---                      
#> 531417: MCID3112870009 240102
#> 531418: MCID3112870009 240102
#> 531419: MCID3112870009 240102
```

### Using `Y[X, j, on]`

The second approach—native to data.table and computationally more
efficient—has the form

        Y[X, j, on]

where

- `X` is the “left” data frame, all rows returned  
- `Y` is the “right” data frame, matching rows returned
- `j` selects columns from the joined data frame to retain
- `on` is the vector of shared column names to merge on

``` r

# Y[X, j, on] left join (data.table native syntax)
term[DT, .(mcid, cip6), on = c("mcid")]
#>                   mcid   cip6
#>                 <char> <char>
#>      1: MCID3111142689 090401
#>      2: MCID3111142782 260101
#>      3: MCID3111142782 260101
#>     ---                      
#> 531417: MCID3112870009 240102
#> 531418: MCID3112870009 240102
#> 531419: MCID3112870009 240102
```

*Demonstrate equivalence.* Showing that the two approaches produce the
same result.

``` r

# merge(X, Y, by) left join
x <- merge(DT, term[, .(mcid, cip6)], by = c("mcid"), all.x = TRUE)
setkey(x, NULL)

# Y[X, j, on] left join
y <- term[DT, .(mcid, cip6), on = c("mcid")]

# Demonstrate equivalence
check_equiv_frames(x, y)
#> [1] TRUE
```

### Left join matching rules

*Rows in X with no match in Y*   will have NA values in the columns
normally filled with `Y` values.

For example, not all students in `DT` will earn a degree. After a left
join (`degree` into `DT`), all rows of `DT` are returned. IDs in `DT`
with no match in `degree` have an NA in the `term_degree` column (a
variable from the `degree` source table).

``` r

x <- degree[DT, .(mcid, term_degree), on = c("mcid")]
setkeyv(x, c("mcid"))
x[]
#> Key: <mcid>
#>                  mcid term_degree
#>                <char>      <char>
#>     1: MCID3111142689       19913
#>     2: MCID3111142782       19903
#>     3: MCID3111142881       19894
#>     4: MCID3111142884        <NA>
#>     5: MCID3111142893        <NA>
#>    ---                           
#> 76988: MCID3112727985        <NA>
#> 76989: MCID3112730841       20164
#> 76990: MCID3112785480        <NA>
#> 76991: MCID3112800920        <NA>
#> 76992: MCID3112870009        <NA>
```

The result has 76,875 unique IDs with 43,903 degrees.

*Rows in X with multiple matches in Y*   yields a new row in `X` for
every matching row in `Y`.

For example, most students in `DT` will be enrolled in multiple terms.
After a left join (`term` into `DT`), all rows in `DT` are returned. IDs
in `DT` with multiple matches in `term` have multiple rows in the
result, differentiated by the values in the `term` column (a variable
from the `term` source table).

``` r

x <- term[DT, .(mcid, term), on = c("mcid")]
setkeyv(x, c("mcid", "term"))
x[]
#> Key: <mcid, term>
#>                   mcid   term
#>                 <char> <char>
#>      1: MCID3111142689  19883
#>      2: MCID3111142782  19883
#>      3: MCID3111142782  19885
#>      4: MCID3111142782  19893
#>      5: MCID3111142782  19895
#>     ---                      
#> 531415: MCID3112800920  20163
#> 531416: MCID3112870009  19951
#> 531417: MCID3112870009  19953
#> 531418: MCID3112870009  19954
#> 531419: MCID3112870009  19983
```

The result has 76,875 unique IDs distributed over 531,419 observations.

*“Left” and “right” matter.*   In left joins (unlike inner joins),
`X[Y]` and `Y[X]` return different results:

- `Y[X, j, on]` returns all rows of `X`

- `X[Y, j, on]` returns all rows of `Y`

``` r

# What we want
x <- degree[DT, .(mcid, term_degree), on = c("mcid")]

# Not what we want
y <- DT[degree, .(mcid, term_degree), on = c("mcid")]

# Same content?
check_equiv_frames(x, y)
#> [1] FALSE

# Compare N rows
nrow(x)
#> [1] 76992
nrow(y)
#> [1] 49665
```

## Ever-enrolled

*Work.*   The baseline data frame we preserved earlier is the intake for
this section.

``` r

# Reusable starting state
DT <- copy(baseline)
DT[]
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

*Add a variable.*   Use a left join from `term` to `DT` to add the CIP
variable.

``` r

# Left-outer join from term to DT
DT <- term[DT, .(mcid, cip6), on = c("mcid")]
```

*Filter.*   Filter to retain unique combinations if ID and CIP code.

``` r

# One observation per ID-CIP combination
DT <- unique(DT)
DT
#>                   mcid   cip6
#>                 <char> <char>
#>      1: MCID3111142689 090401
#>      2: MCID3111142782 260101
#>      3: MCID3111142881 450601
#>     ---                      
#> 127347: MCID3112800920 240102
#> 127348: MCID3112800920 240199
#> 127349: MCID3112870009 240102
```

## Filter by program

*Filter.*   Because “ever-enrolled” usually means “ever-enrolled in
specific programs,” this bloc concludes with a filter by program. Code
reproduced from
[Groupings](https://midfieldr.github.io/midfieldr/articles/art-090-groupings.html#program-labels).

``` r

# Filter by program
DT <- study_programs[DT, on = c("cip6"), nomatch = NULL]
DT[, cip6 := NULL]
DT <- unique(DT)
DT
#>       program           mcid
#>        <char>         <char>
#>    1:      EE MCID3111142965
#>    2:      EE MCID3111145102
#>    3:      EE MCID3111146537
#>   ---                       
#> 5651:      ME MCID3112641399
#> 5652:      ME MCID3112641535
#> 5653:      ME MCID3112698681
```

## Reusable code

*Preparation.*   The baseline data frame we preserved earlier is the
intake for this section.

``` r

DT <- copy(baseline)
```

*Ever-enrolled.*   A summary code chunk for ready reference. Requires
editing of `study_programs` before reuse with different programs.

``` r

# Ever-enrolled bloc
DT <- term[DT, .(mcid, cip6), on = c("mcid")]
DT <- unique(DT)

# Filter by program
DT <- study_programs[DT, on = c("cip6"), nomatch = NULL]
DT[, cip6 := NULL]
DT <- unique(DT)
```

------------------------------------------------------------------------

[◁
Programs](https://midfieldr.github.io/midfieldr/articles/art-040-programs.md)
   [▲ top of page](#top)    [FYE proxies
▷](https://midfieldr.github.io/midfieldr/articles/art-060-fye-proxies.md)

------------------------------------------------------------------------

## References
