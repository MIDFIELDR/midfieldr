# Introduction to midfieldr

When working with student-level records to develop quantitative metrics,
we recommend that you:

- Know the structure of your data
- Define your metrics and the relevant blocs of students
- Develop a process to refine and shape your data to produce the blocs
  you need
- Use chart designs suited to the types of results

midfieldr helps you with this process in these areas:

- *Programs.*   Collecting and labeling 6-digit program codes.
- *Records.*   Credibly choosing rows and columns of the source data.  
- *Population.*   Selectively subsetting a population to avoid
  miscounts.
- *Blocs.*   Grouping and summarizing before computing metrics.  
- *Charts.*   Conditioning data for multiway charts.

This document introduces you to midfieldr’s basic set of tools, and
shows you how to apply them to data frames of student-level records.

``` r

library(midfieldr)
library(midfielddata)
library(data.table)
```

## Functions

*Organizing midfieldr’s major functions.*

Working with programs

- [`filter_cip()`](https://midfieldr.github.io/midfieldr/reference/filter_cip.md)
  chooses rows of CIP data based on search terms.

Working with student records

- [`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md)
  chooses columns required by midfieldr functions.
- [`add_post_bacc()`](https://midfieldr.github.io/midfieldr/reference/add_post_bacc.md)
  identifies rows of post-baccalaureate terms to exclude.
- [`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)
  estimates a student’s timely graduation term.
- [`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md)
  identifies rows to exclude due to insufficient data.  
- [`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md)
  determines if program completion is timely or late.

Special conditioning

- [`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)
  conditions data for imputing starting majors of FYE students.
- [`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)
  conditions data for Cleveland multiway charts.

## Syntax

*midfieldr uses data.table syntax.*

Throughout midfieldr—articles, functions, and datasets—we employ
data.table syntax. However, if you prefer using the tidyverse package,
midfieldr functions attempt to return a tibble output if you employ a
tibble input. For example, the `toy_student` data frame that loads with
midfieldr is of the `data.table/data.frame` class.

``` r

class(toy_student)
#> [1] "data.table" "data.frame"
```

If we convert `toy_student` to a tibble and operate on it with a
midfieldr function, we get a tibble (`tbl_df/tbl/data.frame`) in return.

``` r

library(tibble)
x <- as_tibble(toy_student)
class(x)
#> [1] "tbl_df"     "tbl"        "data.frame"

out <- midfieldr::select_basic_cols(x)
class(out)
#> [1] "tbl_df"     "tbl"        "data.frame"
```

Operating on the original dataset with the same function, we get a
`data.table/data.frame` in return.

``` r

out <- select_basic_cols(toy_student)
class(out)
#> [1] "data.table" "data.frame"
```

Those midfieldr users who prefer handling data with dplyr (and friends)
may want to translate our sample scripts into their preferred dialect.
Good resources for such translations are available, e.g., the MIDFIELD
Institute tutorials
([2024](#ref-midfieldinstitute:processing-data:2024)) or Atrebas
([2019](#ref-atrebas:2019))

## Program data

*Collecting and labeling 6-digit program codes.*

The *Classification of Instructional Programs (CIP)* is a taxonomy of
academic programs, encoded by 6-digit numeric codes curated by the US
Department of Education ([NCES 2010](#ref-NCES:2010)).

The `cip` data set, loaded with midfieldr, is a subset of the NCES
CIP2010 data that contains codes and names for 1582 instructional
programs organized on three levels—a 6-digit series, a 4-digit series,
and a 2-digit series—keyed by the `cip6` variable.

``` r

cip
#>                                             cip6name   cip6
#>                                               <char> <char>
#>    1:                           Agriculture, General 010000
#>    2:  Agricultural Business and Management, General 010101
#>    3: Agribusiness, Agricultural Business Operations 010102
#>    4:                         Agricultural Economics 010103
#>    5:                Farm, Farm and Ranch Management 010104
#>   ---                                                      
#> 1578:                                  Asian History 540106
#> 1579:                               Canadian History 540107
#> 1580:                               Military History 540108
#> 1581:                                 History, Other 540199
#> 1582:              NonIPEDS - Undecided, Unspecified 999999
#>                                   cip4name   cip4
#>                                     <char> <char>
#>    1:                 Agriculture, General   0100
#>    2: Agricultural Business and Management   0101
#>    3: Agricultural Business and Management   0101
#>    4: Agricultural Business and Management   0101
#>    5: Agricultural Business and Management   0101
#>   ---                                            
#> 1578:                              History   5401
#> 1579:                              History   5401
#> 1580:                              History   5401
#> 1581:                              History   5401
#> 1582:    NonIPEDS - Undecided, Unspecified   9999
#>                                                        cip2name   cip2
#>                                                          <char> <char>
#>    1: Agriculture, Agricultural Operations and Related Sciences     01
#>    2: Agriculture, Agricultural Operations and Related Sciences     01
#>    3: Agriculture, Agricultural Operations and Related Sciences     01
#>    4: Agriculture, Agricultural Operations and Related Sciences     01
#>    5: Agriculture, Agricultural Operations and Related Sciences     01
#>   ---                                                                 
#> 1578:                                                   History     54
#> 1579:                                                   History     54
#> 1580:                                                   History     54
#> 1581:                                                   History     54
#> 1582:                         NonIPEDS - Undecided, Unspecified     99
```

## `filter_cip()`

*Chooses rows of CIP data based on search terms.*

[`filter_cip()`](https://midfieldr.github.io/midfieldr/reference/filter_cip.md)
acts on the `cip` data frame to select rows that match or partially
match search strings. Search strings are case-independent and can
include regular expressions.

``` r

filter_cip("music")
#>                                      cip6name   cip6
#>                                        <char> <char>
#>  1:                   Music Teacher Education 131312
#>  2:                                     Music 360115
#>  3:                   Religious, Sacred Music 390501
#>  4: Musical Instrument Fabrication and Repair 470404
#>  5:                              Digital Arts 500102
#> ---                                                 
#> 21:                      Woodwind Instruments 500915
#> 22:                    Percussion Instruments 500916
#> 23:                              Music, Other 500999
#> 24:                          Music Management 501003
#> 25:                  Music Therapy, Therapist 512305
#>                                                                   cip4name
#>                                                                     <char>
#>  1: Teacher Education and Professional Development, Specific Subject Areas
#>  2:                                    Leisure and Recreational Activities
#>  3:                                                Religious, Sacred Music
#>  4:                  Precision Systems Maintenance and Repair Technologies
#>  5:                                          General Art and Music Studies
#> ---                                                                       
#> 21:                                                                  Music
#> 22:                                                                  Music
#> 23:                                                                  Music
#> 24:                               Arts, Entertainment and Media Management
#> 25:                             Rehabilitation and Therapeutic Professions
#>       cip4                                         cip2name   cip2
#>     <char>                                           <char> <char>
#>  1:   1313                                        Education     13
#>  2:   3601              Leisure and Recreational Activities     36
#>  3:   3905      Theological Studies and Religious Vocations     39
#>  4:   4704                   Mechanic and Repair Technology     47
#>  5:   5001                       Visual and Performing Arts     50
#> ---                                                               
#> 21:   5009                       Visual and Performing Arts     50
#> 22:   5009                       Visual and Performing Arts     50
#> 23:   5009                       Visual and Performing Arts     50
#> 24:   5010                       Visual and Performing Arts     50
#> 25:   5123 Health Professions and Related Clinical Sciences     51
```

To refine the results of one pass, assign those results to the `cip`
argument in a subsequent pass. To illustrate the process, we collect
programs related to “music” within the Visual and Performing Arts (CIP
code 50).

``` r

first_pass <- filter_cip("music")

second_pass <- filter_cip("^50", cip = first_pass)

second_pass
#>                                 cip6name   cip6
#>                                   <char> <char>
#>  1:                         Digital Arts 500102
#>  2:                      Musical Theatre 500509
#>  3:                       Music, General 500901
#>  4: Music History, Literature and Theory 500902
#>  5:           Music Performance, General 500903
#> ---                                            
#> 16:                    Brass Instruments 500914
#> 17:                 Woodwind Instruments 500915
#> 18:               Percussion Instruments 500916
#> 19:                         Music, Other 500999
#> 20:                     Music Management 501003
#>                                     cip4name   cip4                   cip2name
#>                                       <char> <char>                     <char>
#>  1:            General Art and Music Studies   5001 Visual and Performing Arts
#>  2:       Drama, Theatre Arts and Stagecraft   5005 Visual and Performing Arts
#>  3:                                    Music   5009 Visual and Performing Arts
#>  4:                                    Music   5009 Visual and Performing Arts
#>  5:                                    Music   5009 Visual and Performing Arts
#> ---                                                                           
#> 16:                                    Music   5009 Visual and Performing Arts
#> 17:                                    Music   5009 Visual and Performing Arts
#> 18:                                    Music   5009 Visual and Performing Arts
#> 19:                                    Music   5009 Visual and Performing Arts
#> 20: Arts, Entertainment and Media Management   5010 Visual and Performing Arts
#>       cip2
#>     <char>
#>  1:     50
#>  2:     50
#>  3:     50
#>  4:     50
#>  5:     50
#> ---       
#> 16:     50
#> 17:     50
#> 18:     50
#> 19:     50
#> 20:     50
```

In this case, the 4-digit CIP code 5009 identifies “Music” programs,
distinguishing them from other programs in the Visual and Performing
Arts. We assign the second pass to the `cip` argument and restrict the
search to codes starting with “5009”.

``` r

third_pass <- filter_cip("^5009", cip = second_pass)

third_pass
#>                                 cip6name   cip6 cip4name   cip4
#>                                   <char> <char>   <char> <char>
#>  1:                       Music, General 500901    Music   5009
#>  2: Music History, Literature and Theory 500902    Music   5009
#>  3:           Music Performance, General 500903    Music   5009
#>  4:         Music Theory and Composition 500904    Music   5009
#>  5:       Musicology and Ethnomusicology 500905    Music   5009
#> ---                                                            
#> 13:                     Music Technology 500913    Music   5009
#> 14:                    Brass Instruments 500914    Music   5009
#> 15:                 Woodwind Instruments 500915    Music   5009
#> 16:               Percussion Instruments 500916    Music   5009
#> 17:                         Music, Other 500999    Music   5009
#>                       cip2name   cip2
#>                         <char> <char>
#>  1: Visual and Performing Arts     50
#>  2: Visual and Performing Arts     50
#>  3: Visual and Performing Arts     50
#>  4: Visual and Performing Arts     50
#>  5: Visual and Performing Arts     50
#> ---                                  
#> 13: Visual and Performing Arts     50
#> 14: Visual and Performing Arts     50
#> 15: Visual and Performing Arts     50
#> 16: Visual and Performing Arts     50
#> 17: Visual and Performing Arts     50
```

If these programs were needed for our study, we would save the 6-digit
codes and names and add a `program` variable to label each row as needed
to suit our goals.

``` r

third_pass[, .(cip6name, cip6, program = "custom_label")]
#>                                                 cip6name   cip6      program
#>                                                   <char> <char>       <char>
#>  1:                                       Music, General 500901 custom_label
#>  2:                 Music History, Literature and Theory 500902 custom_label
#>  3:                           Music Performance, General 500903 custom_label
#>  4:                         Music Theory and Composition 500904 custom_label
#>  5:                       Musicology and Ethnomusicology 500905 custom_label
#>  6:                                           Conducting 500906 custom_label
#>  7:                                      Piano and Organ 500907 custom_label
#>  8:                                      Voice and Opera 500908 custom_label
#>  9:                   Music Management and Merchandising 500909 custom_label
#> 10:                                   Jazz, Jazz Studies 500910 custom_label
#> 11: Violin, Viola, Guitar and Other Stringed Instruments 500911 custom_label
#> 12:                                       Music Pedagogy 500912 custom_label
#> 13:                                     Music Technology 500913 custom_label
#> 14:                                    Brass Instruments 500914 custom_label
#> 15:                                 Woodwind Instruments 500915 custom_label
#> 16:                               Percussion Instruments 500916 custom_label
#> 17:                                         Music, Other 500999 custom_label
```

## Student-level data

To explore the basic functionality of midfieldr, we use the datasets in
*midfielddata*: an R data package containing four tables — `student`,
`course`, `term`, and `degree` — providing anonymized student-level
records for 98,000 undergraduates at three US institutions from 1988
through 2018. The data tables are documented at the
[midfielddata](https://midfieldr.github.io/midfielddata/reference/index.html)
website.

For this article we load the student, term, and degree tables from
midfielddata.

``` r

data(student, term, degree)
```

We usually copy the source data, giving them new names (and new
locations in memory), to keep them intact while we use the original
names — `student`, `term`, and `degree` — to do our work.

``` r

student_source <- copy(student)
term_source <- copy(term)
degree_source <- copy(degree)
```

The data tables are linked by `mcid`, the anonymized student ID.
[`look_at()`](https://midfieldr.github.io/midfieldr/reference/look_at.md)
is a midfieldr convenience function that wraps `base::str()`.

``` r

look_at(student)
#> Classes 'data.table' and 'data.frame':   97555 obs. of  13 variables:
#>  $ mcid          : chr  "MCID3111142225" "MCID3111142283" "MCID3111142290" "M"..
#>  $ institution   : chr  "Institution B" "Institution J" "Institution J" "Inst"..
#>  $ transfer      : chr  "First-Time Transfer" "First-Time Transfer" "First-Ti"..
#>  $ hours_transfer: num  NA NA NA NA NA NA NA NA NA NA ...
#>  $ race          : chr  "Asian" "Asian" "Asian" "Asian" ...
#>  $ sex           : chr  "Male" "Female" "Male" "Male" ...
#>  $ age_desc      : chr  "Under 25" "Under 25" "Under 25" "Under 25" ...
#>  $ us_citizen    : chr  "Yes" "Yes" "Yes" "Yes" ...
#>  $ home_zip      : chr  NA "22020" "23233" "20853" ...
#>  $ high_school   : chr  NA NA "471872" NA ...
#>  $ sat_math      : num  NA 560 510 640 600 570 480 NA NA NA ...
#>  $ sat_verbal    : num  NA 230 380 460 500 530 530 NA NA NA ...
#>  $ act_comp      : num  NA NA NA NA NA NA NA NA NA NA ...

look_at(term)
#> Classes 'data.table' and 'data.frame':   639915 obs. of  13 variables:
#>  $ mcid               : chr  "MCID3111142225" "MCID3111142283" "MCID311114228"..
#>  $ institution        : chr  "Institution B" "Institution J" "Institution J" "..
#>  $ term               : chr  "19881" "19881" "19883" "19885" ...
#>  $ cip6               : chr  "140901" "240102" "240102" "190601" ...
#>  $ level              : chr  "01 First-year" "01 First-year" "01 First-year" "..
#>  $ standing           : chr  "Good Standing" "Academic Probation" "Academic P"..
#>  $ coop               : chr  "No" "No" "No" "No" ...
#>  $ hours_term         : num  7 6 12 6 6 6 6 18 15 14 ...
#>  $ hours_term_attempt : num  7 6 12 6 6 6 6 18 18 14 ...
#>  $ hours_cumul        : num  7 6 18 24 30 36 42 63 78 14 ...
#>  $ hours_cumul_attempt: num  7 6 18 24 30 36 42 63 81 14 ...
#>  $ gpa_term           : num  2.56 1.85 1.93 2.15 1.85 1.2 1.85 2.33 2.32 2.15 ..
#>  $ gpa_cumul          : num  2.56 1.85 1.9 1.96 1.94 1.82 1.82 1.98 2.04 2.15 ..

look_at(degree)
#> Classes 'data.table' and 'data.frame':   49665 obs. of  5 variables:
#>  $ mcid       : chr  "MCID3111142225" "MCID3111142290" "MCID3111142294" "MCID"..
#>  $ institution: chr  "Institution B" "Institution J" "Institution J" "Institu"..
#>  $ term_degree: chr  "19881" "19921" "19903" "19921" ...
#>  $ cip6       : chr  "141001" "141001" "141001" "141001" ...
#>  $ degree     : chr  "Bachelor of Science in Electrical Engineering" "Bachelo"..
```

## `select_basic_cols()`

*Chooses columns required by midfieldr functions.*

[`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md)
operates on student records to reduce the number of columns to those
required by other midfieldr functions plus the key or composite key
variables of the four data tables.

``` r

student <- select_basic_cols(student)
term <- select_basic_cols(term)
degree <- select_basic_cols(degree)
```

For example, compare `term` before and after applying
[`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md).

``` r

look_at(term_source)
#> Classes 'data.table' and 'data.frame':   639915 obs. of  13 variables:
#>  $ mcid               : chr  "MCID3111142225" "MCID3111142283" "MCID311114228"..
#>  $ institution        : chr  "Institution B" "Institution J" "Institution J" "..
#>  $ term               : chr  "19881" "19881" "19883" "19885" ...
#>  $ cip6               : chr  "140901" "240102" "240102" "190601" ...
#>  $ level              : chr  "01 First-year" "01 First-year" "01 First-year" "..
#>  $ standing           : chr  "Good Standing" "Academic Probation" "Academic P"..
#>  $ coop               : chr  "No" "No" "No" "No" ...
#>  $ hours_term         : num  7 6 12 6 6 6 6 18 15 14 ...
#>  $ hours_term_attempt : num  7 6 12 6 6 6 6 18 18 14 ...
#>  $ hours_cumul        : num  7 6 18 24 30 36 42 63 78 14 ...
#>  $ hours_cumul_attempt: num  7 6 18 24 30 36 42 63 81 14 ...
#>  $ gpa_term           : num  2.56 1.85 1.93 2.15 1.85 1.2 1.85 2.33 2.32 2.15 ..
#>  $ gpa_cumul          : num  2.56 1.85 1.9 1.96 1.94 1.82 1.82 1.98 2.04 2.15 ..

look_at(term)
#> Classes 'data.table' and 'data.frame':   639915 obs. of  5 variables:
#>  $ mcid       : chr  "MCID3111142225" "MCID3111142283" "MCID3111142283" "MCID"..
#>  $ institution: chr  "Institution B" "Institution J" "Institution J" "Institu"..
#>  $ term       : chr  "19881" "19881" "19883" "19885" ...
#>  $ cip6       : chr  "140901" "240102" "240102" "190601" ...
#>  $ level      : chr  "01 First-year" "01 First-year" "01 First-year" "01 Firs"..
```

With a smaller number of columns, the printout of the data frame is more
readable, a benefit when working with the data interactively.

``` r

term
#>                   mcid   institution   term   cip6          level
#>                 <char>        <char> <char> <char>         <char>
#>      1: MCID3111142225 Institution B  19881 140901  01 First-year
#>      2: MCID3111142283 Institution J  19881 240102  01 First-year
#>      3: MCID3111142283 Institution J  19883 240102  01 First-year
#>      4: MCID3111142283 Institution J  19885 190601  01 First-year
#>      5: MCID3111142283 Institution J  19891 190601 02 Second-year
#>     ---                                                          
#> 639911: MCID3112898886 Institution B  20181 500501  01 First-year
#> 639912: MCID3112898890 Institution B  20181 451101  01 First-year
#> 639913: MCID3112898894 Institution B  20181 451001  01 First-year
#> 639914: MCID3112898895 Institution B  20181 302001  01 First-year
#> 639915: MCID3112898940 Institution B  20181 050103  01 First-year
```

## `add_post_bacc()`

*Identifies rows of post-baccalaureate terms to exclude.*

[`add_post_bacc()`](https://midfieldr.github.io/midfieldr/reference/add_post_bacc.md)
identifies terms later than the first baccalaureate, if any. Because we
are not generally interested in terms beyond the first degree term, we
use the results of this function to exclude post-first-degree terms.

``` r

term <- add_post_bacc(dframe = term, midfield_degree = degree)
degree <- add_post_bacc(dframe = degree, midfield_degree = degree)
```

[`add_post_bacc()`](https://midfieldr.github.io/midfieldr/reference/add_post_bacc.md)
adds a column indicating the term status for every student in the
record. The new columns are documented in
[`?add_post_bacc`](https://midfieldr.github.io/midfieldr/reference/add_post_bacc.md).

``` r

term
#>                   mcid   institution   cip6          level   term
#>                 <char>        <char> <char>         <char> <char>
#>      1: MCID3111142225 Institution B 140901  01 First-year  19881
#>      2: MCID3111142283 Institution J 240102  01 First-year  19881
#>      3: MCID3111142283 Institution J 240102  01 First-year  19883
#>      4: MCID3111142283 Institution J 190601  01 First-year  19885
#>      5: MCID3111142283 Institution J 190601 02 Second-year  19891
#>     ---                                                          
#> 639911: MCID3112898886 Institution B 500501  01 First-year  20181
#> 639912: MCID3112898890 Institution B 451101  01 First-year  20181
#> 639913: MCID3112898894 Institution B 451001  01 First-year  20181
#> 639914: MCID3112898895 Institution B 302001  01 First-year  20181
#> 639915: MCID3112898940 Institution B 050103  01 First-year  20181
#>         first_degree_term  term_status
#>                    <char>       <char>
#>      1:             19881 first-degree
#>      2:              <NA>     pre-bacc
#>      3:              <NA>     pre-bacc
#>      4:              <NA>     pre-bacc
#>      5:              <NA>     pre-bacc
#>     ---                               
#> 639911:              <NA>     pre-bacc
#> 639912:              <NA>     pre-bacc
#> 639913:              <NA>     pre-bacc
#> 639914:              <NA>     pre-bacc
#> 639915:              <NA>     pre-bacc
```

Using
[`sort_uniq()`](https://midfieldr.github.io/midfieldr/reference/sort_uniq.md),
a midfieldr convenience function to sort unique values of a vector, we
find the possible values for term status to be:

``` r

sort_uniq(term$term_status)
#> [1] "first-degree"      "post-first-degree" "pre-bacc"
```

We filter to exclude all terms labeled “post-first-degree”.

``` r

term <- term[term_status != "post-first-degree"]
degree <- degree[term_status != "post-first-degree"]

term
#>                   mcid   institution   cip6          level   term
#>                 <char>        <char> <char>         <char> <char>
#>      1: MCID3111142225 Institution B 140901  01 First-year  19881
#>      2: MCID3111142283 Institution J 240102  01 First-year  19881
#>      3: MCID3111142283 Institution J 240102  01 First-year  19883
#>      4: MCID3111142283 Institution J 190601  01 First-year  19885
#>      5: MCID3111142283 Institution J 190601 02 Second-year  19891
#>     ---                                                          
#> 632913: MCID3112898886 Institution B 500501  01 First-year  20181
#> 632914: MCID3112898890 Institution B 451101  01 First-year  20181
#> 632915: MCID3112898894 Institution B 451001  01 First-year  20181
#> 632916: MCID3112898895 Institution B 302001  01 First-year  20181
#> 632917: MCID3112898940 Institution B 050103  01 First-year  20181
#>         first_degree_term  term_status
#>                    <char>       <char>
#>      1:             19881 first-degree
#>      2:              <NA>     pre-bacc
#>      3:              <NA>     pre-bacc
#>      4:              <NA>     pre-bacc
#>      5:              <NA>     pre-bacc
#>     ---                               
#> 632913:              <NA>     pre-bacc
#> 632914:              <NA>     pre-bacc
#> 632915:              <NA>     pre-bacc
#> 632916:              <NA>     pre-bacc
#> 632917:              <NA>     pre-bacc
```

## `add_timely_term()`

*Estimates a student’s timely graduation term.*

The timely completion term is the last term in which a student’s degree
completion would be considered timely. In many cases the timely
completion (TC) term is 6 years after admission.

We regularly use this step to begin defining our population for a study,
so we begin with the unique IDs from the term record obtained above.

``` r

DT <- term[, .(mcid)]
DT <- unique(DT)

DT
#>                  mcid
#>                <char>
#>     1: MCID3111142225
#>     2: MCID3111142283
#>     3: MCID3111142290
#>     4: MCID3111142294
#>     5: MCID3111142299
#>    ---               
#> 97532: MCID3112898886
#> 97533: MCID3112898890
#> 97534: MCID3112898894
#> 97535: MCID3112898895
#> 97536: MCID3112898940
```

[`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)
adds a column indicating the TC term for every student in the record.
New columns of supporting information are also added, documented in
[`?add_timely_term`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md).

``` r

DT <- add_timely_term(DT, midfield_term = term)

DT
#>                  mcid term_i       level_i adj_span timely_term
#>                <char> <char>        <char>    <num>      <char>
#>     1: MCID3111142225  19881 01 First-year        6       19933
#>     2: MCID3111142283  19881 01 First-year        6       19933
#>     3: MCID3111142290  19881 01 First-year        6       19933
#>     4: MCID3111142294  19881 01 First-year        6       19933
#>     5: MCID3111142299  19881 01 First-year        6       19933
#>    ---                                                         
#> 97532: MCID3112898886  20181 01 First-year        6       20233
#> 97533: MCID3112898890  20181 01 First-year        6       20233
#> 97534: MCID3112898894  20181 01 First-year        6       20233
#> 97535: MCID3112898895  20181 01 First-year        6       20233
#> 97536: MCID3112898940  20181 01 First-year        6       20233
```

## `add_data_sufficiency()`

*Identifies rows to exclude due to insufficient data.*

The data sufficiency criterion limits student records to those for which
available data are sufficient to assess timely completion without biased
counts of completers or non-completers.

[`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md)
adds a column that labels each row for inclusion or exclusion based on
data sufficiency near the upper and lower bounds of an institution’s
data range. New columns of supporting information are also added,
documented in
[`?add_data_sufficiency`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md).

``` r

DT <- add_data_sufficiency(DT, midfield_term = term)

DT
#>                  mcid       level_i adj_span timely_term term_i lower_limit
#>                <char>        <char>    <num>      <char> <char>      <char>
#>     1: MCID3111142225 01 First-year        6       19933  19881       19881
#>     2: MCID3111142283 01 First-year        6       19933  19881       19881
#>     3: MCID3111142290 01 First-year        6       19933  19881       19881
#>     4: MCID3111142294 01 First-year        6       19933  19881       19881
#>     5: MCID3111142299 01 First-year        6       19933  19881       19881
#>    ---                                                                     
#> 97532: MCID3112898886 01 First-year        6       20233  20181       19881
#> 97533: MCID3112898890 01 First-year        6       20233  20181       19881
#> 97534: MCID3112898894 01 First-year        6       20233  20181       19881
#> 97535: MCID3112898895 01 First-year        6       20233  20181       19881
#> 97536: MCID3112898940 01 First-year        6       20233  20181       19881
#>        upper_limit data_sufficiency
#>             <char>           <char>
#>     1:       20181    exclude-lower
#>     2:       20096    exclude-lower
#>     3:       20096    exclude-lower
#>     4:       20096    exclude-lower
#>     5:       20096    exclude-lower
#>    ---                             
#> 97532:       20181    exclude-upper
#> 97533:       20181    exclude-upper
#> 97534:       20181    exclude-upper
#> 97535:       20181    exclude-upper
#> 97536:       20181    exclude-upper
```

The possible values for data sufficiency are:

``` r

sort_uniq(DT$data_sufficiency)
#> [1] "exclude-lower" "exclude-upper" "include"
```

We filter to retain rows labeled “include”.

``` r

DT <- DT[data_sufficiency == "include"]

DT
#>                  mcid       level_i adj_span timely_term term_i lower_limit
#>                <char>        <char>    <num>      <char> <char>      <char>
#>     1: MCID3111142689 01 First-year        6       19941  19883       19881
#>     2: MCID3111142782 01 First-year        6       19941  19883       19881
#>     3: MCID3111142881 01 First-year        6       19951  19893       19881
#>     4: MCID3111142884 01 First-year        6       19941  19883       19881
#>     5: MCID3111142893 01 First-year        6       19941  19883       19881
#>    ---                                                                     
#> 76861: MCID3112727985 01 First-year        6       20173  20114       19881
#> 76862: MCID3112730841 01 First-year        6       20173  20121       19881
#> 76863: MCID3112785480 01 First-year        6       20123  20071       19901
#> 76864: MCID3112800920 01 First-year        6       20153  20101       19881
#> 76865: MCID3112870009 01 First-year        6       20003  19951       19881
#>        upper_limit data_sufficiency
#>             <char>           <char>
#>     1:       20181          include
#>     2:       20096          include
#>     3:       20181          include
#>     4:       20181          include
#>     5:       20181          include
#>    ---                             
#> 76861:       20181          include
#> 76862:       20181          include
#> 76863:       20154          include
#> 76864:       20181          include
#> 76865:       20181          include
```

## `add_completion_status()`

*Determines if program completion is timely or late.*

[`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md)
adds a column of labels indicating whether or not a student completes a
degree, and if they do, labeling it timely or late compared to their
timely completion term.

``` r

DT <- add_completion_status(DT, midfield_degree = degree)

DT
#>                  mcid       level_i adj_span timely_term term_i lower_limit
#>                <char>        <char>    <num>      <char> <char>      <char>
#>     1: MCID3111142689 01 First-year        6       19941  19883       19881
#>     2: MCID3111142782 01 First-year        6       19941  19883       19881
#>     3: MCID3111142881 01 First-year        6       19951  19893       19881
#>     4: MCID3111142884 01 First-year        6       19941  19883       19881
#>     5: MCID3111142893 01 First-year        6       19941  19883       19881
#>    ---                                                                     
#> 76861: MCID3112727985 01 First-year        6       20173  20114       19881
#> 76862: MCID3112730841 01 First-year        6       20173  20121       19881
#> 76863: MCID3112785480 01 First-year        6       20123  20071       19901
#> 76864: MCID3112800920 01 First-year        6       20153  20101       19881
#> 76865: MCID3112870009 01 First-year        6       20003  19951       19881
#>        upper_limit data_sufficiency term_degree completion_status
#>             <char>           <char>      <char>            <char>
#>     1:       20181          include       19913            timely
#>     2:       20096          include       19903            timely
#>     3:       20181          include       19894            timely
#>     4:       20181          include        <NA>              <NA>
#>     5:       20181          include        <NA>              <NA>
#>    ---                                                           
#> 76861:       20181          include        <NA>              <NA>
#> 76862:       20181          include       20164            timely
#> 76863:       20154          include        <NA>              <NA>
#> 76864:       20181          include        <NA>              <NA>
#> 76865:       20181          include        <NA>              <NA>
```

The possible values for completion status are:

``` r

sort_uniq(DT$completion_status)
#> [1] NA       "late"   "timely"
```

If we were constructing a bloc of timely graduates, we would filter to
retain rows labeled “timely”.

``` r

DT[completion_status == "timely"]
#>                  mcid       level_i adj_span timely_term term_i lower_limit
#>                <char>        <char>    <num>      <char> <char>      <char>
#>     1: MCID3111142689 01 First-year        6       19941  19883       19881
#>     2: MCID3111142782 01 First-year        6       19941  19883       19881
#>     3: MCID3111142881 01 First-year        6       19951  19893       19881
#>     4: MCID3111142965 01 First-year        6       19941  19883       19881
#>     5: MCID3111143066 01 First-year        6       19941  19883       19881
#>    ---                                                                     
#> 40426: MCID3112675459 01 First-year        6       20173  20114       19881
#> 40427: MCID3112675472 01 First-year        6       20171  20113       19881
#> 40428: MCID3112692944 01 First-year        6       20163  20111       19881
#> 40429: MCID3112694738 01 First-year        6       20161  20103       19881
#> 40430: MCID3112730841 01 First-year        6       20173  20121       19881
#>        upper_limit data_sufficiency term_degree completion_status
#>             <char>           <char>      <char>            <char>
#>     1:       20181          include       19913            timely
#>     2:       20096          include       19903            timely
#>     3:       20181          include       19894            timely
#>     4:       20096          include       19901            timely
#>     5:       20181          include       19883            timely
#>    ---                                                           
#> 40426:       20181          include       20153            timely
#> 40427:       20181          include       20153            timely
#> 40428:       20181          include       20153            timely
#> 40429:       20181          include       20143            timely
#> 40430:       20181          include       20164            timely
```

## Other functions

[`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)
  Conditions data for imputing the starting majors of First-Year
Engineering (FYE) students. Used when blocs of starters in Engineering
are needed and an institution has a required FYE program. For details
see [FYE
proxies](https://midfieldr.github.io/midfieldr/articles/art-060-fye-proxies.md).

[`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)
  Conditions data for Cleveland multiway charts. The ordering of its
rows and panels is crucial to the perception of effects. Used when data
have a multiway structure. For details see [Multiway data and
charts](https://midfieldr.github.io/midfieldr/articles/art-120-multiway.md).

Utilities

- [`look_at()`](https://midfieldr.github.io/midfieldr/reference/look_at.md)
  wraps base [`str()`](https://rdrr.io/r/utils/str.html).  
- [`sort_uniq()`](https://midfieldr.github.io/midfieldr/reference/sort_uniq.md)
  wraps base [`sort()`](https://rdrr.io/r/base/sort.html) and
  [`unique()`](https://rdrr.io/r/base/unique.html).  
- [`catch_error()`](https://midfieldr.github.io/midfieldr/reference/catch_error.md)
  wraps base [`tryCatch()`](https://rdrr.io/r/base/conditions.html) for
  errors.  
- [`check_equiv_frames()`](https://winvector.github.io/wrapr//reference/check_equiv_frames.html)
  re-exported from the wrapr package

## References

atrebas. 2019. *A data.table and dplyr tour*.
<https://atrebas.github.io/post/2019-03-03-datatable-dplyr/>.

Lord, Susan, Richard Layton, Russell Long, Matthew Ohland, and Marisa
Orr. 2024. *MIDFIELD Institute*.
<https://midfieldr.github.io/2024-midfield-institute/data-shaping-00-introduction.html>.

NCES. 2010. *IPEDS Classification of Instructional Programs (CIP)*.
National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>.
