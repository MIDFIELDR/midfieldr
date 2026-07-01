# Choose rows of CIP data

Subset a CIP data frame, retaining rows that match or partially match
any string in a vector of character strings.

## Usage

``` r
filter_programs(dframe, pattern, ..., negate = FALSE)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble).
  Expected variables (or subset thereof):
  `{cip6name, cip6, cip4name, cip4, cip2name, cip2}.`

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

- Rows are a subset of the input and appear in the same order.

- Columns are not modified.

## Details

Each element of the `pattern` vector is matched row-wise to every value
in `dframe` using `grepl().` Row values are coerced to character strings
if possible. If `negate = FALSE` (default), a match retains the full
row; if `negate = TRUE,` a match removes the full row.

## Examples

``` r
# Subset using keywords
filter_programs(cip, pattern = "history")
#>                                                cip6name   cip6
#>                                                  <char> <char>
#>  1:                 Architectural History and Criticism 040801
#>  2:                           History Teacher Education 131328
#>  3:           Theatre Literature, History and Criticism 500505
#>  4:             Art History, Criticism and Conservation 500703
#>  5:                Music History, Literature and Theory 500902
#>  6:                                    History, General 540101
#>  7:                    American History (United States) 540102
#>  8:                                    European History 540103
#>  9:    History and Philosophy of Science and Technology 540104
#> 10: Public, Applied History and Archival Administration 540105
#> 11:                                       Asian History 540106
#> 12:                                    Canadian History 540107
#> 13:                                    Military History 540108
#> 14:                                      History, Other 540199
#>                                                                   cip4name
#>                                                                     <char>
#>  1:                                    Architectural History and Criticism
#>  2: Teacher Education and Professional Development, Specific Subject Areas
#>  3:                                     Drama, Theatre Arts and Stagecraft
#>  4:                                                    Fine and Studio Art
#>  5:                                                                  Music
#>  6:                                                                History
#>  7:                                                                History
#>  8:                                                                History
#>  9:                                                                History
#> 10:                                                                History
#> 11:                                                                History
#> 12:                                                                History
#> 13:                                                                History
#> 14:                                                                History
#>       cip4                          cip2name   cip2
#>     <char>                            <char> <char>
#>  1:   0408 Architecture and Related Services     04
#>  2:   1313                         Education     13
#>  3:   5005        Visual and Performing Arts     50
#>  4:   5007        Visual and Performing Arts     50
#>  5:   5009        Visual and Performing Arts     50
#>  6:   5401                           History     54
#>  7:   5401                           History     54
#>  8:   5401                           History     54
#>  9:   5401                           History     54
#> 10:   5401                           History     54
#> 11:   5401                           History     54
#> 12:   5401                           History     54
#> 13:   5401                           History     54
#> 14:   5401                           History     54

# Subset using codes
filter_programs(cip, pattern = "^54")
#>                                               cip6name   cip6 cip4name   cip4
#>                                                 <char> <char>   <char> <char>
#> 1:                                    History, General 540101  History   5401
#> 2:                    American History (United States) 540102  History   5401
#> 3:                                    European History 540103  History   5401
#> 4:    History and Philosophy of Science and Technology 540104  History   5401
#> 5: Public, Applied History and Archival Administration 540105  History   5401
#> 6:                                       Asian History 540106  History   5401
#> 7:                                    Canadian History 540107  History   5401
#> 8:                                    Military History 540108  History   5401
#> 9:                                      History, Other 540199  History   5401
#>    cip2name   cip2
#>      <char> <char>
#> 1:  History     54
#> 2:  History     54
#> 3:  History     54
#> 4:  History     54
#> 5:  History     54
#> 6:  History     54
#> 7:  History     54
#> 8:  History     54
#> 9:  History     54

