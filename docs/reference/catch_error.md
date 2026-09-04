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
catch_error(qualification_level(t, d))
#>               mcid   term   bacc qual_level
#>             <char> <char> <char>     <char>
#>  1: MCID3111213539  19891  19923  undergrad
#>  2: MCID3111213539  19893  19923  undergrad
#>  3: MCID3111213539  19901  19923  undergrad
#>  4: MCID3111213539  19903  19923  undergrad
#>  5: MCID3111213539  19911  19923  undergrad
#>  6: MCID3111213539  19913  19923  undergrad
#>  7: MCID3111213539  19921  19923  undergrad
#>  8: MCID3111213539  19923  19923  undergrad
#>  9: MCID3111213539  19924  19923  post-bacc
#> 10: MCID3111213856  19891  19911  undergrad
#> 11: MCID3111213856  19893  19911  undergrad
#> 12: MCID3111213856  19901  19911  undergrad
#> 13: MCID3111213856  19903  19911  undergrad
#> 14: MCID3111213856  19904  19911  undergrad
#> 15: MCID3111246563  19901   <NA>  undergrad
#> 16: MCID3111246563  19903   <NA>  undergrad
#> 17: MCID3111254225  19901  19923  undergrad
#> 18: MCID3111254225  19903  19923  undergrad
#> 19: MCID3111254225  19911  19923  undergrad
#> 20: MCID3111254225  19923  19923  undergrad
#> 21: MCID3111254412  19901  19933  undergrad
#> 22: MCID3111254412  19903  19933  undergrad
#> 23: MCID3111254412  19911  19933  undergrad
#> 24: MCID3111254412  19913  19933  undergrad
#> 25: MCID3111254412  19921  19933  undergrad
#> 26: MCID3111254412  19931  19933  undergrad
#> 27: MCID3111254412  19933  19933  undergrad
#>               mcid   term   bacc qual_level
#>             <char> <char> <char>     <char>

# Error, no term variable 
catch_error(qualification_level(s, d))
#> Error: Assertion on 'term_var' failed. Must be of length == 1, but has length 0. 

# Error, missing dframe argument
catch_error(qualification_level())
#> Error: argument "dframe" is missing, with no default 

# Error, missing degree argumeny
catch_error(qualification_level(t))
#> Error: object 'degree' not found 
```
