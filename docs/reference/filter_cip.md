# Subset rows that include matches to search strings

Subset a CIP data frame, retaining rows that match or partially match a
vector of character strings. Columns are not subset unless selected in
an optional argument.

## Usage

``` r
filter_cip(keep_text = NULL, ..., drop_text = NULL, cip = NULL, select = NULL)
```

## Arguments

- keep_text:

  Character vector of search text for retaining rows, not
  case-sensitive. Can be empty if `drop_text` is used.

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- drop_text:

  Optional character vector of search text for dropping rows, default
  NULL.

- cip:

  Data frame to be searched. Default `cip`.

- select:

  Optional character vector of column names to return, default all
  columns.

## Value

A data frame in `data.table` format, a subset of `cip`, with the
following properties: exclude rows that match elements of `drop_text`;
of the remaining rows, include those that match elements of `keep_text`;
if `select` is empty, all columns are preserved, otherwise only columns
included in `select` are retained; grouping structures are not
preserved.

## Details

Search terms can include regular expressions. Uses
[`grepl()`](https://rdrr.io/r/base/grep.html), therefore non-character
columns (if any) that can be coerced to character are also searched for
matches. Columns are subset by the values in `select` after the search
concludes.

If none of the optional arguments are specified, the function returns
the original data frame.

## Examples

``` r
# Subset using keywords
filter_cip(keep_text = "engineering")
#>                                                              cip6name   cip6
#>                                                                <char> <char>
#>   1:                                             Engineering, General 140101
#>   2:                                                  Pre-Engineering 140102
#>   3:     Aerospace, Aeronautical and Astronautical, Space Engineering 140201
#>   4:          Agricultural, Biological Engineering and Bioengineering 140301
#>   5:                                        Architectural Engineering 140401
#>  ---                                                                        
#> 115:                                                   Nanotechnology 151601
#> 116:             Engineering Related Technologies, Technicians, Other 159999
#> 117:                                       Combat Systems Engineering 290301
#> 118:                                            Engineering Acoustics 290303
#> 119: Assistive, Augmentative Technology and Rehabiliation Engineering 512312
#>                                                     cip4name   cip4
#>                                                       <char> <char>
#>   1:                                    Engineering, General   1401
#>   2:                                    Engineering, General   1401
#>   3:   Aerospace, Aeronautical and Astronautical Engineering   1402
#>   4: Agricultural, Biological Engineering and Bioengineering   1403
#>   5:                               Architectural Engineering   1404
#>  ---                                                               
#> 115:                                          Nanotechnology   1516
#> 116:    Engineering-Related Technologies, Technicians, Other   1599
#> 117:                               Military Applied Sciences   2903
#> 118:                               Military Applied Sciences   2903
#> 119:              Rehabilitation and Therapeutic Professions   5123
#>                                              cip2name   cip2
#>                                                <char> <char>
#>   1:                                      Engineering     14
#>   2:                                      Engineering     14
#>   3:                                      Engineering     14
#>   4:                                      Engineering     14
#>   5:                                      Engineering     14
#>  ---                                                        
#> 115:                           Engineering Technology     15
#> 116:                           Engineering Technology     15
#> 117:                            Military Technologies     29
#> 118:                            Military Technologies     29
#> 119: Health Professions and Related Clinical Sciences     51

# \donttest{
    # Multiple passes to narrow the results
    first_pass <- filter_cip("civil")
    second_pass <- filter_cip("engineering", cip = first_pass)
    filter_cip(drop_text = "technology", cip = second_pass)
#>                                  cip6name   cip6          cip4name   cip4
#>                                    <char> <char>            <char> <char>
#> 1:             Civil Engineering, General 140801 Civil Engineering   1408
#> 2:               Geotechnical Engineering 140802 Civil Engineering   1408
#> 3:                 Structural Engineering 140803 Civil Engineering   1408
#> 4: Transportation and Highway Engineering 140804 Civil Engineering   1408
#> 5:            Water Resources Engineering 140805 Civil Engineering   1408
#> 6:               Civil Engineering, Other 140899 Civil Engineering   1408
#>       cip2name   cip2
#>         <char> <char>
#> 1: Engineering     14
#> 2: Engineering     14
#> 3: Engineering     14
#> 4: Engineering     14
#> 5: Engineering     14
#> 6: Engineering     14
    
    # drop_text argument, when used, must be named
    filter_cip("civil engineering", drop_text = "technology")
#>                                  cip6name   cip6          cip4name   cip4
#>                                    <char> <char>            <char> <char>
#> 1:             Civil Engineering, General 140801 Civil Engineering   1408
#> 2:               Geotechnical Engineering 140802 Civil Engineering   1408
#> 3:                 Structural Engineering 140803 Civil Engineering   1408
#> 4: Transportation and Highway Engineering 140804 Civil Engineering   1408
#> 5:            Water Resources Engineering 140805 Civil Engineering   1408
#> 6:               Civil Engineering, Other 140899 Civil Engineering   1408
#>       cip2name   cip2
#>         <char> <char>
#> 1: Engineering     14
#> 2: Engineering     14
#> 3: Engineering     14
#> 4: Engineering     14
#> 5: Engineering     14
#> 6: Engineering     14
    
    # Subset using numerical codes
    filter_cip(keep_text = c("050125", "160501"))
#>                          cip6name   cip6
#>                            <char> <char>
#> 1:                 German Studies 050125
#> 2: German Language and Literature 160501
#>                                       cip4name   cip4
#>                                         <char> <char>
#> 1:                                Area Studies   0501
#> 2: Germanic Languages, Literatures Linguistics   1605
#>                                               cip2name   cip2
#>                                                 <char> <char>
#> 1: Area, Ethnic, Cultural and Gender and Group Studies     05
#> 2:      Foreign Languages, Literatures and Linguistics     16
    
    # Subset using regular expressions
    filter_cip(keep_text = "^54")
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
    filter_cip(keep_text = c("^1407", "^1408"))
#>                                  cip6name   cip6             cip4name   cip4
#>                                    <char> <char>               <char> <char>
#> 1:                   Chemical Engineering 140701 Chemical Engineering   1407
#> 2:  Chemical and Biomolecular Engineering 140702 Chemical Engineering   1407
#> 3:            Chemical Engineering, Other 140799 Chemical Engineering   1407
#> 4:             Civil Engineering, General 140801    Civil Engineering   1408
#> 5:               Geotechnical Engineering 140802    Civil Engineering   1408
#> 6:                 Structural Engineering 140803    Civil Engineering   1408
#> 7: Transportation and Highway Engineering 140804    Civil Engineering   1408
#> 8:            Water Resources Engineering 140805    Civil Engineering   1408
#> 9:               Civil Engineering, Other 140899    Civil Engineering   1408
#>       cip2name   cip2
#>         <char> <char>
#> 1: Engineering     14
#> 2: Engineering     14
#> 3: Engineering     14
#> 4: Engineering     14
#> 5: Engineering     14
#> 6: Engineering     14
#> 7: Engineering     14
#> 8: Engineering     14
#> 9: Engineering     14
    
    # Select columns
    filter_cip(keep_text = "^54", select = c("cip6", "cip4name"))
#>      cip6 cip4name
#>    <char>   <char>
#> 1: 540101  History
#> 2: 540102  History
#> 3: 540103  History
#> 4: 540104  History
#> 5: 540105  History
#> 6: 540106  History
#> 7: 540107  History
#> 8: 540108  History
#> 9: 540199  History
# }
```
