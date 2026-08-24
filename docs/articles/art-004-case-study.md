# Case study

A complete case study illustrating how we work with longitudinal data
and how midfieldr supports the process. In subsequent articles, many of
the topics introduced here are more fully developed.

## Outline

The work is organized in three major sections.

1.  Refining the student records—generally independent of the case
    specifics
2.  Obtaining the metric—depends on one’s programs, metrics, and
    groupings.
3.  Conditioning the results for dissemination—depends on one’s audience
    and rhetorical goals.

### *Scope*

*Records.*   Data: `student, term,` and `degree` from midfielddata.
Filter for data sufficiency and degree seeking; exclude records later
than a student’s first degree term.

*Population.*   The set of unique IDs from the above records.

*Programs.*   Data: `cip` from midfieldr. We study four Engineering
majors: Civil, Electrical, Industrial/Systems, and Mechanical.

*Metric.*   Program *stickiness:* the ratio \small (S) of the number of
graduates of a program \small (N\_\textrm{grad}) to the number ever
enrolled in the program \small (N\_\textrm{ever}).

\small S = \frac{\small N\_\textrm{grad}}{\small N\_\textrm{ever}} =
\frac{\small\mathrm{number\\ of\\ graduates\\ of\\ a\\
program}}{\small\mathrm{number\\ ever\\ enrolled\\ in\\ the\\ program}}

