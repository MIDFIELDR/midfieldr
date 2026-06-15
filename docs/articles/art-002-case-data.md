# Case study part 2: Data

Our data processing goal is to reduce the source data tables to the
specific observations needed to compute our metrics. The data processing
tasks include filtering observations, creating, renaming, and recoding
variables, and joining data frames.

The analysis is organized to produce two data frames—students ever
enrolled in the programs and students graduating from the programs—that
are joined and written to file as a starting point for developing the
results.

*Reminder.*   midfielddata is for practice, not research.

## Load data

*Start.*   If you are writing your own script to follow along, we use
these packages in this article:

``` r

library(midfieldr)
library(midfielddata)
library(data.table)
```

*Load.*   Practice datasets. View data dictionaries via
[`?student`](https://midfieldr.github.io/midfielddata/reference/student.html),
[`?term`](https://midfieldr.github.io/midfielddata/reference/term.html),
[`?degree`](https://midfieldr.github.io/midfielddata/reference/degree.html).

``` r

# Load practice data
data(student, term, degree)
```

## Initial processing

*Select (optional).*   Reduce the number of columns to the minimum
needed by the midfieldr functions.

``` r

# Work with required midfieldr variables only
student <- select_basic_cols(student)
term <- select_basic_cols(term)
degree <- select_basic_cols(degree)
```

*Initialize.*   Assign a working data frame. We often start with the
`term` dataset.

``` r

# Working data frame
DT <- copy(term)
DT
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

The result has 639,915 observations. In the case study, we will
typically note the number of observations as they change.

## Filter for data sufficiency

Some student records near the lower and upper terms that bound the
available data must be excluded to prevent false summaries involving
timely degree completion. To apply this filter, we first determine the
timely completion term.

- timely completion term:

  The last term in which a student’s degree completion would be
  considered timely. In many cases the timely completion (TC) term is 6
  years after admission. The TC term can be adjusted to account for
  transfer credits. (Currently, there is no mechanism for extending the
  TC term for co-ops or migrators.)

*Add variables.*   Using information in `term`, we add the `timely_term`
variable as well as supporting variables used in its construction.

``` r

# Determine a timely completion term for every student
DT <- add_timely_term(DT, term)
DT
#>                   mcid   institution   term   cip6         level term_i
#>                 <char>        <char> <char> <char>        <char> <char>
#>      1: MCID3111142225 Institution B  19881 140901 01 First-year  19881
#>      2: MCID3111142283 Institution J  19881 240102 01 First-year  19881
#>      3: MCID3111142283 Institution J  19883 240102 01 First-year  19881
#>     ---                                                                
#> 639913: MCID3112898894 Institution B  20181 451001 01 First-year  20181
#> 639914: MCID3112898895 Institution B  20181 302001 01 First-year  20181
#> 639915: MCID3112898940 Institution B  20181 050103 01 First-year  20181
#>               level_i adj_span timely_term
#>                <char>    <num>      <char>
#>      1: 01 First-year        6       19933
#>      2: 01 First-year        6       19933
#>      3: 01 First-year        6       19933
#>     ---                                   
#> 639913: 01 First-year        6       20233
#> 639914: 01 First-year        6       20233
#> 639915: 01 First-year        6       20233
```

*Add variables.*   Using information in `term`, we add the
`data_sufficiency` variable as well as supporting variables used in its
construction.

``` r

# Determine data sufficiency for every student
DT <- add_data_sufficiency(DT, term)
DT
#>                   mcid   institution   term   cip6         level       level_i
#>                 <char>        <char> <char> <char>        <char>        <char>
#>      1: MCID3111142225 Institution B  19881 140901 01 First-year 01 First-year
#>      2: MCID3111142283 Institution J  19881 240102 01 First-year 01 First-year
#>      3: MCID3111142283 Institution J  19883 240102 01 First-year 01 First-year
#>     ---                                                                       
#> 639913: MCID3112898894 Institution B  20181 451001 01 First-year 01 First-year
#> 639914: MCID3112898895 Institution B  20181 302001 01 First-year 01 First-year
#> 639915: MCID3112898940 Institution B  20181 050103 01 First-year 01 First-year
#>         adj_span timely_term term_i lower_limit upper_limit data_sufficiency
#>            <num>      <char> <char>      <char>      <char>           <char>
#>      1:        6       19933  19881       19881       20181    exclude-lower
#>      2:        6       19933  19881       19881       20096    exclude-lower
#>      3:        6       19933  19881       19881       20096    exclude-lower
#>     ---                                                                     
#> 639913:        6       20233  20181       19881       20181    exclude-upper
#> 639914:        6       20233  20181       19881       20181    exclude-upper
#> 639915:        6       20233  20181       19881       20181    exclude-upper
```

- data sufficiency criterion:

  Student records are limited to those for which available data are
  sufficient to assess timely completion without biased counts of
  completers or non-completers.

*Filter.* We filter to retain observations for which the data are
sufficient then drop all but the ID variable.

``` r

# Retain observations having sufficient data
DT <- DT[data_sufficiency == "include"]
DT <- DT[, .(mcid)]
DT <- unique(DT)
DT
#>                  mcid
#>                <char>
#>     1: MCID3111142689
#>     2: MCID3111142782
#>     3: MCID3111142881
#>    ---               
#> 76873: MCID3112785480
#> 76874: MCID3112800920
#> 76875: MCID3112870009
```

The result has 76,875 observations.

## Filter for degree seeking

- inner join:

  A merge operation between two data frames `X` and `Y` that returns
  observations (rows) that match specified conditions in both. The
  data.table syntax is `Y[X, j, on]` where `j` can be used to select
  columns.

*Filter.*   Use an inner join with `student` to retain degree-seeking
students only. Select the ID column.

``` r

# Filter for degree seeking, output unique IDs
DT <- student[DT, .(mcid), on = c("mcid"), nomatch = NULL]
DT <- unique(DT)
DT
#>                  mcid
#>                <char>
#>     1: MCID3111142689
#>     2: MCID3111142782
#>     3: MCID3111142881
#>    ---               
#> 76873: MCID3112785480
#> 76874: MCID3112800920
#> 76875: MCID3112870009
```

The result has 76,875 observations. (No change is expected in this
example because all students in the midfielddata practice data are
degree-seeking.) We preserve this data frame as a baseline set of IDs to
be used again.

``` r

baseline <- copy(DT)
```

*Verify prepared data.*   `baseline_mcid`, included with midfieldr,
contains the case study information developed above. Here we verify that
the two data frames have the same content.

``` r

# Demonstrate equivalence
check_equiv_frames(DT, baseline_mcid)
#> [1] TRUE
```

## Identify programs

In MIDFIELD datasets, the `cip6` variable identifies the 6-digit code
for the program in which a student is enrolled in a given term.

- CIP:

  *Classification of Instructional Programs*, a taxonomy of academic
  programs curated by the US Department of Education ([NCES
  2010](#ref-NCES:2010)). The 2010 codes are included with midfieldr in
  the data set `cip`.

We have already searched `cip` to obtain the codes for the four programs
in our case study. The first four digits of the 6-digit CIP codes are:

- Civil Engineering 1408
- Electrical Engineering 1410
- Mechanical Engineering 1419  
- Industrial/Systems Engineering 1427, 1435, 1436, and 1437.

From `cip`, we obtain all codes that start with any of the selected
4-digit codes.

``` r

# Four engineering programs using 4-digit CIP codes
selected_programs <- filter_cip(c("^1408", "^1410", "^1419", "^1427", "^1435", "^1436", "^1437"))
selected_programs
#>                       cip6name   cip6                  cip4name   cip4
#>                         <char> <char>                    <char> <char>
#>  1: Civil Engineering, General 140801         Civil Engineering   1408
#>  2:   Geotechnical Engineering 140802         Civil Engineering   1408
#>  3:     Structural Engineering 140803         Civil Engineering   1408
#> ---                                                                   
#> 13:     Industrial Engineering 143501    Industrial Engineering   1435
#> 14:  Manufacturing Engineering 143601 Manufacturing Engineering   1436
#> 15:        Operations Research 143701       Operations Research   1437
#>        cip2name   cip2
#>          <char> <char>
#>  1: Engineering     14
#>  2: Engineering     14
#>  3: Engineering     14
#> ---                   
#> 13: Engineering     14
#> 14: Engineering     14
#> 15: Engineering     14
```

*Add a variable.*   User-defined program names are nearly always
required. Add a variable to label each of these 15 programs with one of
the four conventional program abbreviations we will use in comparing
metrics, i.e., Civil (CE), Electrical (EE), Mechanical (ME), and
Industrial/Systems Engineering (ISE).

``` r

# Recode program labels. Edit as required.
selected_programs[, program := fcase(
  cip6 %like% "^1408", "CE",
  cip6 %like% "^1410", "EE",
  cip6 %like% "^1419", "ME",
  cip6 %chin% c("142701", "143501", "143601", "143701"), "ISE"
)]
```

Confirm that the abbreviations match the original 4-digit CIP names. We
also illustrate using [`options()`](https://rdrr.io/r/base/options.html)
to change the number of data.table rows to print.

``` r

# Preserve settings
op <- options()
# Edit number of rows to print
options(datatable.print.nrows = 15)

# Confirm that abbreviations match the longer program names
selected_programs[, .(cip4name, program)]
#>                                                   cip4name program
#>                                                     <char>  <char>
#>  1:                                      Civil Engineering      CE
#>  2:                                      Civil Engineering      CE
#>  3:                                      Civil Engineering      CE
#>  4:                                      Civil Engineering      CE
#>  5:                                      Civil Engineering      CE
#>  6:                                      Civil Engineering      CE
#>  7: Electrical, Electronics and Communications Engineering      EE
#>  8: Electrical, Electronics and Communications Engineering      EE
#>  9: Electrical, Electronics and Communications Engineering      EE
#> 10: Electrical, Electronics and Communications Engineering      EE
#> 11:                                 Mechanical Engineering      ME
#> 12:                                    Systems Engineering     ISE
#> 13:                                 Industrial Engineering     ISE
#> 14:                              Manufacturing Engineering     ISE
#> 15:                                    Operations Research     ISE
```

Having checked that the new abbreviations correctly represent the
programs, we can finalize the data frame of program CIPs and names.

``` r

selected_programs <- selected_programs[, .(cip6, program)]
selected_programs
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

# Restore original settings
options(op)
```

*Verify prepared data.*   `study_programs`, included with midfieldr,
contains the case study information developed above. Here we verify that
the two data frames have the same content.

``` r

# Demonstrate equivalence
check_equiv_frames(selected_programs, study_programs)
#> [1] TRUE
```

## Gather ever-enrolled

*Reset*   The data frame of baseline IDs is the intake for this section.

``` r

# IDs of data-sufficient, degree-seeking students
DT <- copy(baseline)
DT
#>                  mcid
#>                <char>
#>     1: MCID3111142689
#>     2: MCID3111142782
#>     3: MCID3111142881
#>    ---               
#> 76873: MCID3112785480
#> 76874: MCID3112800920
#> 76875: MCID3112870009
```

The result has 76,875 observations.

- left join:

  A merge operation between two data frames `X` and `Y` which returns
  all observations (rows) of `X` and all matching rows in `Y`. The
  data.table syntax is `Y[X, j, on]` where `j` can be used to select
  columns.

*Left join (add a variable).*   Returns all rows from `DT` and rows from
`term` that match on `mcid`—in effect, adding the `cip6` variable to
`DT`. Additionally, because `term` contains multiple rows per ID, the
merged data frame also has the possibility of multiple rows per ID.

``` r

# Left-outer join from term to DT
DT <- term[DT, .(mcid, cip6), on = c("mcid")]
DT <- unique(DT)
DT
#>                   mcid   cip6
#>                 <char> <char>
#>      1: MCID3111142689 090401
#>      2: MCID3111142782 260101
#>      3: MCID3111142881 450601
#>     ---                      
#> 127347: MCID3112800920 240102
#> 127348: MCID3112800920 240199
#> 127349: MCID3112870009 240102
```

The result has 127,349 observations.

*Inner join (add a variable, filter observations).*   Returns rows in
`DT` and `study_programs` that match on `cip6`. In effect, we add a
column of program labels to `DT` and simultaneously filter `DT` to
retain rows that match the four case study programs only.

``` r

# Join program names and retain desired programs only
DT <- study_programs[DT, on = c("cip6"), nomatch = NULL]
DT
#>         cip6 program           mcid
#>       <char>  <char>         <char>
#>    1: 141001      EE MCID3111142965
#>    2: 141001      EE MCID3111145102
#>    3: 141001      EE MCID3111146537
#>   ---                              
#> 5655: 141901      ME MCID3112641399
#> 5656: 141901      ME MCID3112641535
#> 5657: 141901      ME MCID3112698681
```

The result has 5657 observations.

*Filter.*   Because students can change CIP codes but remain within the
same labeled group (e.g., ISE), we drop the `cip6` code and filter for
unique combinations of ID and program label.

``` r

# Filter for unique ID-program combinations
DT[, cip6 := NULL]
DT <- unique(DT)
DT
#>       program           mcid
#>        <char>         <char>
#>    1:      EE MCID3111142965
#>    2:      EE MCID3111145102
#>    3:      EE MCID3111146537
#>   ---                       
#> 5651:      ME MCID3112641399
#> 5652:      ME MCID3112641535
#> 5653:      ME MCID3112698681
```

The result has 5653 observations.

*Copy.*   Set aside the ever enrolled information under a new name to
use later for joining with graduates.

``` r

# Prepare for joining
setcolorder(DT, c("mcid", "program"))
ever_enrolled <- copy(DT)
ever_enrolled
#>                 mcid program
#>               <char>  <char>
#>    1: MCID3111142965      EE
#>    2: MCID3111145102      EE
#>    3: MCID3111146537      EE
#>   ---                       
#> 5651: MCID3112641399      ME
#> 5652: MCID3112641535      ME
#> 5653: MCID3112698681      ME
```

## Gather graduates

*Reset*   The data frame of baseline IDs is the intake for this section.
As before, the result has 76,875 observations.

``` r

# IDs of data-sufficient, degree-seeking students
DT <- copy(baseline)
DT
#>                  mcid
#>                <char>
#>     1: MCID3111142689
#>     2: MCID3111142782
#>     3: MCID3111142881
#>    ---               
#> 76873: MCID3112785480
#> 76874: MCID3112800920
#> 76875: MCID3112870009
```

*Add variables.*   We use `term` to again add the `timely_term` variable
and its supporting variables.

``` r

# Add timely completion term
DT <- add_timely_term(DT, term)
DT
#>                  mcid term_i       level_i adj_span timely_term
#>                <char> <char>        <char>    <num>      <char>
#>     1: MCID3111142689  19883 01 First-year        6       19941
#>     2: MCID3111142782  19883 01 First-year        6       19941
#>     3: MCID3111142881  19893 01 First-year        6       19951
#>    ---                                                         
#> 76873: MCID3112785480  20071 01 First-year        6       20123
#> 76874: MCID3112800920  20101 01 First-year        6       20153
#> 76875: MCID3112870009  19951 01 First-year        6       20003
```

*Add variables.*   We use `degree` to add the `completion_status`
variable and its supporting variables.

``` r

# Add completion status
DT <- add_completion_status(DT, degree)
DT
#>                  mcid term_i       level_i adj_span timely_term term_degree
#>                <char> <char>        <char>    <num>      <char>      <char>
#>     1: MCID3111142689  19883 01 First-year        6       19941       19913
#>     2: MCID3111142782  19883 01 First-year        6       19941       19903
#>     3: MCID3111142881  19893 01 First-year        6       19951       19894
#>    ---                                                                     
#> 76873: MCID3112785480  20071 01 First-year        6       20123        <NA>
#> 76874: MCID3112800920  20101 01 First-year        6       20153        <NA>
#> 76875: MCID3112870009  19951 01 First-year        6       20003        <NA>
#>        completion_status
#>                   <char>
#>     1:            timely
#>     2:            timely
#>     3:            timely
#>    ---                  
#> 76873:              <NA>
#> 76874:              <NA>
#> 76875:              <NA>
```

- timely completion criterion:

  Completing a program in no more than a specified span of years, in
  many cases, within 6 years after admission (150% of the “normal”
  4-year span), or possibly less for some transfer students.

*Filter.*   Retain observations of timely completers only. Drop
unnecessary variables.

``` r

# Retain timely completers
DT <- DT[completion_status == "timely"]
DT <- DT[, .(mcid)]
DT
#>                  mcid
#>                <char>
#>     1: MCID3111142689
#>     2: MCID3111142782
#>     3: MCID3111142881
#>    ---               
#> 40438: MCID3112692944
#> 40439: MCID3112694738
#> 40440: MCID3112730841
```

The result has 40,440 observations.

*Left join (add variables).*   We use a left-join with `degree` to add
the CIP codes and terms of the degrees earned.

``` r

DT <- degree[DT, .(mcid, term_degree, cip6), on = c("mcid")]
DT
#>                  mcid term_degree   cip6
#>                <char>      <char> <char>
#>     1: MCID3111142689       19913 090401
#>     2: MCID3111142782       19903 260101
#>     3: MCID3111142881       19894 450601
#>    ---                                  
#> 40538: MCID3112692944       20153 090101
#> 40539: MCID3112694738       20143 230101
#> 40540: MCID3112730841       20164 040401
```

The result has 40,540 observations.

*Inner join (add a variable, filter observations)*   Again, add a column
of program labels and filter by program.

``` r

# Join programs
DT <- study_programs[DT, on = c("cip6"), nomatch = NULL]
DT
#>         cip6 program           mcid term_degree
#>       <char>  <char>         <char>      <char>
#>    1: 141001      EE MCID3111142965       19901
#>    2: 141001      EE MCID3111145102       19893
#>    3: 141001      EE MCID3111146537       19913
#>   ---                                          
#> 3264: 141901      ME MCID3112618976       20153
#> 3265: 141001      EE MCID3112619484       20133
#> 3266: 141901      ME MCID3112641535       20143
```

The result has 3266 observations.

*Filter.*   Students may have earned multiple degrees in different
terms. We retain degrees earned in their first degree term only.

``` r

DT <- DT[, .SD[term_degree == min(term_degree)], by = "mcid"]
DT
#>                 mcid   cip6 program term_degree
#>               <char> <char>  <char>      <char>
#>    1: MCID3111142965 141001      EE       19901
#>    2: MCID3111145102 141001      EE       19893
#>    3: MCID3111146537 141001      EE       19913
#>   ---                                          
#> 3264: MCID3112618976 141901      ME       20153
#> 3265: MCID3112619484 141001      EE       20133
#> 3266: MCID3112641535 141901      ME       20143
```

The result has 3266 observations.

*Filter.*   Drop unnecessary variables and filter for unique
observations of ID and program label.

``` r

# Filter for unique ID-program combinations
DT[, c("cip6", "term_degree") := NULL]
DT <- unique(DT)
DT
#>                 mcid program
#>               <char>  <char>
#>    1: MCID3111142965      EE
#>    2: MCID3111145102      EE
#>    3: MCID3111146537      EE
#>   ---                       
#> 3264: MCID3112618976      ME
#> 3265: MCID3112619484      EE
#> 3266: MCID3112641535      ME
```

*Copy.*   Set aside the graduates information under a new name to use
for joining with ever enrolled.

``` r

# Prepare for joining
setcolorder(DT, c("mcid", "program"))
graduates <- copy(DT)
graduates
#>                 mcid program
#>               <char>  <char>
#>    1: MCID3111142965      EE
#>    2: MCID3111145102      EE
#>    3: MCID3111146537      EE
#>   ---                       
#> 3264: MCID3112618976      ME
#> 3265: MCID3112619484      EE
#> 3266: MCID3112641535      ME
```

## Add groupings

We plan to group the data by program, bloc, race/ethnicity, and sex.
Program is already present. Bloc labels are added next.

- bloc:

  A grouping of student-level data dealt with as a unit, for example,
  starters, students ever-enrolled, graduates, transfer students,
  traditional and non-traditional students, migrators, etc.

*Add a variable.*   We add a `bloc` variable to the ever enrolled and
graduates data frames before joining.

``` r

ever_enrolled[, bloc := "ever_enrolled"]
graduates[, bloc := "graduates"]
```

*Join.*   Combine the two data frames by rows, binding by matching
column names.

``` r

# Combine two data frames
DT <- rbindlist(list(ever_enrolled, graduates), use.names = TRUE)
DT
#>                 mcid program          bloc
#>               <char>  <char>        <char>
#>    1: MCID3111142965      EE ever_enrolled
#>    2: MCID3111145102      EE ever_enrolled
#>    3: MCID3111146537      EE ever_enrolled
#>   ---                                     
#> 8917: MCID3112618976      ME     graduates
#> 8918: MCID3112619484      EE     graduates
#> 8919: MCID3112641535      ME     graduates
```

The result has 8919 observations.

- grouping variables:

  Detailed information in the student-level data that further
  characterize a bloc of records, typically used to create bloc subsets
  for comparison, for example, program, race/ethnicity, sex, age, grade
  level, grades, etc.

*Add variables.*   Use a left join, matching on `mcid`, to add
race/ethnicity and sex to the data frame.

``` r

# Join race/ethnicity and sex
cols_we_want <- student[, .(mcid, race, sex)]
DT <- cols_we_want[DT, on = c("mcid")]
DT
#>                 mcid          race    sex program          bloc
#>               <char>        <char> <char>  <char>        <char>
#>    1: MCID3111142965 International   Male      EE ever_enrolled
#>    2: MCID3111145102         White   Male      EE ever_enrolled
#>    3: MCID3111146537         Asian Female      EE ever_enrolled
#>   ---                                                          
#> 8917: MCID3112618976         White   Male      ME     graduates
#> 8918: MCID3112619484         White   Male      EE     graduates
#> 8919: MCID3112641535         White   Male      ME     graduates
```

*Verify prepared data.*   `study_observations`, included with midfieldr,
contains the case study information developed above. Here we verify that
the two data frames have the same content.

``` r

# Demonstrate equivalence
check_equiv_frames(DT, study_observations)
#> [1] TRUE
```

In this form, the observations are the starting point for part 3 of the
case study.

## Closer look

We examine the study observations for a few specific students to better
illustrate the structure of these data.

*Example 1.*   This ID yields one observation only. The student was
enrolled in Electrical Engineering but did not complete one of the four
case study programs.

``` r

# Display one student by ID
mcid_we_want <- "MCID3111171519"
DT[mcid == mcid_we_want]
#>              mcid   race    sex program          bloc
#>            <char> <char> <char>  <char>        <char>
#> 1: MCID3111171519  White   Male      EE ever_enrolled
```

A closer look at the student’s `term` record confirms the result: the
student was enrolled in CIP 141001 (Electrical Engineering) but switched
to CIP 110701 (Computer Science). The `degree` record indicates that the
student graduated in Computer Science.

``` r

# Closer look at term
term[mcid == mcid_we_want]
#>              mcid   institution   term   cip6              level
#>            <char>        <char> <char> <char>             <char>
#> 1: MCID3111171519 Institution B  19883 149999     02 Second-year
#> 2: MCID3111171519 Institution B  19891 141001     02 Second-year
#> 3: MCID3111171519 Institution B  19893 141001      03 Third-year
#> 4: MCID3111171519 Institution B  19901 141001      03 Third-year
#> 5: MCID3111171519 Institution B  19903 110701     04 Fourth-year
#> 6: MCID3111171519 Institution B  19913 110701     04 Fourth-year
#> 7: MCID3111171519 Institution B  19921 110701 05 Fifth-year Plus
#> 8: MCID3111171519 Institution B  19923 110701 05 Fifth-year Plus
#> 9: MCID3111171519 Institution B  19924 110701 05 Fifth-year Plus

# Closer look at degree
degree[mcid == mcid_we_want]
#>              mcid   institution term_degree   cip6
#>            <char>        <char>      <char> <char>
#> 1: MCID3111171519 Institution B       19924 110701
```

*Example 2.*   This ID yields two observations indicating that the
student was enrolled in Industrial/Systems Engineering and a timely
graduate of that program.

``` r

# Display one student by ID
mcid_we_want <- "MCID3111150194"
DT[mcid == mcid_we_want]
#>              mcid   race    sex program          bloc
#>            <char> <char> <char>  <char>        <char>
#> 1: MCID3111150194  Black   Male     ISE ever_enrolled
#> 2: MCID3111150194  Black   Male     ISE     graduates
```

The `term` and `degree` excerpts confirm those observations.

``` r

# Closer look at terms
term[mcid == mcid_we_want]
#>              mcid   institution   term   cip6              level
#>            <char>        <char> <char> <char>             <char>
#> 1: MCID3111150194 Institution J  19883 140102      01 First-year
#> 2: MCID3111150194 Institution J  19891 140102     02 Second-year
#> 3: MCID3111150194 Institution J  19893 140102     02 Second-year
#> 4: MCID3111150194 Institution J  19903 143501      03 Third-year
#> 5: MCID3111150194 Institution J  19911 143501     04 Fourth-year
#> 6: MCID3111150194 Institution J  19913 143501     04 Fourth-year
#> 7: MCID3111150194 Institution J  19921 143501 05 Fifth-year Plus
#> 8: MCID3111150194 Institution J  19923 143501 05 Fifth-year Plus

# Closer look at degree
degree[mcid == mcid_we_want]
#>              mcid   institution term_degree   cip6
#>            <char>        <char>      <char> <char>
#> 1: MCID3111150194 Institution J       19923 143501
```

*Example 3.*   This ID yields two observations indicating that the
student was enrolled in Electrical Engineering and in Civil Engineering
but a timely graduate of neither program.

``` r

# Display one student by ID
mcid_we_want <- "MCID3111264877"
DT[mcid == mcid_we_want]
#>              mcid   race    sex program          bloc
#>            <char> <char> <char>  <char>        <char>
#> 1: MCID3111264877  White   Male      EE ever_enrolled
#> 2: MCID3111264877  White   Male      CE ever_enrolled
```

The `term` excerpt agrees; the `degree` record shows they graduated in
CIP 261399 (Biological and Biomedical Sciences).

``` r

# Closer look at term
term[mcid == mcid_we_want]
#>               mcid   institution   term   cip6              level
#>             <char>        <char> <char> <char>             <char>
#>  1: MCID3111264877 Institution B  19901 141001      01 First-year
#>  2: MCID3111264877 Institution B  19903 140201     02 Second-year
#>  3: MCID3111264877 Institution B  19911 140201     02 Second-year
#>  4: MCID3111264877 Institution B  19913 140801      03 Third-year
#>  5: MCID3111264877 Institution B  19914 140801      03 Third-year
#>  6: MCID3111264877 Institution B  19921 240199      03 Third-year
#>  7: MCID3111264877 Institution B  19923 261399     04 Fourth-year
#>  8: MCID3111264877 Institution B  19931 261399     04 Fourth-year
#>  9: MCID3111264877 Institution B  19933 261399 05 Fifth-year Plus
#> 10: MCID3111264877 Institution B  19941 261399 05 Fifth-year Plus

# Closer look at degree
degree[mcid == mcid_we_want]
#>              mcid   institution term_degree   cip6
#>            <char>        <char>      <char> <char>
#> 1: MCID3111264877 Institution B       19941 261399
```

*Example 4.*   This ID yields four observations indicating that the
student was enrolled in Civil, Electrical, and Mechanical Engineering
and a timely graduate of Mechanical.

``` r

# Display one student by ID
mcid_we_want <- "MCID3112470255"
DT[mcid == mcid_we_want]
#>              mcid   race    sex program          bloc
#>            <char> <char> <char>  <char>        <char>
#> 1: MCID3112470255  White   Male      CE ever_enrolled
#> 2: MCID3112470255  White   Male      EE ever_enrolled
#> 3: MCID3112470255  White   Male      ME ever_enrolled
#> 4: MCID3112470255  White   Male      ME     graduates
```

The `term` and `degree` excerpts confirm those observations.

``` r

# Closer look at term
term[mcid == mcid_we_want]
#>               mcid   institution   term   cip6              level
#>             <char>        <char> <char> <char>             <char>
#>  1: MCID3112470255 Institution C  20101 140801      01 First-year
#>  2: MCID3112470255 Institution C  20103 141001      01 First-year
#>  3: MCID3112470255 Institution C  20111 141901     02 Second-year
#>  4: MCID3112470255 Institution C  20113 141901     02 Second-year
#>  5: MCID3112470255 Institution C  20121 141901      03 Third-year
#>  6: MCID3112470255 Institution C  20123 141901      03 Third-year
#>  7: MCID3112470255 Institution C  20124 141901      03 Third-year
#>  8: MCID3112470255 Institution C  20131 141901     04 Fourth-year
#>  9: MCID3112470255 Institution C  20133 141901     04 Fourth-year
#> 10: MCID3112470255 Institution C  20141 141901 05 Fifth-year Plus
#> 11: MCID3112470255 Institution C  20143 141901 05 Fifth-year Plus

# Closer look at degree
degree[mcid == mcid_we_want]
#>              mcid   institution term_degree   cip6
#>            <char>        <char>      <char> <char>
#> 1: MCID3112470255 Institution C       20143 141901
```

------------------------------------------------------------------------

[◁ Case study
goals](https://midfieldr.github.io/midfieldr/articles/art-001-case-goals.md)
  [▲ top of page](#top)  [Case study results
▷](https://midfieldr.github.io/midfieldr/articles/art-003-case-results.md)

------------------------------------------------------------------------

## References

NCES. 2010. *IPEDS Classification of Instructional Programs (CIP)*.
National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>.
