# Choose rows of CIP data

Subset a CIP data frame, retaining rows that match or partially match
any string in a vector of character strings.

## Usage

``` r
filter_programs(dframe, pattern, ..., negate = NULL)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble) with
  CIP program names and codes, e.g., the `cip` dataset.

- pattern:

  Character vector of search strings, including regular expressions.

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- negate:

  Logical (default FALSE). If TRUE, inverts the resulting Boolean
  vector.

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Rows are a subset of the input; row order is preserved. Duplicated
  rows are removed.

- Columns are not modified.

## Details

Each element of the `pattern` vector is matched row-wise to every value
in `dframe` using `grepl().` If `negate = FALSE` (default), a match
retains the full row; if `negate = TRUE,` a match removes the full row.

## Examples

``` r
# Subset using keywords
filter_programs(cip, pattern = "history")
#>                                      cip6name   cip6
#>                                        <char> <char>
#>  1:       Architectural History and Criticism 040801
#>  2:                 History Teacher Education 131328
#>  3: Theatre Literature, History and Criticism 500505
#> ---                                                 
#> 12:                          Canadian History 540107
#> 13:                          Military History 540108
#> 14:                            History, Other 540199
#>                                                                   cip4name
#>                                                                     <char>
#>  1:                                    Architectural History and Criticism
#>  2: Teacher Education and Professional Development, Specific Subject Areas
#>  3:                                     Drama, Theatre Arts and Stagecraft
#> ---                                                                       
#> 12:                                                                History
#> 13:                                                                History
#> 14:                                                                History
#>       cip4                          cip2name   cip2
#>     <char>                            <char> <char>
#>  1:   0408 Architecture and Related Services     04
#>  2:   1313                         Education     13
#>  3:   5005        Visual and Performing Arts     50
#> ---                                                
#> 12:   5401                           History     54
#> 13:   5401                           History     54
#> 14:   5401                           History     54

# Subset using codes
filter_programs(cip, pattern = "^54")
#>                             cip6name   cip6 cip4name   cip4 cip2name   cip2
#>                               <char> <char>   <char> <char>   <char> <char>
#>  1:                 History, General 540101  History   5401  History     54
#>  2: American History (United States) 540102  History   5401  History     54
#>  3:                 European History 540103  History   5401  History     54
#> ---                                                                        
#>  7:                 Canadian History 540107  History   5401  History     54
#>  8:                 Military History 540108  History   5401  History     54
#>  9:                   History, Other 540199  History   5401  History     54

# Multiple passes to narrow the results
first_pass <- filter_programs(cip, "math")
first_pass[, .(cip6name, cip6)]
#>                                 cip6name   cip6
#>                                   <char> <char>
#>  1:        Mathematics Teacher Education 131311
#>  2:                 Biometry, Biometrics 261101
#>  3:                        Biostatistics 261102
#> ---                                            
#> 25:  Developmental, Remedial Mathematics 320104
#> 26: Theoretical and Mathematical Physics 400810
#> 27:                         Aromatherapy 513701

second_pass <- filter_programs(first_pass, c("bio", "educ"), negate = TRUE)
second_pass[, .(cip6name, cip6)]
#>                                                                cip6name   cip6
#>                                                                  <char> <char>
#>  1:                                                Mathematics, General 270101
#>  2:                                           Algebra and Number Theory 270102
#>  3:                                    Analysis and Functional Analysis 270103
#> ---                                                                           
#> 16:                                   Mathematics and Statistics, Other 279999
#> 17: Multi, Interdisciplinary Studies - Mathematics and Computer Science 300801
#> 18:                                Theoretical and Mathematical Physics 400810

third_pass <- filter_programs(second_pass, c("^27", "^30"))
third_pass[, .(cip6name, cip6)]
#>                                                                cip6name   cip6
#>                                                                  <char> <char>
#>  1:                                                Mathematics, General 270101
#>  2:                                           Algebra and Number Theory 270102
#>  3:                                    Analysis and Functional Analysis 270103
#> ---                                                                           
#> 15:                                                   Statistics, Other 270599
#> 16:                                   Mathematics and Statistics, Other 279999
#> 17: Multi, Interdisciplinary Studies - Mathematics and Computer Science 300801

# Multiple passes by chaining
chain_pass <- cip |>
    filter_programs("math") |>
    filter_programs(c("bio", "educ"), negate = TRUE) |>
    filter_programs(c("^27", "^30"))
chain_pass[, .(cip6name, cip6)]
#>                                                                cip6name   cip6
#>                                                                  <char> <char>
#>  1:                                                Mathematics, General 270101
#>  2:                                           Algebra and Number Theory 270102
#>  3:                                    Analysis and Functional Analysis 270103
#> ---                                                                           
#> 15:                                                   Statistics, Other 270599
#> 16:                                   Mathematics and Statistics, Other 279999
#> 17: Multi, Interdisciplinary Studies - Mathematics and Computer Science 300801
```
