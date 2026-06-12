# Introduction to midfieldr

When working with student-level records to develop quantitative metrics,
we recommend that you:

- Know the structure of your data
- Define your metrics and the relevant blocs of students
- Develop a process to refine and shape your data to produce the blocs
  you need
- Use chart designs suited to the types of results

midfieldr helps you with this process in these areas:

- *Records.*   Credibly choosing rows and columns of the source data.  
- *Population.*   Selectively subsetting a population to avoid
  miscounts.
- *Programs.*   Collecting and labeling 6-digit program codes.
- *Blocs.*   Grouping and summarizing before computing metrics.  
- *Charts.*   Conditioning data for multiway charts.

This document introduces you to midfieldr’s basic set of tools, and
shows you how to apply them to data frames of student-level records.

``` r

library(midfieldr)
library(data.table)
```

## Data: midfielddata

To explore the basic functionality of midfieldr, we use the datasets in
*midfielddata*: an R data package containing four tables — `student`,
`course`, `term`, and `degree` — providing anonymized student-level
records for 98,000 undergraduates at three US institutions from 1988
through 2018. The data tables are documented at the
[midfielddata](https://midfieldr.github.io/midfielddata/reference/index.html)
website.

For this article we load the student, term, and degree tables.

``` r

library(midfielddata)
data(student, term, degree)
```

We usually copy the source data, giving them new names (and new
locations in memory), to keep them intact while we use the original
names — `student`, `term`, and `degree` — to do our work. Also, these
names are the default values when the term or degree tables, for
example, are required arguments in a midfieldr function.

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

## midfieldr functions

We organize midfieldr functions based on their position in a typical
workflow. The first few steps are common to most studies; the remainder
depend largely on the goals and metrics of a particular study.

Baseline records and population (common to most studies)

- [`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md)
  chooses columns required by midfieldr functions.
- [`add_post_bacc()`](https://midfieldr.github.io/midfieldr/reference/add_post_bacc.md)
  identifies rows of post-baccalaureate terms to exclude.
- [`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)
  estimates a student’s timely graduation term.
- [`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md)
  identifies rows to exclude due to insufficient data.

Programs and blocs (goals- and metric-specific)

- [`filter_cip()`](https://midfieldr.github.io/midfieldr/reference/filter_cip.md)
  chooses rows of CIP data based on search terms.
- [`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md)
  determines if program completion is timely or late.  
- [`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)
  conditions data for imputing starting majors of FYE students.

Charts (depends on the variables and the message)

- [`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)
  conditions data for Cleveland multiway charts.

***midfieldr and data.table.***   midfieldr functions (internally) use
data.table syntax; our scripts in these articles use it as well; and
data provided in midfieldr and midfielddata are of the `data.table`
class. For example,

``` r

degree_in <- copy(degree)
class(degree_in)
#> [1] "data.table" "data.frame"
```

In default usage, midfieldr functions return data frames in data.table
format, e.g.,

``` r

degree_out <- select_basic_cols(degree_in)

class(degree_out)
#> [1] "data.table" "data.frame"

degree_out
#>                  mcid   institution term_degree   cip6
#>                <char>        <char>      <char> <char>
#>     1: MCID3111142225 Institution B       19881 141001
#>     2: MCID3111142290 Institution J       19921 141001
#>     3: MCID3111142294 Institution J       19903 141001
#>    ---                                                
#> 49663: MCID3112839623 Institution B       20181 160102
#> 49664: MCID3112845220 Institution B       20181 270101
#> 49665: MCID3112845673 Institution B       20174 090101
```

***midfieldr and tibbles.***   Knowing that some of our users prefer
tibbles (from the tidyverse package) to data.tables, midfieldr functions
do attempt to return data frames of the same class as the input. So if
we convert `degree` to a tibble,

``` r

library(tibble)
degree_tbl <- as_tibble(degree)

degree_tbl
#> # A tibble: 49,665 × 5
#>    mcid           institution   term_degree cip6   degree                       
#>    <chr>          <chr>         <chr>       <chr>  <chr>                        
#>  1 MCID3111142225 Institution B 19881       141001 Bachelor of Science in Elect…
#>  2 MCID3111142290 Institution J 19921       141001 Bachelor of Science in Elect…
#>  3 MCID3111142294 Institution J 19903       141001 Bachelor of Science in Elect…
#>  4 MCID3111142299 Institution J 19921       141001 Bachelor of Science in Elect…
#>  5 MCID3111142689 Institution B 19913       090401 Bachelor of Arts in Journali…
#>  6 MCID3111142729 Institution B 19883       141901 Bachelor of Science in Mecha…
#>  7 MCID3111142775 Institution J 19901       141001 Bachelor of Science in Elect…
#>  8 MCID3111142782 Institution J 19903       260101 Bachelor of Science in Biolo…
#>  9 MCID3111142784 Institution J 19911       521401 Bachelor of Science in Marke…
#> 10 MCID3111142840 Institution B 19901       540101 Bachelor of Arts in History  
#> # ℹ 49,655 more rows
```

and use it as an input value, a midfieldr function (in most cases)
yields a tibble output.

``` r

select_basic_cols(degree_tbl)
#> # A tibble: 49,665 × 4
#>    mcid           institution   term_degree cip6  
#>    <chr>          <chr>         <chr>       <chr> 
#>  1 MCID3111142225 Institution B 19881       141001
#>  2 MCID3111142290 Institution J 19921       141001
#>  3 MCID3111142294 Institution J 19903       141001
#>  4 MCID3111142299 Institution J 19921       141001
#>  5 MCID3111142689 Institution B 19913       090401
#>  6 MCID3111142729 Institution B 19883       141901
#>  7 MCID3111142775 Institution J 19901       141001
#>  8 MCID3111142782 Institution J 19903       260101
#>  9 MCID3111142784 Institution J 19911       521401
#> 10 MCID3111142840 Institution B 19901       540101
#> # ℹ 49,655 more rows
```

Outside of the functions, however, all of our sample scripts employ
data.table syntax. If you prefer dplyr (and friends) for data
manipulation, you would have to translate our sample scripts into your
preferred dialect. Good translation resources are available, e.g., the
MIDFIELD Institute tutorials
([2024](#ref-midfieldinstitute:processing-data:2024)) or Atrebas
([2019](#ref-atrebas:2019))

## `select_basic_cols()`

*Chooses columns required by midfieldr functions.*

[`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md)
operates on source data frames to reduce the number of columns to those
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
#>                   mcid   institution   term   cip6         level
#>                 <char>        <char> <char> <char>        <char>
#>      1: MCID3111142225 Institution B  19881 140901 01 First-year
#>      2: MCID3111142283 Institution J  19881 240102 01 First-year
#>      3: MCID3111142283 Institution J  19883 240102 01 First-year
#>     ---                                                         
#> 639913: MCID3112898894 Institution B  20181 451001 01 First-year
#> 639914: MCID3112898895 Institution B  20181 302001 01 First-year
#> 639915: MCID3112898940 Institution B  20181 050103 01 First-year
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

As shown below, two new columns have been added: the term of a student’s
first degree and a term-status variable that indicates the term is
earlier than, equal to, or later than the first degree term.

``` r

term
#>                   mcid   institution   cip6         level   term
#>                 <char>        <char> <char>        <char> <char>
#>      1: MCID3111142225 Institution B 140901 01 First-year  19881
#>      2: MCID3111142283 Institution J 240102 01 First-year  19881
#>      3: MCID3111142283 Institution J 240102 01 First-year  19883
#>     ---                                                         
#> 639913: MCID3112898894 Institution B 451001 01 First-year  20181
#> 639914: MCID3112898895 Institution B 302001 01 First-year  20181
#> 639915: MCID3112898940 Institution B 050103 01 First-year  20181
#>         first_degree_term  term_status
#>                    <char>       <char>
#>      1:             19881 first-degree
#>      2:              <NA>     pre-bacc
#>      3:              <NA>     pre-bacc
#>     ---                               
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

``` f
term <- term[term_status != "post-first-degree"]
degree <- degree[term_status != "post-first-degree"]

term
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
#>    ---               
#> 97553: MCID3112898894
#> 97554: MCID3112898895
#> 97555: MCID3112898940
```

[`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)
adds a column indicating the TC term for every student in the record.
New columns of supporting information are also added: the student’s
initial term; their academic level upon entry; and the span in years,
adjusted by their starting level, for timely completion.

``` r

DT <- add_timely_term(DT, midfield_term = term)

DT
#>                  mcid term_i       level_i adj_span timely_term
#>                <char> <char>        <char>    <num>      <char>
#>     1: MCID3111142225  19881 01 First-year        6       19933
#>     2: MCID3111142283  19881 01 First-year        6       19933
#>     3: MCID3111142290  19881 01 First-year        6       19933
#>    ---                                                         
#> 97553: MCID3112898894  20181 01 First-year        6       20233
#> 97554: MCID3112898895  20181 01 First-year        6       20233
#> 97555: MCID3112898940  20181 01 First-year        6       20233
```

## `add_data_sufficiency()`

*Identifies rows to exclude due to insufficient data.*

The data sufficiency criterion limits student records to those for which
available data are sufficient to assess timely completion without biased
counts of completers or non-completers.

[`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md)
adds a column that labels each row for inclusion or exclusion based on
data sufficiency near the upper and lower bounds of an institution’s
data range. New columns of supporting information: the lower and upper
limits of the institution’s data range.

``` r

DT <- add_data_sufficiency(DT, midfield_term = term)

DT
#>                  mcid       level_i adj_span timely_term term_i lower_limit
#>                <char>        <char>    <num>      <char> <char>      <char>
#>     1: MCID3111142225 01 First-year        6       19933  19881       19881
#>     2: MCID3111142283 01 First-year        6       19933  19881       19881
#>     3: MCID3111142290 01 First-year        6       19933  19881       19881
#>    ---                                                                     
#> 97553: MCID3112898894 01 First-year        6       20233  20181       19881
#> 97554: MCID3112898895 01 First-year        6       20233  20181       19881
#> 97555: MCID3112898940 01 First-year        6       20233  20181       19881
#>        upper_limit data_sufficiency
#>             <char>           <char>
#>     1:       20181    exclude-lower
#>     2:       20096    exclude-lower
#>     3:       20096    exclude-lower
#>    ---                             
#> 97553:       20181    exclude-upper
#> 97554:       20181    exclude-upper
#> 97555:       20181    exclude-upper
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
#>    ---                                                                     
#> 76873: MCID3112785480 01 First-year        6       20123  20071       19901
#> 76874: MCID3112800920 01 First-year        6       20153  20101       19881
#> 76875: MCID3112870009 01 First-year        6       20003  19951       19881
#>        upper_limit data_sufficiency
#>             <char>           <char>
#>     1:       20181          include
#>     2:       20096          include
#>     3:       20181          include
#>    ---                             
#> 76873:       20154          include
#> 76874:       20181          include
#> 76875:       20181          include
```

## Data: cip

*Collecting and labeling 6-digit program codes.*

The *Classification of Instructional Programs (CIP)* is a taxonomy of
academic programs, encoded by 6-digit numeric codes curated by the US
Department of Education ([NCES 2010](#ref-NCES:2010)).

The `cip` data set, loaded with midfieldr, is a subset of the NCES
CIP2010 data that contains codes and names for 1582 instructional
programs organized on three levels—a 2-digit series, a 4-digit series,
and a 6-digit series—keyed by the `cip6` variable.

``` r

look_at(cip)
#> Classes 'data.table' and 'data.frame':   1582 obs. of  6 variables:
#>  $ cip2    : chr  "01" "01" "01" "01" ...
#>  $ cip2name: chr  "Agriculture, Agricultural Operations and Related Sciences""..
#>  $ cip4    : chr  "0100" "0101" "0101" "0101" ...
#>  $ cip4name: chr  "Agriculture, General" "Agricultural Business and Managemen"..
#>  $ cip6    : chr  "010000" "010101" "010102" "010103" ...
#>  $ cip6name: chr  "Agriculture, General" "Agricultural Business and Managemen"..

# 6-digit codes
cip[, .(cip6, cip6name)]
#>         cip6                                       cip6name
#>       <char>                                         <char>
#>    1: 010000                           Agriculture, General
#>    2: 010101  Agricultural Business and Management, General
#>    3: 010102 Agribusiness, Agricultural Business Operations
#>    4: 010103                         Agricultural Economics
#>    5: 010104                Farm, Farm and Ranch Management
#>   ---                                                      
#> 1578: 540106                                  Asian History
#> 1579: 540107                               Canadian History
#> 1580: 540108                               Military History
#> 1581: 540199                                 History, Other
#> 1582: 999999              NonIPEDS - Undecided, Unspecified

# 4-digit codes
cip[, .(cip4, cip4name)]
#>         cip4                             cip4name
#>       <char>                               <char>
#>    1:   0100                 Agriculture, General
#>    2:   0101 Agricultural Business and Management
#>    3:   0101 Agricultural Business and Management
#>    4:   0101 Agricultural Business and Management
#>    5:   0101 Agricultural Business and Management
#>   ---                                            
#> 1578:   5401                              History
#> 1579:   5401                              History
#> 1580:   5401                              History
#> 1581:   5401                              History
#> 1582:   9999    NonIPEDS - Undecided, Unspecified

# 2-digit codes
cip[, .(cip2, cip2name)]
#>         cip2                                                  cip2name
#>       <char>                                                    <char>
#>    1:     01 Agriculture, Agricultural Operations and Related Sciences
#>    2:     01 Agriculture, Agricultural Operations and Related Sciences
#>    3:     01 Agriculture, Agricultural Operations and Related Sciences
#>    4:     01 Agriculture, Agricultural Operations and Related Sciences
#>    5:     01 Agriculture, Agricultural Operations and Related Sciences
#>   ---                                                                 
#> 1578:     54                                                   History
#> 1579:     54                                                   History
#> 1580:     54                                                   History
#> 1581:     54                                                   History
#> 1582:     99                         NonIPEDS - Undecided, Unspecified
```

## `filter_cip()`

*Chooses rows of CIP data based on search terms.*

[`filter_cip()`](https://midfieldr.github.io/midfieldr/reference/filter_cip.md)
acts on the `cip` data frame to select rows that match or partially
match search strings. Search strings are case-independent and can
include regular expressions.

``` r

filter_cip("music")
#>       cip2                                         cip2name   cip4
#>     <char>                                           <char> <char>
#>  1:     13                                        Education   1313
#>  2:     36              Leisure and Recreational Activities   3601
#>  3:     39      Theological Studies and Religious Vocations   3905
#>  4:     47                   Mechanic and Repair Technology   4704
#>  5:     50                       Visual and Performing Arts   5001
#> ---                                                               
#> 21:     50                       Visual and Performing Arts   5009
#> 22:     50                       Visual and Performing Arts   5009
#> 23:     50                       Visual and Performing Arts   5009
#> 24:     50                       Visual and Performing Arts   5010
#> 25:     51 Health Professions and Related Clinical Sciences   5123
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
#>       cip6                                  cip6name
#>     <char>                                    <char>
#>  1: 131312                   Music Teacher Education
#>  2: 360115                                     Music
#>  3: 390501                   Religious, Sacred Music
#>  4: 470404 Musical Instrument Fabrication and Repair
#>  5: 500102                              Digital Arts
#> ---                                                 
#> 21: 500915                      Woodwind Instruments
#> 22: 500916                    Percussion Instruments
#> 23: 500999                              Music, Other
#> 24: 501003                          Music Management
#> 25: 512305                  Music Therapy, Therapist
```

To refine the results of one pass, assign those results to the `cip`
argument in a subsequent pass. To illustrate the process, we collect
programs related to “music” within the Visual and Performing Arts (CIP
code 50).

``` r

first_pass <- filter_cip("music")

second_pass <- filter_cip("^50", cip = first_pass)

second_pass
#>       cip2                   cip2name   cip4
#>     <char>                     <char> <char>
#>  1:     50 Visual and Performing Arts   5001
#>  2:     50 Visual and Performing Arts   5005
#>  3:     50 Visual and Performing Arts   5009
#>  4:     50 Visual and Performing Arts   5009
#>  5:     50 Visual and Performing Arts   5009
#> ---                                         
#> 16:     50 Visual and Performing Arts   5009
#> 17:     50 Visual and Performing Arts   5009
#> 18:     50 Visual and Performing Arts   5009
#> 19:     50 Visual and Performing Arts   5009
#> 20:     50 Visual and Performing Arts   5010
#>                                     cip4name   cip6
#>                                       <char> <char>
#>  1:            General Art and Music Studies 500102
#>  2:       Drama, Theatre Arts and Stagecraft 500509
#>  3:                                    Music 500901
#>  4:                                    Music 500902
#>  5:                                    Music 500903
#> ---                                                
#> 16:                                    Music 500914
#> 17:                                    Music 500915
#> 18:                                    Music 500916
#> 19:                                    Music 500999
#> 20: Arts, Entertainment and Media Management 501003
#>                                 cip6name
#>                                   <char>
#>  1:                         Digital Arts
#>  2:                      Musical Theatre
#>  3:                       Music, General
#>  4: Music History, Literature and Theory
#>  5:           Music Performance, General
#> ---                                     
#> 16:                    Brass Instruments
#> 17:                 Woodwind Instruments
#> 18:               Percussion Instruments
#> 19:                         Music, Other
#> 20:                     Music Management
```

In this case, the 4-digit CIP code 5009 identifies “Music” programs,
distinguishing them from other programs in the Visual and Performing
Arts. We assign the second pass to the `cip` argument and restrict the
search to codes starting with “5009”.

``` r

third_pass <- filter_cip("^5009", cip = second_pass)

third_pass
#>       cip2                   cip2name   cip4 cip4name   cip6
#>     <char>                     <char> <char>   <char> <char>
#>  1:     50 Visual and Performing Arts   5009    Music 500901
#>  2:     50 Visual and Performing Arts   5009    Music 500902
#>  3:     50 Visual and Performing Arts   5009    Music 500903
#>  4:     50 Visual and Performing Arts   5009    Music 500904
#>  5:     50 Visual and Performing Arts   5009    Music 500905
#> ---                                                         
#> 13:     50 Visual and Performing Arts   5009    Music 500913
#> 14:     50 Visual and Performing Arts   5009    Music 500914
#> 15:     50 Visual and Performing Arts   5009    Music 500915
#> 16:     50 Visual and Performing Arts   5009    Music 500916
#> 17:     50 Visual and Performing Arts   5009    Music 500999
#>                                 cip6name
#>                                   <char>
#>  1:                       Music, General
#>  2: Music History, Literature and Theory
#>  3:           Music Performance, General
#>  4:         Music Theory and Composition
#>  5:       Musicology and Ethnomusicology
#> ---                                     
#> 13:                     Music Technology
#> 14:                    Brass Instruments
#> 15:                 Woodwind Instruments
#> 16:               Percussion Instruments
#> 17:                         Music, Other
```

If these programs were needed for our study, we would save the 6-digit
codes and probably edit the program names for later use.

``` r

third_pass[, .(cip6, cip6name)]
#>       cip6                                             cip6name
#>     <char>                                               <char>
#>  1: 500901                                       Music, General
#>  2: 500902                 Music History, Literature and Theory
#>  3: 500903                           Music Performance, General
#>  4: 500904                         Music Theory and Composition
#>  5: 500905                       Musicology and Ethnomusicology
#>  6: 500906                                           Conducting
#>  7: 500907                                      Piano and Organ
#>  8: 500908                                      Voice and Opera
#>  9: 500909                   Music Management and Merchandising
#> 10: 500910                                   Jazz, Jazz Studies
#> 11: 500911 Violin, Viola, Guitar and Other Stringed Instruments
#> 12: 500912                                       Music Pedagogy
#> 13: 500913                                     Music Technology
#> 14: 500914                                    Brass Instruments
#> 15: 500915                                 Woodwind Instruments
#> 16: 500916                               Percussion Instruments
#> 17: 500999                                         Music, Other
```

## `add_completion_status()`

*Determines if a graduation is timely or late.*

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
#>    ---                                                                     
#> 76873: MCID3112785480 01 First-year        6       20123  20071       19901
#> 76874: MCID3112800920 01 First-year        6       20153  20101       19881
#> 76875: MCID3112870009 01 First-year        6       20003  19951       19881
#>        upper_limit data_sufficiency term_degree completion_status
#>             <char>           <char>      <char>            <char>
#>     1:       20181          include       19913            timely
#>     2:       20096          include       19903            timely
#>     3:       20181          include       19894            timely
#>    ---                                                           
#> 76873:       20154          include        <NA>              <NA>
#> 76874:       20181          include        <NA>              <NA>
#> 76875:       20181          include        <NA>              <NA>
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
#>    ---                                                                     
#> 40438: MCID3112692944 01 First-year        6       20163  20111       19881
#> 40439: MCID3112694738 01 First-year        6       20161  20103       19881
#> 40440: MCID3112730841 01 First-year        6       20173  20121       19881
#>        upper_limit data_sufficiency term_degree completion_status
#>             <char>           <char>      <char>            <char>
#>     1:       20181          include       19913            timely
#>     2:       20096          include       19903            timely
#>     3:       20181          include       19894            timely
#>    ---                                                           
#> 40438:       20181          include       20153            timely
#> 40439:       20181          include       20143            timely
#> 40440:       20181          include       20164            timely
```

## Other functions

[`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)

:   Conditions data for imputing the starting majors of First-Year
    Engineering (FYE) students. Used when blocs of starters in
    Engineering are needed and an institution has a required FYE
    program. For details see [FYE
    proxies](https://midfieldr.github.io/midfieldr/articles/art-060-fye-proxies.md).

[`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)

:   Conditions data for Cleveland multiway charts. The ordering of its
    rows and panels is crucial to the perception of effects. Used when
    data have a multiway structure. For details see [Multiway data and
    charts](https://midfieldr.github.io/midfieldr/articles/art-120-multiway.md).

Utilities

:   - [`look_at()`](https://midfieldr.github.io/midfieldr/reference/look_at.md)
      wraps base [`str()`](https://rdrr.io/r/utils/str.html).  

:   - [`sort_uniq()`](https://midfieldr.github.io/midfieldr/reference/sort_uniq.md)
      wraps base [`sort()`](https://rdrr.io/r/base/sort.html) and
      [`unique()`](https://rdrr.io/r/base/unique.html).  

:   - [`catch_error()`](https://midfieldr.github.io/midfieldr/reference/catch_error.md)
      wraps base [`tryCatch()`](https://rdrr.io/r/base/conditions.html)
      for errors.  

:   - [`check_equiv_frames()`](https://winvector.github.io/wrapr//reference/check_equiv_frames.html)
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
