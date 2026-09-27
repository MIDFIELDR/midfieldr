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
# setup
selected_ids <- toy_student[14:18, (mcid)]
s <- toy_student[mcid %chin% selected_ids, .(mcid, sex)]
t <- toy_term[mcid %chin% selected_ids, .(mcid, term)]
d <- toy_degree[mcid %chin% selected_ids, .(mcid, term_degree)]

# No error
catch_error(pre_or_post_bacc(dframe = t, midf_table = d))
#>               mcid   term bacc_term pre_or_post
#>             <char> <char>    <char>      <char>
#>  1: MCID3111213539  19891     19923    pre-bacc
#>  2: MCID3111213539  19893     19923    pre-bacc
#>  3: MCID3111213539  19901     19923    pre-bacc
#>  4: MCID3111213539  19903     19923    pre-bacc
#>  5: MCID3111213539  19911     19923    pre-bacc
#>  6: MCID3111213539  19913     19923    pre-bacc
#>  7: MCID3111213539  19921     19923    pre-bacc
#>  8: MCID3111213539  19923     19923    pre-bacc
#>  9: MCID3111213539  19924     19923   post-bacc
#> 10: MCID3111213856  19891     19911    pre-bacc
#> 11: MCID3111213856  19893     19911    pre-bacc
#> 12: MCID3111213856  19901     19911    pre-bacc
#> 13: MCID3111213856  19903     19911    pre-bacc
#> 14: MCID3111213856  19904     19911    pre-bacc
#> 15: MCID3111246563  19901      <NA>    pre-bacc
#> 16: MCID3111246563  19903      <NA>    pre-bacc
#> 17: MCID3111254225  19901     19923    pre-bacc
#> 18: MCID3111254225  19903     19923    pre-bacc
#> 19: MCID3111254225  19911     19923    pre-bacc
#> 20: MCID3111254225  19923     19923    pre-bacc
#> 21: MCID3111254412  19901     19933    pre-bacc
#> 22: MCID3111254412  19903     19933    pre-bacc
#> 23: MCID3111254412  19911     19933    pre-bacc
#> 24: MCID3111254412  19913     19933    pre-bacc
#> 25: MCID3111254412  19921     19933    pre-bacc
#> 26: MCID3111254412  19931     19933    pre-bacc
#> 27: MCID3111254412  19933     19933    pre-bacc
#>               mcid   term bacc_term pre_or_post
#>             <char> <char>    <char>      <char>

# Error, no term variable in dframe
catch_error(pre_or_post_bacc(dframe = s, midf_table = d))
#> Error: Assertion on 'term_var' failed. Must be of length == 1, but has length 0. 

# Error, missing dframe argument
catch_error(pre_or_post_bacc(midf_table = d))
#> Error: argument "dframe" is missing, with no default 

# Error, missing degree value in environment
catch_error(pre_or_post_bacc(dframe = t))
#> Error: object 'degree' not found 
```
