# Programs

In the US, instructional programs are encoded by 6-digit numbers curated
by the US Department of Education. The standard encoding format is a
two-digit number followed by a period, followed by a four-digit number,
for example, 14.0102.

MIDFIELD encodes programs using the same 6 digits without the period,
e.g., 140102, recorded as character strings under the `cip6` variable in
the relevant data tables. As strings, any leading zeros are preserved,
e.g., 010101, 030101, etc.

## Introduction

Academic programs have three levels of codes and names:

- 6-digit code, a specific program
- 4-digit code, a group of 6-digit programs of comparable content
- 2-digit code, a grouping of 4-digit groups of related content

Specialties within a discipline are encoded at the 6-digit level, the
discipline itself is represented by one or more 4-digit codes (roughly
corresponding to an academic department), and a collection of
disciplines are represented by one or more 2-digit codes (roughly
corresponding to an academic college).

For example, Geotechnical Engineering (140802) is a specialty of Civil
Engineering (1408) which is a department in a College of Engineering
(14).

To illustrate the taxonomy in a little more detail, the table shows all
programs under CIP 41 *Science Technologies, Technicians*, subdivided
into (5) programs at the 4-digit level and (9) programs at the 6-digit
level. Some 4-digit codes include only (1) 6-digit code, e.g., 4100 and
4101, while others include more than one, e.g., 4102 and 4103.

| cip2 | cip2name | cip4 | cip4name | cip6 | cip6name |
|----|----|----|----|----|----|
| 41 | Science Technologies, Technicians | 4100 | Science Technologies, Technicians, General | 410000 | Science Technologies, Technicians, General |
| 41 |  ↓ | 4101 | Biology Technician, Biotechnology Laboratory Technician | 410101 | Biology Technician, Biotechnology Laboratory Technician |
| 41 |  ↓ | 4102 | Nuclear and Industrial Radiologic Technologies, Technicians | 410204 | Industrial Radiologic Technology, Technician |
| 41 |  ↓ | 4102 |  ↓ | 410205 | Nuclear, Nuclear Power Technology, Technician |
| 41 |  ↓ | 4102 |  ↓ | 410299 | Nuclear and Industrial Radiologic Technologies, Technicians, Other |
| 41 |  ↓ | 4103 | Physical Science Technologies, Technicians | 410301 | Chemical Technology, Technician |
| 41 |  ↓ | 4103 |  ↓ | 410303 | Chemical Process Technology |
| 41 |  ↓ | 4103 |  ↓ | 410399 | Physical Science Technologies, Technicians, Other |
| 41 |  ↓ | 4199 | Science Technologies, Technicians, Other | 419999 | Science Technologies, Technicians, Other |