# Multiple passes to narrow the results
first_pass <- filter_programs(cip, "math")[, .(cip6name, cip6)]
first_pass
#>                                                                cip6name   cip6
#>                                                                  <char> <char>
#>  1:                                       Mathematics Teacher Education 131311
#>  2:                                                Biometry, Biometrics 261101
#>  3:                                                       Biostatistics 261102
#>  4:                                                      Bioinformatics 261103
#>  5:                                               Computational Biology 261104
#>  6:                            Biomathematics and Bioinformatics, Other 261199
#>  7:                                                Mathematics, General 270101
#>  8:                                           Algebra and Number Theory 270102
#>  9:                                    Analysis and Functional Analysis 270103
#> 10:                                        Geometry, Geometric Analysis 270104
#> 11:                                            Topology and Foundations 270105
#> 12:                                                  Mathematics, Other 270199
#> 13:                                                 Applied Mathematics 270301
#> 14:                                           Computational Mathematics 270303
#> 15:                               Computational and Applied Mathematics 270304
#> 16:                                               Financial Mathematics 270305
#> 17:                                                Mathematical Biology 270306
#> 18:                                          Applied Mathematics, Other 270399
#> 19:                                                 Statistics, General 270501
#> 20:                             Mathematical Statistics and Probability 270502
#> 21:                                          Mathematics and Statistics 270503
#> 22:                                                   Statistics, Other 270599
#> 23:                                   Mathematics and Statistics, Other 279999
#> 24: Multi, Interdisciplinary Studies - Mathematics and Computer Science 300801
#> 25:                                 Developmental, Remedial Mathematics 320104
#> 26:                                Theoretical and Mathematical Physics 400810
#> 27:                                                        Aromatherapy 513701
#>                                                                cip6name   cip6
#>                                                                  <char> <char>

second_pass <- filter_programs(first_pass, c("bio", "educ"), negate = TRUE)
second_pass
#>                                                                cip6name   cip6
#>                                                                  <char> <char>
#>  1:                                                Mathematics, General 270101
#>  2:                                           Algebra and Number Theory 270102
#>  3:                                    Analysis and Functional Analysis 270103
#>  4:                                        Geometry, Geometric Analysis 270104
#>  5:                                            Topology and Foundations 270105
#>  6:                                                  Mathematics, Other 270199
#>  7:                                                 Applied Mathematics 270301
#>  8:                                           Computational Mathematics 270303
#>  9:                               Computational and Applied Mathematics 270304
#> 10:                                               Financial Mathematics 270305
#> 11:                                          Applied Mathematics, Other 270399
#> 12:                                                 Statistics, General 270501
#> 13:                             Mathematical Statistics and Probability 270502
#> 14:                                          Mathematics and Statistics 270503
#> 15:                                                   Statistics, Other 270599
#> 16:                                   Mathematics and Statistics, Other 279999
#> 17: Multi, Interdisciplinary Studies - Mathematics and Computer Science 300801
#> 18:                                 Developmental, Remedial Mathematics 320104
#> 19:                                Theoretical and Mathematical Physics 400810
#> 20:                                                        Aromatherapy 513701
#>                                                                cip6name   cip6
#>                                                                  <char> <char>

third_pass <- filter_programs(second_pass, c("^27", "^30"))
third_pass
#>                                                                cip6name   cip6
#>                                                                  <char> <char>
#>  1:                                                Mathematics, General 270101
#>  2:                                           Algebra and Number Theory 270102
#>  3:                                    Analysis and Functional Analysis 270103
#>  4:                                        Geometry, Geometric Analysis 270104
#>  5:                                            Topology and Foundations 270105
#>  6:                                                  Mathematics, Other 270199
#>  7:                                                 Applied Mathematics 270301
#>  8:                                           Computational Mathematics 270303
#>  9:                               Computational and Applied Mathematics 270304
#> 10:                                               Financial Mathematics 270305
#> 11:                                          Applied Mathematics, Other 270399
#> 12:                                                 Statistics, General 270501
#> 13:                             Mathematical Statistics and Probability 270502
#> 14:                                          Mathematics and Statistics 270503
#> 15:                                                   Statistics, Other 270599
#> 16:                                   Mathematics and Statistics, Other 279999
#> 17: Multi, Interdisciplinary Studies - Mathematics and Computer Science 300801
 
```
