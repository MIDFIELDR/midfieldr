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
catch_error(post_completion_terms(t, d))
#>               mcid   term first_degree_term      term_cluster
#>             <char> <char>            <char>            <char>
#>  1: MCID3111213539  19891             19923        pre-degree
#>  2: MCID3111213539  19893             19923        pre-degree
#>  3: MCID3111213539  19901             19923        pre-degree
#>  4: MCID3111213539  19903             19923        pre-degree
#>  5: MCID3111213539  19911             19923        pre-degree
#>  6: MCID3111213539  19913             19923        pre-degree
#>  7: MCID3111213539  19921             19923        pre-degree
#>  8: MCID3111213539  19923             19923      first-degree
#>  9: MCID3111213539  19924             19923 post-first-degree
#> 10: MCID3111213856  19891             19911        pre-degree
#> 11: MCID3111213856  19893             19911        pre-degree
#> 12: MCID3111213856  19901             19911        pre-degree
#> 13: MCID3111213856  19903             19911        pre-degree
#> 14: MCID3111213856  19904             19911        pre-degree
#> 15: MCID3111246563  19901              <NA>        pre-degree
#> 16: MCID3111246563  19903              <NA>        pre-degree
#> 17: MCID3111254225  19901             19923        pre-degree
#> 18: MCID3111254225  19903             19923        pre-degree
#> 19: MCID3111254225  19911             19923        pre-degree
#> 20: MCID3111254225  19923             19923      first-degree
#> 21: MCID3111254412  19901             19933        pre-degree
#> 22: MCID3111254412  19903             19933        pre-degree
#> 23: MCID3111254412  19911             19933        pre-degree
#> 24: MCID3111254412  19913             19933        pre-degree
#> 25: MCID3111254412  19921             19933        pre-degree
#> 26: MCID3111254412  19931             19933        pre-degree
#> 27: MCID3111254412  19933             19933      first-degree
#>               mcid   term first_degree_term      term_cluster
#>             <char> <char>            <char>            <char>

# Error, no term variable 
catch_error(post_completion_terms(s, d))
#> Error: Assertion on 'term_var' failed. Must be of length == 1, but has length 0. 

# Error, missing dframe argument
catch_error(post_completion_terms())
#> Error: argument "dframe" is missing, with no default 

# Error, missing degree argument
catch_error(post_completion_terms(t))
#> Error: object 'degree' not found 
```