“Ever-enrolled” means that students at some point decided to seek a
degree in that program. Stickiness reports the likelihood that such
students will “stick to” and graduate from that program ([Ohland et al.
2012](#ref-Ohland+Orr+others:2012)).

*Blocs.*   The metric requires two blocs: students ever enrolled in the
programs; and timely graduates of the programs.

*Groupings.*   Group the findings by program, race/ethnicity, and sex.

*Dissemination.*   Exclude groupings too small to preserve anonymity.
Edit column names to suit the audience. Condition/transform data as
needed for tables or charts.

### *Terminology*

Definitions critical to understanding our data manipulation process.

- The population is usually expected to be *degree-seeking,* i.e.,
  attempting to complete a program.

- *Program completion* means satisfying the requirements for a first
  baccalaureate degree.

- The *timely-completion term* is the term by which we would consider
  their completion “timely”, default 6 years after admission.

- The *data sufficiency* test identifies students whose admission term
  and projected timely completion term lie within the range of data
  available from their institution—a necessary and sufficient condition
  for determining completion status.

- *Completion status* is “timely” for students graduating no later than
  their timely-completion term; “late” if they graduate after that term;
  and “NA” for non-completion.

## Refining the records

``` r

# packages
library("midfieldr") # working with student records
library("midfielddata") # practice data
library("data.table") # data manipulation
library("gt") # tables
library("ggplot2") # charts
```

We load three of the midfielddata data tables. This study does not
require the `course` data table. If it had been required, it would be
included here and in similar steps throughout the article.

``` r

data(student, term, degree)
```

We copy the original data sets, giving them new names
`{student_source, term_source, degree_source}` and new locations in
memory. This step allows us to use the more convenient names
`{student, term, degree}` to do our work without updating the source
tables “by reference.” Reference semantics in data.table is documented
in ([*Reference Semantics* 2026](#ref-reference-semantics:2026)).

``` r

student_source <- copy(student)
term_source <- copy(term)
degree_source <- copy(degree)
```

For comparing results as we refine the population, we start with the
following number of rows in the original data frames.

| Table   | Original tables |
|---------|-----------------|
| student | 97,555          |
| term    | 639,915         |
| degree  | 49,665          |

Table 1(a). Number of rows. {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

### *Minimum necessary columns*

In the next few steps, we do not require all of the columns in our data
tables. We can (optionally) minimize the number of columns we see during
an interactive session using `select_basic_cols().` The columns returned
are those required by other midfieldr functions.

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
#>    ---                                    
#> 97553: MCID3112898894         White Female
#> 97554: MCID3112898895         White Female
#> 97555: MCID3112898940 Other/Unknown   Male

term
#>                   mcid   term   cip6   institution         level
#>                 <char> <char> <char>        <char>        <char>
#>      1: MCID3111142225  19881 140901 Institution B 01 First-year
#>      2: MCID3111142283  19881 240102 Institution J 01 First-year
#>      3: MCID3111142283  19883 240102 Institution J 01 First-year
#>     ---                                                         
#> 639913: MCID3112898894  20181 451001 Institution B 01 First-year
#> 639914: MCID3112898895  20181 302001 Institution B 01 First-year
#> 639915: MCID3112898940  20181 050103 Institution B 01 First-year

degree
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

### *Data sufficiency*

Per the terminology discussion above, only those records passing the
data sufficiency test are included in a population study. We start with
the full set of unique student IDs.

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

We use
[`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md)
to determine the timely completion term for every student and add
columns to the data frame to support those findings.

``` r

DT <- timely_term(DT, midf_table = term)
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

Next, we can (optionally) reduce the number of columns to just those
needed in the next step.

``` r

DT <- DT[, .(mcid, term_i, timely_term)]
DT
#>                  mcid term_i timely_term
#>                <char> <char>      <char>
#>     1: MCID3111142225  19881       19933
#>     2: MCID3111142283  19881       19933
#>     3: MCID3111142290  19881       19933
#>    ---                                  
#> 97553: MCID3112898894  20181       20233
#> 97554: MCID3112898895  20181       20233
#> 97555: MCID3112898940  20181       20233
```

We operate on this output with
[`data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/data_sufficiency.md)
to identify records that pass the data sufficiency test and those that
do not and add columns to the data frame to support those findings.

``` r

DT <- data_sufficiency(DT, midf_table = term)
DT
#>                  mcid term_i timely_term  data_range data_sufficiency
#>                <char> <char>      <char>      <char>           <char>
#>     1: MCID3111142225  19881       19933 19881-20181    exclude-lower
#>     2: MCID3111142283  19881       19933 19881-20096    exclude-lower
#>     3: MCID3111142290  19881       19933 19881-20096    exclude-lower
#>    ---                                                               
#> 97553: MCID3112898894  20181       20233 19881-20181    exclude-upper
#> 97554: MCID3112898895  20181       20233 19881-20181    exclude-upper
#> 97555: MCID3112898940  20181       20233 19881-20181    exclude-upper
```

*Summary check.*   A brief aside to summarize the numbers of students
identified to include and exclude. We run a similar summary at a number
of points in the analysis as a credibility check.

``` r

DT[, .N, by = c("data_sufficiency")][order(-N)]
#>    data_sufficiency     N
#>              <char> <int>
#> 1:          include 76875
#> 2:    exclude-upper 17934
#> 3:    exclude-lower  2746
```

We filter to retain rows labeled “include” and drop all but the ID
column.

``` r

DT <- DT[data_sufficiency == "include", .(mcid)]
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

### *Degree seeking*

We require all students in our study to be degree-seeking. By design,
the `student` table contains only degree-seeking students. We inner-join
the ID column from the `student` table, matching on `mcid`. In effect,
the inner join filters our population to remove any non-degree-seeking
students.

``` r

student_cols <- student[, .(mcid)]
DT <- student_cols[DT, on = "mcid", nomatch = NULL]
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

It happens that all students in this case are degree-seeking, so this
step did not reduce the size of our population. Still, we include the
step to illustrate our complete process.

### *Population*

Filtering for data sufficiency and degree-seeking yields the baseline
population for this study.

``` r

population <- copy(DT)
```

We use this population to filter the source records using an inner join,
matching on ID. The inner join retains those IDs common to both data
frames. The results are our first iteration of our “baseline” data
tables.

``` r

student_baseline <- population[student_source, on = "mcid", nomatch = NULL]
term_baseline <- population[term_source, on = "mcid", nomatch = NULL]
degree_baseline <- population[degree_source, on = "mcid", nomatch = NULL]
```

| Table   | Original tables | Refined population |
|---------|-----------------|--------------------|
| student | 97,555          | 76,875             |
| term    | 639,915         | 531,419            |
| degree  | 49,665          | 43,903             |

Table 1(b). Number of rows {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

### *Post-completion terms*

We are not generally interested in terms beyond the first degree term,
so we identify and exclude terms later than the first degree term in all
the source data frames. Here, we retrieve our source tables with term
variables. (A study that used the `course` data table would be included
in this step too.)

``` r

term <- copy(term_baseline)
degree <- copy(degree_baseline)
```

For each student and term in a data frame,
[`post_completion_terms()`](https://midfieldr.github.io/midfieldr/reference/post_completion_terms.md)
identifies terms that are before, equal to, or after the student’s first
degree term and adds columns to the data frame to support those
findings.

``` r

term <- post_completion_terms(term, midf_table = degree)
degree <- post_completion_terms(degree, midf_table = degree)

term
#>                   mcid   term   cip6   institution          level      standing
#>                 <char> <char> <char>        <char>         <char>        <char>
#>      1: MCID3111142689  19883 090401 Institution B  01 First-year Good Standing
#>      2: MCID3111142782  19883 260101 Institution J  01 First-year Good Standing
#>      3: MCID3111142782  19885 260101 Institution J 02 Second-year Good Standing
#>     ---                                                                        
#> 531417: MCID3112870009  19953 240102 Institution B  01 First-year Good Standing
#> 531418: MCID3112870009  19954 240102 Institution B  01 First-year Good Standing
#> 531419: MCID3112870009  19983 240102 Institution B 02 Second-year Good Standing
#>           coop hours_term hours_term_attempt hours_cumul hours_cumul_attempt
#>         <char>      <num>              <num>       <num>               <num>
#>      1:     No          9                  9          18                  18
#>      2:     No         16                 16          26                  26
#>      3:     No          4                  4          30                  30
#>     ---                                                                     
#> 531417:     No         12                 12          24                  24
#> 531418:     No          1                  1          25                  25
#> 531419:     No          7                  7          53                  53
#>         gpa_term gpa_cumul first_degree_term term_cluster
#>            <num>     <num>            <char>       <char>
#>      1:     3.33      3.05             19913   pre-degree
#>      2:     2.80      2.57             19903   pre-degree
#>      3:     3.00      2.63             19903   pre-degree
#>     ---                                                  
#> 531417:     3.57      3.71              <NA>   pre-degree
#> 531418:     4.00      3.72              <NA>   pre-degree
#> 531419:     4.00      3.87              <NA>   pre-degree
```

*Summary check.*   Numbers of students in each term cluster.

``` r

term[, .N, by = c("term_cluster")][order(-N)]
#>         term_cluster      N
#>               <char>  <int>
#> 1:        pre-degree 495563
#> 2:      first-degree  29883
#> 3: post-first-degree   5973

degree[, .N, by = c("term_cluster")][order(-N)]
#>         term_cluster     N
#>               <char> <int>
#> 1:      first-degree 43857
#> 2: post-first-degree    46
```

We exclude the rows labeled “post-first-degree.” Note that we are
dropping *terms* without affecting the number of student IDs.

``` r

term <- term[term_cluster != "post-first-degree"]
degree <- degree[term_cluster != "post-first-degree"]
```

We drop the temporary columns.

``` r

term[, c("term_cluster", "first_degree_term") := NULL]
degree[, c("term_cluster", "first_degree_term") := NULL]
```

We redefine our tables to incorporate the exclusion of post-completion
terms, yielding our baseline data tables.

``` r

term_baseline <- copy(term)
degree_baseline <- copy(degree)
```

| Table   | Original tables | Refined population | Baseline tables |
|---------|-----------------|--------------------|-----------------|
| student | 97,555          | 76,875             | 76,875          |
| term    | 639,915         | 531,419            | 525,446         |
| degree  | 49,665          | 43,903             | 43,857          |

Table 1(c). Number of rows. {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

Review the results.

``` r

look_at(student_baseline)
#> Classes 'data.table' and 'data.frame':   76875 obs. of  13 variables:
#>  $ mcid          : chr  "MCID3111142689" "MCID3111142782" "MCID3111142881" "M"..
#>  $ race          : chr  "Hispanic" "Hispanic" "International" "International" ..
#>  $ sex           : chr  "Female" "Female" "Male" "Male" ...
#>  $ institution   : chr  "Institution B" "Institution J" "Institution B" "Inst"..
#>  $ transfer      : chr  "First-Time Transfer" "First-Time Transfer" "First-Ti"..
#>  $ hours_transfer: num  NA NA NA NA NA NA NA NA NA NA ...
#>  $ age_desc      : chr  "Under 25" "Under 25" "25 and Older" "Under 25" ...
#>  $ us_citizen    : chr  "Yes" "Yes" "Yes" "No" ...
#>  $ home_zip      : chr  NA "22101" NA NA ...
#>  $ high_school   : chr  NA "471395" NA NA ...
#>  $ sat_math      : num  NA 520 NA NA NA NA NA NA NA NA ...
#>  $ sat_verbal    : num  NA 490 NA NA NA NA NA NA NA NA ...
#>  $ act_comp      : num  NA NA NA NA NA NA NA NA NA NA ...

look_at(term_baseline)
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

look_at(degree_baseline)
#> Classes 'data.table' and 'data.frame':   43857 obs. of  5 variables:
#>  $ mcid       : chr  "MCID3111142689" "MCID3111142782" "MCID3111142881" "MCID"..
#>  $ term_degree: chr  "19913" "19903" "19894" "19901" ...
#>  $ cip6       : chr  "090401" "260101" "450601" "141001" ...
#>  $ institution: chr  "Institution B" "Institution J" "Institution B" "Institu"..
#>  $ degree     : chr  "Bachelor of Arts in Journalism" "Bachelor of Science in"..

look_at(population)
#> Classes 'data.table' and 'data.frame':   76875 obs. of  1 variable:
#>  $ mcid: chr  "MCID3111142689" "MCID3111142782" "MCID3111142881" "MCID3111142"..
```

The baseline tables are the starting point for most studies, independent
of case specifics. From this point forward, anytime we need a fresh copy
of any of the data tables, we copy the “baseline” version. Anytime we
need a starting population, we copy `population.`

## Programs

In this section, we begin the procedures that transform our baseline
records and population into case-specific programs, blocs, metrics, and
groupings.

Our goal in this section is to search the CIP data table for the 6-digit
codes for our programs. The `cip` dataset loads with midfieldr.

### *Search for program codes*

[`filter_programs()`](https://midfieldr.github.io/midfieldr/reference/filter_programs.md)
searches `dframe` for string patterns. Searching for “engineering”
yields 2-digit CIP codes 14, 15, 29, and 51. From the program names, the
2-digit code we want is 14.

``` r

filter_programs(dframe = cip, pattern = "engineering")
#>                                                              cip6name   cip6
#>                                                                <char> <char>
#>   1:                                             Engineering, General 140101
#>   2:                                                  Pre-Engineering 140102
#>   3:     Aerospace, Aeronautical and Astronautical, Space Engineering 140201
#>   4:          Agricultural, Biological Engineering and Bioengineering 140301
#>   5:                                        Architectural Engineering 140401
#>   6:                                  Biomedical, Medical Engineering 140501
#>  ---                                                                        
#> 114:                                Engineering-Related Fields, Other 151599
#> 115:                                                   Nanotechnology 151601
#> 116:             Engineering Related Technologies, Technicians, Other 159999
#> 117:                                       Combat Systems Engineering 290301
#> 118:                                            Engineering Acoustics 290303
#> 119: Assistive, Augmentative Technology and Rehabiliation Engineering 512312
#>                                                     cip4name   cip4
#>                                                       <char> <char>
#>   1:                                    Engineering, General   1401
#>   2:                                    Engineering, General   1401
#>   3:   Aerospace, Aeronautical and Astronautical Engineering   1402
#>   4: Agricultural, Biological Engineering and Bioengineering   1403
#>   5:                               Architectural Engineering   1404
#>   6:                         Biomedical, Medical Engineering   1405
#>  ---                                                               
#> 114:                              Engineering-Related Fields   1515
#> 115:                                          Nanotechnology   1516
#> 116:    Engineering-Related Technologies, Technicians, Other   1599
#> 117:                               Military Applied Sciences   2903
#> 118:                               Military Applied Sciences   2903
#> 119:              Rehabilitation and Therapeutic Professions   5123
#>                                              cip2name   cip2
#>                                                <char> <char>
#>   1:                                      Engineering     14
#>   2:                                      Engineering     14
#>   3:                                      Engineering     14
#>   4:                                      Engineering     14
#>   5:                                      Engineering     14
#>   6:                                      Engineering     14
#>  ---                                                        
#> 114:                           Engineering Technology     15
#> 115:                           Engineering Technology     15
#> 116:                           Engineering Technology     15
#> 117:                            Military Technologies     29
#> 118:                            Military Technologies     29
#> 119: Health Professions and Related Clinical Sciences     51
```

Subset the full `cip` for the Engineering code 14 and search that result
for “civil”. We find that Civil Engineering is encoded by the 4-digit
code 1408.

``` r

engr_cip <- filter_programs(cip, "^14")
filter_programs(engr_cip, "civil")
#>                                  cip6name   cip6          cip4name   cip4
#>                                    <char> <char>            <char> <char>
#> 1:             Civil Engineering, General 140801 Civil Engineering   1408
#> 2:               Geotechnical Engineering 140802 Civil Engineering   1408
#> 3:                 Structural Engineering 140803 Civil Engineering   1408
#> 4: Transportation and Highway Engineering 140804 Civil Engineering   1408
#> 5:            Water Resources Engineering 140805 Civil Engineering   1408
#> 6:               Civil Engineering, Other 140899 Civil Engineering   1408
#>       cip2name   cip2
#>         <char> <char>
#> 1: Engineering     14
#> 2: Engineering     14
#> 3: Engineering     14
#> 4: Engineering     14
#> 5: Engineering     14
#> 6: Engineering     14
```

Repeat for “electrical” and obtain the 4-digit code 1410.

``` r

filter_programs(engr_cip, "electrical")
#>                                                         cip6name   cip6
#>                                                           <char> <char>
#> 1:        Electrical, Electronics and Communications Engineering 141001
#> 2:                                 Laser and Optical Engineering 141003
#> 3:                                Telecommunications Engineering 141004
#> 4: Electrical, Electronics and Communications Engineering, Other 141099
#>                                                  cip4name   cip4    cip2name
#>                                                    <char> <char>      <char>
#> 1: Electrical, Electronics and Communications Engineering   1410 Engineering
#> 2: Electrical, Electronics and Communications Engineering   1410 Engineering
#> 3: Electrical, Electronics and Communications Engineering   1410 Engineering
#> 4: Electrical, Electronics and Communications Engineering   1410 Engineering
#>      cip2
#>    <char>
#> 1:     14
#> 2:     14
#> 3:     14
#> 4:     14
```

Continuing in a similar fashion, we find that our programs have the
following 4-digit codes.

- Civil Engineering 1408
- Electrical Engineering 1410
- Mechanical Engineering 1419  
- Industrial/Systems Engineering 1427, 1435, 1436, and 1437.

Note that in general an accredited engineering degree-granting program
is encoded by a single 4-digit CIP code, but not always. In addition,
the code or codes used by a degree-granting program can vary over time
and by institution.

### *Construct the programs table*

We create a search string of the desired 4-digit codes.

``` r

codes_we_want <- c("^1408", "^1410", "^1419", "^1427", "^1435", "^1436", "^1437")
programs <- filter_programs(engr_cip, codes_we_want)
programs
#>                                                          cip6name   cip6
#>                                                            <char> <char>
#>  1:                                    Civil Engineering, General 140801
#>  2:                                      Geotechnical Engineering 140802
#>  3:                                        Structural Engineering 140803
#>  4:                        Transportation and Highway Engineering 140804
#>  5:                                   Water Resources Engineering 140805
#>  6:                                      Civil Engineering, Other 140899
#> ---                                                                     
#> 10: Electrical, Electronics and Communications Engineering, Other 141099
#> 11:                                        Mechanical Engineering 141901
#> 12:                                           Systems Engineering 142701
#> 13:                                        Industrial Engineering 143501
#> 14:                                     Manufacturing Engineering 143601
#> 15:                                           Operations Research 143701
#>                                                   cip4name   cip4    cip2name
#>                                                     <char> <char>      <char>
#>  1:                                      Civil Engineering   1408 Engineering
#>  2:                                      Civil Engineering   1408 Engineering
#>  3:                                      Civil Engineering   1408 Engineering
#>  4:                                      Civil Engineering   1408 Engineering
#>  5:                                      Civil Engineering   1408 Engineering
#>  6:                                      Civil Engineering   1408 Engineering
#> ---                                                                          
#> 10: Electrical, Electronics and Communications Engineering   1410 Engineering
#> 11:                                 Mechanical Engineering   1419 Engineering
#> 12:                                    Systems Engineering   1427 Engineering
#> 13:                                 Industrial Engineering   1435 Engineering
#> 14:                              Manufacturing Engineering   1436 Engineering
#> 15:                                    Operations Research   1437 Engineering
#>       cip2
#>     <char>
#>  1:     14
#>  2:     14
#>  3:     14
#>  4:     14
#>  5:     14
#>  6:     14
#> ---       
#> 10:     14
#> 11:     14
#> 12:     14
#> 13:     14
#> 14:     14
#> 15:     14
```

While we searched `cip` using 4-digit codes, it is the 6-digit codes
that we want for matching to the student records later. Here we drop all
but the 6-digit information.

``` r

programs <- programs[, .(cip6name, cip6)]
programs
#>                                                          cip6name   cip6
#>                                                            <char> <char>
#>  1:                                    Civil Engineering, General 140801
#>  2:                                      Geotechnical Engineering 140802
#>  3:                                        Structural Engineering 140803
#>  4:                        Transportation and Highway Engineering 140804
#>  5:                                   Water Resources Engineering 140805
#>  6:                                      Civil Engineering, Other 140899
#>  7:        Electrical, Electronics and Communications Engineering 141001
#>  8:                                 Laser and Optical Engineering 141003
#>  9:                                Telecommunications Engineering 141004
#> 10: Electrical, Electronics and Communications Engineering, Other 141099
#> 11:                                        Mechanical Engineering 141901
#> 12:                                           Systems Engineering 142701
#> 13:                                        Industrial Engineering 143501
#> 14:                                     Manufacturing Engineering 143601
#> 15:                                           Operations Research 143701
```

The program names in `cip` are usually too long for effective
use—user-defined names are nearly always required. So we add a `program`
variable with values “CE” (Civil Engineering), “EE” (electrical), “ME”
(Mechanical), and “ISE” (Industrial/Systems Engineering).

``` r

programs[, program := fcase(
  cip6 %like% "^1408", "CE",
  cip6 %like% "^1410", "EE",
  cip6 %like% "^1419", "ME",
  cip6 %like% c("^1427|^1435|^1436|^1437"), "ISE",
  default = NA_character_
)]
```

While we don’t use the original 6-digit program names, we can preserve
them for reference. Here we abbreviate some of them for a more compact
display.

``` r

programs[, cip6name := gsub("Engineering", "Engng", cip6name)]
programs[, cip6name := gsub("Communications", "Commns", cip6name)]
programs[, cip6name := gsub("Electrical, Electronics", "Elec, Electr,", cip6name)]

programs
#>                                  cip6name   cip6 program
#>                                    <char> <char>  <char>
#>  1:                  Civil Engng, General 140801      CE
#>  2:                    Geotechnical Engng 140802      CE
#>  3:                      Structural Engng 140803      CE
#>  4:      Transportation and Highway Engng 140804      CE
#>  5:                 Water Resources Engng 140805      CE
#>  6:                    Civil Engng, Other 140899      CE
#>  7:        Elec, Electr, and Commns Engng 141001      EE
#>  8:               Laser and Optical Engng 141003      EE
#>  9:              Telecommunications Engng 141004      EE
#> 10: Elec, Electr, and Commns Engng, Other 141099      EE
#> 11:                      Mechanical Engng 141901      ME
#> 12:                         Systems Engng 142701     ISE
#> 13:                      Industrial Engng 143501     ISE
#> 14:                   Manufacturing Engng 143601     ISE
#> 15:                   Operations Research 143701     ISE
```

Our programs data frame is complete: 15 six-digit codes are encoded
using 4 program labels. This data frame can sit in memory (or written to
file) until we’re ready to filter the blocs by program, joining data
frames by matching on the `cip6` variable.

## Blocs and groupings

The stickiness metric requires these blocs:

- students with timely completion from the study programs
- students ever enrolled in these programs

And we selected these groupings:

- program
- race/ethnicity
- sex

We have a lot of flexibility in the order in which we construct our
blocs and groupings, so what follows is only one of several effective
solutions. Our approach here is to construct a bloc, filter by program,
join the demographics, and repeat for the next bloc.

First, we copy so our work will not affect the baseline material by
reference.

``` r

student <- copy(student_baseline)
term <- copy(term_baseline)
degree <- copy(degree_baseline)
```

## Timely graduates

We start with the baseline population. Like we did with the original
data files, we copy it to protect `population` from changes by
reference.

``` r

DT <- copy(population)
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

### *Filter by program*

We left-join the CIP column from the `degree` table, matching on `mcid`.
That the number of rows has increased indicates that some students have
more than one degree in their first degree term.

``` r

degree_cols <- degree[, .(mcid, cip6)]
DT <- degree_cols[DT, on = "mcid"]
DT
#>                  mcid   cip6
#>                <char> <char>
#>     1: MCID3111142689 090401
#>     2: MCID3111142782 260101
#>     3: MCID3111142881 450601
#>    ---                      
#> 76944: MCID3112785480   <NA>
#> 76945: MCID3112800920   <NA>
#> 76946: MCID3112870009   <NA>
```

*Summary check.*   Numbers of students completing \small N degrees.

``` r

x <- DT[, .(N_degrees = .N), by = "mcid"]
x[, .(N_students = .N), by = "N_degrees"]
#>    N_degrees N_students
#>        <int>      <int>
#> 1:         1      76804
#> 2:         2         71
```

We use an inner-join with our `programs` data frame to retain only the
rows that have matching CIP codes in both tables.

``` r

programs_cols <- programs[, .(cip6, program)]
DT <- programs_cols[DT, on = "cip6", nomatch = NULL]
DT
#>         cip6 program           mcid
#>       <char>  <char>         <char>
#>    1: 141001      EE MCID3111142965
#>    2: 141001      EE MCID3111145102
#>    3: 141001      EE MCID3111146537
#>   ---                              
#> 3429: 141901      ME MCID3112618976
#> 3430: 141001      EE MCID3112619484
#> 3431: 141901      ME MCID3112641535
```

We drop the `cip6` column, leaving the `program` column with our
user-defined program labels. These students all have a degree in one of
our four engineering programs.

``` r

DT[, cip6 := NULL]
DT <- unique(DT)
DT
#>       program           mcid
#>        <char>         <char>
#>    1:      EE MCID3111142965
#>    2:      EE MCID3111145102
#>    3:      EE MCID3111146537
#>   ---                       
#> 3429:      ME MCID3112618976
#> 3430:      EE MCID3112619484
#> 3431:      ME MCID3112641535
```

### *Filter for timely completion*

We want to retain timely graduates only. We start by obtaining the
timely completion term then selecting the variables we need to go
forward.

``` r

DT <- timely_term(DT)
DT <- DT[, .(mcid, program, timely_term)]
DT
#>                 mcid program timely_term
#>               <char>  <char>      <char>
#>    1: MCID3111142965      EE       19941
#>    2: MCID3111145102      EE       19941
#>    3: MCID3111146537      EE       19931
#>   ---                                   
#> 3429: MCID3112618976      ME       20181
#> 3430: MCID3112619484      EE       20181
#> 3431: MCID3112641535      ME       20173
```

[`completion_status()`](https://midfieldr.github.io/midfieldr/reference/completion_status.md)
builds on the output from
[`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md)
to label rows to indicate whether a student completes a degree timely or
late compared to their timely completion term (or NA for no completion).

``` r

DT <- completion_status(DT)
DT
#>                 mcid program timely_term completion_term completion_status
#>               <char>  <char>      <char>          <char>            <char>
#>    1: MCID3111142965      EE       19941           19901            timely
#>    2: MCID3111145102      EE       19941           19893            timely
#>    3: MCID3111146537      EE       19931           19913            timely
#>   ---                                                                     
#> 3429: MCID3112618976      ME       20181           20153            timely
#> 3430: MCID3112619484      EE       20181           20133            timely
#> 3431: MCID3112641535      ME       20173           20143            timely
```

*Summary check.*   Numbers of students by completion status.

``` r

DT[, .N, by = c("completion_status")][order(-N)]
#>    completion_status     N
#>               <char> <int>
#> 1:            timely  3263
#> 2:              late   168
```

We retain the rows labeled “timely” and the drop all the columns except
the ID and program columns.

``` r

DT <- DT[completion_status == "timely", .(mcid, program)]
DT
#>                 mcid program
#>               <char>  <char>
#>    1: MCID3111142965      EE
#>    2: MCID3111145102      EE
#>    3: MCID3111146537      EE
#>   ---                       
#> 3261: MCID3112618976      ME
#> 3262: MCID3112619484      EE
#> 3263: MCID3112641535      ME
```

### *Join demographics*

To add columns for student demographics, we left-join selected columns
from the `student` table, matching on `mcid`.

``` r

student <- select_basic_cols(student)
DT <- student[DT, on = "mcid"]
DT
#>                 mcid          race    sex program
#>               <char>        <char> <char>  <char>
#>    1: MCID3111142965 International   Male      EE
#>    2: MCID3111145102         White   Male      EE
#>    3: MCID3111146537         Asian Female      EE
#>   ---                                            
#> 3261: MCID3112618976         White   Male      ME
#> 3262: MCID3112619484         White   Male      EE
#> 3263: MCID3112641535         White   Male      ME
```

### *Bloc of timely graduates*

This is the bloc of timely graduates required by our metric. We add a
`bloc` variable with the value “grad” and ensure we have unique rows.

``` r

DT[, bloc := "grad"]
graduates <- unique(DT)
graduates
#>                 mcid          race    sex program   bloc
#>               <char>        <char> <char>  <char> <char>
#>    1: MCID3111142965 International   Male      EE   grad
#>    2: MCID3111145102         White   Male      EE   grad
#>    3: MCID3111146537         Asian Female      EE   grad
#>   ---                                                   
#> 3261: MCID3112618976         White   Male      ME   grad
#> 3262: MCID3112619484         White   Male      EE   grad
#> 3263: MCID3112641535         White   Male      ME   grad
```

*Summary check.*   Numbers of timely graduates by program.

``` r

graduates[, .N, by = c("program")][order(-N)]
#>    program     N
#>     <char> <int>
#> 1:      ME  1353
#> 2:      CE   936
#> 3:      EE   736
#> 4:     ISE   238
```

## Ever enrolled

Again we start with the baseline population.

``` r

DT <- copy(population)
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

### *Filter by program*

We left-join the CIP column from the `term` table, matching on `mcid`.

``` r

term_cols <- term[, .(mcid, cip6)]
term_cols <- unique(term_cols)
DT <- term_cols[DT, on = "mcid"]
DT
#>                   mcid   cip6
#>                 <char> <char>
#>      1: MCID3111142689 090401
#>      2: MCID3111142782 260101
#>      3: MCID3111142881 450601
#>     ---                      
#> 126176: MCID3112800920 240102
#> 126177: MCID3112800920 240199
#> 126178: MCID3112870009 240102
```

CIP codes are also present in the `degree` table. Students working in a
multidisciplinary program may have CIP codes at graduation that do not
appear in the `term` data, where only their primary major is recorded.
We assume that if a student earns a degree in such a program we can
consider them “ever enrolled” in the program.

From `degree,` we extract the CIP codes by ID and join them by rows to
the previous data frame.

``` r

extra_cip <- copy(population)
degree_cols <- unique(degree[, .(mcid, cip6)])
extra_cip <- degree_cols[extra_cip, on = "mcid", nomatch = NULL]
DT <- unique(rbindlist(list(DT, extra_cip)))
DT
#>                   mcid   cip6
#>                 <char> <char>
#>      1: MCID3111142689 090401
#>      2: MCID3111142782 260101
#>      3: MCID3111142881 450601
#>     ---                      
#> 128460: MCID3112603386 030103
#> 128461: MCID3112610194 270301
#> 128462: MCID3112616507 302001
```

We repeat the process we used earlier to inner-join our `programs` data
frame, matching on `cip6`.

``` r

programs_cols <- programs[, .(cip6, program)]
DT <- programs_cols[DT, on = "cip6", nomatch = NULL]
DT[, cip6 := NULL]
```

With the CIP code removed, we filter for unique rows. A student may
switch CIP codes yet stay within a program as defined by our custom
labels. We want to avoid counting that student as ever-enrolled in the
same program more than once.

``` r

DT <- unique(DT)
DT
#>       program           mcid
#>        <char>         <char>
#>    1:      EE MCID3111142965
#>    2:      EE MCID3111145102
#>    3:      EE MCID3111146537
#>   ---                       
#> 5603:      ME MCID3112414647
#> 5604:      ME MCID3112415453
#> 5605:      ME MCID3112475209
```

### *Join demographics*

Again, we left-join selected columns from the `student` table, matching
on `mcid`.

``` r

DT <- student[DT, on = "mcid"]
DT
#>                 mcid          race    sex program
#>               <char>        <char> <char>  <char>
#>    1: MCID3111142965 International   Male      EE
#>    2: MCID3111145102         White   Male      EE
#>    3: MCID3111146537         Asian Female      EE
#>   ---                                            
#> 5603: MCID3112414647         White   Male      ME
#> 5604: MCID3112415453         White   Male      ME
#> 5605: MCID3112475209         White Female      ME
```

### *Bloc of ever-enrolled*

This is the bloc of students ever enrolled in our programs required by
our metric. We add a `bloc` variable with the value “ever” and ensure we
have unique rows.

``` r

DT[, bloc := "ever"]
ever_enrolled <- unique(DT)
ever_enrolled
#>                 mcid          race    sex program   bloc
#>               <char>        <char> <char>  <char> <char>
#>    1: MCID3111142965 International   Male      EE   ever
#>    2: MCID3111145102         White   Male      EE   ever
#>    3: MCID3111146537         Asian Female      EE   ever
#>   ---                                                   
#> 5603: MCID3112414647         White   Male      ME   ever
#> 5604: MCID3112415453         White   Male      ME   ever
#> 5605: MCID3112475209         White Female      ME   ever
```

*Summary check.*   Numbers of students ever enrolled by program.

``` r

ever_enrolled[, .N, by = c("program")][order(-N)]
#>    program     N
#>     <char> <int>
#> 1:      ME  2296
#> 2:      CE  1504
#> 3:      EE  1469
#> 4:     ISE   336
```

## Outcomes

Combining the two data frames (blocs) by rows, we obtain the data
structure we need for grouping and summarizing.

``` r

DT <- rbindlist(list(graduates, ever_enrolled))
DT
#>                 mcid          race    sex program   bloc
#>               <char>        <char> <char>  <char> <char>
#>    1: MCID3111142965 International   Male      EE   grad
#>    2: MCID3111145102         White   Male      EE   grad
#>    3: MCID3111146537         Asian Female      EE   grad
#>   ---                                                   
#> 8866: MCID3112414647         White   Male      ME   ever
#> 8867: MCID3112415453         White   Male      ME   ever
#> 8868: MCID3112475209         White Female      ME   ever
```

### *Group and summarize*

Count the numbers of observations for each combination of the grouping
variables. These data are in block-record form with four keys, one value
column, and one row per value.

``` r

DT <- DT[, .N, by = c("bloc", "program", "race", "sex")]
DT
#>       bloc program            race    sex     N
#>     <char>  <char>          <char> <char> <int>
#>  1:   grad      EE   International   Male    90
#>  2:   grad      EE           White   Male   439
#>  3:   grad      EE           Asian Female    12
#> ---                                            
#> 96:   ever      ME Native American   Male     5
#> 97:   ever      ME   Other/Unknown Female     8
#> 98:   ever      CE Native American Female     1
```

### *Reshape*

*Reshaping the data frame to calculate the metric.*

We want to separate the \small N column into two columns—one for the
number of graduates and the other for the number of ever enrolled. This
operation is known by a number of different names, e.g., pivot,
crosstab, unstack, spread, or widen ([Mount and Zumel
2019](#ref-Mount+Zumel:2019:fluid-data)).

The data.table package uses
[`dcast()`](https://rdrr.io/pkg/data.table/man/dcast.data.table.html)
for this operation. The key columns `program, race,` and `sex` remain in
place, the `bloc` column yields the new key columns `ever` and `grad,`
and the values in the new columns are taken from the `N` column. The
`fill` argument replaces missing values with zero.

``` r

DT <- dcast(DT,
  program + sex + race ~ bloc,
  value.var = "N",
  fill = 0
)
setkey(DT, NULL)
DT
#>     program    sex            race  ever  grad
#>      <char> <char>          <char> <int> <int>
#>  1:      CE Female           Asian    14    10
#>  2:      CE Female           Black     4     1
#>  3:      CE Female        Hispanic    13     6
#> ---                                           
#> 48:      ME   Male Native American     5     1
#> 49:      ME   Male   Other/Unknown    81    41
#> 50:      ME   Male           White  1587   952
```

These data are in block-record form with three keys and two value
columns. This is the data structure we called out in our project
description for calculating the metric.

### *Calculate the metric*

*Completes the analysis.*

Before calculating the metric, we have to omit rows in which `ever` (the
denominator of the metric) is zero. In this example, no rows are
removed.

``` r

DT <- DT[ever != 0]
setorderv(DT, c("program", "sex", "race"))
DT
#>     program    sex            race  ever  grad
#>      <char> <char>          <char> <int> <int>
#>  1:      CE Female           Asian    14    10
#>  2:      CE Female           Black     4     1
#>  3:      CE Female        Hispanic    13     6
#> ---                                           
#> 48:      ME   Male Native American     5     1
#> 49:      ME   Male   Other/Unknown    81    41
#> 50:      ME   Male           White  1587   952
```

Stickiness is the ratio of the number of graduates to the number ever
enrolled, expressed as a percentage. Stickiness is calculated for each
combination of program, race/ethnicity, and sex.

``` r

DT[, stick := round(100 * grad / ever, 1)]
setkey(DT, NULL)
DT
#>     program    sex            race  ever  grad stick
#>      <char> <char>          <char> <int> <int> <num>
#>  1:      CE Female           Asian    14    10  71.4
#>  2:      CE Female           Black     4     1  25.0
#>  3:      CE Female        Hispanic    13     6  46.2
#> ---                                                 
#> 48:      ME   Male Native American     5     1  20.0
#> 49:      ME   Male   Other/Unknown    81    41  50.6
#> 50:      ME   Male           White  1587   952  60.0
```

These data are in block-record form with three key columns (the grouping
variables), one value column (stick), and thus one row per value.

## Dissemination

We take several additional steps before disseminating these results.

First, we remove rows with summary values that are small enough that
student anonymity can no longer be assured. Here, for example, we have
13 rows with three or fewer graduates.

``` r

head(DT[order(grad, ever)], 15L)
#>     program    sex            race  ever  grad stick
#>      <char> <char>          <char> <int> <int> <num>
#>  1:      EE Female Native American     1     0   0.0
#>  2:      EE   Male Native American     3     0   0.0
#>  3:      CE Female Native American     1     1 100.0
#>  4:      CE   Male Native American     3     1  33.3
#>  5:      CE Female           Black     4     1  25.0
#>  6:      ME   Male Native American     5     1  20.0
#>  7:      ME Female           Asian     7     1  14.3
#>  8:      ME Female           Black     3     2  66.7
#>  9:     ISE Female   International     6     2  33.3
#> 10:      CE Female   Other/Unknown     5     3  60.0
#> 11:      EE Female           Black     6     3  50.0
#> 12:      EE Female   Other/Unknown     7     3  42.9
#> 13:      EE Female        Hispanic     8     3  37.5
#> 14:     ISE   Male        Hispanic     6     4  66.7
#> 15:      ME Female   Other/Unknown     8     4  50.0
```

When dealing with the full MIDFIELD research data, we typically use
\small N \> 10, but for these practice data we illustrate the procedure
using \small N \> 3 in the graduate column.

``` r

DT <- DT[grad > 3]
DT
#>     program    sex          race  ever  grad stick
#>      <char> <char>        <char> <int> <int> <num>
#>  1:      CE Female         Asian    14    10  71.4
#>  2:      CE Female      Hispanic    13     6  46.2
#>  3:      CE Female International    23    13  56.5
#> ---                                               
#> 35:      ME   Male International   176    89  50.6
#> 36:      ME   Male Other/Unknown    81    41  50.6
#> 37:      ME   Male         White  1587   952  60.0
```

We have found it useful to report such data with a variable that
combines race/ethnicity and sex.

``` r

DT[, people := paste(race, sex)]
setcolorder(DT)
DT
#>     program    sex          race  ever  grad stick               people
#>      <char> <char>        <char> <int> <int> <num>               <char>
#>  1:      CE Female         Asian    14    10  71.4         Asian Female
#>  2:      CE Female      Hispanic    13     6  46.2      Hispanic Female
#>  3:      CE Female International    23    13  56.5 International Female
#> ---                                                                    
#> 35:      ME   Male International   176    89  50.6   International Male
#> 36:      ME   Male Other/Unknown    81    41  50.6   Other/Unknown Male
#> 37:      ME   Male         White  1587   952  60.0           White Male
```

Readers can more readily interpret our charts and tables if the programs
are unabbreviated.

``` r

DT[, program := fcase(
  program %like% "CE", "Civil",
  program %like% "EE", "Electrical",
  program %like% "ME", "Mechanical",
  program %like% "ISE", "Industrial/Systems"
)]
DT
#>        program    sex          race  ever  grad stick               people
#>         <char> <char>        <char> <int> <int> <num>               <char>
#>  1:      Civil Female         Asian    14    10  71.4         Asian Female
#>  2:      Civil Female      Hispanic    13     6  46.2      Hispanic Female
#>  3:      Civil Female International    23    13  56.5 International Female
#> ---                                                                       
#> 35: Mechanical   Male International   176    89  50.6   International Male
#> 36: Mechanical   Male Other/Unknown    81    41  50.6   Other/Unknown Male
#> 37: Mechanical   Male         White  1587   952  60.0           White Male
```

### *Table*

Retain the columns that appear in the table. The result is in
block-record with two key column and one value column.

``` r

DT_table <- DT[, .(people, program, stick)]
setorderv(DT_table, c("people", "program"))
DT_table
#>           people            program stick
#>           <char>             <char> <num>
#>  1: Asian Female              Civil  71.4
#>  2: Asian Female         Electrical  57.1
#>  3: Asian Female Industrial/Systems  66.7
#>  4:   Asian Male              Civil  75.8
#>  5:   Asian Male         Electrical  58.2
#>  6:   Asian Male Industrial/Systems  66.7
#> ---                                      
#> 32: White Female Industrial/Systems  74.0
#> 33: White Female         Mechanical  62.9
#> 34:   White Male              Civil  64.6
#> 35:   White Male         Electrical  51.8
#> 36:   White Male Industrial/Systems  73.0
#> 37:   White Male         Mechanical  60.0
```

Transform the data to row-record form. The key column `{people}` remains
in place, the `{program}` column yields the new key columns
`{Civil, Electrical, etc.}`, and the values in the new columns are taken
from the `{stick}` column. The `fill` argument replaces missing values
with NA.

``` r

DT_table <- dcast(DT_table,
  people ~ program,
  value.var = "stick",
  fill = NA
)
setnames(DT_table, old = "people", new = "People")
setkey(DT_table, NULL)
DT_table
#>                   People Civil Electrical Industrial/Systems Mechanical
#>                   <char> <num>      <num>              <num>      <num>
#>  1:         Asian Female  71.4       57.1               66.7         NA
#>  2:           Asian Male  75.8       58.2               66.7       63.6
#>  3:         Black Female    NA         NA               85.7         NA
#>  4:           Black Male  62.5       58.6               66.7       65.5
#>  5:      Hispanic Female  46.2         NA                 NA       66.7
#>  6:        Hispanic Male  47.0       38.6               66.7       53.8
#>  7: International Female  56.5       33.3                 NA       55.0
#>  8:   International Male  56.1       46.2               57.1       50.6
#>  9: Other/Unknown Female    NA         NA                 NA       50.0
#> 10:   Other/Unknown Male  40.7       39.0                 NA       50.6
#> 11:         White Female  62.1       47.9               74.0       62.9
#> 12:           White Male  64.6       51.8               73.0       60.0
```

Format the table for publication. The
[`sub_missing()`](https://gt.rstudio.com/reference/sub_missing.html)
argument replaces NAs with an em-dash to improve readability.

``` r

DT_table |>
  gt() |>
  sub_missing() |>
  tab_caption("Table 1. Engineering program stickiness (%)") |>
  tab_options(table.font.size = "small") |>
  opt_stylize(style = 1, color = "gray") |>
  tab_style(
    style = list(cell_fill(color = "#c7eae5")),
    locations = cells_column_labels(columns = everything())
  )
```

| People               | Civil | Electrical | Industrial/Systems | Mechanical |
|----------------------|-------|------------|--------------------|------------|
| Asian Female         | 71.4  | 57.1       | 66.7               | —          |
| Asian Male           | 75.8  | 58.2       | 66.7               | 63.6       |
| Black Female         | —     | —          | 85.7               | —          |
| Black Male           | 62.5  | 58.6       | 66.7               | 65.5       |
| Hispanic Female      | 46.2  | —          | —                  | 66.7       |
| Hispanic Male        | 47.0  | 38.6       | 66.7               | 53.8       |
| International Female | 56.5  | 33.3       | —                  | 55.0       |
| International Male   | 56.1  | 46.2       | 57.1               | 50.6       |
| Other/Unknown Female | —     | —          | —                  | 50.0       |
| Other/Unknown Male   | 40.7  | 39.0       | —                  | 50.6       |
| White Female         | 62.1  | 47.9       | 74.0               | 62.9       |
| White Male           | 64.6  | 51.8       | 73.0               | 60.0       |

Table 1. Engineering program stickiness (%) {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

### *Chart*

To use
[`ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html), we
want the data in its original block-record form with one value column
(stickiness). We can drop two columns as well.

``` r

DT_chart <- copy(DT)
DT_chart[, c("race", "sex") := NULL]
```

We (optionally) rearrange the order of columns and rows.

``` r

setcolorder(DT_chart, c("people", "program"))
setkeyv(DT_chart, c("people", "program"))
setkey(DT_chart, NULL)
DT_chart
#>           people            program  ever  grad stick
#>           <char>             <char> <int> <int> <num>
#>  1: Asian Female              Civil    14    10  71.4
#>  2: Asian Female         Electrical    21    12  57.1
#>  3: Asian Female Industrial/Systems    15    10  66.7
#>  4:   Asian Male              Civil    33    25  75.8
#>  5:   Asian Male         Electrical   122    71  58.2
#>  6:   Asian Male Industrial/Systems    21    14  66.7
#> ---                                                  
#> 32: White Female Industrial/Systems    73    54  74.0
#> 33: White Female         Mechanical   213   134  62.9
#> 34:   White Male              Civil   948   612  64.6
#> 35:   White Male         Electrical   848   439  51.8
#> 36:   White Male Industrial/Systems   178   130  73.0
#> 37:   White Male         Mechanical  1587   952  60.0
```

With one quantitative variable (stickiness) for every combination of the
levels of two categorical variables (program and people), these are
*multiway data* ([Cleveland 1993](#ref-Cleveland:1993)). How one orders
the categorical variables is critical for visualizing effects.

[`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)
converts the two categorical variables to ordered factors to support the
ordering of rows and panels in the chart. Ordering is based on a
calculation of aggregate stickiness values reported in two columns added
to the data frame, one column per category.

``` r

DT_chart <- order_multiway(DT_chart,
  quantity = "stick",
  categories = c("people", "program"),
  method = "percent",
  ratio_of = c("grad", "ever")
)
DT_chart[, c("ever", "grad") := NULL]
DT_chart
#>           people            program stick people_metric program_metric
#>           <fctr>             <fctr> <num>         <num>          <num>
#>  1: Asian Female              Civil  71.4          64.0           62.4
#>  2: Asian Female         Electrical  57.1          64.0           50.3
#>  3: Asian Female Industrial/Systems  66.7          64.0           71.5
#>  4:   Asian Male              Civil  75.8          62.8           62.4
#>  5:   Asian Male         Electrical  58.2          62.8           50.3
#>  6:   Asian Male Industrial/Systems  66.7          62.8           71.5
#> ---                                                                   
#> 32: White Female Industrial/Systems  74.0          61.1           71.5
#> 33: White Female         Mechanical  62.9          61.1           59.1
#> 34:   White Male              Civil  64.6          59.9           62.4
#> 35:   White Male         Electrical  51.8          59.9           50.3
#> 36:   White Male Industrial/Systems  73.0          59.9           71.5
#> 37:   White Male         Mechanical  60.0          59.9           59.1
```

Format the chart for publication. No arguments for ordering the data are
required because the two categorical variables are ordered factors.

``` r

ggplot(DT_chart, aes(x = stick, y = people)) +
  facet_wrap(vars(program),
    ncol = 1,
    as.table = FALSE
  ) +
  geom_vline(aes(xintercept = program_metric),
    linetype = 2,
    color = "gray60"
  ) +
  geom_point(size = 1.8) +
  labs(x = "Stickiness (%)", y = "") +
  theme_light(base_size = 10)
```

![Figure 1: Program stickiness.](figures/art-004-fig01-1.png)

Figure 1: Program stickiness.

The vertical dashed line in each panel represents the overall stickiness
of the program, calculated without regard to race/ethnicity and sex. The
panels are ordered by those values, increasing from bottom to top. The
stickiness of each “people” group, calculated without regard to program,
determines the row order, also increasing from bottom to top.

In the next chart, we swap the roles of panels and rows.

``` r

ggplot(DT_chart, aes(x = stick, y = program)) +
  facet_wrap(vars(people),
    ncol = 2,
    as.table = FALSE
  ) +
  geom_vline(aes(xintercept = people_metric),
    linetype = 2,
    color = "gray60"
  ) +
  geom_point(size = 1.8) +
  labs(x = "Stickiness (%)", y = "") +
  theme_light(base_size = 10)
```

![Figure 2: Program stickiness.](figures/art-004-fig02-1.png)

Figure 2: Program stickiness.

In this version, the vertical dashed line in each panel represents the
overall stickiness of the people group, calculated without regard to
program. Panels are ordered by increasing group stickiness from left to
right and from bottom to top.

## References

Cleveland, William S. 1993. *Visualizing Data*. Hobart Press.

Mount, John, and Nina Zumel. 2019. *Coordinatized data: A fluid data
specification*. Win Vector LLC.
[http://winvector.github.io/FluidData/RowsAndColumns.html](http://winvector.github.io/FluidData/RowsAndColumns.md).

Ohland, Matthew, Marisa Orr, Richard Layton, Susan Lord, and Russell
Long. 2012. “Introducing stickiness as a versatile metric of engineering
persistence.” *Proceedings of the Frontiers in Education Conference*,
1–5.

*Reference Semantics*. 2026.
<https://r-datatable.com/articles/datatable-reference-semantics.html>.
