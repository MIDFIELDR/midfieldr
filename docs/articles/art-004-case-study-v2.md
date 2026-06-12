# Case study

In this study we present a complete case, from metric to records to
charts, with an emphasis on how midfieldr supports the *process* of
working with longitudinal data, leaving the details of the code itself
to later detailed articles.

## Introduction

*Metric.*   *Stickiness* is the ratio \small (S) of the number of
graduates of a program \small (N\_\textrm{grad}) to the number ever
enrolled in the program \small (N\_\textrm{ever}). This metric includes
part-time students, transfers, students admitted in any term, and
migrators ([Ohland et al. 2012](#ref-Ohland+Orr+others:2012)).

\small S = \frac{N\_\textrm{grad}}{N\_\textrm{ever}} =
\frac{\mathrm{number\\ of\\ graduates\\ of\\ a\\
program}}{\mathrm{number\\ ever\\ enrolled\\ in\\ the\\ program}}

*Records.*   Records up to and including a student’s first degree term,
if any.

*Population.*   Degree-seeking students for whom the data sufficiency
constraint is satisfied. No exclusions due to part-time status, transfer
status, admission term, or starting program.

*Programs.*   Civil, Electrical, Industrial, and Mechanical Engineering.

*Groupings.*   The metric requires counts of timely graduates and of
students ever enrolled in a program. We will group by program,
race/ethnicity and sex.

We use the following packages:

``` r

library(midfieldr)
library(midfielddata)
library(data.table)
```

## Choose the baseline records

*Load the data.*   We use the practice data provided in the midfielddata
package. Data are given in four tables: `student`, `course`, `term`, and
`degree`, three of which we load for this case.

``` r

data(student, term, degree)
```

*Keep a copy of the original source data.*   We copy the original data
to preserve them should we need them later. This step allows us to
continue using the simple names `student`, `term`, etc. as we work
without affecting the original source data due to data.table’s “change
by reference” behavior.

``` r

student_source <- copy(student)
term_source <- copy(term)
degree_source <- copy(degree)
```

*Reduce the number of columns.*   Optional, but convenient for viewing
data frames at intermediate stages. We subset our data to select the
minimum set of columns required by midfieldr functions.

``` r

student <- select_basic_cols(student)
term <- select_basic_cols(term)
degree <- select_basic_cols(degree)

look_at(student)
#> Classes 'data.table' and 'data.frame':   97555 obs. of  4 variables:
#>  $ mcid       : chr  "MCID3111142225" "MCID3111142283" "MCID3111142290" "MCID"..
#>  $ institution: chr  "Institution B" "Institution J" "Institution J" "Institu"..
#>  $ race       : chr  "Asian" "Asian" "Asian" "Asian" ...
#>  $ sex        : chr  "Male" "Female" "Male" "Male" ...

look_at(term)
#> Classes 'data.table' and 'data.frame':   639915 obs. of  5 variables:
#>  $ mcid       : chr  "MCID3111142225" "MCID3111142283" "MCID3111142283" "MCID"..
#>  $ institution: chr  "Institution B" "Institution J" "Institution J" "Institu"..
#>  $ term       : chr  "19881" "19881" "19883" "19885" ...
#>  $ cip6       : chr  "140901" "240102" "240102" "190601" ...
#>  $ level      : chr  "01 First-year" "01 First-year" "01 First-year" "01 Firs"..

look_at(degree)
#> Classes 'data.table' and 'data.frame':   49665 obs. of  4 variables:
#>  $ mcid       : chr  "MCID3111142225" "MCID3111142290" "MCID3111142294" "MCID"..
#>  $ institution: chr  "Institution B" "Institution J" "Institution J" "Institu"..
#>  $ term_degree: chr  "19881" "19921" "19903" "19921" ...
#>  $ cip6       : chr  "141001" "141001" "141001" "141001" ...
```

*Exclude post-baccalaureate terms.*   Identify rows of
post-baccalaureate terms to exclude. This step does not apply to the
`student` table because it contains no term information. This step adds
two temporary columns to each data frame:

``` r

term <- add_post_bacc(term, midfield_degree = degree)
degree <- add_post_bacc(degree, midfield_degree = degree)

look_at(term)
#> Classes 'data.table' and 'data.frame':   639915 obs. of  7 variables:
#>  $ mcid             : chr  "MCID3111142225" "MCID3111142283" "MCID3111142283""..
#>  $ institution      : chr  "Institution B" "Institution J" "Institution J" "I"..
#>  $ cip6             : chr  "140901" "240102" "240102" "190601" ...
#>  $ level            : chr  "01 First-year" "01 First-year" "01 First-year" "0"..
#>  $ term             : chr  "19881" "19881" "19883" "19885" ...
#>  $ first_degree_term: chr  "19881" NA NA NA ...
#>  $ term_status      : chr  "first-degree" "pre-bacc" "pre-bacc" "pre-bacc" ...

look_at(degree)
#> Classes 'data.table' and 'data.frame':   49665 obs. of  6 variables:
#>  $ mcid             : chr  "MCID3111142225" "MCID3111142290" "MCID3111142294""..
#>  $ institution      : chr  "Institution B" "Institution J" "Institution J" "I"..
#>  $ cip6             : chr  "141001" "141001" "141001" "141001" ...
#>  $ term_degree      : chr  "19881" "19921" "19903" "19921" ...
#>  $ first_degree_term: chr  "19881" "19921" "19903" "19921" ...
#>  $ term_status      : chr  "first-degree" "first-degree" "first-degree" "firs"..
```

Summarizing by term status, we have a total of 6998 post-baccalaureate
terms in `term` and 47 in degree.

``` r

term[, .N, by = c("term_status")]
#>          term_status      N
#>               <char>  <int>
#> 1:      first-degree  34440
#> 2:          pre-bacc 598477
#> 3: post-first-degree   6998

degree[, .N, by = c("term_status")]
#>          term_status     N
#>               <char> <int>
#> 1:      first-degree 49618
#> 2: post-first-degree    47
```

Excluding the post-baccalaureate terms, then dropping the two temporary
columns, yields the final shape of the baseline records.

``` r

term <- term[term_status != "post-first-degree"]
degree <- degree[term_status != "post-first-degree"]

cols_to_drop <- c("first_degree_term", "term_status")
term[, (cols_to_drop) := NULL]
degree[, (cols_to_drop) := NULL]

look_at(term)
#> Classes 'data.table' and 'data.frame':   632917 obs. of  5 variables:
#>  $ mcid       : chr  "MCID3111142225" "MCID3111142283" "MCID3111142283" "MCID"..
#>  $ institution: chr  "Institution B" "Institution J" "Institution J" "Institu"..
#>  $ cip6       : chr  "140901" "240102" "240102" "190601" ...
#>  $ level      : chr  "01 First-year" "01 First-year" "01 First-year" "01 Firs"..
#>  $ term       : chr  "19881" "19881" "19883" "19885" ...

look_at(degree)
#> Classes 'data.table' and 'data.frame':   49618 obs. of  4 variables:
#>  $ mcid       : chr  "MCID3111142225" "MCID3111142290" "MCID3111142294" "MCID"..
#>  $ institution: chr  "Institution B" "Institution J" "Institution J" "Institu"..
#>  $ cip6       : chr  "141001" "141001" "141001" "141001" ...
#>  $ term_degree: chr  "19881" "19921" "19903" "19921" ...
```

*Result.*  

- baseline `student`  
- baseline `term`  
- baseline `degree`

## Identifying the baseline population

The goal here is to develop a data frame with one column of IDs that
satisfies our constraints of data sufficiency and degree-seeking. We
start with the unique IDs from the `term` data table we just derived.

``` r

DT <- copy(term)
DT <- DT[, .(mcid)]
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

*Filter rows for data sufficiency.*   Data sufficiency requires the
timely completion term estimate.

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

We can drop the columns of supporting variables and add the data
sufficiency columns.

``` r

cols_to_drop <- c("level_i", "adj_span")
DT[, (cols_to_drop) := NULL]

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

Summarizing by data sufficiency, we have a total of 20,671 rows to
exclude due to insufficient data, leaving a population of 76,865.

``` r

DT[, .N, by = c("data_sufficiency")]
#>    data_sufficiency     N
#>              <char> <int>
#> 1:    exclude-lower  2746
#> 2:          include 76865
#> 3:    exclude-upper 17925
```

Filtering for the “include” label, and dropping the extra columns,

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

*Filter rows for degree seeking.*   Using this result, we apply an inner
join with the student data table, which contains degree-seeking students
only. The result contains rows that are common to both by ID—in effect,
removing rows from `DT` of any non-degree-seeking students. We also
select the ID column alone to return.

``` r

population <- student[DT, .(mcid), on = "mcid", nomatch = NULL]

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

It happens that all students in the practice data are degree-seeking, so
this step did not reduce the size of our population. We include the step
to illustrate our complete process. The result is our final, baseline
population.

*Result.*  

- baseline `population`

## Collecting and labeling study program codes

In MIDFIELD data tables, the `cip6` variable identifies the 6-digit code
for the program in which a student is enrolled in a given term.

Finding your program codes can be a bit of a trial and error process
(although the NCES website does have a search feature as well). Let’s
start with Civil Engineering.

``` r

filter_cip("civil engineering")
#>       cip2               cip2name   cip4
#>     <char>                 <char> <char>
#>  1:     14            Engineering   1408
#>  2:     14            Engineering   1408
#>  3:     14            Engineering   1408
#> ---                                     
#>  6:     14            Engineering   1408
#>  7:     15 Engineering Technology   1502
#>  8:     15 Engineering Technology   1513
#>                                                   cip4name   cip6
#>                                                     <char> <char>
#>  1:                                      Civil Engineering 140801
#>  2:                                      Civil Engineering 140802
#>  3:                                      Civil Engineering 140803
#> ---                                                              
#>  6:                                      Civil Engineering 140899
#>  7:            Civil Engineering Technologies, Technicians 150201
#>  8: Drafting, Design Engineering Technologies, Technicians 151304
#>                                           cip6name
#>                                             <char>
#>  1:                     Civil Engineering, General
#>  2:                       Geotechnical Engineering
#>  3:                         Structural Engineering
#> ---                                               
#>  6:                       Civil Engineering, Other
#>  7:       Civil Engineering Technology, Technician
#>  8: Civil Drafting and Civil Engineering CAD, CADD
```

We see that the 4-digit code 1408 represents the Civil Engineering
programs we want. We also note from the 2-digit code and name that
Engineering in general has a 2-digit code of 14. So we’ll take a first
pass on “14” and use that result as the `cip` *argument* in the next
pass. We select a subset of the columns to display.

``` r

engr_cip <- filter_cip("^14")
civil_engr <- filter_cip("civil", cip = engr_cip)

civil_engr[, .(cip6, cip6name, cip4name)]
#>      cip6                               cip6name          cip4name
#>    <char>                                 <char>            <char>
#> 1: 140801             Civil Engineering, General Civil Engineering
#> 2: 140802               Geotechnical Engineering Civil Engineering
#> 3: 140803                 Structural Engineering Civil Engineering
#> 4: 140804 Transportation and Highway Engineering Civil Engineering
#> 5: 140805            Water Resources Engineering Civil Engineering
#> 6: 140899               Civil Engineering, Other Civil Engineering
```

Moving on to Electrical Engineering, we find a 4-digit code of 1410.

``` r

elec_engr <- filter_cip("electrical", cip = engr_cip)
elec_engr
#>      cip2    cip2name   cip4
#>    <char>      <char> <char>
#> 1:     14 Engineering   1410
#> 2:     14 Engineering   1410
#> 3:     14 Engineering   1410
#> 4:     14 Engineering   1410
#>                                                  cip4name   cip6
#>                                                    <char> <char>
#> 1: Electrical, Electronics and Communications Engineering 141001
#> 2: Electrical, Electronics and Communications Engineering 141003
#> 3: Electrical, Electronics and Communications Engineering 141004
#> 4: Electrical, Electronics and Communications Engineering 141099
#>                                                         cip6name
#>                                                           <char>
#> 1:        Electrical, Electronics and Communications Engineering
#> 2:                                 Laser and Optical Engineering
#> 3:                                Telecommunications Engineering
#> 4: Electrical, Electronics and Communications Engineering, Other

elec_engr[, .(cip6, cip6name, cip4name)]
#>      cip6                                                      cip6name
#>    <char>                                                        <char>
#> 1: 141001        Electrical, Electronics and Communications Engineering
#> 2: 141003                                 Laser and Optical Engineering
#> 3: 141004                                Telecommunications Engineering
#> 4: 141099 Electrical, Electronics and Communications Engineering, Other
#>                                                  cip4name
#>                                                    <char>
#> 1: Electrical, Electronics and Communications Engineering
#> 2: Electrical, Electronics and Communications Engineering
#> 3: Electrical, Electronics and Communications Engineering
#> 4: Electrical, Electronics and Communications Engineering
```

Continuing in a similar fashion, we establish that the 4-digit codes we
need for study are:

- Civil Engineering 1408
- Electrical Engineering 1410
- Mechanical Engineering 1419  
- Industrial/Systems Engineering 1427, 1435, 1436, and 1437.

From `cip`, we obtain 15 codes that start with any of the selected
4-digit codes. We can drop all columns except the 6-digit code and
4-digit name, leaving

``` r

programs <- filter_cip(c("^1408", "^1410", "^1419", "^1427", "^1435", "^1436", "^1437"))
programs <- programs[, .(cip6, cip4name)]

programs
#>       cip6                                               cip4name
#>     <char>                                                 <char>
#>  1: 140801                                      Civil Engineering
#>  2: 140802                                      Civil Engineering
#>  3: 140803                                      Civil Engineering
#>  4: 140804                                      Civil Engineering
#>  5: 140805                                      Civil Engineering
#>  6: 140899                                      Civil Engineering
#>  7: 141001 Electrical, Electronics and Communications Engineering
#>  8: 141003 Electrical, Electronics and Communications Engineering
#>  9: 141004 Electrical, Electronics and Communications Engineering
#> 10: 141099 Electrical, Electronics and Communications Engineering
#> 11: 141901                                 Mechanical Engineering
#> 12: 142701                                    Systems Engineering
#> 13: 143501                                 Industrial Engineering
#> 14: 143601                              Manufacturing Engineering
#> 15: 143701                                    Operations Research
```

User-defined program names are nearly always required. We add a
`program` variable to label each of these 15 programs with abbreviations
we will use in comparing metrics, i.e., Civil (CE), Electrical (EE),
Mechanical (ME), and Industrial/Systems Engineering (ISE).

``` r

programs[, program := fcase(
  cip6 %like% "^1408", "CE",
  cip6 %like% "^1410", "EE",
  cip6 %like% "^1419", "ME",
  cip6 %chin% c("142701", "143501", "143601", "143701"), "ISE"
)]
```

Now we can drop all but the 6-digit code and the program labels we
created.

``` r

programs <- programs[, .(cip6, program)]

programs
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
```

The result is our programs data frame for the study.

*Result.*  

- study `programs`

## Blocs and groupings

Before computing our metric, we must group and summarize our final
population. We have two blocs (from the definition of the metric):

- ever-enrolled  
- graduates

and three grouping variables

- program
- race/ethnicity
- sex

We have a lot of flexibility in the order in which we construct our
blocs and groupings, so what follows is only one of several effective
solutions.

## Timely-graduates bloc

We start with the baseline population. Like we did with the original
source data files, we copy it to protect `population` from “by
reference” changes.

``` r

graduates <- copy(population)
```

Because we plan on this becoming a bloc of timely graduates, we add a
`bloc` variable with the value “grad”.

``` r

graduates[, bloc := "grad"]

graduates
#>                  mcid   bloc
#>                <char> <char>
#>     1: MCID3111142689   grad
#>     2: MCID3111142782   grad
#>     3: MCID3111142881   grad
#>    ---                      
#> 76863: MCID3112785480   grad
#> 76864: MCID3112800920   grad
#> 76865: MCID3112870009   grad
```

Inner join with `degree` excludes rows of non-completers.

``` r

graduates <- degree[graduates, .(mcid, bloc, cip6, term_degree),
  on = "mcid", nomatch = NULL
]

graduates
#>                  mcid   bloc   cip6 term_degree
#>                <char> <char> <char>      <char>
#>     1: MCID3111142689   grad 090401       19913
#>     2: MCID3111142782   grad 260101       19903
#>     3: MCID3111142881   grad 450601       19894
#>    ---                                         
#> 43845: MCID3112694738   grad 230101       20143
#> 43846: MCID3112698681   grad 110701       20181
#> 43847: MCID3112730841   grad 040401       20164
```

*Filter rows for timely completion.*   Determining a student’s
completion status requires the timely term variable.

``` r

graduates <- add_timely_term(graduates, midfield_term = term)

graduates
#>                  mcid   bloc   cip6 term_degree term_i       level_i adj_span
#>                <char> <char> <char>      <char> <char>        <char>    <num>
#>     1: MCID3111142689   grad 090401       19913  19883 01 First-year        6
#>     2: MCID3111142782   grad 260101       19903  19883 01 First-year        6
#>     3: MCID3111142881   grad 450601       19894  19893 01 First-year        6
#>    ---                                                                       
#> 43845: MCID3112694738   grad 230101       20143  20103 01 First-year        6
#> 43846: MCID3112698681   grad 110701       20181  20113 01 First-year        6
#> 43847: MCID3112730841   grad 040401       20164  20121 01 First-year        6
#>        timely_term
#>             <char>
#>     1:       19941
#>     2:       19941
#>     3:       19951
#>    ---            
#> 43845:       20161
#> 43846:       20171
#> 43847:       20173
```

We can drop the columns of supporting variables and add the completion
status columns.

``` r

cols_to_drop <- c("term_i", "level_i", "adj_span")
graduates[, (cols_to_drop) := NULL]

graduates <- add_completion_status(graduates, midfield_degree = degree)

graduates
#>                  mcid   bloc   cip6 timely_term term_degree completion_status
#>                <char> <char> <char>      <char>      <char>            <char>
#>     1: MCID3111142689   grad 090401       19941       19913            timely
#>     2: MCID3111142782   grad 260101       19941       19903            timely
#>     3: MCID3111142881   grad 450601       19951       19894            timely
#>    ---                                                                       
#> 43845: MCID3112694738   grad 230101       20161       20143            timely
#> 43846: MCID3112698681   grad 110701       20171       20181              late
#> 43847: MCID3112730841   grad 040401       20173       20164            timely
```

Summarizing by completion status, we find 40,490 rows with timely
completion.

``` r

graduates[, .N, by = "completion_status"]
#>    completion_status     N
#>               <char> <int>
#> 1:            timely 40490
#> 2:              late  3357
```

Filtering for the “timely” label and keeping the ID, bloc, and CIP
columns,

``` r

graduates <- graduates[completion_status == "timely", .(mcid, bloc, cip6)]

graduates
#>                  mcid   bloc   cip6
#>                <char> <char> <char>
#>     1: MCID3111142689   grad 090401
#>     2: MCID3111142782   grad 260101
#>     3: MCID3111142881   grad 450601
#>    ---                             
#> 40488: MCID3112692944   grad 090101
#> 40489: MCID3112694738   grad 230101
#> 40490: MCID3112730841   grad 040401
```

We can complete this stage by filtering for programs.

``` r

graduates <- programs[graduates, .(mcid, bloc, program, cip6), on = "cip6"]

graduates
#>                  mcid   bloc program   cip6
#>                <char> <char>  <char> <char>
#>     1: MCID3111142689   grad    <NA> 090401
#>     2: MCID3111142782   grad    <NA> 260101
#>     3: MCID3111142881   grad    <NA> 450601
#>    ---                                     
#> 40488: MCID3112692944   grad    <NA> 090101
#> 40489: MCID3112694738   grad    <NA> 230101
#> 40490: MCID3112730841   grad    <NA> 040401
```

Then drop all rows with an NA program value

``` r

graduates <- graduates[!is.na(program)]

graduates
#>                 mcid   bloc program   cip6
#>               <char> <char>  <char> <char>
#>    1: MCID3111142965   grad      EE 141001
#>    2: MCID3111145102   grad      EE 141001
#>    3: MCID3111146537   grad      EE 141001
#>   ---                                     
#> 3261: MCID3112618976   grad      ME 141901
#> 3262: MCID3112619484   grad      EE 141001
#> 3263: MCID3112641535   grad      ME 141901
```

Drop the CIP code

``` r

graduates[, cip6 := NULL]
graduates <- unique(graduates)

graduates
#>                 mcid   bloc program
#>               <char> <char>  <char>
#>    1: MCID3111142965   grad      EE
#>    2: MCID3111145102   grad      EE
#>    3: MCID3111146537   grad      EE
#>   ---                              
#> 3261: MCID3112618976   grad      ME
#> 3262: MCID3112619484   grad      EE
#> 3263: MCID3112641535   grad      ME
```

Summarize to check results so far

``` r

graduates[, .N, by = "program"]
#>    program     N
#>     <char> <int>
#> 1:      EE   736
#> 2:     ISE   238
#> 3:      ME  1353
#> 4:      CE   936
```

## Ever-enrolled group

Again, we start with the baseline set of IDs and we add a `bloc`
variable with the value “ever”.

``` r

ever_enrolled <- copy(population)
ever_enrolled[, bloc := "ever"]

ever_enrolled
#>                  mcid   bloc
#>                <char> <char>
#>     1: MCID3111142689   ever
#>     2: MCID3111142782   ever
#>     3: MCID3111142881   ever
#>    ---                      
#> 76863: MCID3112785480   ever
#> 76864: MCID3112800920   ever
#> 76865: MCID3112870009   ever
```

Left-join adds all terms

``` r

ever_enrolled <- term[ever_enrolled, .(mcid, bloc, cip6), on = "mcid"]

ever_enrolled
#>                   mcid   bloc   cip6
#>                 <char> <char> <char>
#>      1: MCID3111142689   ever 090401
#>      2: MCID3111142782   ever 260101
#>      3: MCID3111142782   ever 260101
#>     ---                             
#> 525444: MCID3112870009   ever 240102
#> 525445: MCID3112870009   ever 240102
#> 525446: MCID3112870009   ever 240102
```

Filter by programs

``` r

ever_enrolled <- programs[ever_enrolled, .(mcid, bloc, program, cip6), on = "cip6"]
ever_enrolled <- ever_enrolled[!is.na(program)]
ever_enrolled <- unique(ever_enrolled)
ever_enrolled
#>                 mcid   bloc program   cip6
#>               <char> <char>  <char> <char>
#>    1: MCID3111142965   ever      EE 141001
#>    2: MCID3111145102   ever      EE 141001
#>    3: MCID3111146537   ever      EE 141001
#>   ---                                     
#> 5581: MCID3112641399   ever      ME 141901
#> 5582: MCID3112641535   ever      ME 141901
#> 5583: MCID3112698681   ever      ME 141901
```

## References

Ohland, Matthew, Marisa Orr, Richard Layton, Susan Lord, and Russell
Long. 2012. “Introducing stickiness as a versatile metric of engineering
persistence.” *Proceedings of the Frontiers in Education Conference*,
1–5.
