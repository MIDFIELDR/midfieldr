# Notes on syntax

``` r

library("midfieldr")
library("midfielddata")
library("data.table")
library("tibble")
```

*On printing data frame:*   Set the following data frame printing
options to print all columns with the total number of rows set by
`print_all_rows_max`.

``` r

# set max number of rows to display
print_all_rows_max <- 6

# data.table syntax
half_max <- round(print_all_rows_max / 2, 0)
options(
  datatable.print.nrows = print_all_rows_max,
  datatable.print.topn = half_max
)

# dplyr/tibble syntax
options(
  pillar.width = Inf,
  pillar.print_max = print_all_rows_max,
  pillar.print_min = print_all_rows_max
)
```

For example

``` r

# data.table syntax
x <- copy(toy_student)
as.data.table(x)
#>                mcid          race    sex   institution              transfer
#>              <char>        <char> <char>        <char>                <char>
#>   1: MCID3111142897 International   Male Institution B   First-Time Transfer
#>   2: MCID3111157634         White Female Institution J First-Time in College
#>   3: MCID3111158724         White   Male Institution J First-Time in College
#>  ---                                                                        
#> 349: MCID3112868072         White   Male Institution B First-Time in College
#> 350: MCID3112869843         White Female Institution B   First-Time Transfer
#> 351: MCID3112885339         White   Male Institution B First-Time in College
#>      hours_transfer age_desc us_citizen home_zip high_school sat_math
#>               <num>   <char>     <char>   <char>      <char>    <num>
#>   1:             NA Under 25         No     <NA>        <NA>       NA
#>   2:             NA Under 25        Yes    23842      471790      610
#>   3:             NA Under 25        Yes    22026      471345      760
#>  ---                                                                 
#> 349:             NA Under 25        Yes    98354      481345      670
#> 350:             NA Under 25        Yes    80238      060400       NA
#> 351:             NA Under 25        Yes    81615      060060      600
#>      sat_verbal act_comp
#>           <num>    <num>
#>   1:         NA       NA
#>   2:        550       NA
#>   3:        560       NA
#>  ---                    
#> 349:        460       25
#> 350:         NA       28
#> 351:        640       29

# tibble syntax
library(tibble)
as_tibble(x)
#> # A tibble: 351 × 13
#>   mcid           race          sex    institution   transfer             
#>   <chr>          <chr>         <chr>  <chr>         <chr>                
#> 1 MCID3111142897 International Male   Institution B First-Time Transfer  
#> 2 MCID3111157634 White         Female Institution J First-Time in College
#> 3 MCID3111158724 White         Male   Institution J First-Time in College
#> 4 MCID3111163443 White         Male   Institution J First-Time in College
#> 5 MCID3111163894 White         Male   Institution J First-Time in College
#> 6 MCID3111164659 White         Male   Institution J First-Time in College
#>   hours_transfer age_desc us_citizen home_zip high_school sat_math sat_verbal
#>            <dbl> <chr>    <chr>      <chr>    <chr>          <dbl>      <dbl>
#> 1             NA Under 25 No         NA       NA                NA         NA
#> 2             NA Under 25 Yes        23842    471790           610        550
#> 3             NA Under 25 Yes        22026    471345           760        560
#> 4             NA Under 25 Yes        22075    471230           790        630
#> 5             NA Under 25 Yes        33157    101623           600        640
#> 6             NA Under 25 Yes        22207    470130           600        660
#>   act_comp
#>      <dbl>
#> 1       NA
#> 2       NA
#> 3       NA
#> 4       NA
#> 5       NA
#> 6       NA
#> # ℹ 345 more rows

# base R syntax
x <- as.data.frame(x)
head(x, n = print_all_rows_max)
#>             mcid          race    sex   institution              transfer
#> 1 MCID3111142897 International   Male Institution B   First-Time Transfer
#> 2 MCID3111157634         White Female Institution J First-Time in College
#> 3 MCID3111158724         White   Male Institution J First-Time in College
#> 4 MCID3111163443         White   Male Institution J First-Time in College
#> 5 MCID3111163894         White   Male Institution J First-Time in College
#> 6 MCID3111164659         White   Male Institution J First-Time in College
#>   hours_transfer age_desc us_citizen home_zip high_school sat_math sat_verbal
#> 1             NA Under 25         No     <NA>        <NA>       NA         NA
#> 2             NA Under 25        Yes    23842      471790      610        550
#> 3             NA Under 25        Yes    22026      471345      760        560
#> 4             NA Under 25        Yes    22075      471230      790        630
#> 5             NA Under 25        Yes    33157      101623      600        640
#> 6             NA Under 25        Yes    22207      470130      600        660
#>   act_comp
#> 1       NA
#> 2       NA
#> 3       NA
#> 4       NA
#> 5       NA
#> 6       NA
```
