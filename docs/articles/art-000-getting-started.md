# Introduction to midfieldr

When working with student-level records to develop quantitative metrics,
midfieldr helps you refine and shape your data in these areas:

- *Programs.*   Collect 6-digit program codes.
- *Records.*   Credibly subset source data and refine the population to
  suit your study.
- *Blocs.*   Construct group of records for computing metrics.

This document introduces you to midfieldr’s basic set of tools.

``` r

library("midfieldr")
library("midfielddata")
library("data.table")
```

Before you start:

1.  *On syntax:*   We use data.table syntax for data manipulation
    throughout midfieldr and all data frames are of the `data.table`
    class. However, if you happen to prefer tidyverse syntax, midfieldr
    functions do attempt to preserve data frame attributes such as the
    `tbl_df` class.

2.  *On functions:*   In getting started, we provide a brief
    introduction only. Details are discussed at length in subsequent
    articles. You can always access the documentation, e.g.,
    `?function_name`, for more information.

## midfieldr functions

The major functions can be organized into four categories based on their
contribution to a typical workflow:

Refining primary data

- [`filter_programs()`](https://midfieldr.github.io/midfieldr/reference/filter_programs.md)
  helps you find program names and CIP codes.  
- [`post_bacc_terms()`](https://midfieldr.github.io/midfieldr/reference/post_bacc_terms.md)
  identifies post-baccalaureate terms to exclude.

Refining a population

- [`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md)
  estimates timely completion terms.  
- [`data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/data_sufficiency.md)
  identifies IDs to exclude due to insufficient data.  
- [`completion_status()`](https://midfieldr.github.io/midfieldr/reference/completion_status.md)
  labels program completion as timely, late, or NA.

Special conditioning

- [`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)
  conditions data for imputing starting majors of FYE students.  
- [`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)
  conditions data for Cleveland multiway charts.

Convenience

- [`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md)
  chooses those columns required by other midfieldr functions.

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

## `filter_programs()`

*Chooses rows of CIP data based on search terms.*

[`filter_programs()`](https://midfieldr.github.io/midfieldr/reference/filter_programs.md)
acts on the data frame assigned to its `dframe` argument to select rows
that match or partially match search strings. Search strings are
case-independent and can include regular expressions.

``` r

filter_programs(cip, "music")
#>                     cip6name   cip6
#>                       <char> <char>
#>  1:  Music Teacher Education 131312
#>  2:                    Music 360115
#>  3:  Religious, Sacred Music 390501
#> ---                                
#> 23:             Music, Other 500999
#> 24:         Music Management 501003
#> 25: Music Therapy, Therapist 512305
#>                                                                   cip4name
#>                                                                     <char>
#>  1: Teacher Education and Professional Development, Specific Subject Areas
#>  2:                                    Leisure and Recreational Activities
#>  3:                                                Religious, Sacred Music
#> ---                                                                       
#> 23:                                                                  Music
#> 24:                               Arts, Entertainment and Media Management
#> 25:                             Rehabilitation and Therapeutic Professions
#>       cip4                                         cip2name   cip2
#>     <char>                                           <char> <char>
#>  1:   1313                                        Education     13
#>  2:   3601              Leisure and Recreational Activities     36
#>  3:   3905      Theological Studies and Religious Vocations     39
#> ---                                                               
#> 23:   5009                       Visual and Performing Arts     50
#> 24:   5010                       Visual and Performing Arts     50
#> 25:   5123 Health Professions and Related Clinical Sciences     51
```

To refine our results, we can assign the results of a first pass to the
`dframe` argument of a second pass. For example, our first pass below
searches the default `cip` dataset for “music”. Our second pass searches
the results of the first pass for any line that starts with “50”.

``` r

first_pass <- filter_programs(cip, "music")
second_pass <- filter_programs(first_pass, "^50")
second_pass
#>                   cip6name   cip6                                 cip4name
#>                     <char> <char>                                   <char>
#>  1:           Digital Arts 500102            General Art and Music Studies
#>  2:        Musical Theatre 500509       Drama, Theatre Arts and Stagecraft
#>  3:         Music, General 500901                                    Music
#> ---                                                                       
#> 18: Percussion Instruments 500916                                    Music
#> 19:           Music, Other 500999                                    Music
#> 20:       Music Management 501003 Arts, Entertainment and Media Management
#>       cip4                   cip2name   cip2
#>     <char>                     <char> <char>
#>  1:   5001 Visual and Performing Arts     50
#>  2:   5005 Visual and Performing Arts     50
#>  3:   5009 Visual and Performing Arts     50
#> ---                                         
#> 18:   5009 Visual and Performing Arts     50
#> 19:   5009 Visual and Performing Arts     50
#> 20:   5010 Visual and Performing Arts     50
```

Alternatively, one may chain the operations,

``` r

cip |>
  filter_programs("music") |>
  filter_programs("^50")
#>                   cip6name   cip6                                 cip4name
#>                     <char> <char>                                   <char>
#>  1:           Digital Arts 500102            General Art and Music Studies
#>  2:        Musical Theatre 500509       Drama, Theatre Arts and Stagecraft
#>  3:         Music, General 500901                                    Music
#> ---                                                                       
#> 18: Percussion Instruments 500916                                    Music
#> 19:           Music, Other 500999                                    Music
#> 20:       Music Management 501003 Arts, Entertainment and Media Management
#>       cip4                   cip2name   cip2
#>     <char>                     <char> <char>
#>  1:   5001 Visual and Performing Arts     50
#>  2:   5005 Visual and Performing Arts     50
#>  3:   5009 Visual and Performing Arts     50
#> ---                                         
#> 18:   5009 Visual and Performing Arts     50
#> 19:   5009 Visual and Performing Arts     50
#> 20:   5010 Visual and Performing Arts     50
```

Assuming we are looking for programs in a School of Music, the 4-digit
code “5009” appears to be the correct finding. Our third pass searches
the results of the second pass for any line that starts with “5009”.

``` r

third_pass <- filter_programs(second_pass, "^5009")
third_pass
#>                                 cip6name   cip6 cip4name   cip4
#>                                   <char> <char>   <char> <char>
#>  1:                       Music, General 500901    Music   5009
#>  2: Music History, Literature and Theory 500902    Music   5009
#>  3:           Music Performance, General 500903    Music   5009
#> ---                                                            
#> 15:                 Woodwind Instruments 500915    Music   5009
#> 16:               Percussion Instruments 500916    Music   5009
#> 17:                         Music, Other 500999    Music   5009
#>                       cip2name   cip2
#>                         <char> <char>
#>  1: Visual and Performing Arts     50
#>  2: Visual and Performing Arts     50
#>  3: Visual and Performing Arts     50
#> ---                                  
#> 15: Visual and Performing Arts     50
#> 16: Visual and Performing Arts     50
#> 17: Visual and Performing Arts     50
```

If these were part of our study programs, we would save the 6-digit
codes and names and add a `program` variable to label each row as needed
to suit our goals. Here, we insert a placeholder value “label_TBD”. We
might save the data frame as our `programs` data frame.

``` r

programs <- third_pass[, .(cip6name, cip6, program = "label_TBD")]
programs
#>                                                 cip6name   cip6   program
#>                                                   <char> <char>    <char>
#>  1:                                       Music, General 500901 label_TBD
#>  2:                 Music History, Literature and Theory 500902 label_TBD
#>  3:                           Music Performance, General 500903 label_TBD
#>  4:                         Music Theory and Composition 500904 label_TBD
#>  5:                       Musicology and Ethnomusicology 500905 label_TBD
#>  6:                                           Conducting 500906 label_TBD
#>  7:                                      Piano and Organ 500907 label_TBD
#>  8:                                      Voice and Opera 500908 label_TBD
#>  9:                   Music Management and Merchandising 500909 label_TBD
#> 10:                                   Jazz, Jazz Studies 500910 label_TBD
#> 11: Violin, Viola, Guitar and Other Stringed Instruments 500911 label_TBD
#> 12:                                       Music Pedagogy 500912 label_TBD
#> 13:                                     Music Technology 500913 label_TBD
#> 14:                                    Brass Instruments 500914 label_TBD
#> 15:                                 Woodwind Instruments 500915 label_TBD
#> 16:                               Percussion Instruments 500916 label_TBD
#> 17:                                         Music, Other 500999 label_TBD
```

Which specific programs we select depend on the study, of course, but in
all cases the end result is a data frame like the one shown above with
the 6-digit CIP codes, possibly the NCES 6-digit program name, and our
own program labels.

## Student-level data

*Credibly subset the source data and refine the population.*

For this article we load the `student`, `term`, and `degree` tables from
midfielddata.

``` r

data(student, term, degree)
```

[`look_at()`](https://midfieldr.github.io/midfieldr/reference/look_at.md)
is a midfieldr convenience function that wraps `base::str()` using our
preferred arguments. The data tables are linked by `mcid`, the
anonymized student ID.

``` r

look_at(student)
#> Classes 'data.table' and 'data.frame':   97555 obs. of  13 variables:
#>  $ mcid          : chr  "MCID3111142225" "MCID3111142283" "MCID3111142290" "M"..
#>  $ race          : chr  "Asian" "Asian" "Asian" "Asian" ...
#>  $ sex           : chr  "Male" "Female" "Male" "Male" ...
#>  $ institution   : chr  "Institution B" "Institution J" "Institution J" "Inst"..
#>  $ transfer      : chr  "First-Time Transfer" "First-Time Transfer" "First-Ti"..
#>  $ hours_transfer: num  NA NA NA NA NA NA NA NA NA NA ...
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
#>  $ term               : chr  "19881" "19881" "19883" "19885" ...
#>  $ cip6               : chr  "140901" "240102" "240102" "190601" ...
#>  $ institution        : chr  "Institution B" "Institution J" "Institution J" "..
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
#>  $ term_degree: chr  "19881" "19921" "19903" "19921" ...
#>  $ cip6       : chr  "141001" "141001" "141001" "141001" ...
#>  $ institution: chr  "Institution B" "Institution J" "Institution J" "Institu"..
#>  $ degree     : chr  "Bachelor of Science in Electrical Engineering" "Bachelo"..
```

As we prepare the data, we copy our “source” material under separate
names (and locations in memory) at a couple of key points.

``` r

student_source <- copy(student)
term_source <- copy(term)
degree_source <- copy(degree)
```

Then we can use the shorter names such as `term` and `degree` as we
work. The shorter names are also the default values for arguments in
several midfieldr functions.

## `post_bacc_terms()`

*Identify rows of post-baccalaureate terms to exclude.*

In most cases, we are not generally interested in academic terms beyond
the first degree term, so we use the results of this function to exclude
post-first-degree terms from the source data.

[`post_bacc_terms()`](https://midfieldr.github.io/midfieldr/reference/post_bacc_terms.md)
identifies terms later than the first baccalaureate, if any.

``` r

term <- post_bacc_terms(term_source, midfield_table = degree)
degree <- post_bacc_terms(degree_source, midfield_table = degree)
```

[`post_bacc_terms()`](https://midfieldr.github.io/midfieldr/reference/post_bacc_terms.md)
adds a column indicating the cluster a term belongs to with respect to
the first degree term.

``` r

look_at(term)
#> Classes 'data.table' and 'data.frame':   639915 obs. of  15 variables:
#>  $ mcid               : chr  "MCID3111142225" "MCID3111142283" "MCID311114228"..
#>  $ term               : chr  "19881" "19881" "19883" "19885" ...
#>  $ cip6               : chr  "140901" "240102" "240102" "190601" ...
#>  $ institution        : chr  "Institution B" "Institution J" "Institution J" "..
#>  $ level              : chr  "01 First-year" "01 First-year" "01 First-year" "..
#>  $ standing           : chr  "Good Standing" "Academic Probation" "Academic P"..
#>  $ coop               : chr  "No" "No" "No" "No" ...
#>  $ hours_term         : num  7 6 12 6 6 6 6 18 15 14 ...
#>  $ hours_term_attempt : num  7 6 12 6 6 6 6 18 18 14 ...
#>  $ hours_cumul        : num  7 6 18 24 30 36 42 63 78 14 ...
#>  $ hours_cumul_attempt: num  7 6 18 24 30 36 42 63 81 14 ...
#>  $ gpa_term           : num  2.56 1.85 1.93 2.15 1.85 1.2 1.85 2.33 2.32 2.15 ..
#>  $ gpa_cumul          : num  2.56 1.85 1.9 1.96 1.94 1.82 1.82 1.98 2.04 2.15 ..
#>  $ first_degree_term  : chr  "19881" NA NA NA ...
#>  $ term_cluster       : chr  "first-degree" "pre-degree" "pre-degree" "pre-de"..
```

[`sort_uniq()`](https://midfieldr.github.io/midfieldr/reference/sort_uniq.md)
is a convenience function that wraps `base::sort(unique())` using our
preferred arguments. The possible term cluster values are given by,

``` r

sort_uniq(term$term_cluster)
#> [1] "first-degree"      "post-first-degree" "pre-degree"
```

We filter to exclude all terms labeled “post-first-degree” and drop the
temporary columns.

``` r

term <- term[!"post-first-degree", on = "term_cluster"]
degree <- degree[!"post-first-degree", on = "term_cluster"]

term[, c("term_cluster", "first_degree_term") := NULL]
degree[, c("term_cluster", "first_degree_term") := NULL]

look_at(term)
#> Classes 'data.table' and 'data.frame':   632917 obs. of  13 variables:
#>  $ mcid               : chr  "MCID3111142225" "MCID3111142283" "MCID311114228"..
#>  $ term               : chr  "19881" "19881" "19883" "19885" ...
#>  $ cip6               : chr  "140901" "240102" "240102" "190601" ...
#>  $ institution        : chr  "Institution B" "Institution J" "Institution J" "..
#>  $ level              : chr  "01 First-year" "01 First-year" "01 First-year" "..
#>  $ standing           : chr  "Good Standing" "Academic Probation" "Academic P"..
#>  $ coop               : chr  "No" "No" "No" "No" ...
#>  $ hours_term         : num  7 6 12 6 6 6 6 18 15 14 ...
#>  $ hours_term_attempt : num  7 6 12 6 6 6 6 18 18 14 ...
#>  $ hours_cumul        : num  7 6 18 24 30 36 42 63 78 14 ...
#>  $ hours_cumul_attempt: num  7 6 18 24 30 36 42 63 81 14 ...
#>  $ gpa_term           : num  2.56 1.85 1.93 2.15 1.85 1.2 1.85 2.33 2.32 2.15 ..
#>  $ gpa_cumul          : num  2.56 1.85 1.9 1.96 1.94 1.82 1.82 1.98 2.04 2.15 ..
```

We redefine our source material to incorporate the exclusion of
post-baccalaureate terms.

``` r

term_source <- copy(term)
degree_source <- copy(degree)
```

## `timely_term()`

*Determine the term by which degree completion would be considered
timely.*

In this section, we begin refining the population, so we start with a
unique set of IDs from the `term` record obtained above.

``` r

DT <- term[, .(mcid)]
DT <- unique(DT)

DT
#>                  mcid
#>                <char>
#>     1: MCID3111142225
#>     2: MCID3111142283
#>     3: MCID3111142290
#>    ---               
#> 97534: MCID3112898894
#> 97535: MCID3112898895
#> 97536: MCID3112898940
```

[`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md)
builds a data frame with one row per student, a column for the timely
completion term, and columns of supporting information. This data frame
contains the required inputs for both
[`data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/data_sufficiency.md)
and `timely_completion()`.

``` r

DT <- timely_term(DT, midfield_table = term)

DT
#>                  mcid term_i       level_i adj_span timely_term
#>                <char> <char>        <char>    <num>      <char>
#>     1: MCID3111142225  19881 01 First-year        6       19933
#>     2: MCID3111142283  19881 01 First-year        6       19933
#>     3: MCID3111142290  19881 01 First-year        6       19933
#>    ---                                                         
#> 97534: MCID3112898894  20181 01 First-year        6       20233
#> 97535: MCID3112898895  20181 01 First-year        6       20233
#> 97536: MCID3112898940  20181 01 First-year        6       20233
```

## `data_sufficiency()`

*Identify members of the population to exclude due to insufficient
data.*

*Data sufficiency* is an assessment whether a student record lies
sufficiently within their institution’s data range to unambiguously
assess their completion status and if so include them in the study
population.

[`data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/data_sufficiency.md)
builds on the output from
[`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md),
labels rows to be included or excluded based on the data sufficiency
finding, and generates additional columns of supporting information.

``` r

DT <- data_sufficiency(DT, midfield_table = term)

DT
#>                  mcid term_i timely_term   institution lower_limit upper_limit
#>                <char> <char>      <char>        <char>      <char>      <char>
#>     1: MCID3111142225  19881       19933 Institution B       19881       20181
#>     2: MCID3111142283  19881       19933 Institution J       19881       20096
#>     3: MCID3111142290  19881       19933 Institution J       19881       20096
#>    ---                                                                        
#> 97534: MCID3112898894  20181       20233 Institution B       19881       20181
#> 97535: MCID3112898895  20181       20233 Institution B       19881       20181
#> 97536: MCID3112898940  20181       20233 Institution B       19881       20181
#>        data_sufficiency
#>                  <char>
#>     1:    exclude-lower
#>     2:    exclude-lower
#>     3:    exclude-lower
#>    ---                 
#> 97534:    exclude-upper
#> 97535:    exclude-upper
#> 97536:    exclude-upper
```

The possible values for data sufficiency are:

``` r

sort_uniq(DT$data_sufficiency)
#> [1] "exclude-lower" "exclude-upper" "include"
```

We filter to retain rows labeled “include”. The resulting IDs define our
baseline population.

``` r

population <- DT["include", on = "data_sufficiency", .(mcid)]
population <- unique(population)

population
#>                  mcid
#>                <char>
#>     1: MCID3111142689
#>     2: MCID3111142782
#>     3: MCID3111142881
#>    ---               
#> 76863: MCID3112785480
#> 76864: MCID3112800920
#> 76865: MCID3112870009
```

We use this population to filter our source material one last time. We
use an inner join to return records for this population only.

``` r

student_source <- population[student_source, on = "mcid", nomatch = NULL]
term_source <- population[term_source, on = "mcid", nomatch = NULL]
degree_source <- population[degree_source, on = "mcid", nomatch = NULL]

look_at(term_source)
#> Classes 'data.table' and 'data.frame':   525446 obs. of  13 variables:
#>  $ mcid               : chr  "MCID3111142689" "MCID3111142782" "MCID311114278"..
#>  $ term               : chr  "19883" "19883" "19885" "19893" ...
#>  $ cip6               : chr  "090401" "260101" "260101" "260101" ...
#>  $ institution        : chr  "Institution B" "Institution J" "Institution J" "..
#>  $ level              : chr  "01 First-year" "01 First-year" "02 Second-year""..
#>  $ standing           : chr  "Good Standing" "Good Standing" "Good Standing" "..
#>  $ coop               : chr  "No" "No" "No" "No" ...
#>  $ hours_term         : num  9 16 4 13 4 4 10 9 18 6 ...
#>  $ hours_term_attempt : num  9 16 4 13 4 4 10 9 18 6 ...
#>  $ hours_cumul        : num  18 26 30 56 60 64 74 83 21 27 ...
#>  $ hours_cumul_attempt: num  18 26 30 56 60 64 74 83 21 27 ...
#>  $ gpa_term           : num  3.33 2.8 3 2.84 4 3.25 2.26 2.43 2.55 2.15 ...
#>  $ gpa_cumul          : num  3.05 2.57 2.63 2.53 2.63 2.67 2.61 2.59 2.76 2.62..
```

In subsequent analysis, any variables we need from the source data has
already been filtered to satisfy the data sufficiency constraint and to
exclude post-baccalaureate terms.

From this point forward, anytime we need a fresh copy of any of the data
tables, we copy the “source” version. Anytime we need a starting
population, we use `population` or unique IDs from `student_source` or
`term_source.`

``` r

student <- copy(student_source)
term <- copy(term_source)
degree <- copy(degree_source)

all.equal(population$mcid, student_source$mcid)
#> [1] TRUE
all.equal(population$mcid, unique(term_source$mcid))
#> [1] TRUE
```

## `select_basic_cols()`

*Choose columns required by midfieldr functions.*

[`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md)
operates on student records to reduce the number of columns to those
required by other midfieldr functions plus the key or composite key
variables of the four data tables. With a smaller number of columns, the
printout of the data frame is more readable, a benefit when working with
the data interactively.

``` r

student <- select_basic_cols(student)
term <- select_basic_cols(term)
degree <- select_basic_cols(degree)

student
#>                  mcid          race    sex
#>                <char>        <char> <char>
#>     1: MCID3111142689      Hispanic Female
#>     2: MCID3111142782      Hispanic Female
#>     3: MCID3111142881 International   Male
#>    ---                                    
#> 76863: MCID3112785480         White   Male
#> 76864: MCID3112800920         White Female
#> 76865: MCID3112870009         White   Male

term
#>                   mcid   term   cip6   institution          level
#>                 <char> <char> <char>        <char>         <char>
#>      1: MCID3111142689  19883 090401 Institution B  01 First-year
#>      2: MCID3111142782  19883 260101 Institution J  01 First-year
#>      3: MCID3111142782  19885 260101 Institution J 02 Second-year
#>     ---                                                          
#> 525444: MCID3112870009  19953 240102 Institution B  01 First-year
#> 525445: MCID3112870009  19954 240102 Institution B  01 First-year
#> 525446: MCID3112870009  19983 240102 Institution B 02 Second-year

degree
#>                  mcid term_degree   cip6
#>                <char>      <char> <char>
#>     1: MCID3111142689       19913 090401
#>     2: MCID3111142782       19903 260101
#>     3: MCID3111142881       19894 450601
#>    ---                                  
#> 43845: MCID3112694738       20143 230101
#> 43846: MCID3112698681       20181 110701
#> 43847: MCID3112730841       20164 040401
```

Any variables you might need that have been dropped can always be
recovered from the source tables we saved earlier. For example, if we
needed GPA in our working `term` table, we can use a left join, knowing
that student ID and term are the composite keys in this case.

``` r

x <- copy(term)
source_cols <- term_source[, .(mcid, term, gpa_term, gpa_cumul)]
x <- source_cols[x, on = c("mcid", "term")]
x
#>                   mcid   term gpa_term gpa_cumul   cip6   institution
#>                 <char> <char>    <num>     <num> <char>        <char>
#>      1: MCID3111142689  19883     3.33      3.05 090401 Institution B
#>      2: MCID3111142782  19883     2.80      2.57 260101 Institution J
#>      3: MCID3111142782  19885     3.00      2.63 260101 Institution J
#>     ---                                                              
#> 525444: MCID3112870009  19953     3.57      3.71 240102 Institution B
#> 525445: MCID3112870009  19954     4.00      3.72 240102 Institution B
#> 525446: MCID3112870009  19983     4.00      3.87 240102 Institution B
#>                  level
#>                 <char>
#>      1:  01 First-year
#>      2:  01 First-year
#>      3: 02 Second-year
#>     ---               
#> 525444:  01 First-year
#> 525445:  01 First-year
#> 525446: 02 Second-year
```

Keys and composite keys to the four data tables are described in the
midfielddata [Data
structure](https://midfieldr.github.io/midfielddata/articles/data-structure.html)
article.

## `completion_status()`

*Determines if program completion is timely or late.*

This section often pertains to constructing a bloc of graduates,
starting with the baseline population we obtained above.

``` r

DT <- copy(population)
```

[`completion_status()`](https://midfieldr.github.io/midfieldr/reference/completion_status.md)
builds on the output from
[`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md),
labels rows to indicate whether a student completes a degree timely or
late compared to their timely completion term (or NA for no completion),
and includes columns for the timely term and degree term as supporting
information.

``` r

DT <- timely_term(DT, midfield_table = term)
DT <- completion_status(DT, midfield_table = degree)

DT
#>                  mcid timely_term term_degree completion_status
#>                <char>      <char>      <char>            <char>
#>     1: MCID3111142689       19941       19913            timely
#>     2: MCID3111142782       19941       19903            timely
#>     3: MCID3111142881       19951       19894            timely
#>    ---                                                         
#> 76863: MCID3112785480       20123        <NA>              <NA>
#> 76864: MCID3112800920       20153        <NA>              <NA>
#> 76865: MCID3112870009       20003        <NA>              <NA>
```

The possible values for completion status are:

``` r

sort_uniq(DT$completion_status)
#> [1] NA       "late"   "timely"
```

If we were constructing a bloc of timely graduates, we would filter to
retain rows labeled “timely”. The resulting IDs would define our
graduates bloc.

``` r

graduates <- DT["timely", on = "completion_status", .(mcid)]
graduates[, bloc := "grad"]
graduates
#>                  mcid   bloc
#>                <char> <char>
#>     1: MCID3111142689   grad
#>     2: MCID3111142782   grad
#>     3: MCID3111142881   grad
#>    ---                      
#> 40428: MCID3112692944   grad
#> 40429: MCID3112694738   grad
#> 40430: MCID3112730841   grad
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
  wraps base [`str()`](https://rdrr.io/r/utils/str.html) with our
  preferred arguments.
- [`sort_uniq()`](https://midfieldr.github.io/midfieldr/reference/sort_uniq.md)
  wraps base `sort(unique())` with our preferred arguments.
- [`catch_error()`](https://midfieldr.github.io/midfieldr/reference/catch_error.md)
  wraps base [`tryCatch()`](https://rdrr.io/r/base/conditions.html) for
  errors.  
- [`check_equiv_frames()`](https://winvector.github.io/wrapr//reference/check_equiv_frames.html)
  re-exported from the wrapr package

## References

NCES. 2010. *IPEDS Classification of Instructional Programs (CIP)*.
National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>.
