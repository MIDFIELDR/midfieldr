# Getting started

Familiarity with the MIDFIELD data structure is a prerequisite for
working with midfieldr functions so we start by inspecting the practice
data in [midfielddata](https://midfieldr.github.io/midfielddata/), a
companion R package that provides anonymized student-level records for
98,000 undergraduates at three US institutions from 1988 through 2018.
(If you haven’t yet installed midfielddata, see the
[Installation](https://midfieldr.github.io/midfieldr/index.html#installation)
instructions.)

The practice data are organized in four datasets keyed by student ID.

| Dataset | Each row is                   | N students | N rows    | N columns | Memory   |
|---------|-------------------------------|------------|-----------|-----------|----------|
| course  | one student per term & course | 97,555     | 3,289,532 | 12        | 324.3 MB |
| term    | one student per term          | 97,555     | 639,915   | 13        | 72.8 MB  |
| student | one student                   | 97,555     | 97,555    | 13        | 17.3 MB  |
| degree  | one student per degree        | 49,543     | 49,665    | 5         | 5.2 MB   |

Table 1. Practice datasets in midfielddata {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

## Definitions

student-level data

:   Data at the “student-level” refers to information about individual
    students including, for example, demographics, programs, academic
    standing, courses, grades, and degrees. Also called Student Unit
    Records (SURs).

:   MIDFIELD student-level data are provided in four data tables
    (`student`, `course`, `term`, and `degree`) that were compiled by
    institutions and anonymized and curated by the MIDFIELD data
    steward.

observation

:   Row of a data frame (`student`, `course`, `term`, `degree`) keyed by
    student ID.

variable

:   Column of a data frame

## Method

In this article:

- Overview of each dataset
- Summary of variables typically encountered when using midfieldr
  functions
- Closer look: For one student, all records in all datasets
- Introduce helper function
  [`select_required()`](https://midfieldr.github.io/midfieldr/reference/select_required.md)
  and wrapr
  [`check_equiv_frames()`](https://winvector.github.io/wrapr//reference/check_equiv_frames.html)

*Reminder.*   midfielddata is suitable for learning to work with
student-level data but not for drawing inferences about program
attributes or student experiences. midfielddata supplies practice data,
not research data.

## Load data

*Start.*   If you are writing your own script to follow along, we use
these packages in this article:

``` r

library(midfieldr)
library(midfielddata)
library(data.table)
```

*Load data tables.*   Data tables can be loaded individually or
collectively as needed. View data dictionaries via
[`?student`](https://midfieldr.github.io/midfielddata/reference/student.html),
[`?course`](https://midfieldr.github.io/midfielddata/reference/course.html),
[`?term`](https://midfieldr.github.io/midfielddata/reference/term.html),
or
[`?degree`](https://midfieldr.github.io/midfielddata/reference/degree.html).

``` r

# Load one table as needed
data(student)

# Or load multiple tables
data(course, term, degree)
```

## `student`

Contains one observation per student. Data are assumed to be current at
the time the student was admitted to their institution.

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

Student IDs and institution names have been anonymized to remove
identifiable information.

``` r

# Anonymized IDs
sample(student$mcid, 8)
#> [1] "MCID3111478315" "MCID3111363338" "MCID3111216590" "MCID3111876789"
#> [5] "MCID3112383444" "MCID3111948721" "MCID3111381575" "MCID3112827958"

# Anonymized institutions
sort(unique(student$institution))
#> [1] "Institution B" "Institution C" "Institution J"
```

Race/ethnicity and sex are often used as grouping variables.

``` r

# Possible values
sort(unique(student$race))
#> [1] "Asian"           "Black"           "Hispanic"        "International"  
#> [5] "Native American" "Other/Unknown"   "White"

# Possible values
sort(unique(student$sex))
#> [1] "Female"  "Male"    "Unknown"
```

Counts in each category.

``` r

# N by institution
student[order(institution), .N, by = "institution"]
#>      institution     N
#>           <char> <int>
#> 1: Institution B 45660
#> 2: Institution C 26712
#> 3: Institution J 25183

# N by race
student[order(race), .N, by = "race"]
#>               race     N
#>             <char> <int>
#> 1:           Asian  4193
#> 2:           Black  1860
#> 3:        Hispanic  5386
#> 4:   International  7354
#> 5: Native American   403
#> 6:   Other/Unknown  4509
#> 7:           White 73850

# N by sex
student[order(sex), .N, by = "sex"]
#>        sex     N
#>     <char> <int>
#> 1:  Female 46403
#> 2:    Male 51151
#> 3: Unknown     1
```

## `course`

Contains one observation per student per course.

``` r

course
#>                    mcid   institution term_course                   course
#>                  <char>        <char>      <char>                   <char>
#>       1: MCID3111142225 Institution B       19881       Microprocessor Lab
#>       2: MCID3111142225 Institution B       19881           Neural Signals
#>       3: MCID3111142225 Institution B       19881      Engineering Economy
#>      ---                                                                  
#> 3289530: MCID3112898940 Institution B       20181     Beginning Japanese 1
#> 3289531: MCID3112898940 Institution B       20181  Precalculus Mathematics
#> 3289532: MCID3112898940 Institution B       20181 Deviance In U S  Society
#>          abbrev number section         type faculty_rank hours_course  grade
#>          <char> <char>  <char>       <char>       <char>        <num> <char>
#>       1:   ECEN   2230     005         <NA>         <NA>            1      C
#>       2:   ECEN   4811     001         <NA>         <NA>            3      C
#>       3:   MCEN   4147     001         <NA>         <NA>            3     B+
#>      ---                                                                    
#> 3289530:   JPNS   1010     009 Face-to-Face     Lecturer            5      C
#> 3289531:   MATH   1150     012 Face-to-Face     Lecturer            4     C-
#> 3289532:   SOCY   1004     100 Face-to-Face   Instructor            3      B
#>                           discipline_midfield
#>                                        <char>
#>       1: Engineering: Electrical and Computer
#>       2: Engineering: Electrical and Computer
#>       3:              Engineering: Mechanical
#>      ---                                     
#> 3289530:    Language and Literature: Japanese
#> 3289531:                          Mathematics
#> 3289532:           Social Sciences: Sociology
```

The `abbrev`, `number`, and `discipline_midfield` columns have no NA
values, so they might be useful if one is filtering for specific course
types. The `course` column, on the other hand, has a high number of NA
values.

``` r

# Many NA values in this column
sum(is.na(course$course))
#> [1] 1003976

# No NA values in these columns.
sum(is.na(course$abbrev))
#> [1] 0
sum(is.na(course$number))
#> [1] 0
sum(is.na(course$discipline_midfield))
#> [1] 0
```

## `term`

Contains one observation per student per term.

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
#>                   standing   coop hours_term hours_term_attempt hours_cumul
#>                     <char> <char>      <num>              <num>       <num>
#>      1:      Good Standing     No          7                  7           7
#>      2: Academic Probation     No          6                  6           6
#>      3: Academic Probation     No         12                 12          18
#>     ---                                                                    
#> 639913:      Good Standing     No         13                 13          13
#> 639914:      Good Standing     No         18                 18          18
#> 639915:      Good Standing     No         15                 15          15
#>         hours_cumul_attempt gpa_term gpa_cumul
#>                       <num>    <num>     <num>
#>      1:                   7     2.56      2.56
#>      2:                   6     1.85      1.85
#>      3:                  18     1.93      1.90
#>     ---                                       
#> 639913:                  13     3.52      3.52
#> 639914:                  18     3.50      3.50
#> 639915:                  15     2.18      2.18
```

Terms are encoded `YYYYT`, where

- `YYYY` is the year at the start of the academic year, and  
- `T` encodes the semester or quarter—Fall (`1`), Winter (`2`), Spring
  (`3`), and Summer (`4`, `5`, and `6`)—within an academic year

For example, for academic year 1995–96,

- `19951` encodes Fall 95–96
- `19953` encodes Spring 95–96
- `19954` encodes Summer 95–96 (first session)

Different institutions supply data over different time spans.

``` r

# Range of data by institution
term[, .(min_term = min(term), max_term = max(term)), by = "institution"]
#>      institution min_term max_term
#>           <char>   <char>   <char>
#> 1: Institution B    19881    20181
#> 2: Institution J    19881    20096
#> 3: Institution C    19901    20154
```

Programs are encoded in the `cip6` variable, a 6-digit character based
on the 2010 Classification of Instructional Programs (CIP) ([NCES
2010](#ref-NCES:2010)).

``` r

# A sample of cip6 values
sort(unique(sample(term$cip6, 8)))
#> [1] "110101" "140102" "240102" "520201" "521401"
```

Student level is used when determining timely completion terms of
transfer students.

``` r

# Possible values
sort(unique(term$level))
#> [1] "01 First-year"      "02 Second-year"     "03 Third-year"     
#> [4] "04 Fourth-year"     "05 Fifth-year Plus"
```

## `degree`

Contains one observation per student per degree.

This dataset contains records for graduates only, thus the number of
observations in `degree` (49,665) is less than the number of
observations in `student` (97,555). The `term_degree` and `cip6`
variables indicate when and from which program a student graduates.

``` r

degree
#>                  mcid   institution term_degree   cip6
#>                <char>        <char>      <char> <char>
#>     1: MCID3111142225 Institution B       19881 141001
#>     2: MCID3111142290 Institution J       19921 141001
#>     3: MCID3111142294 Institution J       19903 141001
#>    ---                                                
#> 49663: MCID3112839623 Institution B       20181 160102
#> 49664: MCID3112845220 Institution B       20181 270101
#> 49665: MCID3112845673 Institution B       20174 090101
#>                                                          degree
#>                                                          <char>
#>     1:            Bachelor of Science in Electrical Engineering
#>     2:            Bachelor of Science in Electrical Engineering
#>     3:            Bachelor of Science in Electrical Engineering
#>    ---                                                         
#> 49663:                       Bachelor of Science in Linguistics
#> 49664:                       Bachelor of Science in Mathematics
#> 49665: Bachelor of Science in Speech Communication and Rhetoric
```

Number of degrees earned per student.

``` r

# Count students by number of degrees
by_id <- degree[, .(degree_count = .N), by = "mcid"]
by_id[, .(N_students = .N), by = "degree_count"]
#>    degree_count N_students
#>           <int>      <int>
#> 1:            1      49421
#> 2:            2        122
```

## Closer look

We display the records for one specific student, using their ID to
subset each dataset.

``` r

# One student ID
id_we_want <- "MCID3112192438"
```

*Student.*   As expected, `student` yields one row per student.

``` r

# Observations for a selected ID
student[mcid == id_we_want]
#>              mcid   institution              transfer hours_transfer   race
#>            <char>        <char>                <char>          <num> <char>
#> 1: MCID3112192438 Institution C First-Time in College             NA  White
#>       sex age_desc us_citizen home_zip high_school sat_math sat_verbal act_comp
#>    <char>   <char>     <char>   <char>      <char>    <num>      <num>    <num>
#> 1: Female Under 25        Yes    80521        <NA>      580        390       27
```

*Course.*   For this student, the records span 47 rows, one row per
course.

``` r

# Observations for a selected ID
course[mcid == id_we_want]
#>               mcid   institution term_course                         course
#>             <char>        <char>      <char>                         <char>
#>  1: MCID3112192438 Institution C       20051 Key Academic Community Seminar
#>  2: MCID3112192438 Institution C       20051       Humans and Other Animals
#>  3: MCID3112192438 Institution C       20051            Health and Wellness
#> ---                                                                        
#> 45: MCID3112192438 Institution C       20093            Health and the Mind
#> 46: MCID3112192438 Institution C       20093   Social Psychology Laboratory
#> 47: MCID3112192438 Institution C       20093                    Group Study
#>     abbrev number section         type              faculty_rank hours_course
#>     <char> <char>  <char>       <char>                    <char>        <num>
#>  1:     KA    192     009         <NA>                Instructor            3
#>  2:   BZCC    101     002         <NA>       Assistant Professor            3
#>  3:   EXCC    145     004         <NA> Non-Academic Professional            3
#> ---                                                                          
#> 45:    PSY    121     001 Face-to-Face Non-Academic Professional            1
#> 46:    PSY    317     L02 Face-to-Face        Graduate Assistant            2
#> 47:    PSY    496     004 Face-to-Face                Instructor            3
#>      grade                        discipline_midfield
#>     <char>                                     <char>
#>  1:      A                           Academic Support
#>  2:      B Biological and Biomedical Sciences: Botany
#>  3:      A           Education: Physical and Coaching
#> ---                                                  
#> 45:     A+                                 Psychology
#> 46:      A                                 Psychology
#> 47:     A+                                 Psychology
```

*Term.*   Here, the records span 10 rows, one row per term.

``` r

# Observations for a selected ID
term[mcid == id_we_want]
#>               mcid   institution   term   cip6              level      standing
#>             <char>        <char> <char> <char>             <char>        <char>
#>  1: MCID3112192438 Institution C  20051 451101      01 First-year Good Standing
#>  2: MCID3112192438 Institution C  20053 190701      01 First-year Good Standing
#>  3: MCID3112192438 Institution C  20061 451101     02 Second-year Good Standing
#>  4: MCID3112192438 Institution C  20063 451101     02 Second-year Good Standing
#>  5: MCID3112192438 Institution C  20071 451101      03 Third-year Good Standing
#>  6: MCID3112192438 Institution C  20073 451101      03 Third-year Good Standing
#>  7: MCID3112192438 Institution C  20081 451101      03 Third-year Good Standing
#>  8: MCID3112192438 Institution C  20083 451101     04 Fourth-year Good Standing
#>  9: MCID3112192438 Institution C  20091 451101     04 Fourth-year Good Standing
#> 10: MCID3112192438 Institution C  20093 451101 05 Fifth-year Plus Good Standing
#>       coop hours_term hours_term_attempt hours_cumul hours_cumul_attempt
#>     <char>      <num>              <num>       <num>               <num>
#>  1:     No         15                 15          15                  15
#>  2:     No         11                 11          26                  26
#>  3:     No         16                 16          42                  42
#>  4:     No          8                  8          50                  50
#>  5:     No         12                 12          62                  62
#>  6:     No         13                 13          75                  75
#>  7:    Yes         14                 14          89                  89
#>  8:     No         16                 16         105                 105
#>  9:     No         13                 13         118                 118
#> 10:     No         12                 12         130                 130
#>     gpa_term gpa_cumul
#>        <num>     <num>
#>  1:     3.80      3.80
#>  2:     3.40      3.63
#>  3:     3.25      3.49
#>  4:     3.81      3.54
#>  5:     3.75      3.58
#>  6:     3.38      3.54
#>  7:     3.79      3.58
#>  8:     3.75      3.61
#>  9:     4.00      3.65
#> 10:     4.00      3.68
```

*Degree.*   In this example, the records span 2 rows, one row per
degree. The degrees were earned in the same term, Spring 2009.

``` r

# Observations for a selected ID
degree[mcid == id_we_want]
#>              mcid   institution term_degree   cip6
#>            <char>        <char>      <char> <char>
#> 1: MCID3112192438 Institution C       20093 420101
#> 2: MCID3112192438 Institution C       20093 451101
#>                               degree
#>                               <char>
#> 1: Bachelor of Science in Psychology
#> 2:     Bachelor of Arts in Sociology
```

Not all students with more than one degree earn them in the same term.
For example, the next student earned a degree in 1996 and a second
degree in 1999. In most analyses, only the first baccalaureate degree
would be used.

``` r

# Observations for a different ID
degree[mcid == "MCID3111315508"]
#>              mcid   institution term_degree   cip6
#>            <char>        <char>      <char> <char>
#> 1: MCID3111315508 Institution C       19961 260101
#> 2: MCID3111315508 Institution C       19994 260701
#>                                        degree
#>                                        <char>
#> 1: Bachelor of Science in Biological Sciences
#> 2:      Bachelor of Science in Animal Biology
```

## `select_required()`

A midfieldr convenience function to reduce the number of columns of a
MIDFIELD data table after loading. Using this function is optional.

[`select_required()`](https://midfieldr.github.io/midfieldr/reference/select_required.md)
selects only those columns typically required by other midfieldr
functions. Operates on a data frame to retain columns having names that
match or partially match search terms. Rows are unaffected.

The primary benefit is reducing screen clutter when viewing data frames
during an interactive session. The disadvantage is that the deleted
columns are unavailable unless you first set aside a copy of the source
file or reload it using [`data()`](https://rdrr.io/r/utils/data.html)
when you need it.

*Arguments.*

- **`midfield_x`**   MIDFIELD data frame, typically `student`, `term`,
  or `degree`.

- **`select_add`**   Optional character vector of search terms to add to
  the default vector given by
  `c("mcid", "institution", "race", "sex", "^term", "cip6", "level")`.
  Argument, if used, must be used by name.

For example, term records are significantly more compact if we select
this minimum set of columns.

``` r

# Select variables required by midfieldr functions
select_required(term)
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

We can add columns if we need them.

``` r

# Select additional columns
select_required(term, select_add = c("gpa_term"))
#>                   mcid   institution   term   cip6         level gpa_term
#>                 <char>        <char> <char> <char>        <char>    <num>
#>      1: MCID3111142225 Institution B  19881 140901 01 First-year     2.56
#>      2: MCID3111142283 Institution J  19881 240102 01 First-year     1.85
#>      3: MCID3111142283 Institution J  19883 240102 01 First-year     1.93
#>     ---                                                                  
#> 639913: MCID3112898894 Institution B  20181 451001 01 First-year     3.52
#> 639914: MCID3112898895 Institution B  20181 302001 01 First-year     3.50
#> 639915: MCID3112898940 Institution B  20181 050103 01 First-year     2.18
```

## `check_equiv_frames()`

A function imported from the wrapr package that confirms two data frames
are equivalent after reordering columns and rows. Accessible by loading
midfieldr.

*Example.*   Demonstrate that the following implementations of
[`select_required()`](https://midfieldr.github.io/midfieldr/reference/select_required.md)
yield identical results.

``` r

# Required argument explicitly named
x <- select_required(midfield_x = term)

# Required argument not named
y <- select_required(term)

# Optional argument, if used, must be named. NULL yields the default columns.
z <- select_required(term, select_add = NULL)

# Demonstrate equivalence
check_equiv_frames(x, y)
#> [1] TRUE
check_equiv_frames(x, z)
#> [1] TRUE
```

Demonstrate that row and column order are ignored.

``` r

# Two columns from student, use key to order rows
x <- student[, .(mcid, institution)]
setkey(x, mcid)
x
#> Key: <mcid>
#>                  mcid   institution
#>                <char>        <char>
#>     1: MCID3111142225 Institution B
#>     2: MCID3111142283 Institution J
#>     3: MCID3111142290 Institution J
#>    ---                             
#> 97553: MCID3112898894 Institution B
#> 97554: MCID3112898895 Institution B
#> 97555: MCID3112898940 Institution B

# Same information with different row order, column order, and key
y <- student[, .(institution, mcid)]
setkey(y, institution)
y
#> Key: <institution>
#>          institution           mcid
#>               <char>         <char>
#>     1: Institution B MCID3111142225
#>     2: Institution B MCID3111142689
#>     3: Institution B MCID3111142729
#>    ---                             
#> 97553: Institution J MCID3112447751
#> 97554: Institution J MCID3112447753
#> 97555: Institution J MCID3112447754

# Demonstrate equivalence
check_equiv_frames(x, y)
#> [1] TRUE
```

If the two data tables do not have the same content, the return is
FALSE.

``` r

# Demonstrate non-equivalence
check_equiv_frames(student, degree)
#> [1] FALSE
```

To explore the differences between non-equivalent data frames,
[`janitor::compare_df_cols()`](https://sfirke.github.io/janitor/reference/compare_df_cols.html)
returns a comparison of column names and class.

``` r

library("janitor")
compare_df_cols(student, degree)
#>       column_name   student    degree
#> 1        act_comp   numeric      <NA>
#> 2        age_desc character      <NA>
#> 3            cip6      <NA> character
#> 4          degree      <NA> character
#> 5     high_school character      <NA>
#> 6        home_zip character      <NA>
#> 7  hours_transfer   numeric      <NA>
#> 8     institution character character
#> 9            mcid character character
#> 10           race character      <NA>
#> 11       sat_math   numeric      <NA>
#> 12     sat_verbal   numeric      <NA>
#> 13            sex character      <NA>
#> 14    term_degree      <NA> character
#> 15       transfer character      <NA>
#> 16     us_citizen character      <NA>
```

## Reusable code

*Preparation.*   The immediate prerequisites or “intake” required by the
reusable code chunk are the source data tables.

``` r

# Load source data
data(student, term, degree)
```

*Initial data processing.*   A summary code chunk for ready reference.

``` r

# Optional. Copy of source files with all variables
source_student <- copy(student)
source_term <- copy(term)
source_degree <- copy(degree)

# Optional. Select variables required by midfieldr functions
student <- select_required(source_student)
term <- select_required(source_term)
degree <- select_required(source_degree)
```

The [`copy()`](https://rdrr.io/pkg/data.table/man/copy.html) function
ensures that “by-reference” changes to `student`, for example, have no
effect on `source_student` ([Dowle and Srinivasan
2022](#ref-data.table-reference-semantics)). Thus the `source_*` objects
retain all the original columns, if needed later.

## References

Dowle, Matt, and Arun Srinivasan. 2022. *Reference semantics
\[data.table\]*.
<https://rdatatable.gitlab.io/data.table/articles/datatable-reference-semantics.html>.

NCES. 2010. *IPEDS Classification of Instructional Programs (CIP)*.
National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>.
