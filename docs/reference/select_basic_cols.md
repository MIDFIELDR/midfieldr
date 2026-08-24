# Choose columns of student records

Subset a MIDFIELD data table to retain the variables required by one or
more midfieldr functions. Variables that constitute the key or composite
key for a table are retained as well. A convenience function to reduce
the number of columns displayed.

## Usage

``` r
select_basic_cols(dframe)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble)
  equivalent to or derived from one of the MIDFIELD data tables:
  `{student, term, course, degree}.`

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Rows are not modified.

- Columns are a subset of the input, appearing in the same order.

## Details

Functions in midfieldr with a MIDFIELD dataset argument—such as
`student, term,` etc.—typically require only a few of the columns
available in the table. Depending on which table is input, the following
columns are returned if present:

- `student: {mcid, race, sex}`

- `term: {mcid, term, cip6, institution, level}`

- `course: {mcid, term_course, abbrev, number}`

- `degree: {mcid, term_degree, cip6}`

- Combination of the above if `dframe` contains columns from multiple
  tables.

## Examples

``` r
# Basic usage
select_basic_cols(toy_student[1:5])
#>              mcid          race    sex
#>            <char>        <char> <char>
#> 1: MCID3111142897 International   Male
#> 2: MCID3111157634         White Female
#> 3: MCID3111158724         White   Male
#> 4: MCID3111163443         White   Male
#> 5: MCID3111163894         White   Male
select_basic_cols(toy_term[1:5])
#>              mcid   term   cip6   institution          level
#>            <char> <char> <char>        <char>         <char>
#> 1: MCID3111142897  19881 400801 Institution B  01 First-year
#> 2: MCID3111157634  19881 240102 Institution J  01 First-year
#> 3: MCID3111157634  19883 040201 Institution J  01 First-year
#> 4: MCID3111157634  19891 040201 Institution J 02 Second-year
#> 5: MCID3111157634  19893 040201 Institution J 02 Second-year
select_basic_cols(toy_course[1:5])
#>              mcid term_course abbrev number
#>            <char>      <char> <char> <char>
#> 1: MCID3111142897       19881   APAS   3730
#> 2: MCID3111142897       19881   CSCI   1700
#> 3: MCID3111142897       19881   PHYS   7270
#> 4: MCID3111142897       19881   PHYS   7320
#> 5: MCID3111142897       19883   PHYS   5840
select_basic_cols(toy_degree[1:5])
#>              mcid term_degree   cip6
#>            <char>      <char> <char>
#> 1: MCID3111169601       19903 520201
#> 2: MCID3111169729       19901 520201
#> 3: MCID3111213539       19923 030103
#> 4: MCID3111213856       19911 261399
#> 5: MCID3111254225       19923 270101

# If the input is not strictly one of the four MIDFIELD data
# tables, all possible required columns are returned.
x <- toy_student[toy_degree, on = c("mcid")][1:5]
select_basic_cols(x)
#>              mcid     race    sex   institution term_degree   cip6
#>            <char>   <char> <char>        <char>      <char> <char>
#> 1: MCID3111169601 Hispanic   Male Institution B       19903 520201
#> 2: MCID3111169729    White Female Institution B       19901 520201
#> 3: MCID3111213539    White Female Institution B       19923 030103
#> 4: MCID3111213856    White Female Institution B       19911 261399
#> 5: MCID3111254225    White   Male Institution J       19923 270101

# Required columns can only be returned if present, 
# e.g., consider the result for a full table:
select_basic_cols(toy_term)
#> Index: <mcid>
#>                 mcid   term   cip6   institution          level
#>               <char> <char> <char>        <char>         <char>
#>    1: MCID3111142897  19881 400801 Institution B  01 First-year
#>    2: MCID3111157634  19881 240102 Institution J  01 First-year
#>    3: MCID3111157634  19883 040201 Institution J  01 First-year
#>    4: MCID3111157634  19891 040201 Institution J 02 Second-year
#>    5: MCID3111157634  19893 040201 Institution J 02 Second-year
#>   ---                                                          
#> 1817: MCID3112868072  20171 240199 Institution B  01 First-year
#> 1818: MCID3112868072  20173 380101 Institution B 02 Second-year
#> 1819: MCID3112869843  20173 240199 Institution B  01 First-year
#> 1820: MCID3112869843  20181 240199 Institution B  01 First-year
#> 1821: MCID3112885339  20181 520201 Institution B  01 First-year

# Compared to the result for a subset of the same table:
y <- toy_term[, .(mcid, term, cip6, hours_term, gpa_term)]
select_basic_cols(y)
#>                 mcid   term   cip6
#>               <char> <char> <char>
#>    1: MCID3111142897  19881 400801
#>    2: MCID3111157634  19881 240102
#>    3: MCID3111157634  19883 040201
#>    4: MCID3111157634  19891 040201
#>    5: MCID3111157634  19893 040201
#>   ---                             
#> 1817: MCID3112868072  20171 240199
#> 1818: MCID3112868072  20173 380101
#> 1819: MCID3112869843  20173 240199
#> 1820: MCID3112869843  20181 240199
#> 1821: MCID3112885339  20181 520201
```
