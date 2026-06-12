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

Utilities (for convenience)

- [`look_at()`](https://midfieldr.github.io/midfieldr/reference/look_at.md)
  wraps base [`str()`](https://rdrr.io/r/utils/str.html).  
- [`catch_error()`](https://midfieldr.github.io/midfieldr/reference/catch_error.md)
  wraps base [`tryCatch()`](https://rdrr.io/r/base/conditions.html) for
  errors.  
- [`sort_uniq()`](https://midfieldr.github.io/midfieldr/reference/sort_uniq.md)
  wraps base [`sort()`](https://rdrr.io/r/base/sort.html) and
  [`unique()`](https://rdrr.io/r/base/unique.html).  
- [`check_equiv_frames()`](https://winvector.github.io/wrapr//reference/check_equiv_frames.html)
  re-exported from the wrapr package

***midfieldr and data.table.***   midfieldr functions (internally) use
data.table syntax; our scripts in these articles use it as well; and
data provided in midfieldr and midfielddata are of the `data.table`
class. For example,

``` r

degree_in <- copy(degree)
class(degree_in)
#> [1] "data.table" "data.frame"
```

In default usage, midfieldr functions that yield data frames return them
in data.table format, e.g.,

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

Outside of the functions, however, all of our sample scripts employ the
data.table syntax. If you prefer dplyr (and friends) for data
manipulation, you would have to translate our sample scripts into your
preferred dialect. Good translation resources are available, e.g., the
MIDFIELD Institute tutorials
([2024](#ref-midfieldinstitute:processing-data:2024)) or Atrebas
([2019](#ref-atrebas:2019))

## Records

In this section, we start choosing rows and columns of the source data
to produce our *baseline records*—a set of data tables on which all
future analysis is based. This starting point is common to most studies.

Before going any further, we copy the source data, giving them new names
(and new locations in memory). This lets us re-use the original names —
`student`, `term`, and `degree` — to refer to the baseline records we
are working towards.

``` r

student_source <- copy(student)
term_source <- copy(term)
degree_source <- copy(degree)
```

## `select_basic_cols()`

*Chooses columns required by midfieldr functions.*

[`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md)
operates on the source data to reduce the number of columns to those
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

The possible values for term status are:

``` r

sort_uniq(term$term_status)
#> [1] "first-degree"      "post-first-degree" "pre-bacc"
```

We filter to exclude rows labeled “post-first-degree”.

``` r

term <- term[term_status != "post-first-degree"]
degree <- degree[term_status != "post-first-degree"]
```

We can drop the new columns.

``` r

cols_to_drop <- c("first_degree_term", "term_status")
term[, (cols_to_drop) := NULL]
degree[, (cols_to_drop) := NULL]

term
#>                   mcid   institution   cip6         level   term
#>                 <char>        <char> <char>        <char> <char>
#>      1: MCID3111142225 Institution B 140901 01 First-year  19881
#>      2: MCID3111142283 Institution J 240102 01 First-year  19881
#>      3: MCID3111142283 Institution J 240102 01 First-year  19883
#>     ---                                                         
#> 632915: MCID3112898894 Institution B 451001 01 First-year  20181
#> 632916: MCID3112898895 Institution B 302001 01 First-year  20181
#> 632917: MCID3112898940 Institution B 050103 01 First-year  20181
```

*This step concludes the construction of our records baseline.* Our
results are

- `student`
- `term`
- `degree`

## Population

In this section, we start to develop our *baseline population* by
filtering the baseline records for the IDs of students that can be used
as a credible population for a study. This procedure too is common to
most studies.

We start with the unique IDs from the baseline term data frame.

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

## `add_timely_term()`

*Estimates a student’s timely graduation term.*

The timely completion term is the last term in which a student’s degree
completion would be considered timely. In many cases the timely
completion (TC) term is 6 years after admission. The TC term is also
necessary for determining data sufficiency.

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
#> 97534: MCID3112898894  20181 01 First-year        6       20233
#> 97535: MCID3112898895  20181 01 First-year        6       20233
#> 97536: MCID3112898940  20181 01 First-year        6       20233
```

For data sufficiency, we retain the IDs and timely term columns.

``` r

DT <- DT[, .(mcid, timely_term)]

DT
#>                  mcid timely_term
#>                <char>      <char>
#>     1: MCID3111142225       19933
#>     2: MCID3111142283       19933
#>     3: MCID3111142290       19933
#>    ---                           
#> 97534: MCID3112898894       20233
#> 97535: MCID3112898895       20233
#> 97536: MCID3112898940       20233
```

## `add_data_sufficiency()`

*Identifies rows to exclude due to insufficient data.*

The data sufficiency criterion limits student records to those for which
available data are sufficient to assess timely completion without biased
counts of completers or non-completers.

[`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md)
adds a column that labels each row for inclusion or exclusion based on
data sufficiency near the upper and lower bounds of an institution’s
data range. New columns of supporting information: the student’s initial
term and the lower and upper limits of the institution’s data range.

``` r

DT <- add_data_sufficiency(DT, midfield_term = term)

DT
#>                  mcid timely_term term_i lower_limit upper_limit
#>                <char>      <char> <char>      <char>      <char>
#>     1: MCID3111142225       19933  19881       19881       20181
#>     2: MCID3111142283       19933  19881       19881       20096
#>     3: MCID3111142290       19933  19881       19881       20096
#>    ---                                                          
#> 97534: MCID3112898894       20233  20181       19881       20181
#> 97535: MCID3112898895       20233  20181       19881       20181
#> 97536: MCID3112898940       20233  20181       19881       20181
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

We filter to retain rows labeled “include”, and drop all columns except
the ID. We end up with 76,865 unique students, approximately 80% of the
previous population.

``` r

DT <- DT[data_sufficiency == "include", .(mcid)]

DT
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

## Degree seeking

*Degree seeking* describes students advancing toward a bachelor’s
degree, accumulating credit hours in their program with the goal of
graduating from their institution.

By design, the `student` data table contains records of degree-seeking
students only. We filter our population for degree seekers using an
inner join with the student table. Because this is the final step in
constructing our baseline population, we name the result accordingly.

``` r

baseline_population <- student[DT, .(mcid), on = "mcid", nomatch = NULL]

baseline_population
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

Note that the size of the population has not been reduced, because the
practice data in midfielddata contain degree-seeking students only.
Nevertheless, we include this step for the sake of completeness—any data
other than that in midfielddata will likely contain non-degree-seeking
students.

*This step concludes the construction of our population baseline.* Our
results are:

- `baseline_population`

## Programs

*Collecting and labeling 6-digit program codes.*

In this section, we start constructing the data frame containing the
6-digit codes and program names for a given study. The specific programs
being collected will vary from study to study, but the general procedure
is common to most studies.

***CIP data.***   The *Classification of Instructional Programs (CIP)*
is a taxonomy of academic programs, encoded by 6-digit numeric codes
curated by the US Department of Education ([NCES 2010](#ref-NCES:2010)).

The `cip` data set, loaded with midfieldr, is a subset of the NCES
CIP2010 data that contains codes and names for 1582 instructional
programs organized on three levels—a 2-digit series, a 4-digit series,
and a 6-digit series—keyed by the `cip6` variable and documented in
[`?cip`](https://midfieldr.github.io/midfieldr/reference/cip.md).

``` r

cip
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
#> ---                                                               
#> 23:     50                       Visual and Performing Arts   5009
#> 24:     50                       Visual and Performing Arts   5010
#> 25:     51 Health Professions and Related Clinical Sciences   5123
#>                                                                   cip4name
#>                                                                     <char>
#>  1: Teacher Education and Professional Development, Specific Subject Areas
#>  2:                                    Leisure and Recreational Activities
#>  3:                                                Religious, Sacred Music
#> ---                                                                       
#> 23:                                                                  Music
#> 24:                               Arts, Entertainment and Media Management
#> 25:                             Rehabilitation and Therapeutic Professions
#>       cip6                 cip6name
#>     <char>                   <char>
#>  1: 131312  Music Teacher Education
#>  2: 360115                    Music
#>  3: 390501  Religious, Sacred Music
#> ---                                
#> 23: 500999             Music, Other
#> 24: 501003         Music Management
#> 25: 512305 Music Therapy, Therapist
```

To refine the results of one pass, assign those results to the `cip`
argument in a subsequent pass. To illustrate the process, we collect and
label programs related to music theory, instruments, and performance.

``` r

first_pass <- filter_cip("music")

second_pass <- filter_cip("^50", cip = first_pass)

second_pass[, .(cip4, cip4name, cip6, cip6name)]
#>       cip4                                 cip4name   cip6
#>     <char>                                   <char> <char>
#>  1:   5001            General Art and Music Studies 500102
#>  2:   5005       Drama, Theatre Arts and Stagecraft 500509
#>  3:   5009                                    Music 500901
#>  4:   5009                                    Music 500902
#>  5:   5009                                    Music 500903
#>  6:   5009                                    Music 500904
#>  7:   5009                                    Music 500905
#>  8:   5009                                    Music 500906
#>  9:   5009                                    Music 500907
#> 10:   5009                                    Music 500908
#> 11:   5009                                    Music 500909
#> 12:   5009                                    Music 500910
#> 13:   5009                                    Music 500911
#> 14:   5009                                    Music 500912
#> 15:   5009                                    Music 500913
#> 16:   5009                                    Music 500914
#> 17:   5009                                    Music 500915
#> 18:   5009                                    Music 500916
#> 19:   5009                                    Music 500999
#> 20:   5010 Arts, Entertainment and Media Management 501003
#>       cip4                                 cip4name   cip6
#>     <char>                                   <char> <char>
#>                                                 cip6name
#>                                                   <char>
#>  1:                                         Digital Arts
#>  2:                                      Musical Theatre
#>  3:                                       Music, General
#>  4:                 Music History, Literature and Theory
#>  5:                           Music Performance, General
#>  6:                         Music Theory and Composition
#>  7:                       Musicology and Ethnomusicology
#>  8:                                           Conducting
#>  9:                                      Piano and Organ
#> 10:                                      Voice and Opera
#> 11:                   Music Management and Merchandising
#> 12:                                   Jazz, Jazz Studies
#> 13: Violin, Viola, Guitar and Other Stringed Instruments
#> 14:                                       Music Pedagogy
#> 15:                                     Music Technology
#> 16:                                    Brass Instruments
#> 17:                                 Woodwind Instruments
#> 18:                               Percussion Instruments
#> 19:                                         Music, Other
#> 20:                                     Music Management
#>                                                 cip6name
#>                                                   <char>
```

The `select` argument allows you to select specific columns, dropping
all others. In this case, the 4-digit CIP code 5009 identifies “Music”
programs, distinguishing them from other programs in the Visual and
Performing Arts (CIP code 50).

``` r

third_pass <- filter_cip("^5009", cip = second_pass, select = c("cip4name", "cip6", "cip6name"))

third_pass
#>     cip4name   cip6                                             cip6name
#>       <char> <char>                                               <char>
#>  1:    Music 500901                                       Music, General
#>  2:    Music 500902                 Music History, Literature and Theory
#>  3:    Music 500903                           Music Performance, General
#>  4:    Music 500904                         Music Theory and Composition
#>  5:    Music 500905                       Musicology and Ethnomusicology
#>  6:    Music 500906                                           Conducting
#>  7:    Music 500907                                      Piano and Organ
#>  8:    Music 500908                                      Voice and Opera
#>  9:    Music 500909                   Music Management and Merchandising
#> 10:    Music 500910                                   Jazz, Jazz Studies
#> 11:    Music 500911 Violin, Viola, Guitar and Other Stringed Instruments
#> 12:    Music 500912                                       Music Pedagogy
#> 13:    Music 500913                                     Music Technology
#> 14:    Music 500914                                    Brass Instruments
#> 15:    Music 500915                                 Woodwind Instruments
#> 16:    Music 500916                               Percussion Instruments
#> 17:    Music 500999                                         Music, Other
```

Now that we have the 6-digit codes we want, we label the codes with
program names that make sense to the study. For example, here we group
the 17 6-digit codes of music programs into 5 categories.

``` r

study_programs <- third_pass[, .(cip6, cip6name)]
study_programs[, program := fcase(
  cip6name %ilike% "instrument|piano", "Instrument", 
  cip6name %ilike% "perform|conduct|voice|tech|jazz", "Performance", 
  cip6name %ilike% "theory|musicology", "Theory", 
  cip6name %ilike% "pedagogy", "Teaching", 
  default = "General"
)]
study_programs[order(program)]
#>       cip6                                             cip6name     program
#>     <char>                                               <char>      <char>
#>  1: 500901                                       Music, General     General
#>  2: 500909                   Music Management and Merchandising     General
#>  3: 500999                                         Music, Other     General
#>  4: 500907                                      Piano and Organ  Instrument
#>  5: 500911 Violin, Viola, Guitar and Other Stringed Instruments  Instrument
#>  6: 500914                                    Brass Instruments  Instrument
#>  7: 500915                                 Woodwind Instruments  Instrument
#>  8: 500916                               Percussion Instruments  Instrument
#>  9: 500903                           Music Performance, General Performance
#> 10: 500906                                           Conducting Performance
#> 11: 500908                                      Voice and Opera Performance
#> 12: 500910                                   Jazz, Jazz Studies Performance
#> 13: 500913                                     Music Technology Performance
#> 14: 500912                                       Music Pedagogy    Teaching
#> 15: 500902                 Music History, Literature and Theory      Theory
#> 16: 500904                         Music Theory and Composition      Theory
#> 17: 500905                       Musicology and Ethnomusicology      Theory
```

We then retain the codes and labels,

``` r

study_programs <- study_programs[, .(cip6, program)]
study_programs
#>       cip6     program
#>     <char>      <char>
#>  1: 500901     General
#>  2: 500902      Theory
#>  3: 500903 Performance
#>  4: 500904      Theory
#>  5: 500905      Theory
#>  6: 500906 Performance
#>  7: 500907  Instrument
#>  8: 500908 Performance
#>  9: 500909     General
#> 10: 500910 Performance
#> 11: 500911  Instrument
#> 12: 500912    Teaching
#> 13: 500913 Performance
#> 14: 500914  Instrument
#> 15: 500915  Instrument
#> 16: 500916  Instrument
#> 17: 500999     General
```

*This step concludes the general procedure for collecting programs.* Our
results are:

- `study_programs`

## Blocs: `add_completion_status()`

*Determines if a graduation is timely or late.*

In this section, we refine a population further to develop blocs used in
constructing metrics. We start with the baseline population, add the
timely completion term, retain the minimum set of columns, and apply
[`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md).

``` r

DT <- copy(baseline_population)
DT <- add_timely_term(DT)
DT <- DT[, .(mcid, timely_term)]
DT <- add_completion_status(DT)

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

If we wanted a bloc of graduates, we would filter to retain IDs with a
“timely” status. For example,

``` r

DT <- DT[completion_status == "timely"]
graduates <- DT[, .(mcid, bloc = "graduates")]

graduates
#>                  mcid      bloc
#>                <char>    <char>
#>     1: MCID3111142689 graduates
#>     2: MCID3111142782 graduates
#>     3: MCID3111142881 graduates
#>    ---                         
#> 40428: MCID3112692944 graduates
#> 40429: MCID3112694738 graduates
#> 40430: MCID3112730841 graduates
```

Timely graduates comprise about 53% of the baseline population.

## Blocs: `prep_fye_mice()`

*Conditions data for imputing starting majors of FYE students.*

Used when blocs of starters in Engineering are required. It conditions
data for imputing starting majors of First-Year Engineering (FYE)
students. For details see [FYE
proxies](https://midfieldr.github.io/midfieldr/articles/art-060-fye-proxies.md).

## Charts: `order_multiway()`

*Conditions data for Cleveland multiway charts.* For details see
[Multiway data and
charts](https://midfieldr.github.io/midfieldr/articles/art-120-multiway.md).

## References

atrebas. 2019. *A data.table and dplyr tour*.
<https://atrebas.github.io/post/2019-03-03-datatable-dplyr/>.

Lord, Susan, Richard Layton, Russell Long, Matthew Ohland, and Marisa
Orr. 2024. *MIDFIELD Institute*.
<https://midfieldr.github.io/2024-midfield-institute/data-shaping-00-introduction.html>.

NCES. 2010. *IPEDS Classification of Instructional Programs (CIP)*.
National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>.
