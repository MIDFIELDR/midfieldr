# Case study

In this study we present a complete case, from metric to charts,
emphasizing the *process* of manipulating longitudinal data rather than
the code, functions, or arguments. Subsequent articles deal with those
details.

## Outline

In any study, the data handling process depends on how you structure
your data and how you define your metrics, population, blocs, programs,
and groupings. In this study, we select the following:

*Data.*   The midfieldr program codes in `cip` and the midfielddata
practice data tables `student`, `term`, and `degree`.

*Programs.*   Civil, Electrical, Industrial, and Mechanical Engineering.

*Metric.*   Program *stickiness:* the ratio \small (S) of the number of
graduates of a program \small (N\_\textrm{grad}) to the number ever
enrolled in the program \small (N\_\textrm{ever}). This metric includes
part-time students, transfers, students admitted in any term, and
migrators ([Ohland et al. 2012](#ref-Ohland+Orr+others:2012)).

\small S = \frac{\small N\_\textrm{grad}}{\small N\_\textrm{ever}} =
\frac{\small\mathrm{number\\ of\\ graduates\\ of\\ a\\
program}}{\small\mathrm{number\\ ever\\ enrolled\\ in\\ the\\ program}}

*Records.*   Exclude records later than a student’s first degree term.

*Population.*   Degree-seeking students for whom the data sufficiency
constraint is satisfied. No exclusions due to part-time status, transfer
status, admission term, or starting program.

*Blocs.*   The stickiness metric requires two blocs: students ever
enrolled in the programs; and timely graduates of the programs without
regard to their starting programs.

*Groupings.*   Program, race/ethnicity, and sex will be used for
grouping and summarizing. Groups too small to preserve anonymity will be
excluded.

*Results.*   To group and summarize, we require a data frame with
columns for bloc, program, race/ethnicity, and sex, keyed by student ID.
After summarizing and computing the metric we should have columns for
the metric (stickiness) and for each grouping variable (program,
race/ethnicity, sex).

If you are writing your own script to follow along, we use these
packages in this article:

``` r

library(midfieldr)
library(midfielddata)
library(data.table)
```

## Programs

One can start an analysis with program data or with student record
data—the choice is arbitrary. We start with programs and set the results
aside until needed. Our goal is to search the CIP data table for the
6-digit codes for our programs. The `cip` dataset loads with midfieldr,
and is documented in
[`?cip`](https://midfieldr.github.io/midfieldr/reference/cip.md).

Finding the program codes entails some trial and error. Let’s start with
Civil Engineering.

``` r

filter_cip("civil engineering", cip = cip)
#>                                          cip6name   cip6
#>                                            <char> <char>
#> 1:                     Civil Engineering, General 140801
#> 2:                       Geotechnical Engineering 140802
#> 3:                         Structural Engineering 140803
#> 4:         Transportation and Highway Engineering 140804
#> 5:                    Water Resources Engineering 140805
#> 6:                       Civil Engineering, Other 140899
#> 7:       Civil Engineering Technology, Technician 150201
#> 8: Civil Drafting and Civil Engineering CAD, CADD 151304
#>                                                  cip4name   cip4
#>                                                    <char> <char>
#> 1:                                      Civil Engineering   1408
#> 2:                                      Civil Engineering   1408
#> 3:                                      Civil Engineering   1408
#> 4:                                      Civil Engineering   1408
#> 5:                                      Civil Engineering   1408
#> 6:                                      Civil Engineering   1408
#> 7:            Civil Engineering Technologies, Technicians   1502
#> 8: Drafting, Design Engineering Technologies, Technicians   1513
#>                  cip2name   cip2
#>                    <char> <char>
#> 1:            Engineering     14
#> 2:            Engineering     14
#> 3:            Engineering     14
#> 4:            Engineering     14
#> 5:            Engineering     14
#> 6:            Engineering     14
#> 7: Engineering Technology     15
#> 8: Engineering Technology     15
```

We note two things:

- The 2-digit code for Engineering is “14”
- Civil Engineering (not “technology”) has 4-digit code of “1408”

We take a first pass searching for “^14” (regular expression for “line
that starts with 14”) and use that result as the cip-argument in the
next pass.

``` r

engr_cip <- filter_cip("^14", cip = cip)
filter_cip("civil", cip = engr_cip)
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

In Engineering (at least), the 4-digit code seems to correspond to
department-level, degree-granting programs. Again using `engr_cip`, we
search for “electrical” and find the 4-digit code of “1410.”

``` r

filter_cip("electrical", cip = engr_cip)
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
following 4-digit codes:

- Civil Engineering 1408
- Electrical Engineering 1410
- Mechanical Engineering 1419  
- Industrial/Systems Engineering 1427, 1435, 1436, and 1437.

We create a search string of 4-digit codes and search. We drop all
columns except the 6-digit names and 6-digit codes: `cip6` is the link
from these data to the student records.

``` r

codes_we_want <- c("^1408", "^1410", "^1419", "^1427", "^1435", "^1436", "^1437")
programs <- filter_cip(codes_we_want, cip = engr_cip)
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
(Mechanical), and “ISE” (Industrial/Systems Engineering). We also
abbreviate a couple of terms for a slightly more compact display.

``` r

programs[, program := fcase(
  cip6 %like% "^1408", "CE",
  cip6 %like% "^1410", "EE",
  cip6 %like% "^1419", "ME",
  cip6 %like% c("^1427|^1435|^1436|^1437"), "ISE",
  default = NA_character_
)]
programs[, cip6name := gsub("Engineering", "Engng", cip6name)]
programs[, cip6name := gsub("Communications", "Commn", cip6name)]

programs
#>                                           cip6name   cip6 program
#>                                             <char> <char>  <char>
#>  1:                           Civil Engng, General 140801      CE
#>  2:                             Geotechnical Engng 140802      CE
#>  3:                               Structural Engng 140803      CE
#>  4:               Transportation and Highway Engng 140804      CE
#>  5:                          Water Resources Engng 140805      CE
#>  6:                             Civil Engng, Other 140899      CE
#>  7:        Electrical, Electronics and Commn Engng 141001      EE
#>  8:                        Laser and Optical Engng 141003      EE
#>  9:                       Telecommunications Engng 141004      EE
#> 10: Electrical, Electronics and Commn Engng, Other 141099      EE
#> 11:                               Mechanical Engng 141901      ME
#> 12:                                  Systems Engng 142701     ISE
#> 13:                               Industrial Engng 143501     ISE
#> 14:                            Manufacturing Engng 143601     ISE
#> 15:                            Operations Research 143701     ISE
```

Our programs data frame is complete: 15 six-digit codes are encoded
using 4 program names The original 6-digit names act as a check on the
abbreviations we assigned. Later, as we prepare the blocs required for
the metric, we will join the `program` values to the blocs by matching
on `cip6`.

This data frame can sit in memory (or written to file) until we’re ready
to filter the blocs by program.

## Records

*Load the data.*   We load three of the midfielddata data tables.

``` r

data(student, term, degree)
```

*Copy the source data.*   We usually copy the source data, giving them
new names (and new locations in memory), to keep them intact while we
use the original names — `student`, `term`, and `degree` — to do our
work. Otherwise, the source data would be altered “by reference” as we
work.

``` r

student_source <- copy(student)
term_source <- copy(term)
degree_source <- copy(degree)
```

Having `student`, `term`, and `degree` in our computational environment
is convenient because these names appear as the default values for
arguments in some midfieldr functions. For example, if the object
`degree` exists in the environment, then we can write
`add_post_bacc(dframe)` instead of
`add_post_bacc(dframe, midfield_degree = degree)`.

*Choose columns required by midfieldr functions.*   Optional, but
convenient for viewing data frames at intermediate stages. We subset our
data to select the minimum set of columns required by midfieldr
functions.

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

*Identify rows of post-baccalaureate terms to exclude.*   This step
identifies terms later than the first baccalaureate, if any. We are not
generally interested in terms beyond the first degree term, so we use
the results to exclude post-first-degree terms. This step does not apply
to the `student` table because it contains no term information.

This step adds two columns (`first_degree_term` and `term_status`) to a
data frame:

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

We exclude rows with post-baccalaureate terms.

``` r

term <- term[term_status != "post-first-degree"]
degree <- degree[term_status != "post-first-degree"]
```

Dropping the two temporary columns and ensuring rows are unique yields
the baseline records in their final configuration.

``` r

cols_to_drop <- c("first_degree_term", "term_status")
term[, (cols_to_drop) := NULL]
degree[, (cols_to_drop) := NULL]

student <- unique(student)
term <- unique(term)
degree <- unique(degree)
```

These three data frames are the basis of all further analysis.

``` r

look_at(student)
#> Classes 'data.table' and 'data.frame':   97555 obs. of  4 variables:
#>  $ mcid       : chr  "MCID3111142225" "MCID3111142283" "MCID3111142290" "MCID"..
#>  $ institution: chr  "Institution B" "Institution J" "Institution J" "Institu"..
#>  $ race       : chr  "Asian" "Asian" "Asian" "Asian" ...
#>  $ sex        : chr  "Male" "Female" "Male" "Male" ...

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

## Population

Our goal is developing a data frame with one column of IDs that
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
#>     4: MCID3111142294
#>     5: MCID3111142299
#>    ---               
#> 97532: MCID3112898886
#> 97533: MCID3112898890
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
#>     4: MCID3111142294  19881 01 First-year        6       19933
#>     5: MCID3111142299  19881 01 First-year        6       19933
#>    ---                                                         
#> 97532: MCID3112898886  20181 01 First-year        6       20233
#> 97533: MCID3112898890  20181 01 First-year        6       20233
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
#>     4: MCID3111142294       19933  19881       19881       20096
#>     5: MCID3111142299       19933  19881       19881       20096
#>    ---                                                          
#> 97532: MCID3112898886       20233  20181       19881       20181
#> 97533: MCID3112898890       20233  20181       19881       20181
#> 97534: MCID3112898894       20233  20181       19881       20181
#> 97535: MCID3112898895       20233  20181       19881       20181
#> 97536: MCID3112898940       20233  20181       19881       20181
#>        data_sufficiency
#>                  <char>
#>     1:    exclude-lower
#>     2:    exclude-lower
#>     3:    exclude-lower
#>     4:    exclude-lower
#>     5:    exclude-lower
#>    ---                 
#> 97532:    exclude-upper
#> 97533:    exclude-upper
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

Filtering for the “include” label and dropping all but the ID column,

``` r

DT <- DT[data_sufficiency == "include", .(mcid)]
DT
#>                  mcid
#>                <char>
#>     1: MCID3111142689
#>     2: MCID3111142782
#>     3: MCID3111142881
#>     4: MCID3111142884
#>     5: MCID3111142893
#>    ---               
#> 76861: MCID3112727985
#> 76862: MCID3112730841
#> 76863: MCID3112785480
#> 76864: MCID3112800920
#> 76865: MCID3112870009
```

*Filter rows for degree seeking.*   Using this result, we apply an inner
join with the student data table, which contains degree-seeking students
only. The result contains rows that are common to both by ID—in effect,
removing rows from `DT` of any non-degree-seeking students.

``` r

DT <- student[DT, on = "mcid", nomatch = NULL]
DT
#>                  mcid   institution          race    sex
#>                <char>        <char>        <char> <char>
#>     1: MCID3111142689 Institution B      Hispanic Female
#>     2: MCID3111142782 Institution J      Hispanic Female
#>     3: MCID3111142881 Institution B International   Male
#>     4: MCID3111142884 Institution B International   Male
#>     5: MCID3111142893 Institution B International   Male
#>    ---                                                  
#> 76861: MCID3112727985 Institution B         White Female
#> 76862: MCID3112730841 Institution B      Hispanic Female
#> 76863: MCID3112785480 Institution C         White   Male
#> 76864: MCID3112800920 Institution B         White Female
#> 76865: MCID3112870009 Institution B         White   Male
```

It happens that all students in the practice data are degree-seeking, so
this step did not reduce the size of our population. (We include the
step to illustrate our complete process.)

Extracting the column of IDs yields our baseline population.

``` r

population <- DT[, .(mcid)]
population
#>                  mcid
#>                <char>
#>     1: MCID3111142689
#>     2: MCID3111142782
#>     3: MCID3111142881
#>     4: MCID3111142884
#>     5: MCID3111142893
#>    ---               
#> 76861: MCID3112727985
#> 76862: MCID3112730841
#> 76863: MCID3112785480
#> 76864: MCID3112800920
#> 76865: MCID3112870009
```

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
#>     4: MCID3111142884   grad
#>     5: MCID3111142893   grad
#>    ---                      
#> 76861: MCID3112727985   grad
#> 76862: MCID3112730841   grad
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
#>     4: MCID3111142965   grad 141001       19901
#>     5: MCID3111143066   grad 090401       19883
#>    ---                                         
#> 43843: MCID3112693003   grad 260406       20171
#> 43844: MCID3112693979   grad 450601       20181
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
#>     4: MCID3111142965   grad 141001       19901  19883 01 First-year        6
#>     5: MCID3111143066   grad 090401       19883  19883 01 First-year        6
#>    ---                                                                       
#> 43843: MCID3112693003   grad 260406       20171  20093 01 First-year        6
#> 43844: MCID3112693979   grad 450601       20181  20114 01 First-year        6
#> 43845: MCID3112694738   grad 230101       20143  20103 01 First-year        6
#> 43846: MCID3112698681   grad 110701       20181  20113 01 First-year        6
#> 43847: MCID3112730841   grad 040401       20164  20121 01 First-year        6
#>        timely_term
#>             <char>
#>     1:       19941
#>     2:       19941
#>     3:       19951
#>     4:       19941
#>     5:       19941
#>    ---            
#> 43843:       20151
#> 43844:       20173
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
#>     4: MCID3111142965   grad 141001       19941       19901            timely
#>     5: MCID3111143066   grad 090401       19941       19883            timely
#>    ---                                                                       
#> 43843: MCID3112693003   grad 260406       20151       20171              late
#> 43844: MCID3112693979   grad 450601       20173       20181              late
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
#>     4: MCID3111142965   grad 141001
#>     5: MCID3111143066   grad 090401
#>    ---                             
#> 40486: MCID3112675459   grad 261310
#> 40487: MCID3112675472   grad 500703
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
#>     4: MCID3111142965   grad      EE 141001
#>     5: MCID3111143066   grad    <NA> 090401
#>    ---                                     
#> 40486: MCID3112675459   grad    <NA> 261310
#> 40487: MCID3112675472   grad    <NA> 500703
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
#>    4: MCID3111146674   grad      EE 141001
#>    5: MCID3111150194   grad     ISE 143501
#>   ---                                     
#> 3259: MCID3112618553   grad      ME 141901
#> 3260: MCID3112618574   grad      ME 141901
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
#>    4: MCID3111146674   grad      EE
#>    5: MCID3111150194   grad     ISE
#>   ---                              
#> 3259: MCID3112618553   grad      ME
#> 3260: MCID3112618574   grad      ME
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
#>     4: MCID3111142884   ever
#>     5: MCID3111142893   ever
#>    ---                      
#> 76861: MCID3112727985   ever
#> 76862: MCID3112730841   ever
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
#>      4: MCID3111142782   ever 260101
#>      5: MCID3111142782   ever 260101
#>     ---                             
#> 525442: MCID3112800920   ever 240199
#> 525443: MCID3112870009   ever 240102
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
#>    4: MCID3111146674   ever      EE 141001
#>    5: MCID3111150194   ever     ISE 143501
#>   ---                                     
#> 5579: MCID3112619484   ever      EE 141001
#> 5580: MCID3112619666   ever      ME 141901
#> 5581: MCID3112641399   ever      ME 141901
#> 5582: MCID3112641535   ever      ME 141901
#> 5583: MCID3112698681   ever      ME 141901
```

## References

Ohland, Matthew, Marisa Orr, Richard Layton, Susan Lord, and Russell
Long. 2012. “Introducing stickiness as a versatile metric of engineering
persistence.” *Proceedings of the Frontiers in Education Conference*,
1–5.
