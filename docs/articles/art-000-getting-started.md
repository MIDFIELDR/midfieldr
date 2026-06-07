# Introduction to midfieldr

When working with student-level records and developing quantitative
metrics, we recommend that you:

- Know your data structure
- Define your metrics and the relevant blocs of students
- Develop a process to refine and shape your data to produce the blocs
  you need
- Use contemporary chart design for data visualization and exploration

midfieldr helps you with this process in these areas:

- *Baseline records.*   Subsetting source data.  
- *Baseline programs.*   Collecting and labeling program codes.  
- *Baseline population.*   Determining a population as a basis for
  blocs.  
- *Blocs.*   Grouping records for computing metrics.  
- *Charts.*   Condition data for multiway charts.

This document introduces you to midfieldr’s tools.

``` r

# We use these packages
library(midfieldr)
library(midfielddata)
library(data.table)
```

## Data: Student-level records

*Research data.*   MIDFIELD ([Ohland 2023](#ref-ohland:midfield:2023))
is a database of 2.4M students that has been managed since 2023 by the
American Society for Engineering Education (ASEE). Contact ASEE for
further information.

*Practice data.*   The midfielddata package provides an anonymized
sample of the MIDFIELD database organized in four tables (student,
course, term, degree) as shown in Table 1. midfielddata is used
throughout these articles to demonstrate how midfieldr is used. However,
midfielddata must not be used to draw inferences about program
attributes or student experiences. midfielddata is for *practice*, not
*research*.

| Table | Each row is | N students | N rows | N columns | Mb memory |
|----|----|----|----|----|----|
| student | one student | 97,555 | 97,555 | 13 | 17.3 |
| course | one student per course per term | 97,555 | 3,289,532 | 12 | 324.3 |
| term | one student per term | 97,555 | 639,915 | 13 | 72.8 |
| degree | one student per degree | 49,543 | 49,665 | 5 | 5.2 |

Table 1. Student-level records in midfielddata {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

Data dictionaries are documented in
[`?student`](https://midfieldr.github.io/midfielddata/reference/student.html),
[`?course`](https://midfieldr.github.io/midfielddata/reference/course.html),
[`?term`](https://midfieldr.github.io/midfielddata/reference/term.html),
and
[`?degree`](https://midfieldr.github.io/midfielddata/reference/degree.html).
If you are new to these data, the best place to start is the
midfielddata website:

- [MIDFIELD data
  structure.](https://midfieldr.github.io/midfielddata/articles/data-structure.html)
  An article that describes the structure of the four data tables in
  midfielddata: number of observations, number and class of variables,
  representative values, and database keys.

- [Data linked by student
  ID.](https://midfieldr.github.io/midfielddata/articles/individual-students.html)
  An article that examines the variables and some representative values
  in midfielddata—we take a closer look at the records of individual
  students across the four data tables.

*Load data.*   Data tables from midfielddata can be loaded individually
or collectively as needed. We comment-out code related to course data to
avoid the slower execution time—many conventional metrics, graduation
rate for example, do not depend on course-level data.

``` r

# data(course)
data(student, term, degree)
```

Example of one of the practice data tables.

``` r

student
#>                  mcid   institution              transfer hours_transfer
#>                <char>        <char>                <char>          <num>
#>     1: MCID3111142225 Institution B   First-Time Transfer             NA
#>     2: MCID3111142283 Institution J   First-Time Transfer             NA
#>     3: MCID3111142290 Institution J   First-Time Transfer             NA
#>    ---                                                                  
#> 97553: MCID3112898894 Institution B First-Time in College             NA
#> 97554: MCID3112898895 Institution B First-Time in College             NA
#> 97555: MCID3112898940 Institution B First-Time in College             NA
#>                 race    sex age_desc us_citizen home_zip high_school sat_math
#>               <char> <char>   <char>     <char>   <char>      <char>    <num>
#>     1:         Asian   Male Under 25        Yes     <NA>        <NA>       NA
#>     2:         Asian Female Under 25        Yes    22020        <NA>      560
#>     3:         Asian   Male Under 25        Yes    23233      471872      510
#>    ---                                                                       
#> 97553:         White Female Under 25        Yes    53716      501160      510
#> 97554:         White Female Under 25        Yes    53029      500853      420
#> 97555: Other/Unknown   Male Under 25        Yes    20016      090073      470
#>        sat_verbal act_comp
#>             <num>    <num>
#>     1:         NA       NA
#>     2:        230       NA
#>     3:        380       NA
#>    ---                    
#> 97553:        590       24
#> 97554:        590       32
#> 97555:        540       32
```

*midfieldr uses data.table.*   Data frames in midfieldr and midfielddata
have the attributes of the “data.table” class, designed for fast
manipulation of large data sets. For example,

``` r

class(student)
#> [1] "data.table" "data.frame"

class(term)
#> [1] "data.table" "data.frame"
```

Internally, midfieldr functions convert incoming data frames to
data.table format and run using data.table operations and syntax. While
the practice data sets are not especially large, midfieldr is designed
to also work with the larger MIDFIELD database (about 25 times larger
than midfielddata) where the speed and efficiency of data.table is
beneficial.

*midfieldr and tibbles.*   midfieldr functions attempt to return data
frames of the same class as the input, so a data.table input should
produce a data.table output, a tibble input should produce a tibble
output, etc. Grouped tibbles, however, are returned as data.frames. To
help ensure a tibble output, try ungrouping a tibble before using it as
an input argument.

``` r

library(tibble)
student <- as_tibble(student)

class(student)
#> [1] "tbl_df"     "tbl"        "data.frame"

student
#> # A tibble: 97,555 × 13
#>    mcid      institution transfer hours_transfer race  sex   age_desc us_citizen
#>    <chr>     <chr>       <chr>             <dbl> <chr> <chr> <chr>    <chr>     
#>  1 MCID3111… Institutio… First-T…             NA Asian Male  Under 25 Yes       
#>  2 MCID3111… Institutio… First-T…             NA Asian Fema… Under 25 Yes       
#>  3 MCID3111… Institutio… First-T…             NA Asian Male  Under 25 Yes       
#>  4 MCID3111… Institutio… First-T…             NA Asian Male  Under 25 Yes       
#>  5 MCID3111… Institutio… First-T…             NA Asian Male  Under 25 Yes       
#>  6 MCID3111… Institutio… First-T…             NA Asian Male  Under 25 Yes       
#>  7 MCID3111… Institutio… First-T…             NA Black Male  Under 25 Yes       
#>  8 MCID3111… Institutio… First-T…             NA Hisp… Fema… Under 25 Yes       
#>  9 MCID3111… Institutio… First-T…             NA Hisp… Male  25 and … Yes       
#> 10 MCID3111… Institutio… First-T…             NA Hisp… Male  Under 25 Yes       
#> # ℹ 97,545 more rows
#> # ℹ 5 more variables: home_zip <chr>, high_school <chr>, sat_math <dbl>,
#> #   sat_verbal <dbl>, act_comp <dbl>

# tibble input yields a tibble output
select_basic_cols(student)
#> # A tibble: 97,555 × 4
#>    mcid           institution   race     sex   
#>    <chr>          <chr>         <chr>    <chr> 
#>  1 MCID3111142225 Institution B Asian    Male  
#>  2 MCID3111142283 Institution J Asian    Female
#>  3 MCID3111142290 Institution J Asian    Male  
#>  4 MCID3111142294 Institution J Asian    Male  
#>  5 MCID3111142299 Institution J Asian    Male  
#>  6 MCID3111142303 Institution J Asian    Male  
#>  7 MCID3111142633 Institution J Black    Male  
#>  8 MCID3111142689 Institution B Hispanic Female
#>  9 MCID3111142729 Institution B Hispanic Male  
#> 10 MCID3111142775 Institution J Hispanic Male  
#> # ℹ 97,545 more rows

# restore data.table structure before continuing in this article
setDT(student)
```

## Data: Program codes

*Classification of Instructional Programs (CIP)* is a taxonomy of
academic programs, encoded by 6-digit numeric codes curated by the US
Department of Education ([NCES 2010](#ref-NCES:2010)).

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

A slightly more complete 2010 CIP data set, `cip2010`, is also loaded
with midfieldr. See [Alternative
CIPs](https://midfieldr.github.io/midfieldr/articles/art-041-alternative-cip.md)
for details.
[`look_at()`](https://midfieldr.github.io/midfieldr/reference/look_at.md)
is a midfieldr utility function that wraps `base::str()` for a
cleaner-looking output.

``` r

look_at(cip2010)
#> Classes 'data.table' and 'data.frame':   1849 obs. of  6 variables:
#>  $ cip2    : chr  "01" "01" "01" "01" ...
#>  $ cip2name: chr  "Agriculture, Agriculture Operations, and Related Sciences""..
#>  $ cip4    : chr  "0100" "0101" "0101" "0101" ...
#>  $ cip4name: chr  "Agriculture, General" "Agricultural Business and Managemen"..
#>  $ cip6    : chr  "010000" "010101" "010102" "010103" ...
#>  $ cip6name: chr  "Agriculture, General" "Agricultural Business and Managemen"..
```

## midfieldr functions

We organize midfieldr functions based on their position in a typical
workflow. While midfieldr has no functions for computing metrics
specifically—for that we use conventional methods—it does have functions
to help construct the blocs required for those metrics.

Baseline records, programs, and population

- [`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md)
  chooses columns required by midfieldr functions.  
- [`add_post_bacc()`](https://midfieldr.github.io/midfieldr/reference/add_post_bacc.md)
  identifies rows of post-baccalaureate terms to exclude.  
- [`filter_cip()`](https://midfieldr.github.io/midfieldr/reference/filter_cip.md)
  chooses rows of CIP data based on search terms.  
- [`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)
  estimates a student’s timely graduation term.  
- [`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md)
  identifies rows to exclude due to insufficient data.

Blocs/metrics

- [`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md)
  determines if a graduation is timely or late.  
- [`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)
  conditions data for imputing starting majors of FYE students.

Charts

- [`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)
  conditions data for Cleveland multiway charts.

Utilities

- [`look_at()`](https://midfieldr.github.io/midfieldr/reference/look_at.md)
  wraps base [`str()`](https://rdrr.io/r/utils/str.html).  
- [`catch_error()`](https://midfieldr.github.io/midfieldr/reference/catch_error.md)
  wraps base [`tryCatch()`](https://rdrr.io/r/base/conditions.html) for
  errors.  
- [`sort_uniq()`](https://midfieldr.github.io/midfieldr/reference/sort_uniq.md)
  wraps base [`sort()`](https://rdrr.io/r/base/sort.html) and
  [`unique()`](https://rdrr.io/r/base/unique.html).

## Initialize the source data

Before operating on student records, we
[`data.table::copy()`](https://rdrr.io/pkg/data.table/man/copy.html) the
original data to preserve them should we need them later. That allows us
to use data.table’s “change by reference” operations without affecting
those copies. As we mentioned earlier, course-related code is shown but
not run.

``` r

student.copy <- copy(student)
# course.copy <- copy(course)
term.copy <- copy(term)
degree.copy <- copy(degree)
```

## `select_basic_cols()`

*Chooses columns required by midfieldr functions.*

Operates on the source data to reduce the number of columns to those
required by other midfieldr functions plus the key or composite key
variables of the four data tables.

``` r

student <- select_basic_cols(student)
# course <- select_basic_cols(course)
term <- select_basic_cols(term)
degree <- select_basic_cols(degree)
```

For example, compare `term` before and after applying
[`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md).

``` r

look_at(term.copy)
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

Rows are unaffected, but with a smaller number of columns, the printout
of the data frame is more readable, a benefit when working with the data
interactively.

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

You can specify additional columns with the `patternv` argument, using
regular expressions if desired. To illustrate, we operate on `term.copy`
because `term` no longer includes the Co-op and GPA columns we want in
this example.

``` r

select_basic_cols(term.copy, patternv = c("coop", "^gpa"))
#>                   mcid   institution   term   cip6         level   coop
#>                 <char>        <char> <char> <char>        <char> <char>
#>      1: MCID3111142225 Institution B  19881 140901 01 First-year     No
#>      2: MCID3111142283 Institution J  19881 240102 01 First-year     No
#>      3: MCID3111142283 Institution J  19883 240102 01 First-year     No
#>     ---                                                                
#> 639913: MCID3112898894 Institution B  20181 451001 01 First-year     No
#> 639914: MCID3112898895 Institution B  20181 302001 01 First-year     No
#> 639915: MCID3112898940 Institution B  20181 050103 01 First-year     No
#>         gpa_term gpa_cumul
#>            <num>     <num>
#>      1:     2.56      2.56
#>      2:     1.85      1.85
#>      3:     1.93      1.90
#>     ---                   
#> 639913:     3.52      3.52
#> 639914:     3.50      3.50
#> 639915:     2.18      2.18
```

## `add_post_bacc()`

*Identifies rows of post-baccalaureate terms to exclude.*

In a typical analysis, one is interested in a student’s progress up to
and including the term in which they earn their first degree or degrees.
Any terms later than the first baccalaureate can usually be ignored.

[`add_post_bacc()`](https://midfieldr.github.io/midfieldr/reference/add_post_bacc.md)
identifies post-baccalaureate terms so a user can exclude them from a
data frame. To do so, the input data frame must have a term variable
with one of three possible names: `term` (from the term table),
`term_course` (course table), or `term_degree` (degree table).

``` r

# course <- add_post_bacc(course)
term <- add_post_bacc(term)
degree <- add_post_bacc(degree)
```

An error occurs if you apply the function to a data frame, such as
`student`, that lacks one of the three specified column names. To show
that error message, we can use our
[`catch_error()`](https://midfieldr.github.io/midfieldr/reference/catch_error.md)
utility,

``` r

catch_error(add_post_bacc(student))
#> Error: Assertion on 'term_variable' failed: Must be element of set {'term','term_course','term_degree'}, but is not atomic scalar.
```

Viewing the new `term` table, we see that columns `first_degree_term`
and `term_status` have been added. The values in `first_degree_term`
come from the `degree` data table.

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

We can use another utility,
[`sort_uniq()`](https://midfieldr.github.io/midfieldr/reference/sort_uniq.md),
to display the unique values from the status column.

``` r

sort_uniq(term$term_status)
#> [1] "first-degree"      "post-first-degree" "pre-bacc"
```

Next we typically exclude all post-first-degree terms.

``` r

# course <- course[term_status != "post-first-degree"]
term <- term[term_status != "post-first-degree"]
degree <- degree[term_status != "post-first-degree"]

nrow(term)
#> [1] 632917
```

The `term` data frame now has about 7000 fewer rows than we had in the
original source data. We can now drop the extra columns using
conventional coding practice. In data.table, one approach is:

``` r

cols_to_drop <- c("first_degree_term", "term_status")
# course[ , (cols_to_drop) := NULL]
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

*Baseline records.*   We would generally write these results—student,
course, term, degree—to file as a baseline set of records for all
further analysis.

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
argument in a subsequent pass.

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
#>  6:     50 Visual and Performing Arts   5009
#>  7:     50 Visual and Performing Arts   5009
#>  8:     50 Visual and Performing Arts   5009
#>  9:     50 Visual and Performing Arts   5009
#> 10:     50 Visual and Performing Arts   5009
#> 11:     50 Visual and Performing Arts   5009
#> 12:     50 Visual and Performing Arts   5009
#> 13:     50 Visual and Performing Arts   5009
#> 14:     50 Visual and Performing Arts   5009
#> 15:     50 Visual and Performing Arts   5009
#> 16:     50 Visual and Performing Arts   5009
#> 17:     50 Visual and Performing Arts   5009
#> 18:     50 Visual and Performing Arts   5009
#> 19:     50 Visual and Performing Arts   5009
#> 20:     50 Visual and Performing Arts   5010
#>       cip2                   cip2name   cip4
#>     <char>                     <char> <char>
#>                                     cip4name   cip6
#>                                       <char> <char>
#>  1:            General Art and Music Studies 500102
#>  2:       Drama, Theatre Arts and Stagecraft 500509
#>  3:                                    Music 500901
#>  4:                                    Music 500902
#>  5:                                    Music 500903
#>  6:                                    Music 500904
#>  7:                                    Music 500905
#>  8:                                    Music 500906
#>  9:                                    Music 500907
#> 10:                                    Music 500908
#> 11:                                    Music 500909
#> 12:                                    Music 500910
#> 13:                                    Music 500911
#> 14:                                    Music 500912
#> 15:                                    Music 500913
#> 16:                                    Music 500914
#> 17:                                    Music 500915
#> 18:                                    Music 500916
#> 19:                                    Music 500999
#> 20: Arts, Entertainment and Media Management 501003
#>                                     cip4name   cip6
#>                                       <char> <char>
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

The goal is to identify the 6-digit CIP codes of all relevant programs
and then label the codes with program names that make sense to your
study. For example, the major called Industrial or Systems Engineering
usually encompasses four CIP codes: 1427, 1435, 1436, and 1437.

``` r

filter_cip(c("^1427", "^1435", "^1436", "^1437"))
#>      cip2    cip2name   cip4                  cip4name   cip6
#>    <char>      <char> <char>                    <char> <char>
#> 1:     14 Engineering   1427       Systems Engineering 142701
#> 2:     14 Engineering   1435    Industrial Engineering 143501
#> 3:     14 Engineering   1436 Manufacturing Engineering 143601
#> 4:     14 Engineering   1437       Operations Research 143701
#>                     cip6name
#>                       <char>
#> 1:       Systems Engineering
#> 2:    Industrial Engineering
#> 3: Manufacturing Engineering
#> 4:       Operations Research
```

To prepare these programs for study we keep the `cip6` column and add a
`program` column with a custom program label. We repeat this procedure
until all programs of interest have been collected and labeled.

``` r

study_programs <- filter_cip(c("^1427", "^1435", "^1436", "^1437"))
study_programs <- study_programs[, .(cip6, program = "ISE")]

study_programs
#>      cip6 program
#>    <char>  <char>
#> 1: 142701     ISE
#> 2: 143501     ISE
#> 3: 143601     ISE
#> 4: 143701     ISE
```

*Baseline programs*   We would generally write the `study_programs`
result to file as the baseline set of programs for all further analysis.
The 6-digit codes are used for joining operations and the labels are
used as grouping variables.

## `add_timely_term()`

*Estimates a student’s timely graduation term.*

This section begins the work with our *population*—filtering the
baseline records for the IDs of students that can be used as a credible
baseline population for a study. (To start we would probably read the
baseline files we wrote to file earlier.)

[`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)
estimates for every student the latest term by which their program
completion would be considered timely. The result is used to refine the
population to meet the constraints of data sufficiency and timely
completion.

We start with the baseline term data frame, unique IDs only. In
determining the baseline population, the goal is to obtain a data frame
of IDs.

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

[`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)
adds a column for the timely completion term plus additional columns of
supporting information: the student’s initial term; their academic level
upon entry; and the span in years, adjusted by their starting level,
that defines timely completion for each student (default is 6 years).
Adjusted spans range from 3 years (a transfer student entering with 3
years worth of credit) to 6 years (a typical first-year student).

``` r

DT <- add_timely_term(DT)

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

sort_uniq(DT$adj_span)
#> [1] 3 4 5 6
```

To conclude this section, we retain the IDs and timely term columns.

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

[`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md)
identifies student IDs whose records—near the upper and lower bounds of
an institution’s data range—must be excluded to prevent false counts due
to insufficient data.

We start with the results of the timely term step, with 97,536 unique
students.

The function adds a column for data sufficiency plus additional columns
of supporting information: the initial term; and the lower and upper
limits of the institution’s data range. The data sufficiency column
indicates whether an ID should be included or not, and if not, at which
boundary (lower or upper) the criteria were not met.

``` r

DT <- add_data_sufficiency(DT)

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

sort_uniq(DT$data_sufficiency)
#> [1] "exclude-lower" "exclude-upper" "include"
```

We filter to retain records for which the institutional data is
sufficient and drop all columns except the ID. We end up with 76,865
unique students, approximately 80% of the previous population.

``` r

baseline_pop <- DT[data_sufficiency == "include", .(mcid)]

baseline_pop
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

*Baseline population*   We would generally write the `baseline_pop`
result to file as the baseline population for all further analysis.

> The baseline records, programs, and population developed to this point
> are used for nearly any metric one may develop for students working
> towards/achieving their first baccalaureate.

## `add_completion_status()`

*Determines if a graduation is timely or late.*

This function refines a population further, but usually for developing a
bloc of graduates, not necessarily as part of the baseline population.

We start with the baseline population, add the timely completion term,
retain the minimum set of columns, and apply
[`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md).

``` r

DT <- copy(baseline_pop)
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

## Special functions

[`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)
is used when blocs of starters in Engineering are required. It
conditions data for imputing starting majors of First-Year Engineering
(FYE) students. For details see [FYE
proxies](https://midfieldr.github.io/midfieldr/articles/art-060-fye-proxies.md).

[`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)
conditions data for Cleveland multiway charts. For details see [Multiway
data and
charts](https://midfieldr.github.io/midfieldr/articles/art-120-multiway.md).

## References

NCES. 2010. *IPEDS Classification of Instructional Programs (CIP)*.
National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>.

Ohland, Matthew. 2023. *MIDFIELD, 2004–2023*.
<https://midfield.online/>.
