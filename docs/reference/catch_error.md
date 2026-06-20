# Error handling

A wrapper on
[`base::tryCatch()`](https://rdrr.io/r/base/conditions.html) for
previewing an error message, if any.

## Usage

``` r
catch_error(f)
```

## Arguments

- f:

  Function with arguments expecting an error

## Value

Does not return anything. The side effect is to output to the terminal.

## Examples

``` r
# Example data frames
s <- toy_student[, .(mcid)]
t <- toy_term[, .(mcid, term)]
d <- toy_degree[, .(mcid, term_degree)]

# No error
catch_error(add_term_cluster(t, d))
#>                 mcid   term first_degree_term term_cluster
#>               <char> <char>            <char>       <char>
#>    1: MCID3111158953  19881              <NA>   pre-degree
#>    2: MCID3111158953  19883              <NA>   pre-degree
#>    3: MCID3111158953  19891              <NA>   pre-degree
#>    4: MCID3111158953  19893              <NA>   pre-degree
#>    5: MCID3111158953  19901              <NA>   pre-degree
#>   ---                                                     
#> 1091: MCID3112846308  20181              <NA>   pre-degree
#> 1092: MCID3112877403  20181              <NA>   pre-degree
#> 1093: MCID3112881399  20181              <NA>   pre-degree
#> 1094: MCID3112882995  20181              <NA>   pre-degree
#> 1095: MCID3112884375  20181              <NA>   pre-degree

# Error, no term variable 
catch_error(add_term_cluster(s, d))
#> Error: Assertion on 'term_variable' failed: Must be element of set {'term','term_course','term_degree'}, but is not atomic scalar. 

# Error, missing dframe argument
catch_error(add_term_cluster())
#> Error: argument "dframe" is missing, with no default 

# Error, missing degree argument
catch_error(add_term_cluster(t))
#> Error: object 'degree' not found 
```
