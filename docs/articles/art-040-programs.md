# Programs

In the US, instructional programs are encoded by 6-digit numbers curated
by the US Department of Education. The US standard encoding format is a
two-digit number followed by a period, followed by a four-digit number,
for example, 14.0102. MIDFIELD uses the same numerals, but omits the
period, i.e., 140102, and stores the variable as a character string.

This article in the MIDFIELD workflow:

1.  Planning  
2.  Initial processing
    - Data sufficiency  
    - Degree seeking  
    - Identify programs
3.  Blocs  
4.  Groupings  
5.  Metrics  
6.  Displays

## Definitions

- program:

  US academic field of study. Can be used to indicate a specialty within
  a field or a collection of fields within a Department, College, or
  University. Programs are denoted by the *Classification of
  Instructional Programs* (CIP), a taxonomy of academic programs curated
  by the US Department of Education ([NCES 2010](#ref-NCES:2010)).

- CIP:

  *Classification of Instructional Programs*, a taxonomy of academic
  programs curated by the US Department of Education ([NCES
  2010](#ref-NCES:2010)). The 2010 codes are included with midfieldr in
  the data set `cip`.

- `cip6`:

  Character variable in the `term` and `degree` data tables of program
  observations. Values are 6-digit CIP codes.

## Method

We search the `cip` data set included with midfieldr using a variety of
techniques to obtain the set of 6-digit CIP codes for the programs under
study. We assign custom program names to codes or groups of codes.

## Taxonomy

Academic programs have three levels of codes and names:

- 6-digit code, a specific program
- 4-digit code, a group of 6-digit programs of comparable content
- 2-digit code, a grouping of 4-digit groups of related content

Specialties within a discipline are encoded at the 6-digit level, the
discipline itself is represented by one or more 4-digit codes (roughly
corresponding to an academic department), and a collection of
disciplines are represented by one or more 2-digit codes (roughly
corresponding to an academic college).

For example, Geotechnical Engineering (140802) is a specialty in Civil
Engineering (1408) which is a department in the college of Engineering
(14).

To illustrate the taxonomy in a little more detail, we show in the table
the programs assigned to the 2-digit code 41, “Science Technologies,
Technicians”. This 2-digit grouping is subdivided into 5 groups at the
4-digit level (codes 4100–4199) which are further subdivided into 9
programs at the 6-digit level (codes 410000–419999).

| cip6name | cip6 | cip4name | cip4 | cip2name | cip2 |
|----|----|----|----|----|----|
| Science Technologies, Technicians, General | 410000 | Science Technologies, Technicians, General | 4100 | Science Technologies, Technicians | 41 |
| Biology Technician, Biotechnology Laboratory Technician | 410101 | Biology Technician, Biotechnology Laboratory Technician | 4101 |  ↓ | 41 |
| Industrial Radiologic Technology, Technician | 410204 | Nuclear and Industrial Radiologic Technologies, Technicians | 4102 |  ↓ | 41 |
| Nuclear, Nuclear Power Technology, Technician | 410205 |  ↓ | 4102 |  ↓ | 41 |
| Nuclear and Industrial Radiologic Technologies, Technicians, Other | 410299 |  ↓ | 4102 |  ↓ | 41 |
| Chemical Technology, Technician | 410301 | Physical Science Technologies, Technicians | 4103 |  ↓ | 41 |
| Chemical Process Technology | 410303 |  ↓ | 4103 |  ↓ | 41 |
| Physical Science Technologies, Technicians, Other | 410399 |  ↓ | 4103 |  ↓ | 41 |
| Science Technologies, Technicians, Other | 419999 | Science Technologies, Technicians, Other | 4199 |  ↓ | 41 |

Table 1. CIP taxonomy {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

A 2-digit program can include anywhere from four 4-digit programs (e.g.,
code 24 Liberal Arts and Sciences, General Studies and Humanities) to
238 4-digit programs (e.g., code 51 Health Professions and Related
Clinical Sciences).

And 4-digit programs include anywhere from one 6-digit program (e.g.,
code 4100 above) to 37 6-digit programs (e.g., code 1313 Education).

Unfortunately, some disciplines can comprise more than one 4-digit code.
For example, the programs that comprise the broad discipline of
Industrial and Systems Engineering encompass four distinct 4-digit
codes: 1427 Systems Engineering, 1435 Industrial Engineering, 1436
Manufacturing Engineering, and 1437 Operations Research. Hence the
importance of being able to search all CIP data for programs of
interest.

## Load data

*Start.*   If you are writing your own script to follow along, we use
these packages in this article:

``` r

library(midfieldr)
library(data.table)
```

*Loads with midfieldr.*   Prepared data, adapted from ([NCES
2010](#ref-NCES:2010)). The data dictionary is documented in
[`?cip`](https://midfieldr.github.io/midfieldr/reference/cip.md).

- `cip`

## Inspect the `cip` data

First glance.

``` r

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
zeros of some CIP codes.

``` r

# Names and class of the CIP variables
cip[, lapply(.SD, class)]
#>     cip6name      cip6  cip4name      cip4  cip2name      cip2
#>       <char>    <char>    <char>    <char>    <char>    <char>
#> 1: character character character character character character
```

The number of unique programs.

``` r

# 2-digit level
sort(unique(cip$cip2))
#>  [1] "01" "03" "04" "05" "09" "10" "11" "12" "13" "14" "15" "16" "19" "22" "23"
#> [16] "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34" "35" "36" "37" "38"
#> [31] "39" "40" "41" "42" "43" "44" "45" "46" "47" "48" "49" "50" "51" "52" "54"
#> [46] "99"

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

## `filter_programs()`

Subset the `cip` data frame, retaining rows that match or partially
match a vector of character strings.

*Arguments.*

- **`dframe`**   Data frame of CIP program names and codes to be subset.

- **`pattern`**   Character vector of search text for retaining rows,
  not case-sensitive.

- **`negate`**   Logical (default FALSE). If TRUE, returns rows that do
  not match the search pattern.

*Equivalent usage.*   The following implementations yield identical
results,

``` r

# Arguments named
x <- filter_programs(dframe = cip, pattern = c("engineering"))

# Arguments unnamed
y <- filter_programs(cip, "engineering")

# Using a chain
z <- cip |> filter_programs("engineering")

# Demonstrate equivalence
check_equiv_frames(x, y)
#> [1] TRUE
# Demonstrate equivalence
check_equiv_frames(x, z)
#> [1] TRUE
```

*Output.*   Subset of `cip` with rows matching elements of `pattern`.
Additional subsetting if optional arguments specified. Examples follow.

## Using a keyword search

Filtering the CIP data for all programs containing the word
“engineering” yields 119 observations.

``` r

# Filter basics
filter_programs(cip, "engineering")
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
```

Suppose we want to find the CIP codes and names for all programs in
Civil Engineering. The search is insensitive to case, so we start with
the following code chunk.

``` r

# Example 1 filter using keywords
filter_programs(cip, "civil")
```

| cip6name | cip6 | cip4name | cip4 | cip2name | cip2 |
|----|----|----|----|----|----|
| American, United States Studies, Civilization | 050102 | Area Studies | 0501 | Area, Ethnic, Cultural and Gender and Group Studies | 05 |
| Asian Studies, Civilization | 050103 | Area Studies | 0501 | Area, Ethnic, Cultural and Gender and Group Studies | 05 |
| European Studies, Civilization | 050106 | Area Studies | 0501 | Area, Ethnic, Cultural and Gender and Group Studies | 05 |
| Civil Engineering, General | 140801 | Civil Engineering | 1408 | Engineering | 14 |
| Geotechnical Engineering | 140802 | Civil Engineering | 1408 | Engineering | 14 |
| Structural Engineering | 140803 | Civil Engineering | 1408 | Engineering | 14 |
| Transportation and Highway Engineering | 140804 | Civil Engineering | 1408 | Engineering | 14 |
| Water Resources Engineering | 140805 | Civil Engineering | 1408 | Engineering | 14 |
| Civil Engineering, Other | 140899 | Civil Engineering | 1408 | Engineering | 14 |
| Civil Engineering Technology, Technician | 150201 | Civil Engineering Technologies, Technicians | 1502 | Engineering Technology | 15 |
| Civil Drafting and Civil Engineering CAD, CADD | 151304 | Drafting, Design Engineering Technologies, Technicians | 1513 | Engineering Technology | 15 |
| Multi, Interdisciplinary Studies - Ancient Studies, Civilization | 302201 | Classical and Ancient, Oriental Studies - Multi, Interdisciplinary Studies | 3022 | Muti, Interdisciplinary Studies | 30 |

Table 2. Search results {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

The search returns some programs with Civilization in their names as
well as Engineering Technology. If we wanted Civil Engineering only, we
can use a sequence of function calls, where the outcome of the one
operation is assigned to the first argument of the next operation.

The following code chunk could be read as, “Start with the default `cip`
data frame, then keep any rows in which ‘civil’ is detected, then keep
any rows in which ‘engineering’ is detected, then drop any rows in which
‘technology’ is detected.” The first pass operates on `cip`, but
successive passes do not. If used, the `cip` argument must be named.

``` r

# First search
first_pass <- filter_programs(cip, "civil")

# Refine the search
second_pass <- filter_programs(first_pass, "engineering")

# Refine further
third_pass <- filter_programs(second_pass, "technology", negate = TRUE)
```

| cip6name | cip6 | cip4name | cip4 | cip2name | cip2 |
|----|----|----|----|----|----|
| Civil Engineering, General | 140801 | Civil Engineering | 1408 | Engineering | 14 |
| Geotechnical Engineering | 140802 | Civil Engineering | 1408 | Engineering | 14 |
| Structural Engineering | 140803 | Civil Engineering | 1408 | Engineering | 14 |
| Transportation and Highway Engineering | 140804 | Civil Engineering | 1408 | Engineering | 14 |
| Water Resources Engineering | 140805 | Civil Engineering | 1408 | Engineering | 14 |
| Civil Engineering, Other | 140899 | Civil Engineering | 1408 | Engineering | 14 |

Table 3. Search results {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

## Using a numerical code search

Suppose we want to study programs relating to German culture, language,
and literature. Using “german” for the `keep_text` value yields

``` r

# Search on text
filter_programs(cip, "german")
```

| cip6name | cip6 | cip4name | cip4 | cip2name | cip2 |
|----|----|----|----|----|----|
| German Studies | 050125 | Area Studies | 0501 | Area, Ethnic, Cultural and Gender and Group Studies | 05 |
| German Language Teacher Education | 131326 | Teacher Education and Professional Development, Specific Subject Areas | 1313 | Education | 13 |
| Germanic Languages, Literatures and Linguistics, General | 160500 | Germanic Languages, Literatures Linguistics | 1605 | Foreign Languages, Literatures and Linguistics | 16 |
| German Language and Literature | 160501 | Germanic Languages, Literatures Linguistics | 1605 | Foreign Languages, Literatures and Linguistics | 16 |
| Scandinavian Languages, Literatures and Linguistics | 160502 | Germanic Languages, Literatures Linguistics | 1605 | Foreign Languages, Literatures and Linguistics | 16 |
| Danish Language and Literature | 160503 | Germanic Languages, Literatures Linguistics | 1605 | Foreign Languages, Literatures and Linguistics | 16 |
| Dutch, Flemish Language and Literature | 160504 | Germanic Languages, Literatures Linguistics | 1605 | Foreign Languages, Literatures and Linguistics | 16 |
| Norwegian Language and Literature | 160505 | Germanic Languages, Literatures Linguistics | 1605 | Foreign Languages, Literatures and Linguistics | 16 |
| Swedish Language and Literature | 160506 | Germanic Languages, Literatures Linguistics | 1605 | Foreign Languages, Literatures and Linguistics | 16 |
| Germanic Languages, Literatures and Linguistics, Other | 160599 | Germanic Languages, Literatures Linguistics | 1605 | Foreign Languages, Literatures and Linguistics | 16 |

Table 4. Search results {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

From the 6-digit program names we find only two that are of interest,
German Studies (050125) and German Language and Literature (160501). We
use a character vector to assign these two codes to the `keep_text`
argument.

``` r

# Search on codes
filter_programs(cip, c("050125", "160501"))
```

| cip6name | cip6 | cip4name | cip4 | cip2name | cip2 |
|----|----|----|----|----|----|
| German Studies | 050125 | Area Studies | 0501 | Area, Ethnic, Cultural and Gender and Group Studies | 05 |
| German Language and Literature | 160501 | Germanic Languages, Literatures Linguistics | 1605 | Foreign Languages, Literatures and Linguistics | 16 |

Table 5. Search results {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

If the 6-digit codes are entered as integers, they are coerced to
strings for the search.

``` r

# Search that produces an error
filter_programs(cip, c(050125, 160501))
#> Error in `filter_programs()`:
#> ! Assertion on 'pattern' failed. Must be of class 'string', not 'double'.
```

## Using a regular expression search

Specifying 4-digit codes yields a data frame all 6-digit programs
containing the 4-digit string. We use the regular expression notation
`^` to match the start of the line.

``` r

# example 3 filter using regular expressions
filter_programs(cip, c("^1410", "^1419"))
```

| cip6name | cip6 | cip4name | cip4 | cip2name | cip2 |
|----|----|----|----|----|----|
| Electrical, Electronics and Communications Engineering | 141001 | Electrical, Electronics and Communications Engineering | 1410 | Engineering | 14 |
| Laser and Optical Engineering | 141003 | Electrical, Electronics and Communications Engineering | 1410 | Engineering | 14 |
| Telecommunications Engineering | 141004 | Electrical, Electronics and Communications Engineering | 1410 | Engineering | 14 |
| Electrical, Electronics and Communications Engineering, Other | 141099 | Electrical, Electronics and Communications Engineering | 1410 | Engineering | 14 |
| Mechanical Engineering | 141901 | Mechanical Engineering | 1419 | Engineering | 14 |

Table 6. Search results {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

The 2-digit series represent the most general groupings of related
programs. Here, the result includes all History programs.

``` r

# Search on 2-digit code
filter_programs(cip, "^54")
```

| cip6name | cip6 | cip4name | cip4 | cip2name | cip2 |
|----|----|----|----|----|----|
| History, General | 540101 | History | 5401 | History | 54 |
| American History (United States) | 540102 | History | 5401 | History | 54 |
| European History | 540103 | History | 5401 | History | 54 |
| History and Philosophy of Science and Technology | 540104 | History | 5401 | History | 54 |
| Public, Applied History and Archival Administration | 540105 | History | 5401 | History | 54 |
| Asian History | 540106 | History | 5401 | History | 54 |
| Canadian History | 540107 | History | 5401 | History | 54 |
| Military History | 540108 | History | 5401 | History | 54 |
| History, Other | 540199 | History | 5401 | History | 54 |

Table 7. Search results {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

The series argument can include any combination of 2, 4, and 6-digit
codes. It can also be passed to the function as a character vector.

``` r

# Search on vector of codes
codes_we_want <- c("^24", "^4102", "^450202")
filter_programs(cip, codes_we_want)
```

| cip6name | cip6 | cip4name | cip4 | cip2name | cip2 |
|----|----|----|----|----|----|
| Liberal Arts and Sciences, Liberal Studies | 240101 | Liberal Arts and Sciences, General Studies Humanities | 2401 | Liberal Arts and Sciences, General Studies and Humanities | 24 |
| General Studies | 240102 | Liberal Arts and Sciences, General Studies Humanities | 2401 | Liberal Arts and Sciences, General Studies and Humanities | 24 |
| Humanities, Humanistic Studies | 240103 | Liberal Arts and Sciences, General Studies Humanities | 2401 | Liberal Arts and Sciences, General Studies and Humanities | 24 |
| Liberal Arts and Sciences, General Studies and Humanities, Other | 240199 | Liberal Arts and Sciences, General Studies Humanities | 2401 | Liberal Arts and Sciences, General Studies and Humanities | 24 |
| Industrial Radiologic Technology, Technician | 410204 | Nuclear and Industrial Radiologic Technologies, Technicians | 4102 | Science Technologies, Technicians | 41 |
| Nuclear, Nuclear Power Technology, Technician | 410205 | Nuclear and Industrial Radiologic Technologies, Technicians | 4102 | Science Technologies, Technicians | 41 |
| Nuclear and Industrial Radiologic Technologies, Technicians, Other | 410299 | Nuclear and Industrial Radiologic Technologies, Technicians | 4102 | Science Technologies, Technicians | 41 |
| Physical Anthropology | 450202 | Anthropology | 4502 | Social Sciences | 45 |

Table 8. Search results {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

## CIP data from another source

If you use a CIP data set from another source, it must have the same
structure as `cip`: six character columns named as follows,

``` r

# Name and class of variables (columns) in cip
unlist(lapply(cip, FUN = class))
#>    cip6name        cip6    cip4name        cip4    cip2name        cip2 
#> "character" "character" "character" "character" "character" "character"
```

## Assigning program names

Programs in MIDFIELD data sets are encoded by 6-digit CIP codes. As
we’ve shown, multiple 6-digit codes can be considered specialties within
a larger program with a 4-digit code or even a set of distinct 4-digit
codes. Thus the program names in `cip` are generally inadequate for
grouping and summarizing. User-defined program names are nearly always
required.

> *Most studies require deliberate assignment of user-defined program
> names to CIP codes or groups of CIP codes.*

Here we demonstrate the creation of a data frame with all 6-digit CIP
codes in a study plus their user-defined names.

By searching `cip`, we can find that the 4-digit codes for the four
engineering programs are: Civil (1408), Electrical (1410), Mechanical
(1419), and Industrial/Systems (1427, 1435, 1436, and 1437).

We obtain their 6-digit CIP codes. The 4-digit names are appropriate
here. Our task is to create a variable with custom program names.

``` r

# Changing the number of rows to print
options(datatable.print.nrows = 15)

# Four engineering programs
four_programs <- filter_programs(cip, c("^1408", "^1410", "^1419", "^1427", "^1435", "^1436", "^1437"))

# Retain the needed columns
four_programs <- four_programs[, .(cip6, cip4name)]
four_programs
#>       cip6                                               cip4name
#>     <char>                                                 <char>
#>  1: 140801                                      Civil Engineering
#>  2: 140802                                      Civil Engineering
#>  3: 140803                                      Civil Engineering
#>  4: 140804                                      Civil Engineering
#>  5: 140805                                      Civil Engineering
#>  6: 140899                                      Civil Engineering
#>  7: 141001 Electrical, Electronics and Communications Engineering
#>  8: 141003 Electrical, Electronics and Communications Engineering
#>  9: 141004 Electrical, Electronics and Communications Engineering
#> 10: 141099 Electrical, Electronics and Communications Engineering
#> 11: 141901                                 Mechanical Engineering
#> 12: 142701                                    Systems Engineering
#> 13: 143501                                 Industrial Engineering
#> 14: 143601                              Manufacturing Engineering
#> 15: 143701                                    Operations Research
```

To make the assignments clear, our approach here will be to assign a new
`program` column with NA values, then edit the new column values.

``` r

# Assign a new column
four_programs[, program := NA_character_]
four_programs
#>       cip6                                               cip4name program
#>     <char>                                                 <char>  <char>
#>  1: 140801                                      Civil Engineering    <NA>
#>  2: 140802                                      Civil Engineering    <NA>
#>  3: 140803                                      Civil Engineering    <NA>
#>  4: 140804                                      Civil Engineering    <NA>
#>  5: 140805                                      Civil Engineering    <NA>
#>  6: 140899                                      Civil Engineering    <NA>
#>  7: 141001 Electrical, Electronics and Communications Engineering    <NA>
#>  8: 141003 Electrical, Electronics and Communications Engineering    <NA>
#>  9: 141004 Electrical, Electronics and Communications Engineering    <NA>
#> 10: 141099 Electrical, Electronics and Communications Engineering    <NA>
#> 11: 141901                                 Mechanical Engineering    <NA>
#> 12: 142701                                    Systems Engineering    <NA>
#> 13: 143501                                 Industrial Engineering    <NA>
#> 14: 143601                              Manufacturing Engineering    <NA>
#> 15: 143701                                    Operations Research    <NA>
```

### 1. Use `cip4name %ilike%` to recode one value

The `%like%` function is essentially a wrapper function around the base
R [`grepl()`](https://rdrr.io/r/base/grep.html) function. The `%ilike%`
version is case-insensitive. You can view the help page by running (the
back-ticks facilitate a help search for terms starting with a symbol):

``` r

# Run in Console
? `%like%`
```

In this approach, we search for one distinctive term only. We’re using
abbreviations for compact output.

``` r

# Recode program using the 4-digit name
four_programs[cip4name %ilike% "electrical", program := "EE"]
four_programs
#>       cip6                                               cip4name program
#>     <char>                                                 <char>  <char>
#>  1: 140801                                      Civil Engineering    <NA>
#>  2: 140802                                      Civil Engineering    <NA>
#>  3: 140803                                      Civil Engineering    <NA>
#>  4: 140804                                      Civil Engineering    <NA>
#>  5: 140805                                      Civil Engineering    <NA>
#>  6: 140899                                      Civil Engineering    <NA>
#>  7: 141001 Electrical, Electronics and Communications Engineering      EE
#>  8: 141003 Electrical, Electronics and Communications Engineering      EE
#>  9: 141004 Electrical, Electronics and Communications Engineering      EE
#> 10: 141099 Electrical, Electronics and Communications Engineering      EE
#> 11: 141901                                 Mechanical Engineering    <NA>
#> 12: 142701                                    Systems Engineering    <NA>
#> 13: 143501                                 Industrial Engineering    <NA>
#> 14: 143601                              Manufacturing Engineering    <NA>
#> 15: 143701                                    Operations Research    <NA>
```

### 2. Use `cip6 %like%` to recode one value

In our second approach, we use the `%like%` function again, but apply it
to a CIP code. Here we use the regular expression `^1408` meaning
“starts with 1408.”

``` r

# Recode program using the 4-digit code
four_programs[cip6 %like% "^1408", program := "CE"]
four_programs
#>       cip6                                               cip4name program
#>     <char>                                                 <char>  <char>
#>  1: 140801                                      Civil Engineering      CE
#>  2: 140802                                      Civil Engineering      CE
#>  3: 140803                                      Civil Engineering      CE
#>  4: 140804                                      Civil Engineering      CE
#>  5: 140805                                      Civil Engineering      CE
#>  6: 140899                                      Civil Engineering      CE
#>  7: 141001 Electrical, Electronics and Communications Engineering      EE
#>  8: 141003 Electrical, Electronics and Communications Engineering      EE
#>  9: 141004 Electrical, Electronics and Communications Engineering      EE
#> 10: 141099 Electrical, Electronics and Communications Engineering      EE
#> 11: 141901                                 Mechanical Engineering    <NA>
#> 12: 142701                                    Systems Engineering    <NA>
#> 13: 143501                                 Industrial Engineering    <NA>
#> 14: 143601                              Manufacturing Engineering    <NA>
#> 15: 143701                                    Operations Research    <NA>
```

### 3. Use `program := fcase()` to edit all values

In this approach, we use the data.table function
[`fcase()`](https://rdrr.io/pkg/data.table/man/fcase.html), an
implementation of the SQL CASE WHEN statement. The data.table function
`%chin%` is like `%in%`, but for character vectors.

``` r

# Recode all program values
four_programs[, program := fcase(
  cip6 %like% "^1408", "CE",
  cip6 %like% "^1410", "EE",
  cip6 %like% "^1419", "ME",
  cip6 %chin% c("142701", "143501", "143601", "143701"), "ISE"
)]
four_programs <- four_programs[, .(cip6, program)]
four_programs
#>       cip6 program
#>     <char>  <char>
#>  1: 140801      CE
#>  2: 140802      CE
#>  3: 140803      CE
#>  4: 140804      CE
#>  5: 140805      CE
#>  6: 140899      CE
#>  7: 141001      EE
#>  8: 141003      EE
#>  9: 141004      EE
#> 10: 141099      EE
#> 11: 141901      ME
#> 12: 142701     ISE
#> 13: 143501     ISE
#> 14: 143601     ISE
#> 15: 143701     ISE
```

*Verify prepared data.*   `study_programs`, included with midfieldr,
contains the case study information developed above. Here we verify that
the two data frames have the same content.

``` r

# Demonstrate equivalence
check_equiv_frames(four_programs, study_programs)
#> [1] TRUE
```

## Reusable code

*Preparation.*   To provide a working example, we select the four
engineering programs of the case study used throughout the articles
(Civil, Electrical, Industrial/Systems, and Mechanical Engineering). We
assume a prior search of `cip` yielded the relevant codes used here.
Requires editing before reuse with different programs.

``` r

# Edit as required for different programs
selected_programs <- filter_programs(cip, c("^1408", "^1410", "^1419", "^1427", "^1435", "^1436", "^1437"))
```

*Programs.*   A summary code chunk for ready reference. Requires editing
before reuse with different programs.

``` r

# Recode program labels. Edit as required.
selected_programs[, program := fcase(
  cip6 %like% "^1408", "CE",
  cip6 %like% "^1410", "EE",
  cip6 %like% "^1419", "ME",
  cip6 %chin% c("142701", "143501", "143601", "143701"), "ISE"
)]
selected_programs <- selected_programs[, .(cip6, program)]
```

------------------------------------------------------------------------

[◁ Degree
seeking](https://midfieldr.github.io/midfieldr/articles/art-030-degree-seeking.md)
   [▲ top of page](#top)    [Alternative CIPs
▷](https://midfieldr.github.io/midfieldr/articles/art-041-alternative-cip.md)

------------------------------------------------------------------------

## References

NCES. 2010. *IPEDS Classification of Instructional Programs (CIP)*.
National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>.
