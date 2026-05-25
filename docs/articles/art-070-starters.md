# Starters

A degree-seeking student enrolled in their first degree-granting program
is a *starter* in that program. Identifying starters is typically
performed as part of a graduation rate calculation, though it can also
be a useful measure in its own right.

This vignette in the MIDFIELD workflow.

1.  Planning  
2.  Initial processing  
3.  Blocs
    - Ever-enrolled  
    - FYE proxies  
    - Starters
    - Graduates  
4.  Groupings  
5.  Metrics  
6.  Displays

## Special cases

In two special cases, an entering student’s CIP code does not correspond
to a degree-granting program. Our procedure for identifying starters
accommodate both special cases.

The first case includes records for which a CIP is unspecified or
reported as “undecided”. In MIDFIELD data, both conditions are encoded
as CIP 999999. Students may *enter* with this CIP but we do not consider
them *starters* until and if they enroll in a degree-granting program.
(The midfielddata practice datasets contain no undecided CIP codes.)

The second case is more nuanced. At some US institutions, engineering
students are required to complete a First-Year Engineering (FYE) program
as a prerequisite for declaring an engineering major. These students are
admitted as Engineering majors but we don’t know to which
degree-granting program they intended to transition. At the 2-digit CIP
level, FYE students are starters in Engineering (CIP 14). If we do not
restrict a study to 2-digit CIPs, however, we use [FYE
proxies](https://midfieldr.github.io/midfieldr/articles/art-060-fye-proxies.md)—our
estimates of the degree-granting engineering programs (6-digit CIP
level) that FYE students would have declared had they not been required
to enroll in FYE.

## Definitions

- bloc:

  A grouping of student-level data dealt with as a unit, for example,
  starters, students ever-enrolled, graduates, transfer students,
  traditional and non-traditional students, migrators, etc.

- degree-seeking:

  Describes students advancing toward a bachelor’s degree, accumulating
  credit hours in their program with the goal of graduating from their
  institution.

- starters:

  Bloc of degree-seeking students in their initial terms enrolled in
  degree-granting programs.

- entry term:

  A student’s first term in the database.

- start term:

  The first term in which a student can be considered a starter.
  Identical to the entry term unless the student enters as
  undecided/unspecified.

- undecided/unspecified:

  The MIDFIELD taxonomy includes the non-IPEDS code (CIP 999999) for
  Undecided or Unspecified indicating instances in which a student has
  not declared a major or an institution had not recorded a program.

- FYE:

  First-Year Engineering program, a common-first-year curriculum that is
  a prerequisite for declaring an engineering major at some US
  institutions. Denoted by its own CIP code, FYE is not a
  degree-granting program.

- FYE proxy:

  Our estimate of the degree-granting engineering program in which an
  FYE student would have enrolled had they not been required to enroll
  in FYE. The proxy, a 6-digit CIP code, denotes the program of which
  the FYE student can be considered a starter.

## Method

We use `student` and `term` to identify starters.

1.  Filter the source student-level records for data sufficiency and
    degree-seeking.

2.  Filter for a student’s first term not assigned an undecided/unknown
    CIP code.

3.  Identify the program(s) of which a student can be considered a
    starter. Substitute an FYE proxy when a starting program is FYE.

4.  Filter by program.

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
[`?term`](https://midfieldr.github.io/midfielddata/reference/term.html).

``` r

# Load practice data
data(student, term)
```

*Loads with midfieldr.*   Prepared data. View data dictionaries via
[`?study_programs`](https://midfieldr.github.io/midfieldr/reference/study_programs.md),
[`?baseline_mcid`](https://midfieldr.github.io/midfieldr/reference/baseline_mcid.md),
[`?fye_proxy`](https://midfieldr.github.io/midfieldr/reference/fye_proxy.md).

- `study_programs` (derived in
  [Programs](https://midfieldr.github.io/midfieldr/articles/art-040-programs.html#assigning-program-names)).

- `baseline_mcid` (derived in
  [Blocs](https://midfieldr.github.io/midfieldr/articles/art-050-blocs.html#initial-processing)).

- `fye_proxy` (derived in [FYE
  proxies](https://midfieldr.github.io/midfieldr/articles/art-060-fye-proxies.md)).

## Initial processing

*Select (optional).*   Reduce the number of columns. Code reproduced
from [Getting
started](https://midfieldr.github.io/midfieldr/articles/art-000-getting-started.html#reusable-code).

``` r

# Optional. Copy of source files with all variables
source_student <- copy(student)
source_term <- copy(term)

# Optional. Select variables required by midfieldr functions
student <- select_required(source_student)
term <- select_required(source_term)
```

*Initialize.*   Use the `term` and `student` data tables to obtain a
data frame of student IDs meeting the data sufficiency and
degree-seeking criteria. Applied to the practice data, this procedure
yields the `baseline_mcid` data frame derived in
[Blocs](https://midfieldr.github.io/midfieldr/articles/art-050-blocs.html#initial-processing)
and included with midfieldr.

``` r

# Working data frame
DT <- copy(baseline_mcid)
```

## Isolate the start term

The *start term* is the first term in which a student can be considered
a starter, that is, they are degree-seeking and not recorded as
undecided/unspecified.

*Add variables*.   Left join to add terms and CIPs for these students.

``` r

# Term into DT left join
DT <- term[DT, .(mcid, term, cip6), on = c("mcid")]
DT
#>                   mcid   term   cip6
#>                 <char> <char> <char>
#>      1: MCID3111142689  19883 090401
#>      2: MCID3111142782  19883 260101
#>      3: MCID3111142782  19885 260101
#>     ---                             
#> 531417: MCID3112870009  19953 240102
#> 531418: MCID3112870009  19954 240102
#> 531419: MCID3112870009  19983 240102
```

*Filter.*   We remove observations of undecided/unspecified (CIP
999999). Any rows remaining for the same IDs will have CIPs of
degree-granting program (or FYE), allowing us to infer their preferred
starting programs. (A required step for completeness, but unnecessary
when using the practice data.)

``` r

# Remove undecided/unspecified
DT <- DT[!cip6 %like% "999999"]
DT
#>                   mcid   term   cip6
#>                 <char> <char> <char>
#>      1: MCID3111142689  19883 090401
#>      2: MCID3111142782  19883 260101
#>      3: MCID3111142782  19885 260101
#>     ---                             
#> 531417: MCID3112870009  19953 240102
#> 531418: MCID3112870009  19954 240102
#> 531419: MCID3112870009  19983 240102
```

*Filter.*   Order rows by ID and term, then filter to retain the start
term observation(s). The `.SD[term == min(term)]` retains multiple rows
for the same ID just in case a student is enrolled in more than one
program in their first term.

``` r

# Retain observations of the earliest remaining terms by ID
DT <- DT[, .SD[term == min(term)], by = "mcid"]
DT
#>                  mcid   term   cip6
#>                <char> <char> <char>
#>     1: MCID3111142689  19883 090401
#>     2: MCID3111142782  19883 260101
#>     3: MCID3111142881  19893 450601
#>    ---                             
#> 76873: MCID3112785480  20071 240102
#> 76874: MCID3112800920  20101 240102
#> 76875: MCID3112870009  19951 240102
```

*Filter.*   Remove unnecessary variables and filter for unique
observations.

``` r

# Unique combinations of ID and CIP
DT <- DT[, .(mcid, cip6)]
DT <- unique(DT)
DT
#>                  mcid   cip6
#>                <char> <char>
#>     1: MCID3111142689 090401
#>     2: MCID3111142782 260101
#>     3: MCID3111142881 450601
#>    ---                      
#> 76873: MCID3112785480 240102
#> 76874: MCID3112800920 240102
#> 76875: MCID3112870009 240102
```

## Starters without FYE

If and only if our study excluded Engineering programs that require FYE,
the data frame just derived would be the desired bloc of starters.

In such a case, we would rename `cip6` to `start` to make explicit that
the CIP codes in this column represent programs of which the students
can be considered starters. The code would have the form

``` r

# Not run
DT <- DT[, .(mcid, start = cip6)]
```

which retains the ID variable and changes the name of the CIP variable.

## Starters with FYE

*Add a variable.*   Merge `fye_proxy` with the working data frame. The
left join introduces NA in the proxy column for students not assigned an
FYE proxy.

``` r

# Join the proxies to the working data frame
DT <- fye_proxy[DT, on = c("mcid")]
DT
#>                  mcid  proxy   cip6
#>                <char> <char> <char>
#>     1: MCID3111142689   <NA> 090401
#>     2: MCID3111142782   <NA> 260101
#>     3: MCID3111142881   <NA> 450601
#>    ---                             
#> 76873: MCID3112785480   <NA> 240102
#> 76874: MCID3112800920   <NA> 240102
#> 76875: MCID3112870009   <NA> 240102
```

*Create a variable.*   Estimated starting programs for FYE students are
in the `proxy` column. Actual, recorded starting programs for non-FYE
students are in the `cip6` column. Create the `start` column to combine
the two.

``` r

# Combine all starting CIPs
DT[, start := fcase(
  cip6 == "140102", proxy,
  cip6 != "140102", cip6
)]
DT
#>                  mcid  proxy   cip6  start
#>                <char> <char> <char> <char>
#>     1: MCID3111142689   <NA> 090401 090401
#>     2: MCID3111142782   <NA> 260101 260101
#>     3: MCID3111142881   <NA> 450601 450601
#>    ---                                    
#> 76873: MCID3112785480   <NA> 240102 240102
#> 76874: MCID3112800920   <NA> 240102 240102
#> 76875: MCID3112870009   <NA> 240102 240102
```

*Select.*   Omit unnecessary columns.

``` r

# Omit unnecessary columns.
DT <- DT[, .(mcid, start)]
DT
#>                  mcid  start
#>                <char> <char>
#>     1: MCID3111142689 090401
#>     2: MCID3111142782 260101
#>     3: MCID3111142881 450601
#>    ---                      
#> 76873: MCID3112785480 240102
#> 76874: MCID3112800920 240102
#> 76875: MCID3112870009 240102
```

### Closer look

Examining the records of selected students in detail.

*Example 1.*   In our results, this student is a starter in CIP 143501
(Industrial Engineering).

``` r

# Analysis result
DT[mcid == "MCID3111150194"]
#>              mcid  start
#>            <char> <char>
#> 1: MCID3111150194 143501
```

An excerpt from their record in `term` shows them enrolled in CIP 140102
(FYE) for three terms followed by CIP 143501 They transitioned post-FYE
to Industrial Engineering and we consider them a starter in that
program.

``` r

# Sequence of term records
term[mcid == "MCID3111150194"]
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
```

*Example 2.*   In our results, this student is a starter in CIP 141801
(Materials Engineering).

``` r

# Analysis result
DT[mcid == "MCID3111161837"]
#>              mcid  start
#>            <char> <char>
#> 1: MCID3111161837 141801
```

An excerpt from their record in `term` shows them enrolled in CIP 140102
(FYE) for three terms followed by CIP 270101 (Mathematics)—they
transitioned from FYE to a non-engineering major. Thus we consider them
a starter in their proxy program, Materials Engineering.

``` r

# Sequence of term records
term[mcid == "MCID3111161837"]
#>               mcid   institution   term   cip6              level
#>             <char>        <char> <char> <char>             <char>
#>  1: MCID3111161837 Institution J  19883 140102      01 First-year
#>  2: MCID3111161837 Institution J  19891 140102     02 Second-year
#>  3: MCID3111161837 Institution J  19893 140102     02 Second-year
#>  4: MCID3111161837 Institution J  19905 270101     02 Second-year
#>  5: MCID3111161837 Institution J  19906 270101     02 Second-year
#>  6: MCID3111161837 Institution J  19913 270101      03 Third-year
#>  7: MCID3111161837 Institution J  19921 270101      03 Third-year
#>  8: MCID3111161837 Institution J  19923 270101     04 Fourth-year
#>  9: MCID3111161837 Institution J  19931 270101     04 Fourth-year
#> 10: MCID3111161837 Institution J  19933 270101     04 Fourth-year
#> 11: MCID3111161837 Institution J  19935 270101 05 Fifth-year Plus
```

*Example 3.*   In our results, this student is a starter in CIP 140701
(Chemical Engineering).

``` r

# Analysis result
DT[mcid == "MCID3111303095"]
#>              mcid  start
#>            <char> <char>
#> 1: MCID3111303095 140701
```

An excerpt from their record in `term` shows them enrolled in CIP 140102
(FYE) for two terms and then leaving the database. Again, we consider
them a starter in their proxy program, Chemical Engineering.

``` r

term[mcid == "MCID3111303095"]
#>              mcid   institution   term   cip6         level
#>            <char>        <char> <char> <char>        <char>
#> 1: MCID3111303095 Institution J  19911 140102 01 First-year
#> 2: MCID3111303095 Institution J  19913 140102 01 First-year
```

## Filter by program

*Filter.*   Because “starter” usually means “starter in specific
programs,” this bloc concludes with a filter by program.

``` r

# Rename cip6 as start
join_labels <- copy(study_programs)
join_labels <- join_labels[, .(program, start = cip6)]

# Filter by program
DT <- join_labels[DT, on = c("start"), nomatch = NULL]
DT
#>       program  start           mcid
#>        <char> <char>         <char>
#>    1:      EE 141001 MCID3111142965
#>    2:      EE 141001 MCID3111145102
#>    3:     ISE 143501 MCID3111150194
#>   ---                              
#> 4046:      EE 141001 MCID3112619118
#> 4047:      EE 141001 MCID3112619484
#> 4048:      ME 141901 MCID3112619666
```

*Select.*   Omit unnecessary variables.

``` r

DT <- DT[, .(mcid, program)]
DT <- unique(DT)
DT
#>                 mcid program
#>               <char>  <char>
#>    1: MCID3111142965      EE
#>    2: MCID3111145102      EE
#>    3: MCID3111150194     ISE
#>   ---                       
#> 4046: MCID3112619118      EE
#> 4047: MCID3112619484      EE
#> 4048: MCID3112619666      ME
```

## Reusable code

*Preparation.*   The data frame of baseline IDs is the intake for this
section.

``` r

DT <- copy(baseline_mcid)
```

*Starters.*   Summary code chunks for ready reference.

``` r

# Isolate starting term
DT <- term[DT, .(mcid, term, cip6), on = c("mcid")]
DT <- DT[!cip6 %like% "999999"]
setorderv(DT, cols = c("mcid", "term"))
DT <- DT[, .SD[term == min(term)], by = "mcid"]
DT <- DT[, .(mcid, cip6)]
DT <- unique(DT)
```

For starters without FYE, finish by renaming `cip6`

``` r

# Not run
DT <- DT[, .(mcid, start = cip6)]
```

For starters with FYE, continue with FYE proxies.

``` r

DT <- fye_proxy[DT, .(mcid, cip6, proxy), on = c("mcid")]
DT[, start := fcase(
  cip6 == "140102", proxy,
  cip6 != "140102", cip6
)]
DT <- DT[, .(mcid, start)]

# Filter by program on start
join_labels <- copy(study_programs)
join_labels <- join_labels[, .(program, start = cip6)]
DT <- join_labels[DT, on = c("start"), nomatch = NULL]
DT <- DT[, .(mcid, program)]
DT <- unique(DT)
```

------------------------------------------------------------------------

[◁ FYE
proxies](https://midfieldr.github.io/midfieldr/articles/art-060-fye-proxies.md)
   [▲ top of page](#top)    [Graduates
▷](https://midfieldr.github.io/midfieldr/articles/art-080-graduates.md)

------------------------------------------------------------------------

## References
