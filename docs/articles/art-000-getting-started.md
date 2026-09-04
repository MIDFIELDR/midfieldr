# Introduction to midfieldr

When working with student-level records to develop quantitative metrics,
midfieldr helps you refine and shape your data in these areas:

- *Population and records.* Obtaining a credible population and
  filtering data tables to match.
- *Metrics and groupings.* Calculating quantitative metrics
  disaggregated by grouping variables.
- *Dissemination.* Preparing results for dissemination in tables and
  charts.

This document introduces you to midfieldr’s basic set of tools with a
brief overview of major functions. Details are discussed at length in
subsequent articles.

``` r

library("midfieldr")
library("midfielddata")
library("data.table")
```

## midfieldr functions

We can categorize midfieldr functions by their contribution to a typical
workflow, as follows:

Refining a population and records

- [`qualification_level()`](https://midfieldr.github.io/midfieldr/reference/qualification_level.md)
  identifies terms to include prior to a first degree.
- [`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md)
  estimates timely completion terms.
- [`data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/data_sufficiency.md)
  identifies IDs to exclude due to insufficient data.

Calculating aggregate metrics with grouping variables

- [`filter_programs()`](https://midfieldr.github.io/midfieldr/reference/filter_programs.md)
  helps you find program names and CIP codes.
- [`completion_status()`](https://midfieldr.github.io/midfieldr/reference/completion_status.md)
  identifies IDs to include for timely completion.
- [`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)
  conditions data for imputing starting majors of FYE students.

Preparing results for dissemination

- [`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)
  conditions data for Cleveland multiway charts.

Helper utility functions

- [`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md)
  minimizes the number of columns viewed for interactive sessions.
- [`look_at()`](https://midfieldr.github.io/midfieldr/reference/look_at.md)
  for data frames, wraps base
  [`str()`](https://rdrr.io/r/utils/str.html) with preset arguments.
- [`sort_uniq()`](https://midfieldr.github.io/midfieldr/reference/sort_uniq.md)
  for vectors, wraps base `sort(unique())` with preset arguments.
- [`catch_error()`](https://midfieldr.github.io/midfieldr/reference/catch_error.md)
  wraps base [`tryCatch()`](https://rdrr.io/r/base/conditions.html) for
  errors with preset arguments.
- [`check_equiv_frames()`](https://winvector.github.io/wrapr//reference/check_equiv_frames.html)
  re-exported from the
  [wrapr](https://winvector.github.io/wrapr/reference/check_equiv_frames.html)
  package

*Comments:*

1.  Terms are encoded as character strings `YYYYT`, where `YYYY` is the
    year at the start of the academic year and `T` encodes the semester
    or quarter within an academic year as Fall (1), Winter (2), Spring
    (3), and Summer (4, 5, and 6).

2.  We use [data.table](https://r-datatable.com/) for its data frame
    class and its data manipulation syntax. If you prefer tidyverse
    syntax, midfieldr functions do attempt to preserve data frame
    attributes such as the `tbl_df` (tibble) class.

## Population and records

### Data: Student records

midfieldr is designed to work with the MIDFIELD database or tables with
a similar structure. Data are structured in four tables:
`student, term, course,` and `degree.` For this article we load three
tables from [midfielddata](https://midfieldr.github.io/midfielddata/).

``` r

data(student, term, degree)
```

The data tables are linked by `mcid,` the anonymized student ID.
[`look_at()`](https://midfieldr.github.io/midfieldr/reference/look_at.md)
is a midfieldr convenience function that wraps base
[`str()`](https://rdrr.io/r/utils/str.html) with preset arguments.

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

### `qualification_level()`

*Identify terms to include prior to a first degree.* Applies to data
tables with a term variable:

- `term` in the `term` table
- `term_course` in the `course` table
- `term_degree` in the `degree` table

Applying
[`qualification_level()`](https://midfieldr.github.io/midfieldr/reference/qualification_level.md)
to the `term` table, for example, we display selected columns from the
result. The `bacc` (baccalaureate) column contains the student’s first
degree term (if any). The `qual_level` column labels each term as
focused on “undergrad” or “post-bacc” study, depending on whether a term
is before or after the first degree.

labels terms before a first degree “undergrad”; later terms are labeled
“post-bacc.” Post-baccalaureate terms are typically excluded from a
study.

``` r

DT <- qualification_level(term, midf_table = degree)
DT <- DT[order(-qual_level), .(mcid, term, bacc, qual_level)]
DT
#>                   mcid   term   bacc qual_level
#>                 <char> <char> <char>     <char>
#>      1: MCID3111142225  19881  19881  undergrad
#>      2: MCID3111142283  19881   <NA>  undergrad
#>      3: MCID3111142283  19883   <NA>  undergrad
#>      4: MCID3111142283  19885   <NA>  undergrad
#>      5: MCID3111142283  19891   <NA>  undergrad
#>     ---                                        
#> 639911: MCID3112760109  20174  20153  post-bacc
#> 639912: MCID3112760109  20181  20153  post-bacc
#> 639913: MCID3112760306  20181  20174  post-bacc
#> 639914: MCID3112768322  20181  20174  post-bacc
#> 639915: MCID3112773810  20181  20174  post-bacc
```

### `select_basic_cols()`

*Minimize the number of columns viewed for interactive sessions*

Operates on a MIDFIELD data table to return the minimum number of
columns required by other midfieldr functions. Reducing the number of
columns helps de-clutter a printout in an interactive session. The
algorithm uses the column names present in the input data frame to
identify the table and return the appropriate columns.

``` r

student <- select_basic_cols(student)
term <- select_basic_cols(term)
degree <- select_basic_cols(degree)

student
#>                  mcid          race    sex
#>                <char>        <char> <char>
#>     1: MCID3111142225         Asian   Male
#>     2: MCID3111142283         Asian Female
#>     3: MCID3111142290         Asian   Male
#>     4: MCID3111142294         Asian   Male
#>     5: MCID3111142299         Asian   Male
#>    ---                                    
#> 97551: MCID3112898886         White Female
#> 97552: MCID3112898890         White Female
#> 97553: MCID3112898894         White Female
#> 97554: MCID3112898895         White Female
#> 97555: MCID3112898940 Other/Unknown   Male

term
#>                   mcid   term   cip6   institution          level
#>                 <char> <char> <char>        <char>         <char>
#>      1: MCID3111142225  19881 140901 Institution B  01 First-year
#>      2: MCID3111142283  19881 240102 Institution J  01 First-year
#>      3: MCID3111142283  19883 240102 Institution J  01 First-year
#>      4: MCID3111142283  19885 190601 Institution J  01 First-year
#>      5: MCID3111142283  19891 190601 Institution J 02 Second-year
#>     ---                                                          
#> 639911: MCID3112898886  20181 500501 Institution B  01 First-year
#> 639912: MCID3112898890  20181 451101 Institution B  01 First-year
#> 639913: MCID3112898894  20181 451001 Institution B  01 First-year
#> 639914: MCID3112898895  20181 302001 Institution B  01 First-year
#> 639915: MCID3112898940  20181 050103 Institution B  01 First-year

degree
#>                  mcid term_degree   cip6
#>                <char>      <char> <char>
#>     1: MCID3111142225       19881 141001
#>     2: MCID3111142290       19921 141001
#>     3: MCID3111142294       19903 141001
#>     4: MCID3111142299       19921 141001
#>     5: MCID3111142689       19913 090401
#>    ---                                  
#> 49661: MCID3112829602       20173 451001
#> 49662: MCID3112831015       20181 450701
#> 49663: MCID3112839623       20181 160102
#> 49664: MCID3112845220       20181 270101
#> 49665: MCID3112845673       20174 090101
```

### `timely_term()`

*Estimate timely completion terms*

The *timely-completion term* is the term by which we would consider a
student’s program completion “timely”, default 6 years after admission.
[`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md)
operates on any data frame with an `mcid` column.

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
#> 97551: MCID3112898886
#> 97552: MCID3112898890
#> 97553: MCID3112898894
#> 97554: MCID3112898895
#> 97555: MCID3112898940
```

Columns are added indicating a student’s entry term and level. The span
for timely completion is reduced by one academic year for each year the
student has completed based on their level at entry. The
timely-completion term results from adding the adjusted span to the
entry term.

``` r

timely_term(DT, midf_table = term)
#>                  mcid entry_term   entry_level adj_span timely_term
#>                <char>     <char>        <char>    <num>      <char>
#>     1: MCID3111142225      19881 01 First-year        6       19933
#>     2: MCID3111142283      19881 01 First-year        6       19933
#>     3: MCID3111142290      19881 01 First-year        6       19933
#>     4: MCID3111142294      19881 01 First-year        6       19933
#>     5: MCID3111142299      19881 01 First-year        6       19933
#>    ---                                                             
#> 97551: MCID3112898886      20181 01 First-year        6       20233
#> 97552: MCID3112898890      20181 01 First-year        6       20233
#> 97553: MCID3112898894      20181 01 First-year        6       20233
#> 97554: MCID3112898895      20181 01 First-year        6       20233
#> 97555: MCID3112898940      20181 01 First-year        6       20233
```

### `data_sufficiency()`

*Identify IDs to exclude due to insufficient data*

The *data sufficiency* test identifies students whose admission term and
projected timely completion term lie within the range of data available
from their institution—a necessary and sufficient condition for
determining program completion status.
[`data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/data_sufficiency.md)
requires the entry term and timely-completion term from `timely_term().`

``` r

# Get required variables from timely_term
DT <- unique(term[, .(mcid)])
DT <- timely_term(DT, midf_table = term)
DT <- DT[, .(mcid, entry_term, timely_term)]

# Results
data_sufficiency(DT, midf_table = term)[order(-sufficiency)]
#>                  mcid entry_term timely_term  data_range sufficiency
#>                <char>     <char>      <char>      <char>      <char>
#>     1: MCID3111142689      19883       19941 19881-20181   satisfied
#>     2: MCID3111142782      19883       19941 19881-20096   satisfied
#>     3: MCID3111142881      19893       19951 19881-20181   satisfied
#>     4: MCID3111142884      19883       19941 19881-20181   satisfied
#>     5: MCID3111142893      19883       19941 19881-20181   satisfied
#>    ---                                                              
#> 97551: MCID3111618645      19901       19953 19901-20154  fail-lower
#> 97552: MCID3111624491      19881       19933 19881-20181  fail-lower
#> 97553: MCID3111824139      19901       19953 19901-20154  fail-lower
#> 97554: MCID3111869416      19901       19953 19901-20154  fail-lower
#> 97555: MCID3112056754      19881       19933 19881-20096  fail-lower
```

Columns are added indicating an institution’s data range and the results
of the data sufficiency test: “satisfied” if the time span from entry to
timely completion lie within the range; “fail” if not. We typically
include the “satisfied” rows only.

## Metrics and groupings

### Data: Program names and CIP codes

### `filter_programs()`

*Helps you find program names and CIP codes*

paragraph

### `completion_status()`

*Identify IDs to include for timely completion*

paragraph

### `prep_fye_mice()`

*Condition data for imputing starting majors of FYE students*

Used when an institution has a required First-Year Engineering (FYE)
program and the quantitative metric (e.g., graduation rate) requires
knowledge of a student’s degree-granting starting program.

Because FYE is not a degree-granting program, we impute what their
starting program would have been had they not been required to enroll in
FYE. For details see [FYE
proxies](https://midfieldr.github.io/midfieldr/articles/art-060-fye-proxies.md).

## Dissemination

### `order_multiway()`

*Condition data for Cleveland multiway charts*

The ordering of rows and panels in a multiway chart is crucial to the
perception of effects. Used when data have a multiway structure. For
details see [Multiway data and
charts](https://midfieldr.github.io/midfieldr/articles/art-120-multiway.md).

## Utilities

See the relevant help page for more information, e.g. `?look_at.`

- [`look_at()`](https://midfieldr.github.io/midfieldr/reference/look_at.md)
  for data frames, wraps base
  [`str()`](https://rdrr.io/r/utils/str.html) with preset arguments.
- [`sort_uniq()`](https://midfieldr.github.io/midfieldr/reference/sort_uniq.md)
  for vectors, wraps base `sort(unique())` with preset arguments.
- [`catch_error()`](https://midfieldr.github.io/midfieldr/reference/catch_error.md)
  wraps base [`tryCatch()`](https://rdrr.io/r/base/conditions.html) for
  errors with preset arguments.
- [`check_equiv_frames()`](https://winvector.github.io/wrapr//reference/check_equiv_frames.html)
  re-exported from the wrapr package

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

## `filter_programs()`

*Chooses rows of CIP data based on search terms.*

[`filter_programs()`](https://midfieldr.github.io/midfieldr/reference/filter_programs.md)
acts on the data frame assigned to its `dframe` argument to select rows
that match or partially match search strings. Search strings are
case-independent and can include regular expressions.

``` r

filter_programs(cip, "music")
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

To refine our results, we can assign the results of a first pass to the
`dframe` argument of a second pass. For example, our first pass below
searches the default `cip` dataset for “music”. Our second pass searches
the results of the first pass for any line that starts with “50”. We can
also drop the 2-digit level codes and names to reduce the visual
clutter. Because these programs have the same 2-digit code and name, we
can drop two columns to reduce the visual clutter.

``` r

first_pass <- filter_programs(cip, "music")
second_pass <- filter_programs(first_pass, "^50")
second_pass[, c("cip2", "cip2name") := NULL]
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
#>                                     cip4name   cip4
#>                                       <char> <char>
#>  1:            General Art and Music Studies   5001
#>  2:       Drama, Theatre Arts and Stagecraft   5005
#>  3:                                    Music   5009
#>  4:                                    Music   5009
#>  5:                                    Music   5009
#> ---                                                
#> 16:                                    Music   5009
#> 17:                                    Music   5009
#> 18:                                    Music   5009
#> 19:                                    Music   5009
#> 20: Arts, Entertainment and Media Management   5010
```

Assuming we are looking for programs in a School of Music, the 4-digit
code “5009” appears to be the correct finding. Our third pass searches
the results of the second pass for any line that starts with “5009”.
Again (in this case) we can reduce the visual clutter and remove two
more columns.

``` r

third_pass <- filter_programs(second_pass, "^5009")
third_pass[, c("cip4", "cip4name") := NULL]
third_pass
#>                                                 cip6name   cip6
#>                                                   <char> <char>
#>  1:                                       Music, General 500901
#>  2:                 Music History, Literature and Theory 500902
#>  3:                           Music Performance, General 500903
#>  4:                         Music Theory and Composition 500904
#>  5:                       Musicology and Ethnomusicology 500905
#>  6:                                           Conducting 500906
#>  7:                                      Piano and Organ 500907
#>  8:                                      Voice and Opera 500908
#>  9:                   Music Management and Merchandising 500909
#> 10:                                   Jazz, Jazz Studies 500910
#> 11: Violin, Viola, Guitar and Other Stringed Instruments 500911
#> 12:                                       Music Pedagogy 500912
#> 13:                                     Music Technology 500913
#> 14:                                    Brass Instruments 500914
#> 15:                                 Woodwind Instruments 500915
#> 16:                               Percussion Instruments 500916
#> 17:                                         Music, Other 500999
```

Assuming these were our study programs, we save the 6-digit codes and
names and optionally abbreviate some of the longer names. More
importantly, we add a `program` column with our own program
abbreviations (here I use the placeholder `label_TBD`). These custom
program labels aggregate the 6-digit codes into groups that are relevant
to the study goals.

``` r

programs <- third_pass[, .(cip6name, cip6, program = "to be determined")]
programs[, cip6name := gsub("Violin, Viola, Guitar", "Vn, Va, Gtr", cip6name)]
programs[, cip6name := gsub("Instruments", "Instr", cip6name)]
programs
#>                                 cip6name   cip6          program
#>                                   <char> <char>           <char>
#>  1:                       Music, General 500901 to be determined
#>  2: Music History, Literature and Theory 500902 to be determined
#>  3:           Music Performance, General 500903 to be determined
#>  4:         Music Theory and Composition 500904 to be determined
#>  5:       Musicology and Ethnomusicology 500905 to be determined
#>  6:                           Conducting 500906 to be determined
#>  7:                      Piano and Organ 500907 to be determined
#>  8:                      Voice and Opera 500908 to be determined
#>  9:   Music Management and Merchandising 500909 to be determined
#> 10:                   Jazz, Jazz Studies 500910 to be determined
#> 11: Vn, Va, Gtr and Other Stringed Instr 500911 to be determined
#> 12:                       Music Pedagogy 500912 to be determined
#> 13:                     Music Technology 500913 to be determined
#> 14:                          Brass Instr 500914 to be determined
#> 15:                       Woodwind Instr 500915 to be determined
#> 16:                     Percussion Instr 500916 to be determined
#> 17:                         Music, Other 500999 to be determined
```

For example, here I label all programs I might consider part of an
“orchestra” grouping.

``` r

orch_instr <- c("brass|wood|perc|conduct|vn")
programs[cip6name %ilike% orch_instr, program := "Orchestra"]
programs
#>                                 cip6name   cip6          program
#>                                   <char> <char>           <char>
#>  1:                       Music, General 500901 to be determined
#>  2: Music History, Literature and Theory 500902 to be determined
#>  3:           Music Performance, General 500903 to be determined
#>  4:         Music Theory and Composition 500904 to be determined
#>  5:       Musicology and Ethnomusicology 500905 to be determined
#>  6:                           Conducting 500906        Orchestra
#>  7:                      Piano and Organ 500907 to be determined
#>  8:                      Voice and Opera 500908 to be determined
#>  9:   Music Management and Merchandising 500909 to be determined
#> 10:                   Jazz, Jazz Studies 500910 to be determined
#> 11: Vn, Va, Gtr and Other Stringed Instr 500911        Orchestra
#> 12:                       Music Pedagogy 500912 to be determined
#> 13:                     Music Technology 500913 to be determined
#> 14:                          Brass Instr 500914        Orchestra
#> 15:                       Woodwind Instr 500915        Orchestra
#> 16:                     Percussion Instr 500916        Orchestra
#> 17:                         Music, Other 500999 to be determined
```

The structure of this data frame is representative of the `programs`
data frame you would find in any study: 6-digit CIP codes, possibly the
NCES 6-digit program name, and our own program labels.

## Student-level data

We copy our “source” material under separate names (and locations in
memory).

``` r

student_source <- copy(student)
term_source <- copy(term)
degree_source <- copy(degree)

# demonstrate that memory addresses are different
address(student)
#> [1] "000001ef69f30c60"
address(student_source)
#> [1] "000001ef6a96fa60"
```

Then we can use the shorter names such as `term` and `degree` as we
work. The shorter names are also the default values for arguments in
several midfieldr functions.

### *Terminology*

The following sequence of definitions provides the context for the next
few functions.

- Program *completion* means satisfying the requirements for a
  baccalaureate degree.
- Program completion is *timely* if accomplished within a set time span,
  typically 4, 6, or 8 years after admission depending on the definition
  one adopts. (The midfieldr default is 6 academic years.) The
  *timely-completion term* is the term at the end of that span.
- A student’s *completion status* is “timely” if they graduate no later
  than their timely-completion term, “late” if they graduate after their
  timely-completion term, and NA for non-completers.
- To avoid biased results, completion status can be assessed only for
  students for whom the data tables include a sufficient number of terms
  before and after their admission term. The test for *data sufficiency*
  identifies such students. Only those records passing the data
  sufficiency test are included in a population study.

## `timely_term()`

*Determine the term by which degree completion would be considered
timely.*

The *timely-completion term* is the term by which we would consider a
student’s program completion “timely”, default 6 years after admission.
We start with a unique set of IDs from the `term` table.

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
#>     6: MCID3111142303
#>     7: MCID3111142633
#>     8: MCID3111142689
#>     9: MCID3111142729
#>    10: MCID3111142775
#>    ---               
#> 97546: MCID3112898824
#> 97547: MCID3112898828
#> 97548: MCID3112898842
#> 97549: MCID3112898857
#> 97550: MCID3112898877
#> 97551: MCID3112898886
#> 97552: MCID3112898890
#> 97553: MCID3112898894
#> 97554: MCID3112898895
#> 97555: MCID3112898940
```

[`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md)
builds a data frame with one row per student, a column for the timely
completion term, and columns of supporting information. This data frame
contains the required inputs for both
[`data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/data_sufficiency.md)
and `timely_completion()`.

``` r

DT <- timely_term(DT, midf_table = term)

DT
#>                  mcid entry_term   entry_level adj_span timely_term
#>                <char>     <char>        <char>    <num>      <char>
#>     1: MCID3111142225      19881 01 First-year        6       19933
#>     2: MCID3111142283      19881 01 First-year        6       19933
#>     3: MCID3111142290      19881 01 First-year        6       19933
#>     4: MCID3111142294      19881 01 First-year        6       19933
#>     5: MCID3111142299      19881 01 First-year        6       19933
#>     6: MCID3111142303      19881 01 First-year        6       19933
#>     7: MCID3111142633      19881 01 First-year        6       19933
#>     8: MCID3111142689      19883 01 First-year        6       19941
#>     9: MCID3111142729      19881 01 First-year        6       19933
#>    10: MCID3111142775      19881 01 First-year        6       19933
#>    ---                                                             
#> 97546: MCID3112898824      20181 01 First-year        6       20233
#> 97547: MCID3112898828      20181 01 First-year        6       20233
#> 97548: MCID3112898842      20181 01 First-year        6       20233
#> 97549: MCID3112898857      20181 01 First-year        6       20233
#> 97550: MCID3112898877      20181 01 First-year        6       20233
#> 97551: MCID3112898886      20181 01 First-year        6       20233
#> 97552: MCID3112898890      20181 01 First-year        6       20233
#> 97553: MCID3112898894      20181 01 First-year        6       20233
#> 97554: MCID3112898895      20181 01 First-year        6       20233
#> 97555: MCID3112898940      20181 01 First-year        6       20233
```

## `data_sufficiency()`

*Identify members of the population to exclude due to insufficient
data.*

[`data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/data_sufficiency.md)
builds on the output from
[`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md),
labels rows to be included or excluded based on the data sufficiency
finding, and generates additional columns of supporting information.

``` r

DT <- data_sufficiency(DT, midf_table = term)

DT
#>                  mcid entry_term   entry_level adj_span timely_term  data_range
#>                <char>     <char>        <char>    <num>      <char>      <char>
#>     1: MCID3111142225      19881 01 First-year        6       19933 19881-20181
#>     2: MCID3111142283      19881 01 First-year        6       19933 19881-20096
#>     3: MCID3111142290      19881 01 First-year        6       19933 19881-20096
#>     4: MCID3111142294      19881 01 First-year        6       19933 19881-20096
#>     5: MCID3111142299      19881 01 First-year        6       19933 19881-20096
#>     6: MCID3111142303      19881 01 First-year        6       19933 19881-20096
#>     7: MCID3111142633      19881 01 First-year        6       19933 19881-20096
#>     8: MCID3111142689      19883 01 First-year        6       19941 19881-20181
#>     9: MCID3111142729      19881 01 First-year        6       19933 19881-20181
#>    10: MCID3111142775      19881 01 First-year        6       19933 19881-20096
#>    ---                                                                         
#> 97546: MCID3112898824      20181 01 First-year        6       20233 19881-20181
#> 97547: MCID3112898828      20181 01 First-year        6       20233 19881-20181
#> 97548: MCID3112898842      20181 01 First-year        6       20233 19881-20181
#> 97549: MCID3112898857      20181 01 First-year        6       20233 19881-20181
#> 97550: MCID3112898877      20181 01 First-year        6       20233 19881-20181
#> 97551: MCID3112898886      20181 01 First-year        6       20233 19881-20181
#> 97552: MCID3112898890      20181 01 First-year        6       20233 19881-20181
#> 97553: MCID3112898894      20181 01 First-year        6       20233 19881-20181
#> 97554: MCID3112898895      20181 01 First-year        6       20233 19881-20181
#> 97555: MCID3112898940      20181 01 First-year        6       20233 19881-20181
#>        sufficiency
#>             <char>
#>     1:  fail-lower
#>     2:  fail-lower
#>     3:  fail-lower
#>     4:  fail-lower
#>     5:  fail-lower
#>     6:  fail-lower
#>     7:  fail-lower
#>     8:   satisfied
#>     9:  fail-lower
#>    10:  fail-lower
#>    ---            
#> 97546:  fail-upper
#> 97547:  fail-upper
#> 97548:  fail-upper
#> 97549:  fail-upper
#> 97550:  fail-upper
#> 97551:  fail-upper
#> 97552:  fail-upper
#> 97553:  fail-upper
#> 97554:  fail-upper
#> 97555:  fail-upper
```

The possible values for data sufficiency are:

``` r

DT[, sort(unique(sufficiency), na.last = FALSE)]
#> [1] "fail-lower" "fail-upper" "satisfied"
```

We filter to retain rows labeled “satisfied”. The resulting IDs define
our baseline population.

``` r

population <- DT["satisfied", on = .(sufficiency), .(mcid)]
population <- unique(population)

population
#>                  mcid
#>                <char>
#>     1: MCID3111142689
#>     2: MCID3111142782
#>     3: MCID3111142881
#>     4: MCID3111142884
#>     5: MCID3111142893
#>     6: MCID3111142962
#>     7: MCID3111142965
#>     8: MCID3111143066
#>     9: MCID3111143068
#>    10: MCID3111143078
#>    ---               
#> 76866: MCID3112692944
#> 76867: MCID3112693003
#> 76868: MCID3112693979
#> 76869: MCID3112694738
#> 76870: MCID3112698681
#> 76871: MCID3112727985
#> 76872: MCID3112730841
#> 76873: MCID3112785480
#> 76874: MCID3112800920
#> 76875: MCID3112870009
```

We use this population to filter our source material one last time. We
use an inner join to return records for this population only.

``` r

student_source <- population[student_source, on = "mcid", nomatch = NULL]
term_source <- population[term_source, on = "mcid", nomatch = NULL]
degree_source <- population[degree_source, on = "mcid", nomatch = NULL]

look_at(term_source)
#> Classes 'data.table' and 'data.frame':   531419 obs. of  5 variables:
#>  $ mcid       : chr  "MCID3111142689" "MCID3111142782" "MCID3111142782" "MCID"..
#>  $ term       : chr  "19883" "19883" "19885" "19893" ...
#>  $ cip6       : chr  "090401" "260101" "260101" "260101" ...
#>  $ institution: chr  "Institution B" "Institution J" "Institution J" "Institu"..
#>  $ level      : chr  "01 First-year" "01 First-year" "02 Second-year" "02 Sec"..
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

## `qualification_level()`

*Identify rows of post-baccalaureate terms to exclude.*

In most cases, we are not generally interested in academic terms beyond
the first degree term, so we use the results of this function to exclude
post-first-degree terms from the source data.

[`qualification_level()`](https://midfieldr.github.io/midfieldr/reference/qualification_level.md)
identifies terms later than the first baccalaureate, if any.

``` r

term <- qualification_level(term_source, midf_table = degree)
degree <- qualification_level(degree_source, midf_table = degree)
```

[`qualification_level()`](https://midfieldr.github.io/midfieldr/reference/qualification_level.md)
adds a column indicating the bracket a term belongs to with respect to
the first degree term.

``` r

look_at(term)
#> Classes 'data.table' and 'data.frame':   531419 obs. of  7 variables:
#>  $ mcid       : chr  "MCID3111142689" "MCID3111142782" "MCID3111142782" "MCID"..
#>  $ cip6       : chr  "090401" "260101" "260101" "260101" ...
#>  $ institution: chr  "Institution B" "Institution J" "Institution J" "Institu"..
#>  $ level      : chr  "01 First-year" "01 First-year" "02 Second-year" "02 Sec"..
#>  $ term       : chr  "19883" "19883" "19885" "19893" ...
#>  $ bacc       : chr  "19913" "19903" "19903" "19903" ...
#>  $ qual_level : chr  "undergrad" "undergrad" "undergrad" "undergrad" ...
```

The possible bracket values are given by,

``` r

term[, sort(unique(qual_level), na.last = FALSE)]
#> [1] "post-bacc" "undergrad"
```

We filter to exclude all terms labeled “post-bacc” and drop the
temporary columns.

``` r

term <- term["undergrad", on = "qual_level"]
degree <- degree["undergrad", on = "qual_level"]

term[, c("bacc", "qual_level") := NULL]
degree[, c("bacc", "qual_level") := NULL]

look_at(term)
#> Classes 'data.table' and 'data.frame':   525446 obs. of  5 variables:
#>  $ mcid       : chr  "MCID3111142689" "MCID3111142782" "MCID3111142782" "MCID"..
#>  $ cip6       : chr  "090401" "260101" "260101" "260101" ...
#>  $ institution: chr  "Institution B" "Institution J" "Institution J" "Institu"..
#>  $ level      : chr  "01 First-year" "01 First-year" "02 Second-year" "02 Sec"..
#>  $ term       : chr  "19883" "19883" "19885" "19893" ...
```

We redefine our source material to incorporate the exclusion of
post-baccalaureate terms.

``` r

term_source <- copy(term)
degree_source <- copy(degree)
```

## `select_basic_cols()`

*Choose columns required by midfieldr functions.*

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

DT <- timely_term(DT, midf_table = term)
DT <- completion_status(DT, midf_table = degree)

DT
#>                  mcid entry_term   entry_level adj_span timely_term   bacc
#>                <char>     <char>        <char>    <num>      <char> <char>
#>     1: MCID3111142689      19883 01 First-year        6       19941  19913
#>     2: MCID3111142782      19883 01 First-year        6       19941  19903
#>     3: MCID3111142881      19893 01 First-year        6       19951  19894
#>     4: MCID3111142884      19883 01 First-year        6       19941   <NA>
#>     5: MCID3111142893      19883 01 First-year        6       19941   <NA>
#>     6: MCID3111142962      19883 01 First-year        6       19941   <NA>
#>     7: MCID3111142965      19883 01 First-year        6       19941  19901
#>     8: MCID3111143066      19883 01 First-year        6       19941  19883
#>     9: MCID3111143068      19891 01 First-year        6       19943  19903
#>    10: MCID3111143078      19883 01 First-year        6       19941  19891
#>    ---                                                                    
#> 76856: MCID3112692944      20111 01 First-year        6       20163  20153
#> 76857: MCID3112693003      20093 01 First-year        6       20151  20171
#> 76858: MCID3112693979      20114 01 First-year        6       20173  20181
#> 76859: MCID3112694738      20103 01 First-year        6       20161  20143
#> 76860: MCID3112698681      20113 01 First-year        6       20171  20181
#> 76861: MCID3112727985      20114 01 First-year        6       20173   <NA>
#> 76862: MCID3112730841      20121 01 First-year        6       20173  20164
#> 76863: MCID3112785480      20071 01 First-year        6       20123   <NA>
#> 76864: MCID3112800920      20101 01 First-year        6       20153   <NA>
#> 76865: MCID3112870009      19951 01 First-year        6       20003   <NA>
#>        completion
#>            <char>
#>     1:     timely
#>     2:     timely
#>     3:     timely
#>     4:       <NA>
#>     5:       <NA>
#>     6:       <NA>
#>     7:     timely
#>     8:     timely
#>     9:     timely
#>    10:     timely
#>    ---           
#> 76856:     timely
#> 76857:       late
#> 76858:       late
#> 76859:     timely
#> 76860:       late
#> 76861:       <NA>
#> 76862:     timely
#> 76863:       <NA>
#> 76864:       <NA>
#> 76865:       <NA>
```

The possible values for completion status are:

``` r

DT[, sort(unique(completion), na.last = FALSE)]
#> [1] NA       "late"   "timely"
```

If we were constructing a bloc of timely graduates, we would filter to
retain rows labeled “timely”. The resulting IDs would define our
graduates bloc.

``` r

graduates <- DT["timely", on = .(completion), .(mcid)]
graduates[, bloc := "grad"]
graduates
#>                  mcid   bloc
#>                <char> <char>
#>     1: MCID3111142689   grad
#>     2: MCID3111142782   grad
#>     3: MCID3111142881   grad
#>     4: MCID3111142965   grad
#>     5: MCID3111143066   grad
#>     6: MCID3111143068   grad
#>     7: MCID3111143078   grad
#>     8: MCID3111143126   grad
#>     9: MCID3111143157   grad
#>    10: MCID3111144047   grad
#>    ---                      
#> 40421: MCID3112648334   grad
#> 40422: MCID3112658012   grad
#> 40423: MCID3112672577   grad
#> 40424: MCID3112673376   grad
#> 40425: MCID3112675420   grad
#> 40426: MCID3112675459   grad
#> 40427: MCID3112675472   grad
#> 40428: MCID3112692944   grad
#> 40429: MCID3112694738   grad
#> 40430: MCID3112730841   grad
```

## References

NCES. 2010. *IPEDS Classification of Instructional Programs (CIP)*.
National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>.
