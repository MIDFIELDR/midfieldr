# Display structure

A wrapper on `base::str()` with arguments set to not show attributes, to
not show length, and to cut the width.

## Usage

``` r
look_at(x)
```

## Arguments

- x:

  Any R object.

## Value

Does not return anything. The side effect is to output to the terminal.

## Examples

``` r
# data frames
look_at(cip)
#> Classes ‘data.table’ and 'data.frame':   1582 obs. of  6 variables:
#>  $ cip6name: chr  "Agriculture, General" "Agricultural Business and Managemen"..
#>  $ cip6    : chr  "010000" "010101" "010102" "010103" ...
#>  $ cip4name: chr  "Agriculture, General" "Agricultural Business and Managemen"..
#>  $ cip4    : chr  "0100" "0101" "0101" "0101" ...
#>  $ cip2name: chr  "Agriculture, Agricultural Operations and Related Sciences""..
#>  $ cip2    : chr  "01" "01" "01" "01" ...
look_at(toy_degree)
#> Classes ‘data.table’ and 'data.frame':   193 obs. of  5 variables:
#>  $ mcid       : chr  "MCID3111169601" "MCID3111169729" "MCID3111213539" "MCID"..
#>  $ term_degree: chr  "19903" "19901" "19923" "19911" ...
#>  $ cip6       : chr  "520201" "520201" "030103" "261399" ...
#>  $ institution: chr  "Institution B" "Institution B" "Institution B" "Institu"..
#>  $ degree     : chr  "Bachelor of Science in Business Administration and Mana"..

# character vectors
x <- sort(unique(toy_degree$institution))
look_at(x)
#>  chr  "Institution B" "Institution C" "Institution J"
```
