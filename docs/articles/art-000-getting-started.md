# Introduction to midfieldr

In this document, we introduce midfieldr’s basic tools and show how to
apply them to data frames of student-level records (registrar’s data).
We organize the topics around a typical workflow:

- data
- population
- records
- blocs
- special conditioning

*Packages.* We load midfielddata for its practice data and data.table
for its data manipulation syntax.

``` r

library("midfieldr")
library("midfielddata")
library("data.table")
```

## Data

### *Student records*

midfieldr is designed to work with the MIDFIELD research database or any
database with a similar structure such as the practice data in the
[midfielddata](https://midfieldr.github.io/midfielddata/index.html)
package. If you are new to MIDFIELD, the best place to start is the
article on [Data
structure](https://midfieldr.github.io/midfielddata/articles/data-structure.html).

For this article we load all four midfielddata tables.

``` r

# data(student, term, course, degree)
data(student, term, degree)
```

[`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md)
returns a subset of each table with the variables most often encountered
in the early stages of a project. The tables are linked by the
anonymized student ID variable `mcid.`

``` r

select_basic_cols(student)
#>                  mcid          race    sex
#>                <char>        <char> <char>
#>     1: MCID3111142225         Asian   Male
#>     2: MCID3111142283         Asian Female
#>     3: MCID3111142290         Asian   Male
#>    ---                                    
#> 97553: MCID3112898894         White Female
#> 97554: MCID3112898895         White Female
#> 97555: MCID3112898940 Other/Unknown   Male

select_basic_cols(term)
#>                   mcid   term   cip6   institution         level
#>                 <char> <char> <char>        <char>        <char>
#>      1: MCID3111142225  19881 140901 Institution B 01 First-year
#>      2: MCID3111142283  19881 240102 Institution J 01 First-year
#>      3: MCID3111142283  19883 240102 Institution J 01 First-year
#>     ---                                                         
#> 639913: MCID3112898894  20181 451001 Institution B 01 First-year
#> 639914: MCID3112898895  20181 302001 Institution B 01 First-year
#> 639915: MCID3112898940  20181 050103 Institution B 01 First-year

# select_basic_cols(course)

select_basic_cols(degree)
#>                  mcid term_degree   cip6
#>                <char>      <char> <char>
#>     1: MCID3111142225       19881 141001
#>     2: MCID3111142290       19921 141001
#>     3: MCID3111142294       19903 141001
#>    ---                                  
#> 49663: MCID3112839623       20181 160102
#> 49664: MCID3112845220       20181 270101
#> 49665: MCID3112845673       20174 090101
```

*Notes.*

1.  Like the data frames above, all data frames in midfieldr are
    `data.table` enhanced. However, if you convert these tables to
    another class such as `tbl_df` (tibbles) or `data.frame` (base R),
    midfieldr functions attempt to return data frames of the same class
    to support your preferred syntax.

2.  Term variables `{term, term_course, term_degree}` are encoded as
    character strings `YYYYT`, where `YYYY` is the year at the start of
    the academic year and `T` encodes the semester or quarter within an
    academic year as Fall (1), Winter (2), Spring (3), or Summer (4, 5,
    and 6).

3.  The `cip6` columns contain 6-digit CIP program codes.

### *CIP data*

The US Classification of Instructional Programs (CIP) is a taxonomy of
fields of study ([NCES 2010](#ref-NCES:2010)). The dataset `cip` that
loads with midfieldr contains program names and codes at the 2-digit,
4-digit, and 6-digit level.

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

## Population

Relevant functions:

- [`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md)
- [`data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/data_sufficiency.md)

### timely_term()

The *timely-completion term* is the latest term by which a student’s
program completion would be considered timely (default 6 academic years
after admission). *Program completion* means satisfying the requirements
for a degree.

[`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md)
determines the timely completion term for each student. The principal
data frame must include the variable `{mcid}.` Entry term and level are
pulled from the `term` table. The data frame is returned with the
following variables added:

| variable      | description                                      |
|---------------|--------------------------------------------------|
| `entry_term`  | term when admitted                               |
| `entry_level` | level when admitted                              |
| `adj_span`    | default span adjusted to account for entry level |
| `timely_term` | timely completion term                           |

``` r

# setup
DT <- student[, .(mcid)]

# apply
DT <- timely_term(DT)

# result
DT[order(-adj_span)]
#>                  mcid entry_term    entry_level adj_span timely_term
#>                <char>     <char>         <char>    <num>      <char>
#>     1: MCID3111142225      19881  01 First-year        6       19933
#>     2: MCID3111142283      19881  01 First-year        6       19933
#>     3: MCID3111142290      19881  01 First-year        6       19933
#>    ---                                                              
#> 97553: MCID3111858641      20013  03 Third-year        4       20051
#> 97554: MCID3111860641      20013  03 Third-year        4       20051
#> 97555: MCID3111602161      19991 04 Fourth-year        3       20013
```

The optional `span` argument allows you to change the time span you
consider “timely.”

``` r

DT <- student[, .(mcid)]
timely_term(DT, span = 8)[order(-adj_span)]
#>                  mcid entry_term    entry_level adj_span timely_term
#>                <char>     <char>         <char>    <num>      <char>
#>     1: MCID3111142225      19881  01 First-year        8       19953
#>     2: MCID3111142283      19881  01 First-year        8       19953
#>     3: MCID3111142290      19881  01 First-year        8       19953
#>    ---                                                              
#> 97553: MCID3111858641      20013  03 Third-year        6       20071
#> 97554: MCID3111860641      20013  03 Third-year        6       20071
#> 97555: MCID3111602161      19991 04 Fourth-year        5       20033
```

### data_sufficiency()

*Data sufficiency* is a necessary condition for including a student in a
population if a metric depends on program completion. To meet the
condition, an institution’s data range must bracket a student’s entry
and timely completion terms.

[`data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/data_sufficiency.md)
evaluates whether the condition is met for each student. The principal
data frame must include the variables `{mcid, entry_term, timely_term}.`
Institutions’ data ranges are pulled from the `term` table. The data
frame is returned with the following variables added:

| variable      | description                                        |
|---------------|----------------------------------------------------|
| `data_range`  | an institution's min and max terms in the database |
| `sufficiency` | indicates whether a record satisfies the condition |

``` r

# setup
DT <- student[, .(mcid)]
DT <- timely_term(DT)
DT <- DT[, .(mcid, entry_term, timely_term)]

# apply
DT <- data_sufficiency(DT)

# result
DT[order(-sufficiency)]
#>                  mcid entry_term timely_term  data_range sufficiency
#>                <char>     <char>      <char>      <char>      <char>
#>     1: MCID3111142689      19883       19941 19881-20181   satisfied
#>     2: MCID3111142782      19883       19941 19881-20096   satisfied
#>     3: MCID3111142881      19893       19951 19881-20181   satisfied
#>    ---                                                              
#> 97553: MCID3111824139      19901       19953 19901-20154  fail-lower
#> 97554: MCID3111869416      19901       19953 19901-20154  fail-lower
#> 97555: MCID3112056754      19881       19933 19881-20096  fail-lower
```

We usually filter to retain rows with sufficiency labeled “satisfied,”
indicating that the entry term is at least one term later than the lower
limit of the data range and the timely completion term is no later than
the upper limit.

## Records

Relevant functions:

- [`filter_undergrad()`](https://midfieldr.github.io/midfieldr/reference/filter_undergrad.md)

### filter_undergrad()

*Undergraduate terms* are those prior to (and including) the first
degree term.

[`filter_undergrad()`](https://midfieldr.github.io/midfieldr/reference/filter_undergrad.md)
distinguishes post-baccalaureate terms from undergraduate terms and
retains the undergraduate terms. Here we filter the `term` table and
count the rows before and after the operation.

``` r

nrow(term)
#> [1] 639915
x <- filter_undergrad(term, midf_table = degree)
nrow(x)
#> [1] 632917
```

The optional `add_bacc_term` argument adds the baccalaureate term to the
data frame if you want verify the result; test for yourself that only
terms predating the degree are retained. The results match those above.

``` r

y <- filter_undergrad(term, add_bacc_term = TRUE)
y <- y[, .(mcid, term, bacc_term)][order(bacc_term)]
y
#>                   mcid   term bacc_term
#>                 <char> <char>    <char>
#>      1: MCID3111142225  19881     19881
#>      2: MCID3111143056  19881     19881
#>      3: MCID3111142729  19881     19883
#>     ---                                
#> 639913: MCID3112898894  20181      <NA>
#> 639914: MCID3112898895  20181      <NA>
#> 639915: MCID3112898940  20181      <NA>

# Filter and compare to previous result
y <- y[bacc_term >= term | is.na(bacc_term)]
check_equiv_frames(x[, .(mcid, term)], y[, .(mcid, term)])
#> [1] TRUE
```

The principal data frame is any of the data tables having a term-value
variable. In all cases, the term of the student’s first degree is pulled
from the `degree` table.

``` r

term <- filter_undergrad(term)
course <- filter_undergrad(course)
degree <- filter_undergrad(degree)
```

## Blocs

A *bloc* is a grouping of student-level data dealt with as a unit, for
example, administrative groupings such as transfer students and
traditional or non-traditional students, as well as program-based
groupings such as students starting in, ever-enrolling in, migrating
into or out of, or graduating from a program.

Relevant functions:

- [`filter_programs()`](https://midfieldr.github.io/midfieldr/reference/filter_programs.md)
- [`completion_status()`](https://midfieldr.github.io/midfieldr/reference/completion_status.md)

### filter_programs()

Contributes to assembling a bloc of programs.

*Programs* are academic fields of study—specialties within a field or a
collection of fields within a Department, College, or University—encoded
in the `cip` dataset.

[`filter_programs()`](https://midfieldr.github.io/midfieldr/reference/filter_programs.md)
acts on a CIP data frame to choose rows that match or partially match
search strings. Search strings are case-independent. For example, to
search for music programs, we might start with,

``` r

filter_programs(cip, "music")
#>                                      cip6name   cip6
#>                                        <char> <char>
#>  1:                   Music Teacher Education 131312
#>  2:                                     Music 360115
#>  3:                   Religious, Sacred Music 390501
#>  4: Musical Instrument Fabrication and Repair 470404
#>  5:                              Digital Arts 500102
#>  6:                           Musical Theatre 500509
#>  7:                            Music, General 500901
#>  8:      Music History, Literature and Theory 500902
#> ---                                                 
#> 18:                            Music Pedagogy 500912
#> 19:                          Music Technology 500913
#> 20:                         Brass Instruments 500914
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
#>  6:                                     Drama, Theatre Arts and Stagecraft
#>  7:                                                                  Music
#>  8:                                                                  Music
#> ---                                                                       
#> 18:                                                                  Music
#> 19:                                                                  Music
#> 20:                                                                  Music
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
#>  6:   5005                       Visual and Performing Arts     50
#>  7:   5009                       Visual and Performing Arts     50
#>  8:   5009                       Visual and Performing Arts     50
#> ---                                                               
#> 18:   5009                       Visual and Performing Arts     50
#> 19:   5009                       Visual and Performing Arts     50
#> 20:   5009                       Visual and Performing Arts     50
#> 21:   5009                       Visual and Performing Arts     50
#> 22:   5009                       Visual and Performing Arts     50
#> 23:   5009                       Visual and Performing Arts     50
#> 24:   5010                       Visual and Performing Arts     50
#> 25:   5123 Health Professions and Related Clinical Sciences     51
```

For music as a component of the Visual and Performing Arts, we filter
`cip` again using a regular expression. We can also select specific
columns for a more compact display.

``` r

filter_programs(cip, "^5009")[, .(cip6name, cip6, cip4name)]
#>                                                 cip6name   cip6 cip4name
#>                                                   <char> <char>   <char>
#>  1:                                       Music, General 500901    Music
#>  2:                 Music History, Literature and Theory 500902    Music
#>  3:                           Music Performance, General 500903    Music
#>  4:                         Music Theory and Composition 500904    Music
#>  5:                       Musicology and Ethnomusicology 500905    Music
#>  6:                                           Conducting 500906    Music
#>  7:                                      Piano and Organ 500907    Music
#>  8:                                      Voice and Opera 500908    Music
#>  9:                   Music Management and Merchandising 500909    Music
#> 10:                                   Jazz, Jazz Studies 500910    Music
#> 11: Violin, Viola, Guitar and Other Stringed Instruments 500911    Music
#> 12:                                       Music Pedagogy 500912    Music
#> 13:                                     Music Technology 500913    Music
#> 14:                                    Brass Instruments 500914    Music
#> 15:                                 Woodwind Instruments 500915    Music
#> 16:                               Percussion Instruments 500916    Music
#> 17:                                         Music, Other 500999    Music
```

The `negate` argument allows you to drop the rows that match the search
patterns.

``` r

x <- filter_programs(cip, "^5009")[, .(cip6name, cip6, cip4name)]
filter_programs(x, c("Other", "General"), negate = TRUE)
#>                                 cip6name   cip6 cip4name
#>                                   <char> <char>   <char>
#>  1: Music History, Literature and Theory 500902    Music
#>  2:         Music Theory and Composition 500904    Music
#>  3:       Musicology and Ethnomusicology 500905    Music
#>  4:                           Conducting 500906    Music
#>  5:                      Piano and Organ 500907    Music
#>  6:                      Voice and Opera 500908    Music
#>  7:   Music Management and Merchandising 500909    Music
#>  8:                   Jazz, Jazz Studies 500910    Music
#>  9:                       Music Pedagogy 500912    Music
#> 10:                     Music Technology 500913    Music
#> 11:                    Brass Instruments 500914    Music
#> 12:                 Woodwind Instruments 500915    Music
#> 13:               Percussion Instruments 500916    Music
```

In a study, we would continue in a similar fashion until we had merged
all the 6-digit codes we needed into one data frame.

### completion_status()

Contributes to assembling a bloc of graduates.

*Completion status* is “timely” for students graduating no later than
their timely-completion term; “late” or “NA” otherwise. Only records
satisfying data sufficiency can be processed for completion status.

[`completion_status()`](https://midfieldr.github.io/midfieldr/reference/completion_status.md)
yields a status label for each student. The principal data frame must
include the variables `{mcid, timely_term}.` The first degree term is
pulled from the `degree` table. The data frame is returned with the
following variables added:

| variable     | description                                     |
|--------------|-------------------------------------------------|
| `bacc_term`  | term of a student's first baccalaureate         |
| `completion` | indicates whether status is timely, late, or NA |

``` r

# setup
DT <- student[, .(mcid)]
DT <- timely_term(DT)
DT <- data_sufficiency(DT)
DT <- DT[sufficiency == "satisfied"]
DT <- DT[, .(mcid, timely_term)]

# apply
DT <- completion_status(DT)

# result
DT[order(-completion)]
#>                  mcid timely_term bacc_term completion
#>                <char>      <char>    <char>     <char>
#>     1: MCID3111142689       19941     19913     timely
#>     2: MCID3111142782       19941     19903     timely
#>     3: MCID3111142881       19951     19894     timely
#>    ---                                                
#> 76919: MCID3112785480       20123      <NA>       <NA>
#> 76920: MCID3112800920       20153      <NA>       <NA>
#> 76921: MCID3112870009       20003      <NA>       <NA>
```

When we want of bloc of timely graduates, we filter to retain rows with
completion “timely.”

## Commonalities

You may have noticed similarities in several of the midfieldr functions.
For example, in these functions,

- `timely_term(dframe, midf_table = term)`
- `data_sufficiency(dframe, midf_table = term)`
- `filter_undergrad(dframe, midf_table = degree)`
- `completion status(dframe, midf_table = degree)`

the similarities include:

- The first argument is a data frame.
- The second argument is one of the MIDFIELD data tables.
- The result is a new data frame with columns added that support the
  main finding.
- You can use the main finding to subset the result by rows.

Moreover, because in each case the `midf_table` argument has a default
value, it can be assigned explicitly or not. For example, the three
formulations below all yield the same result.

``` r

# setup
DT <- student[, .(mcid)]

# equivalent statements
x <- timely_term(dframe = DT, midf_table = term)
y <- timely_term(DT, term)
z <- timely_term(DT)

# equivalent results
check_equiv_frames(x, y)
#> [1] TRUE
check_equiv_frames(x, z)
#> [1] TRUE
```

Of other functions used earlier,

- [`filter_programs()`](https://midfieldr.github.io/midfieldr/reference/filter_programs.md)
- [`select_basic_cols()`](https://midfieldr.github.io/midfieldr/reference/select_basic_cols.md)

have in common that:

- The first argument is a data frame.
- The result is a new data frame, a subset of the input: “filter”
  chooses rows; “select” chooses columns.

## Special conditioning

Relevant functions:

- [`initialize_fye_proxies()`](https://midfieldr.github.io/midfieldr/reference/initialize_fye_proxies.md)
- [`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)

### initialize_fye_proxies()

Contributes to assembling a bloc of starters.

At some U.S. institutions, completing a *First-Year Engineering (FYE)*
program is a prerequisite for admission to specific engineering majors.
FYE programs complicate the identification of *starters* because these
students’ preferred starting majors are unknown.

[`initialize_fye_proxies()`](https://midfieldr.github.io/midfieldr/reference/initialize_fye_proxies.md)
constructs a data frame with the IDs of all FYE students with an initial
*FYE proxy,* the 6-digit CIP code of their first specific engineering
major, if any, or NA if not.

``` r

initialize_fye_proxies(student, term)
#>                 mcid   institution          race    sex  proxy
#>               <char>        <fctr>        <fctr> <fctr> <fctr>
#>    1: MCID3111142290 Institution J         Asian   Male 141001
#>    2: MCID3111142294 Institution J         Asian   Male 141001
#>    3: MCID3111142961 Institution J International   Male 142101
#>    4: MCID3111142965 Institution J International   Male 141001
#>    5: MCID3111143894 Institution J         White Female 140701
#>   ---                                                         
#> 5785: MCID3112447650 Institution J         White   Male   <NA>
#> 5786: MCID3112447657 Institution J         White   Male   <NA>
#> 5787: MCID3112447659 Institution J         White   Male   <NA>
#> 5788: MCID3112447663 Institution J         White   Male   <NA>
#> 5789: MCID3112447664 Institution J         White   Male   <NA>
```

The NAs are ultimately treated as missing data that are replaced by
imputed CIP codes. If FYE programs are involved in your study,

- [FYE
  proxies](https://midfieldr.github.io/midfieldr/articles/art-060-fye-proxies.md)
  describes the inner workings of the function and how to process the
  results using the R mice package for multiple imputation.
- [Starters](https://midfieldr.github.io/midfieldr/articles/art-070-starters.md)
  describes how FYE proxies are incorporated in a starter bloc.

### order_multiway()

Conditions data for Cleveland multiway charts.

*Multiway data* comprise two independent categorical variables and one
quantitative variable with a value for each combination of levels of the
two categories.

[`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)
converts the categorical variables to factors ordered by the
quantitative variable. This ordering determines the order of the panels
and rows in a multiway chart, crucial to our ability to perceive
effects.

In this example, we use the `case_results` multiway data that loads with
midfieldr. The two categories are `program` and `people`. The quantity
is `stick` (program stickiness) which is the ratio of `grad` (number of
program graduates) to `ever` (number ever enrolled in the program).

``` r

case_results
#>        program               people  ever  grad stick
#>         <char>               <char> <num> <num> <num>
#>  1:      Civil         Asian Female    14    10  71.4
#>  2:      Civil           Asian Male    33    25  75.8
#>  3:      Civil           Black Male     8     5  62.5
#>  4:      Civil      Hispanic Female    13     6  46.2
#>  5:      Civil        Hispanic Male    66    31  47.0
#> ---                                                  
#> 39: Mechanical   International Male   176    89  50.6
#> 40: Mechanical Other/Unknown Female     8     4  50.0
#> 41: Mechanical   Other/Unknown Male    81    41  50.6
#> 42: Mechanical         White Female   213   134  62.9
#> 43: Mechanical           White Male  1587   952  60.0
```

In the data frame returned, the factor levels are ordered by the
aggregate stickiness calculated separately by category and reported in
the new columns (suffix `_metric`). A multiway chart can be constructed
from the data in this form.

``` r

DT <- order_multiway(case_results,
  quantity = "stick",
  categories = c("program", "people"),
  method = "percent",
  ratio_of = c("grad", "ever")
)
DT[, c("grad", "ever") := NULL]
DT
#>        program               people stick program_metric people_metric
#>         <fctr>               <fctr> <num>          <num>         <num>
#>  1:      Civil         Asian Female  71.4           62.4          64.0
#>  2:      Civil           Asian Male  75.8           62.4          62.8
#>  3:      Civil           Black Male  62.5           62.4          62.7
#>  4:      Civil      Hispanic Female  46.2           62.4          51.5
#>  5:      Civil        Hispanic Male  47.0           62.4          48.5
#> ---                                                                   
#> 39: Mechanical   International Male  50.6           59.2          50.2
#> 40: Mechanical Other/Unknown Female  50.0           59.2          50.0
#> 41: Mechanical   Other/Unknown Male  50.6           59.2          45.6
#> 42: Mechanical         White Female  62.9           59.2          61.1
#> 43: Mechanical           White Male  60.0           59.2          59.9
```

Complete information on using
[`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)
and constructing multiway charts can be found in [Multiway data and
charts](https://midfieldr.github.io/midfieldr/articles/art-120-multiway.md).

## Utilities

See the relevant help page for more information,
e.g. [`?catch_error`](https://midfieldr.github.io/midfieldr/reference/catch_error.md).

- [`catch_error()`](https://midfieldr.github.io/midfieldr/reference/catch_error.md)
  wraps base [`tryCatch()`](https://rdrr.io/r/base/conditions.html) for
  errors with preset arguments.
- [`check_equiv_frames()`](https://winvector.github.io/wrapr//reference/check_equiv_frames.html)
  re-exported from the wrapr package.
- [`look_at()`](https://midfieldr.github.io/midfieldr/reference/look_at.md)
  for data frames, wraps base
  [`str()`](https://rdrr.io/r/utils/str.html) with preset arguments.
- [`rm_redundant_cols()`](https://midfieldr.github.io/midfieldr/reference/rm_redundant_cols.md)
  primarily used internally to drop duplicate columns.
- [`sort_uniq()`](https://midfieldr.github.io/midfieldr/reference/sort_uniq.md)
  for vectors, wraps base `sort(unique())` with preset arguments.

## References

NCES. 2010. *IPEDS Classification of Instructional Programs (CIP)*.
National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>.
