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
#> Error: could not find function "post_completion_terms" 

# Error, no term variable 
catch_error(post_completion_terms(s, d))
#> Error: could not find function "post_completion_terms" 

# Error, missing dframe argument
catch_error(post_completion_terms())
#> Error: could not find function "post_completion_terms" 

# Error, missing degree argument
catch_error(post_completion_terms(t))
#> Error: could not find function "post_completion_terms" 
```
