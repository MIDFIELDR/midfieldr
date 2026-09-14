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
catch_error(is_undergrad(t, d))
#>               mcid   term bacc_term term_focus
#>             <char> <char>    <char>     <char>
#>  1: MCID3111213539  19891     19923  undergrad
#>  2: MCID3111213539  19893     19923  undergrad
#>  3: MCID3111213539  19901     19923  undergrad
#> ---                                           
#> 25: MCID3111254412  19921     19933  undergrad
#> 26: MCID3111254412  19931     19933  undergrad
#> 27: MCID3111254412  19933     19933  undergrad

# Error, no term variable 
catch_error(is_undergrad(s, d))
#> Error: Assertion on 'term_var' failed. Must be of length == 1, but has length 0. 

# Error, missing dframe argument
catch_error(is_undergrad())
#> Error: argument "dframe" is missing, with no default 

# Error, missing degree argumeny
catch_error(is_undergrad(t))
#>               mcid   term bacc_term term_focus
#>             <char> <char>    <char>     <char>
#>  1: MCID3111213539  19891     19923  undergrad
#>  2: MCID3111213539  19893     19923  undergrad
#>  3: MCID3111213539  19901     19923  undergrad
#> ---                                           
#> 25: MCID3111254412  19921     19933  undergrad
#> 26: MCID3111254412  19931     19933  undergrad
#> 27: MCID3111254412  19933     19933  undergrad
```
