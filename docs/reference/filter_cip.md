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
#>        cip2                                         cip2name   cip4
#>      <char>                                           <char> <char>
#>   1:     14                                      Engineering   1401
#>   2:     14                                      Engineering   1401
#>   3:     14                                      Engineering   1402
#>   4:     14                                      Engineering   1403
#>   5:     14                                      Engineering   1404
#>  ---                                                               
#> 115:     15                           Engineering Technology   1516
#> 116:     15                           Engineering Technology   1599
#> 117:     29                            Military Technologies   2903
#> 118:     29                            Military Technologies   2903
#> 119:     51 Health Professions and Related Clinical Sciences   5123
#>                                                     cip4name   cip6
#>                                                       <char> <char>
#>   1:                                    Engineering, General 140101
#>   2:                                    Engineering, General 140102
#>   3:   Aerospace, Aeronautical and Astronautical Engineering 140201
#>   4: Agricultural, Biological Engineering and Bioengineering 140301
#>   5:                               Architectural Engineering 140401
#>  ---                                                               
#> 115:                                          Nanotechnology 151601
#> 116:    Engineering-Related Technologies, Technicians, Other 159999
#> 117:                               Military Applied Sciences 290301
#> 118:                               Military Applied Sciences 290303
#> 119:              Rehabilitation and Therapeutic Professions 512312
#>                                                              cip6name
#>                                                                <char>
#>   1:                                             Engineering, General
#>   2:                                                  Pre-Engineering
#>   3:     Aerospace, Aeronautical and Astronautical, Space Engineering
#>   4:          Agricultural, Biological Engineering and Bioengineering
#>   5:                                        Architectural Engineering
#>  ---                                                                 
#> 115:                                                   Nanotechnology
#> 116:             Engineering Related Technologies, Technicians, Other
#> 117:                                       Combat Systems Engineering
#> 118:                                            Engineering Acoustics
#> 119: Assistive, Augmentative Technology and Rehabiliation Engineering

# \donttest{
    # Multiple passes to narrow the results
    first_pass <- filter_cip("civil")
    second_pass <- filter_cip("engineering", cip = first_pass)
    filter_cip(drop_text = "technology", cip = second_pass)
#>      cip2    cip2name   cip4          cip4name   cip6
#>    <char>      <char> <char>            <char> <char>
#> 1:     14 Engineering   1408 Civil Engineering 140801
#> 2:     14 Engineering   1408 Civil Engineering 140802
#> 3:     14 Engineering   1408 Civil Engineering 140803
#> 4:     14 Engineering   1408 Civil Engineering 140804
#> 5:     14 Engineering   1408 Civil Engineering 140805
#> 6:     14 Engineering   1408 Civil Engineering 140899
#>                                  cip6name
#>                                    <char>
#> 1:             Civil Engineering, General
#> 2:               Geotechnical Engineering
#> 3:                 Structural Engineering
#> 4: Transportation and Highway Engineering
#> 5:            Water Resources Engineering
#> 6:               Civil Engineering, Other
    
    # drop_text argument, when used, must be named
    filter_cip("civil engineering", drop_text = "technology")
#>      cip2    cip2name   cip4          cip4name   cip6
#>    <char>      <char> <char>            <char> <char>
#> 1:     14 Engineering   1408 Civil Engineering 140801
#> 2:     14 Engineering   1408 Civil Engineering 140802
#> 3:     14 Engineering   1408 Civil Engineering 140803
#> 4:     14 Engineering   1408 Civil Engineering 140804
#> 5:     14 Engineering   1408 Civil Engineering 140805
#> 6:     14 Engineering   1408 Civil Engineering 140899
#>                                  cip6name
#>                                    <char>
#> 1:             Civil Engineering, General
#> 2:               Geotechnical Engineering
#> 3:                 Structural Engineering
#> 4: Transportation and Highway Engineering
#> 5:            Water Resources Engineering
#> 6:               Civil Engineering, Other
    
    # Subset using numerical codes
    filter_cip(keep_text = c("050125", "160501"))
#>      cip2                                            cip2name   cip4
#>    <char>                                              <char> <char>
#> 1:     05 Area, Ethnic, Cultural and Gender and Group Studies   0501
#> 2:     16      Foreign Languages, Literatures and Linguistics   1605
#>                                       cip4name   cip6
#>                                         <char> <char>
#> 1:                                Area Studies 050125
#> 2: Germanic Languages, Literatures Linguistics 160501
#>                          cip6name
#>                            <char>
#> 1:                 German Studies
#> 2: German Language and Literature
    
    # Subset using regular expressions
    filter_cip(keep_text = "^54")
#>      cip2 cip2name   cip4 cip4name   cip6
#>    <char>   <char> <char>   <char> <char>
#> 1:     54  History   5401  History 540101
#> 2:     54  History   5401  History 540102
#> 3:     54  History   5401  History 540103
#> 4:     54  History   5401  History 540104
#> 5:     54  History   5401  History 540105
#> 6:     54  History   5401  History 540106
#> 7:     54  History   5401  History 540107
#> 8:     54  History   5401  History 540108
#> 9:     54  History   5401  History 540199
#>                                               cip6name
#>                                                 <char>
#> 1:                                    History, General
#> 2:                    American History (United States)
#> 3:                                    European History
#> 4:    History and Philosophy of Science and Technology
#> 5: Public, Applied History and Archival Administration
#> 6:                                       Asian History
#> 7:                                    Canadian History
#> 8:                                    Military History
#> 9:                                      History, Other
    filter_cip(keep_text = c("^1407", "^1408"))
#>      cip2    cip2name   cip4             cip4name   cip6
#>    <char>      <char> <char>               <char> <char>
#> 1:     14 Engineering   1407 Chemical Engineering 140701
#> 2:     14 Engineering   1407 Chemical Engineering 140702
#> 3:     14 Engineering   1407 Chemical Engineering 140799
#> 4:     14 Engineering   1408    Civil Engineering 140801
#> 5:     14 Engineering   1408    Civil Engineering 140802
#> 6:     14 Engineering   1408    Civil Engineering 140803
#> 7:     14 Engineering   1408    Civil Engineering 140804
#> 8:     14 Engineering   1408    Civil Engineering 140805
#> 9:     14 Engineering   1408    Civil Engineering 140899
#>                                  cip6name
#>                                    <char>
#> 1:                   Chemical Engineering
#> 2:  Chemical and Biomolecular Engineering
#> 3:            Chemical Engineering, Other
#> 4:             Civil Engineering, General
#> 5:               Geotechnical Engineering
#> 6:                 Structural Engineering
#> 7: Transportation and Highway Engineering
#> 8:            Water Resources Engineering
#> 9:               Civil Engineering, Other
    
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