Table 1. Example of CIP taxonomy {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

The number of programs represented by 2-digit codes vary over a wide
range, for example,

- CIP 14 *Engineering* comprises (40) 4-digit codes and (54) 6-digit
  codes
- CIP 24 *Liberal Arts and Sciences, General Studies and Humanities*
  comprise (1) 4-digit code and (4) 6-digit codes
- CIP 51 *Health Professions and Related Clinical Sciences*
  comprise (35) 4-digit codes and (238) 6-digit codes

## Data

The dataset `cip` that loads with midfieldr contains program names and
codes at the 6-digit, 4-digit, and 2-digit level.

``` r

library("midfieldr")
library("data.table")

# Loads with midfieldr
cip
#>                                             cip6name   cip6
#>                                               <char> <char>
#>    1:                           Agriculture, General 010000
#>    2:  Agricultural Business and Management, General 010101
#>    3: Agribusiness, Agricultural Business Operations 010102
#>   ---                                                      
#> 1580:                               Military History 540108
#> 1581:                                 History, Other 540199
#> 1582:              NonIPEDS - Undecided, Unspecified 999999
#>                                   cip4name   cip4
#>                                     <char> <char>
#>    1:                 Agriculture, General   0100
#>    2: Agricultural Business and Management   0101
#>    3: Agricultural Business and Management   0101
#>   ---                                            
#> 1580:                              History   5401
#> 1581:                              History   5401
#> 1582:    NonIPEDS - Undecided, Unspecified   9999
#>                                                        cip2name   cip2
#>                                                          <char> <char>
#>    1: Agriculture, Agricultural Operations and Related Sciences     01
#>    2: Agriculture, Agricultural Operations and Related Sciences     01
#>    3: Agriculture, Agricultural Operations and Related Sciences     01
#>   ---                                                                 
#> 1580:                                                   History     54
#> 1581:                                                   History     54
#> 1582:                         NonIPEDS - Undecided, Unspecified     99
```

All variables in `cip` are character strings, which protects the leading
zeros of CIP codes when present.

``` r

# 2-digit codes with leading zeros
cip[cip2 %like% "^0", .(cip2, cip2name)] |> unique()
#>      cip2                                                  cip2name
#>    <char>                                                    <char>
#> 1:     01 Agriculture, Agricultural Operations and Related Sciences
#> 2:     03                        Natural Resources and Conservation
#> 3:     04                         Architecture and Related Services
#> 4:     05       Area, Ethnic, Cultural and Gender and Group Studies
#> 5:     09           Communications, Journalism and Related Programs
```

The number of unique programs.

``` r

# 2-digit level
length(unique(cip$cip2))
#> [1] 46

# 4-digit level
length(unique(cip$cip4))
#> [1] 394

# 6-digit level
length(unique(cip$cip6))
#> [1] 1582
```

A sample of program names uses a random number generator, so your result
will differ from that shown.

``` r

# 2-digit name sample
sample(cip[, cip2name], 10)
#>  [1] "Education"                                                   
#>  [2] "Foreign Languages, Literatures and Linguistics"              
#>  [3] "Business, Management, Marketing and Related Support Services"
#>  [4] "Engineering"                                                 
#>  [5] "Family and Consumer Sciences, Human Sciences"                
#>  [6] "Engineering Technology"                                      
#>  [7] "Health Professions and Related Clinical Sciences"            
#>  [8] "Business, Management, Marketing and Related Support Services"
#>  [9] "Health Professions and Related Clinical Sciences"            
#> [10] "Physical Sciences"

# 4-digit name sample
sample(cip[, cip4name], 10)
#>  [1] "Allied Health Diagnostic, Intervention Treatment Professions"          
#>  [2] "Applied Horticulture, Horticultural Business Services"                 
#>  [3] "Ophthalmic and Optometric Support Services and Allied Professions"     
#>  [4] "Specialized Sales, Merchandising and Marketing Operations"             
#>  [5] "Engineering-Related Fields"                                            
#>  [6] "Teacher Education and Professional Development, Specific Subject Areas"
#>  [7] "Allied Health Diagnostic, Intervention Treatment Professions"          
#>  [8] "Leatherworking and Upholstery"                                         
#>  [9] "Health, Medical Preparatory Programs"                                  
#> [10] "Research and Experimental Psychology"

# 6-digit name sample
sample(cip[, cip6name], 10)
#>  [1] "Soil Sciences, Other"                                 
#>  [2] "Health, Medical Physics"                              
#>  [3] "Adult Literacy Tutor, Instructor"                     
#>  [4] "Environmental Design, Architecture"                   
#>  [5] "Advanced, Graduate Dentistry and Oral Sciences, Other"
#>  [6] "Dental Materials (MS, PhD)"                           
#>  [7] "Drafting and Design Technology, Technician, General"  
#>  [8] "Chemical Engineering Technology, Technician"          
#>  [9] "Social Science Teacher Education"                     
#> [10] "Sports and Exercise"
```

## How to search for programs

### `filter_programs()`

*Helps in finding 6-digit program codes.*

``` r

# usage
filter_programs(dframe, # cip or equivalent
  pattern,              # search pattern
  ...,                  # subsequent arguments referable only by name
  negate = NULL         # default FALSE
)
```

The first argument is usually `cip` or a subset of `cip`. The output is
a data frame with rows that contain matches or partial matches to the
search pattern. The forward pipe operator `|>` can be used if desired.
Here, we use
[`check_equiv_frames()`](https://winvector.github.io/wrapr//reference/check_equiv_frames.html)
to compare the results of equivalent statements.

``` r

# equivalent statements
x <- filter_programs(dframe = cip, pattern = c("engineering"))
y <- filter_programs(cip, "engineering")
z <- cip |> filter_programs("engineering")

# equivalent results
check_equiv_frames(x, y)
#> [1] TRUE
check_equiv_frames(x, z)
#> [1] TRUE
```

The `negate` argument, if true, drops rows that contain the search
terms.

``` r

x <- filter_programs(cip, "engineering")
x
#>                                                              cip6name   cip6
#>                                                                <char> <char>
#>   1:                                             Engineering, General 140101
#>   2:                                                  Pre-Engineering 140102
#>   3:     Aerospace, Aeronautical and Astronautical, Space Engineering 140201
#>  ---                                                                        
#> 117:                                       Combat Systems Engineering 290301
#> 118:                                            Engineering Acoustics 290303
#> 119: Assistive, Augmentative Technology and Rehabiliation Engineering 512312
#>                                                   cip4name   cip4
#>                                                     <char> <char>
#>   1:                                  Engineering, General   1401
#>   2:                                  Engineering, General   1401
#>   3: Aerospace, Aeronautical and Astronautical Engineering   1402
#>  ---                                                             
#> 117:                             Military Applied Sciences   2903
#> 118:                             Military Applied Sciences   2903
#> 119:            Rehabilitation and Therapeutic Professions   5123
#>                                              cip2name   cip2
#>                                                <char> <char>
#>   1:                                      Engineering     14
#>   2:                                      Engineering     14
#>   3:                                      Engineering     14
#>  ---                                                        
#> 117:                            Military Technologies     29
#> 118:                            Military Technologies     29
#> 119: Health Professions and Related Clinical Sciences     51

filter_programs(x, c("^15", "^29", "51"), negate = TRUE)
#>                                                         cip6name   cip6
#>                                                           <char> <char>
#>  1:                                         Engineering, General 140101
#>  2:                                              Pre-Engineering 140102
#>  3: Aerospace, Aeronautical and Astronautical, Space Engineering 140201
#> ---                                                                    
#> 52:                                        Engineering Chemistry 144401
#> 53:                           Biological, Biosystems Engineering 144501
#> 54:                                           Engineering, Other 149999
#>                                                  cip4name   cip4    cip2name
#>                                                    <char> <char>      <char>
#>  1:                                  Engineering, General   1401 Engineering
#>  2:                                  Engineering, General   1401 Engineering
#>  3: Aerospace, Aeronautical and Astronautical Engineering   1402 Engineering
#> ---                                                                         
#> 52:                                 Engineering Chemistry   1444 Engineering
#> 53:                    Biological, Biosystems Engineering   1445 Engineering
#> 54:                                    Engineering, Other   1499 Engineering
#>       cip2
#>     <char>
#>  1:     14
#>  2:     14
#>  3:     14
#> ---       
#> 52:     14
#> 53:     14
#> 54:     14
```

***Example 1***

Suppose we want to determine the 6-digit codes for literature programs.
We could start with a keyword.

``` r

pass_1 <- filter_programs(cip, "literature")
pass_1
#>                                             cip6name   cip6
#>                                               <char> <char>
#>   1:    Foreign Languages, Modern Languages, General 160000
#>   2:      Foreign Languages and Literatures, General 160101
#>   3:                                     Linguistics 160102
#>  ---                                                       
#> 103: English Language and Literature, Letters, Other 239999
#> 104:       Theatre Literature, History and Criticism 500505
#> 105:            Music History, Literature and Theory 500902
#>                                                           cip4name   cip4
#>                                                             <char> <char>
#>   1:                  Foreign Languages, Modern Languages, General   1600
#>   2: Linguistic, Comparative Related Language Studies and Services   1601
#>   3: Linguistic, Comparative Related Language Studies and Services   1601
#>  ---                                                                     
#> 103:               English Language and Literature, Letters, Other   2399
#> 104:                            Drama, Theatre Arts and Stagecraft   5005
#> 105:                                                         Music   5009
#>                                            cip2name   cip2
#>                                              <char> <char>
#>   1: Foreign Languages, Literatures and Linguistics     16
#>   2: Foreign Languages, Literatures and Linguistics     16
#>   3: Foreign Languages, Literatures and Linguistics     16
#>  ---                                                      
#> 103:       English Language and Literature, Letters     23
#> 104:                     Visual and Performing Arts     50
#> 105:                     Visual and Performing Arts     50
```

To refine the search further, we might first examine the highest level,
2-digit categories.

``` r

unique(pass_1[, .(cip2name, cip2)])
#>                                          cip2name   cip2
#>                                            <char> <char>
#> 1: Foreign Languages, Literatures and Linguistics     16
#> 2:       English Language and Literature, Letters     23
#> 3:                     Visual and Performing Arts     50
```

If our search is for English-language literature, we can restrict the
search for codes that start with 23 (regular expression `"^23"`) and
drop the 2-digit values from the working data frame.

``` r

pass_2 <- pass_1[, .(cip6name, cip6, cip4name, cip4)]
pass_2 <- filter_programs(pass_2, "^23")
pass_2
#>                                            cip6name   cip6
#>                                              <char> <char>
#>  1:        English Language and Literature, General 230101
#>  2:                             English Composition 230401
#>  3:                                Creative Writing 230501
#> ---                                                       
#> 18:                 Child and Adolescent Literature 231405
#> 19:                               Literature, Other 231499
#> 20: English Language and Literature, Letters, Other 239999
#>                                            cip4name   cip4
#>                                              <char> <char>
#>  1:        English Language and Literature, General   2301
#>  2:                             English Composition   2304
#>  3:                                Creative Writing   2305
#> ---                                                       
#> 18:                                      Literature   2314
#> 19:                                      Literature   2314
#> 20: English Language and Literature, Letters, Other   2399
```

Searching the result on “literature.”

``` r

pass_3 <- filter_programs(pass_2, "literature")
pass_3
#>                                            cip6name   cip6
#>                                              <char> <char>
#>  1:        English Language and Literature, General 230101
#>  2:             American Literature (United States) 230701
#>  3:                  American Literature (Canadian) 230702
#>  4:   English Literature (British and Commonwealth) 230801
#>  5:                              General Literature 231401
#>  6:             American Literature (United States) 231402
#>  7:                  American Literature (Canadian) 231403
#>  8:   English Literature (British and Commonwealth) 231404
#>  9:                 Child and Adolescent Literature 231405
#> 10:                               Literature, Other 231499
#> 11: English Language and Literature, Letters, Other 239999
#>                                             cip4name   cip4
#>                                               <char> <char>
#>  1:         English Language and Literature, General   2301
#>  2: American Literature (United States and Canadian)   2307
#>  3: American Literature (United States and Canadian)   2307
#>  4:    English Literature (British and Commonwealth)   2308
#>  5:                                       Literature   2314
#>  6:                                       Literature   2314
#>  7:                                       Literature   2314
#>  8:                                       Literature   2314
#>  9:                                       Literature   2314
#> 10:                                       Literature   2314
#> 11:  English Language and Literature, Letters, Other   2399
```

If we wanted Canadian, US, or UK literature specifically, we can search
for those terms and retain the 6-digit names and codes only.

``` r

pass_4 <- pass_3[, .(cip6name, cip6)]
filter_programs(pass_4, c("united", "canadian", "british"))
#>                                         cip6name   cip6
#>                                           <char> <char>
#> 1:           American Literature (United States) 230701
#> 2:                American Literature (Canadian) 230702
#> 3: English Literature (British and Commonwealth) 230801
#> 4:           American Literature (United States) 231402
#> 5:                American Literature (Canadian) 231403
#> 6: English Literature (British and Commonwealth) 231404
```

Alternatively, we could select the codes themselves,

``` r

filter_programs(pass_4, c("^2307", "^2308", "231402", "231403", "231404"))
#>                                         cip6name   cip6
#>                                           <char> <char>
#> 1:           American Literature (United States) 230701
#> 2:                American Literature (Canadian) 230702
#> 3: English Literature (British and Commonwealth) 230801
#> 4:           American Literature (United States) 231402
#> 5:                American Literature (Canadian) 231403
#> 6: English Literature (British and Commonwealth) 231404
```

***Example 2***

Suppose we are searching for history programs. We can start, as we did
above, with a keyword search across all 2-, 4-, and 6-digit names then
examine the resulting top-level programs

``` r

pass_1 <- filter_programs(cip, "history")
pass_1
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

unique(pass_1[, .(cip2name, cip2)])
#>                             cip2name   cip2
#>                               <char> <char>
#> 1: Architecture and Related Services     04
#> 2:                         Education     13
#> 3:        Visual and Performing Arts     50
#> 4:                           History     54
```

It appears that the 2-digit code we want is 54. In the second pass, we
focus on the 6-digit names and codes.

``` r

pass_2 <- pass_1[, .(cip6name, cip6)]
pass_2 <- filter_programs(pass_2, "^54")
pass_2
#>                                               cip6name   cip6
#>                                                 <char> <char>
#> 1:                                    History, General 540101
#> 2:                    American History (United States) 540102
#> 3:                                    European History 540103
#> 4:    History and Philosophy of Science and Technology 540104
#> 5: Public, Applied History and Archival Administration 540105
#> 6:                                       Asian History 540106
#> 7:                                    Canadian History 540107
#> 8:                                    Military History 540108
#> 9:                                      History, Other 540199
```

Assuming the programs we want are a subset of those shown, we can use
the `negate` argument to drop selected programs by their ending string
(e.g., regular expression `01$`).

``` r

pass_3 <- filter_programs(pass_2, 
                          c("01$", "04$", "05$", "08$", "99$"), 
                          negate = TRUE)
pass_3
#>                            cip6name   cip6
#>                              <char> <char>
#> 1: American History (United States) 540102
#> 2:                 European History 540103
#> 3:                    Asian History 540106
#> 4:                 Canadian History 540107
```

***Example 3***

Illustrating details.
[`catch_error()`](https://midfieldr.github.io/midfieldr/reference/catch_error.md)
is a midfieldr utility.

1.  The first two arguments do not have to be named.

``` r

# equivalent statements
x <- filter_programs(dframe = cip, pattern = "^14")
y <- filter_programs(cip, "^14")

# equivalent results
check_equiv_frames(x, y)
#> [1] TRUE
```

2.  Search expressions must be strings.

``` r

# incorrect
catch_error(
  filter_programs(cip, 050125)
)
#> Error: Assertion on 'pattern' failed. Must be of class 'string', not 'double'.

# correct
filter_programs(cip, "050125")
#>          cip6name   cip6     cip4name   cip4
#>            <char> <char>       <char> <char>
#> 1: German Studies 050125 Area Studies   0501
#>                                               cip2name   cip2
#>                                                 <char> <char>
#> 1: Area, Ethnic, Cultural and Gender and Group Studies     05
```

3.  The `negate` argument, if used, must be named.

``` r

# incorrect
catch_error(
  filter_programs(cip, "050125", FALSE)
)
#> Error: Arguments after ... must be named, as in arg = val. unexpected arguments: 'FALSE'

# correct
filter_programs(cip, "050125", negate = FALSE)
#>          cip6name   cip6     cip4name   cip4
#>            <char> <char>       <char> <char>
#> 1: German Studies 050125 Area Studies   0501
#>                                               cip2name   cip2
#>                                                 <char> <char>
#> 1: Area, Ethnic, Cultural and Gender and Group Studies     05
```
