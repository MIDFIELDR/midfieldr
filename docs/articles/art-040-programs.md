# Programs

In the US, instructional programs are encoded by 6-digit numbers curated
by the US Department of Education. The US standard encoding format is a
two-digit number followed by a period, followed by a four-digit number,
for example, 14.0102. MIDFIELD uses the same numerals, but omits the
period, i.e., 140102, and stores the variable as a character string.

This article in the MIDFIELD workflow.

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
2010](#ref-NCES:2010)). View data dictionary via
[`?cip`](https://midfieldr.github.io/midfieldr/reference/cip.md).

- `cip`

## Inspect the `cip` data

First glance.

``` r

# Loads with midfieldr
cip
#> Index: <cip6>
#>         cip2                                                  cip2name   cip4
#>       <char>                                                    <char> <char>
#>    1:     01 Agriculture, Agricultural Operations and Related Sciences   0100
#>    2:     01 Agriculture, Agricultural Operations and Related Sciences   0101
#>    3:     01 Agriculture, Agricultural Operations and Related Sciences   0101
#>   ---                                                                        
#> 1580:     54                                                   History   5401
#> 1581:     54                                                   History   5401
#> 1582:     99                         NonIPEDS - Undecided, Unspecified   9999
#>                                   cip4name   cip6
#>                                     <char> <char>
#>    1:                 Agriculture, General 010000
#>    2: Agricultural Business and Management 010101
#>    3: Agricultural Business and Management 010102
#>   ---                                            
#> 1580:                              History 540108
#> 1581:                              History 540199
#> 1582:    NonIPEDS - Undecided, Unspecified 999999
#>                                             cip6name
#>                                               <char>
#>    1:                           Agriculture, General
#>    2:  Agricultural Business and Management, General
#>    3: Agribusiness, Agricultural Business Operations
#>   ---                                               
#> 1580:                               Military History
#> 1581:                                 History, Other
#> 1582:              NonIPEDS - Undecided, Unspecified
```

All variables in `cip` are character strings, which protects the leading
zeros of some CIP codes.

``` r

# Names and class of the CIP variables
cip[, lapply(.SD, class)]
#>         cip2  cip2name      cip4  cip4name      cip6  cip6name
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

## `filter_cip()`

Subset the `cip` data frame, retaining rows that match or partially
match a vector of character strings.

*Arguments.*

- **`keep_text`**   Character vector of search text for retaining rows,
  not case-sensitive. Can be empty if `drop_text` is used.

- **`drop_text`**   Character vector of search text for dropping rows,
  not case-sensitive, default NULL. Argument to be used by name.

- **`cip`**   Data frame to be subset, default `cip`. Argument to be
  used by name.

- **`select`**   Character vector of column names to search and return,
  default all columns. Argument to be used by name.

*Equivalent usage.*   The following implementations yield identical
results,

``` r

# First argument named, CIP argument if used must be named
x <- filter_cip(keep_text = c("engineering"), cip = cip)

# First argument unnamed, use default CIP argument
y <- filter_cip("engineering")

# Demonstrate equivalence
check_equiv_frames(x, y)
#> [1] TRUE
```

*Output.*   Subset of `cip` with rows matching elements of `keep_text`.
Additional subsetting if optional arguments specified. Examples follow.

## Using a keyword search

Filtering the CIP data for all programs containing the word
“engineering” yields 119 observations.

``` r

# Filter basics
filter_cip("engineering")
#>        cip2                                         cip2name   cip4
#>      <char>                                           <char> <char>
#>   1:     14                                      Engineering   1401
#>   2:     14                                      Engineering   1401
#>   3:     14                                      Engineering   1402
#>  ---                                                               
#> 117:     29                            Military Technologies   2903
#> 118:     29                            Military Technologies   2903
#> 119:     51 Health Professions and Related Clinical Sciences   5123
#>                                                   cip4name   cip6
#>                                                     <char> <char>
#>   1:                                  Engineering, General 140101
#>   2:                                  Engineering, General 140102
#>   3: Aerospace, Aeronautical and Astronautical Engineering 140201
#>  ---                                                             
#> 117:                             Military Applied Sciences 290301
#> 118:                             Military Applied Sciences 290303
#> 119:            Rehabilitation and Therapeutic Professions 512312
#>                                                              cip6name
#>                                                                <char>
#>   1:                                             Engineering, General
#>   2:                                                  Pre-Engineering
#>   3:     Aerospace, Aeronautical and Astronautical, Space Engineering
#>  ---                                                                 
#> 117:                                       Combat Systems Engineering
#> 118:                                            Engineering Acoustics
#> 119: Assistive, Augmentative Technology and Rehabiliation Engineering
```

The `drop_text` and `select` arguments have to be named explicitly.
Columns in `select` are subset after filtering for `keep_text` and
`drop_text`.

``` r

# Optional arguments drop_text and select
filter_cip("engineering",
  drop_text = c("related", "technology", "technologies"),
  select = c("cip6", "cip6name")
)
#>       cip6                                                     cip6name
#>     <char>                                                       <char>
#>  1: 140101                                         Engineering, General
#>  2: 140102                                              Pre-Engineering
#>  3: 140201 Aerospace, Aeronautical and Astronautical, Space Engineering
#> ---                                                                    
#> 52: 144401                                        Engineering Chemistry
#> 53: 144501                           Biological, Biosystems Engineering
#> 54: 149999                                           Engineering, Other
```

Suppose we want to find the CIP codes and names for all programs in
Civil Engineering. The search is insensitive to case, so we start with
the following code chunk.

``` r

# Example 1 filter using keywords
filter_cip("civil")
```

| cip2 | cip2name | cip4 | cip4name | cip6 | cip6name |
|----|----|----|----|----|----|
| 05 | Area, Ethnic, Cultural and Gender and Group Studies | 0501 | Area Studies | 050102 | American, United States Studies, Civilization |
| 05 | Area, Ethnic, Cultural and Gender and Group Studies | 0501 | Area Studies | 050103 | Asian Studies, Civilization |
| 05 | Area, Ethnic, Cultural and Gender and Group Studies | 0501 | Area Studies | 050106 | European Studies, Civilization |
| 14 | Engineering | 1408 | Civil Engineering | 140801 | Civil Engineering, General |
| 14 | Engineering | 1408 | Civil Engineering | 140802 | Geotechnical Engineering |
| 14 | Engineering | 1408 | Civil Engineering | 140803 | Structural Engineering |
| 14 | Engineering | 1408 | Civil Engineering | 140804 | Transportation and Highway Engineering |
| 14 | Engineering | 1408 | Civil Engineering | 140805 | Water Resources Engineering |
| 14 | Engineering | 1408 | Civil Engineering | 140899 | Civil Engineering, Other |
| 15 | Engineering Technology | 1502 | Civil Engineering Technologies, Technicians | 150201 | Civil Engineering Technology, Technician |
| 15 | Engineering Technology | 1513 | Drafting, Design Engineering Technologies, Technicians | 151304 | Civil Drafting and Civil Engineering CAD, CADD |
| 30 | Muti, Interdisciplinary Studies | 3022 | Classical and Ancient, Oriental Studies - Multi, Interdisciplinary Studies | 302201 | Multi, Interdisciplinary Studies - Ancient Studies, Civilization |

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
first_pass <- filter_cip("civil")

# Refine the search
second_pass <- filter_cip("engineering", cip = first_pass)

# Refine further
third_pass <- filter_cip(drop_text = "technology", cip = second_pass)
```

| cip2 | cip2name | cip4 | cip4name | cip6 | cip6name |
|----|----|----|----|----|----|
| 14 | Engineering | 1408 | Civil Engineering | 140801 | Civil Engineering, General |
| 14 | Engineering | 1408 | Civil Engineering | 140802 | Geotechnical Engineering |
| 14 | Engineering | 1408 | Civil Engineering | 140803 | Structural Engineering |
| 14 | Engineering | 1408 | Civil Engineering | 140804 | Transportation and Highway Engineering |
| 14 | Engineering | 1408 | Civil Engineering | 140805 | Water Resources Engineering |
| 14 | Engineering | 1408 | Civil Engineering | 140899 | Civil Engineering, Other |

Table 3. Search results {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

*Equivalent usage.*   Seeing that all Civil Engineering programs have
the same `cip4name`, we could have used
`keep_text = c("civil engineering")` to narrow the search to rows that
match the full phrase. The following implementations yield identical
results,

``` r

# Three passes
x <- filter_cip("civil")
x <- filter_cip("engineering", cip = x)
x <- filter_cip(drop_text = "technology", cip = x)

# Combined search
y <- filter_cip("civil engineering", drop_text = "technology")

# Demonstrate equivalence
check_equiv_frames(x, y)
#> [1] TRUE
```

## Using a numerical code search

Suppose we want to study programs relating to German culture, language,
and literature. Using “german” for the `keep_text` value yields

``` r

# Search on text
filter_cip("german")
```

| cip2 | cip2name | cip4 | cip4name | cip6 | cip6name |
|----|----|----|----|----|----|
| 05 | Area, Ethnic, Cultural and Gender and Group Studies | 0501 | Area Studies | 050125 | German Studies |
| 13 | Education | 1313 | Teacher Education and Professional Development, Specific Subject Areas | 131326 | German Language Teacher Education |
| 16 | Foreign Languages, Literatures and Linguistics | 1605 | Germanic Languages, Literatures Linguistics | 160500 | Germanic Languages, Literatures and Linguistics, General |
| 16 | Foreign Languages, Literatures and Linguistics | 1605 | Germanic Languages, Literatures Linguistics | 160501 | German Language and Literature |
| 16 | Foreign Languages, Literatures and Linguistics | 1605 | Germanic Languages, Literatures Linguistics | 160502 | Scandinavian Languages, Literatures and Linguistics |
| 16 | Foreign Languages, Literatures and Linguistics | 1605 | Germanic Languages, Literatures Linguistics | 160503 | Danish Language and Literature |
| 16 | Foreign Languages, Literatures and Linguistics | 1605 | Germanic Languages, Literatures Linguistics | 160504 | Dutch, Flemish Language and Literature |
| 16 | Foreign Languages, Literatures and Linguistics | 1605 | Germanic Languages, Literatures Linguistics | 160505 | Norwegian Language and Literature |
| 16 | Foreign Languages, Literatures and Linguistics | 1605 | Germanic Languages, Literatures Linguistics | 160506 | Swedish Language and Literature |
| 16 | Foreign Languages, Literatures and Linguistics | 1605 | Germanic Languages, Literatures Linguistics | 160599 | Germanic Languages, Literatures and Linguistics, Other |

Table 4. Search results {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

From the 6-digit program names we find only two that are of interest,
German Studies (050125) and German Language and Literature (160501). We
use a character vector to assign these two codes to the `keep_text`
argument.

``` r

# Search on codes
filter_cip(c("050125", "160501"))
```

| cip2 | cip2name | cip4 | cip4name | cip6 | cip6name |
|----|----|----|----|----|----|
| 05 | Area, Ethnic, Cultural and Gender and Group Studies | 0501 | Area Studies | 050125 | German Studies |
| 16 | Foreign Languages, Literatures and Linguistics | 1605 | Germanic Languages, Literatures Linguistics | 160501 | German Language and Literature |

Table 5. Search results {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

If the 6-digit codes are entered as integers, they produce an error.

``` r

# Search that produces an error
filter_cip(c(050125, 160501))
#> Error in `filter_cip()`:
#> ! Assertion on 'keep_text' failed. Must be of class 'string', not 'double'.
```

## Using a regular expression search

Specifying 4-digit codes yields a data frame all 6-digit programs
containing the 4-digit string. We use the regular expression notation
`^` to match the start of the strings.

``` r

# example 3 filter using regular expressions
filter_cip(c("^1410", "^1419"))
```

| cip2 | cip2name | cip4 | cip4name | cip6 | cip6name |
|----|----|----|----|----|----|
| 14 | Engineering | 1410 | Electrical, Electronics and Communications Engineering | 141001 | Electrical, Electronics and Communications Engineering |
| 14 | Engineering | 1410 | Electrical, Electronics and Communications Engineering | 141003 | Laser and Optical Engineering |
| 14 | Engineering | 1410 | Electrical, Electronics and Communications Engineering | 141004 | Telecommunications Engineering |
| 14 | Engineering | 1410 | Electrical, Electronics and Communications Engineering | 141099 | Electrical, Electronics and Communications Engineering, Other |
| 14 | Engineering | 1419 | Mechanical Engineering | 141901 | Mechanical Engineering |

Table 6. Search results {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

The 2-digit series represent the most general groupings of related
programs. Here, the result includes all History programs.

``` r

# Search on 2-digit code
filter_cip("^54")
```

| cip2 | cip2name | cip4 | cip4name | cip6 | cip6name |
|----|----|----|----|----|----|
| 54 | History | 5401 | History | 540101 | History, General |
| 54 | History | 5401 | History | 540102 | American History (United States) |
| 54 | History | 5401 | History | 540103 | European History |
| 54 | History | 5401 | History | 540104 | History and Philosophy of Science and Technology |
| 54 | History | 5401 | History | 540105 | Public, Applied History and Archival Administration |
| 54 | History | 5401 | History | 540106 | Asian History |
| 54 | History | 5401 | History | 540107 | Canadian History |
| 54 | History | 5401 | History | 540108 | Military History |
| 54 | History | 5401 | History | 540199 | History, Other |

Table 7. Search results {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

The series argument can include any combination of 2, 4, and 6-digit
codes. It can also be passed to the function as a character vector.

``` r

# Search on vector of codes
codes_we_want <- c("^24", "^4102", "^450202")
filter_cip(codes_we_want)
```

| cip2 | cip2name | cip4 | cip4name | cip6 | cip6name |
|----|----|----|----|----|----|
| 24 | Liberal Arts and Sciences, General Studies and Humanities | 2401 | Liberal Arts and Sciences, General Studies Humanities | 240101 | Liberal Arts and Sciences, Liberal Studies |
| 24 | Liberal Arts and Sciences, General Studies and Humanities | 2401 | Liberal Arts and Sciences, General Studies Humanities | 240102 | General Studies |
| 24 | Liberal Arts and Sciences, General Studies and Humanities | 2401 | Liberal Arts and Sciences, General Studies Humanities | 240103 | Humanities, Humanistic Studies |
| 24 | Liberal Arts and Sciences, General Studies and Humanities | 2401 | Liberal Arts and Sciences, General Studies Humanities | 240199 | Liberal Arts and Sciences, General Studies and Humanities, Other |
| 41 | Science Technologies, Technicians | 4102 | Nuclear and Industrial Radiologic Technologies, Technicians | 410204 | Industrial Radiologic Technology, Technician |
| 41 | Science Technologies, Technicians | 4102 | Nuclear and Industrial Radiologic Technologies, Technicians | 410205 | Nuclear, Nuclear Power Technology, Technician |
| 41 | Science Technologies, Technicians | 4102 | Nuclear and Industrial Radiologic Technologies, Technicians | 410299 | Nuclear and Industrial Radiologic Technologies, Technicians, Other |
| 45 | Social Sciences | 4502 | Anthropology | 450202 | Physical Anthropology |

Table 8. Search results {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

## When search terms cannot be found

If the `keep_text` argument includes terms that cannot be found in the
CIP data frame, the unsuccessful terms are identified in a message and
the successful terms produce the usual output.

For example, the following `keep_text` argument includes three search
terms that are not present in the CIP data (“111111”, “^55”, and
“Bogus”) and two that are (“050125” and “160501”).

``` r

# Unsuccessful terms produce a message
sub_cip <- filter_cip(c("050125", "111111", "160501", "Bogus", "^55"))
#> Can't find these terms: 111111, Bogus, ^55

# But the successful terms are returned
sub_cip
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
```

However, as seen earlier, if none of the search terms are found, an
error occurs.

``` r

# When none of the search terms are found
filter_cip(c("111111", "Bogus", "^55"))
#> Error:
#> ! The search result is empty. Possible causes are:
#>  * 'cip' contained no matches to terms in 'keep_text'.
#>  * 'drop_text' eliminated all remaining rows.
```

## CIP data from another source

If you use a CIP data set from another source, it must have the same
structure as `cip`: six character columns named as follows,

``` r

# Name and class of variables (columns) in cip
unlist(lapply(cip, FUN = class))
#>        cip2    cip2name        cip4    cip4name        cip6    cip6name 
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
four_programs <- filter_cip(c("^1408", "^1410", "^1419", "^1427", "^1435", "^1436", "^1437"))

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
selected_programs <- filter_cip(c("^1408", "^1410", "^1419", "^1427", "^1435", "^1436", "^1437"))
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

## References

NCES. 2010. *IPEDS Classification of Instructional Programs (CIP)*.
National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>.
