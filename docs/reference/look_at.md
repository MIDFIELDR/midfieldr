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
#> Classes 'data.table' and 'data.frame':   1582 obs. of  6 variables:
#>  $ cip6name: chr  "Agriculture, General" "Agricultural Business and Managemen"..
#>  $ cip6    : chr  "010000" "010101" "010102" "010103" ...
#>  $ cip4name: chr  "Agriculture, General" "Agricultural Business and Managemen"..
#>  $ cip4    : chr  "0100" "0101" "0101" "0101" ...
#>  $ cip2name: chr  "Agriculture, Agricultural Operations and Related Sciences""..
#>  $ cip2    : chr  "01" "01" "01" "01" ...
look_at(toy_degree)
#> Classes 'data.table' and 'data.frame':   96 obs. of  5 variables:
#>  $ mcid       : chr  "MCID3111159270" "MCID3111162677" "MCID3111164287" "MCID"..
#>  $ institution: chr  "Institution J" "Institution J" "Institution J" "Institu"..
#>  $ term_degree: chr  "19913" "19913" "19913" "19913" ...
#>  $ cip6       : chr  "141001" "140701" "141001" "270101" ...
#>  $ degree     : chr  "Bachelor of Science in Electrical Engineering" "Bachelo"..

# character vectors
x <- sort(unique(toy_degree$institution))
look_at(x)
#>  chr  "Institution B" "Institution C" "Institution J"
```
