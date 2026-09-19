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
sel_ids <- toy_student[14:18, (mcid)]

s <- toy_student[mcid %chin% sel_ids, .(mcid, sex)]
t <- toy_term[mcid %chin% sel_ids, .(mcid, term)]
d <- toy_degree[mcid %chin% sel_ids, .(mcid, term_degree)]

# No error
catch_error(filter_undergrad(t, d))
#>               mcid   term
#>             <char> <char>
#>  1: MCID3111213539  19891
#>  2: MCID3111213539  19893
#>  3: MCID3111213539  19901
#>  4: MCID3111213539  19903
#>  5: MCID3111213539  19911
#>  6: MCID3111213539  19913
#>  7: MCID3111213539  19921
#>  8: MCID3111213539  19923
#>  9: MCID3111213856  19891
#> 10: MCID3111213856  19893
#> 11: MCID3111213856  19901
#> 12: MCID3111213856  19903
#> 13: MCID3111213856  19904
#> 14: MCID3111246563  19901
#> 15: MCID3111246563  19903
#> 16: MCID3111254225  19901
#> 17: MCID3111254225  19903
#> 18: MCID3111254225  19911
#> 19: MCID3111254225  19923
#> 20: MCID3111254412  19901
#> 21: MCID3111254412  19903
#> 22: MCID3111254412  19911
#> 23: MCID3111254412  19913
#> 24: MCID3111254412  19921
#> 25: MCID3111254412  19931
#> 26: MCID3111254412  19933
#>               mcid   term
#>             <char> <char>

# Error, no term variable 
catch_error(filter_undergrad(s, d))
#> Error: Assertion on 'term_var' failed. Must be of length == 1, but has length 0. 

# Error, missing dframe argument
catch_error(filter_undergrad())
#> Error: argument "dframe" is missing, with no default 

# Error, missing degree argumeny
catch_error(filter_undergrad(t))
#> Error: object 'degree' not found 
```
