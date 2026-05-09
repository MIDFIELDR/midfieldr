# Graduates

An undergraduate student who completes their program and earns their
first degree is a *completer*. To be counted among their program’s
*graduates* however usually depends on whether they satisfy the
criterion for *timely completion*. We derive a *completion status*
variable to filter student-level records to obtain a bloc of graduates.

This vignette in the MIDFIELD workflow.

1.  Planning  
2.  Initial processing  
3.  Blocs
    - Ever-enrolled  
    - FYE proxies  
    - Starters  
    - Graduates $`\longleftarrow`$
4.  Groupings  
5.  Metrics  
6.  Displays

## Definitions

- bloc:

  A grouping of student-level data dealt with as a unit, for example,
  starters, students ever-enrolled, graduates, transfer students,
  traditional and non-traditional students, migrators, etc.

- **degree-seeking**:

  Describes students advancing toward a bachelor’s degree, accumulating
  credit hours in their program with the goal of graduating from their
  institution.

- **completers**:

  Bloc of degree-seeking students who complete their baccalaureate
  programs, earning their first degrees.

- **timely completion criterion**:

  Completing a program in no more than a specified span of years, in
  many cases, within 6 years after admission (150% of the “normal”
  4-year span), or possibly less for some transfer students.

- **completion status**:

  A derived midfieldr variable indicating whether a student completes a
  degree, and if so, whether their completion was timely. Possible
  values are “timely”, “late”, and “NA”. Late completers are often
  excluded from a count of “graduates.”

- **graduates**:

  Bloc of all graduates (timely completers) from a program, without
  regard to their starting programs.

## Method

A bloc of graduates (timely completers) can be determined independent of
other blocs.

1.  Filter source student-level records for data sufficiency and
    degree-seeking.

2.  Determine completion status.

3.  Filter graduates (timely completers).

4.  Filter by degree program.

The next step might be to subset the graduates if necessary to meet the
needs of the metric. For example, the graduation rate metric requires
graduates to be a subset of starters in the same program. We postpone
this step until treating the metrics.

*Reminder.*   midfielddata datasets are for practice, not research.

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

*Loads with midfieldr.*   Prepared data. View data dictionaries via
[`?study_programs`](https://midfieldr.github.io/midfieldr/reference/study_programs.md),
[`?baseline_mcid`](https://midfieldr.github.io/midfieldr/reference/baseline_mcid.md).

- `study_programs` (derived in
  [Programs](https://midfieldr.github.io/midfieldr/articles/art-040-programs.html#assigning-program-names)).

- `baseline_mcid` (derived in
  [Blocs](https://midfieldr.github.io/midfieldr/articles/art-050-blocs.html#initial-processing)).

## Initial processing

*Select (optional).*   Reduce the number of columns. Code reproduced
from [Getting
started](https://midfieldr.github.io/midfieldr/articles/art-000-getting-started.html#reusable-code).

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

*Initialize.*   Use the `term` and `student` data tables to obtain a
data frame of student IDs meeting the data sufficiency and
degree-seeking criteria. Appled to the practice data, this procedure
yields the `baseline_mcid` data frame derived in
[Blocs](https://midfieldr.github.io/midfieldr/articles/art-050-blocs.html#initial-processing)
and included with midfieldr.

``` r

# Working data frame
DT <- copy(baseline_mcid)
```

## `add_completion_status()`

Add columns to a data frame of student-level records that indicate
whether a student completed a degree, and if so, whether their
completion was timely.

The input data frame must have columns for ID and the timely completion
term. We use
[`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)
again, though alternatively we could have retained the `timely_term`
variable from previous code chunks.

``` r

# Timely term required before completion status
DT <- add_timely_term(DT, term)

# Drop unnecessary columns
DT[, c("term_i", "level_i", "adj_span") := NULL]
```

*Arguments.*

- **`dframe`**   Data frame of student-level records keyed by student
  ID. Required variables are `mcid` and `timely_term`.

- **`midfield_degree`**   Data frame of student-level degree
  observations keyed by student ID. Default is `degree`. Required
  variables are `mcid` and `term_degree`.

*Equivalent usage.*   The following implementations yield identical
results,

``` r

# Required arguments in order and explicitly named
x <- add_completion_status(dframe = DT, midfield_degree = degree)

# Required arguments in order, but not named
y <- add_completion_status(DT, degree)

# Using the implicit default for the midfield_degree argument
z <- add_completion_status(DT)

# Demonstrate equivalence
check_equiv_frames(x, y)
#> [1] TRUE
check_equiv_frames(x, z)
#> [1] TRUE
```

*Output.*   Adds the following columns to the data frame.

- **`term_degree`**   Character. Term in which a program is completed.
  Encoded YYYYT. NA indicates non-completion.

- **`completion_status`**   Character. Completion status: “timely”,
  indicating degree completion no later than the timely completion term;
  “late”, indicating completion after the timely completion term; and
  “NA” indicating non-completion.

``` r

# Add completion status and supporting variables
DT <- add_completion_status(DT, degree)
DT
#>                  mcid timely_term term_degree completion_status
#>                <char>      <char>      <char>            <char>
#>     1: MCID3111142689       19941       19913            timely
#>     2: MCID3111142782       19941       19903            timely
#>     3: MCID3111142881       19951       19894            timely
#>    ---                                                         
#> 76873: MCID3112785480       20123        <NA>              <NA>
#> 76874: MCID3112800920       20153        <NA>              <NA>
#> 76875: MCID3112870009       20003        <NA>              <NA>
```

Similar to the details described in the data sufficiency vignette,
[`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md)
accepts [Alternate source
names](https://midfieldr.github.io/midfieldr/articles/art-020-data-sufficiency.html#alternate-source-names)
and uses [Silent
overwriting](https://midfieldr.github.io/midfieldr/articles/art-020-data-sufficiency.html#silent-overwriting)
when existing columns have the same name as one of the added columns.

### Closer look

Examining the records of selected students in detail.

*Example 1.*   The student has a degree term, Spring 1997 (encoded
`19963`) indicating successful completion. Their degree term does not
exceed their timely completion term, Spring 1998 (encoded `19973`), so
their completion status is “timely”.

``` r

# Display one student by ID
DT[mcid == "MID25783162"]
#> Empty data.table (0 rows and 4 cols): mcid,timely_term,term_degree,completion_status
```

*Example 2.*   This student too has a degree term, Spring 2017 (encoded
`20163`) indicating successful completion. Their degree term exceeds
their timely completion term, Spring 2016 (encoded `20153`), so their
completion status is “late”.

``` r

# Display one student by ID
DT[mcid == "MID26696871"]
#> Empty data.table (0 rows and 4 cols): mcid,timely_term,term_degree,completion_status
```

*Example 3.*   The student’s degree term is NA, indicating they did not
complete their program. Thus completion status is NA as well.

``` r

# Display one student by ID
DT[mcid == "MID26697615"]
#> Empty data.table (0 rows and 4 cols): mcid,timely_term,term_degree,completion_status
```

## Graduates

Defining “graduates” as timely completers, we filter to retain records
for which completion status is “timely”. This data set comprises all
timely graduates in the practice data.

``` r

# Graduates
DT <- DT[completion_status == "timely"]

# Filter for unique IDs
DT <- DT[, .(mcid)]
DT <- unique(DT)
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

## Filter by program

In this case, “filter by program” means to filter by *degree program.*
Hence we join variables from `degree` to obtain the CIP codes of the
graduates.

*Add variables.*   Left join with selected variables from `degree`.

``` r

# Add degree CIP codes and terms
cols_we_want <- degree[, .(mcid, term_degree, cip6)]
DT <- cols_we_want[DT, on = c("mcid")]
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

If our IDs are all graduates, there should be no NA values in the CIP
column after joining. We check as follows, where the result is the
integer number of rows with an incomplete case, i.e., an NA in either
column. The result is zero.

``` r

# Verify no NAs in CIP column
sum(!complete.cases(DT))
#> [1] 0
```

*Filter.*   Join program labels and filter to retain the desired
programs.

``` r

# Filter by program
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

*Filter.*   Filter to retain observations in the first degree term only.
Multiple degrees are allowed but only if they occur in the first degree
term.

``` r

# Filter by first degree term
DT <- DT[, .SD[which.min(term_degree)], by = "mcid"]
DT
#>                 mcid   cip6 program term_degree
#>               <char> <char>  <char>      <char>
#>    1: MCID3111142965 141001      EE       19901
#>    2: MCID3111145102 141001      EE       19893
#>    3: MCID3111146537 141001      EE       19913
#>   ---                                          
#> 3262: MCID3112618976 141901      ME       20153
#> 3263: MCID3112619484 141001      EE       20133
#> 3264: MCID3112641535 141901      ME       20143
```

*Filter.*   Drop unnecessary variables and filter for unique
observations of ID and degree program label.

``` r

DT[, c("cip6", "term_degree") := NULL]
DT <- unique(DT)
DT
#>                 mcid program
#>               <char>  <char>
#>    1: MCID3111142965      EE
#>    2: MCID3111145102      EE
#>    3: MCID3111146537      EE
#>   ---                       
#> 3262: MCID3112618976      ME
#> 3263: MCID3112619484      EE
#> 3264: MCID3112641535      ME
```

## Reusable code

*Preparation.*   The data frame of baseline IDs is the intake for this
section.

``` r

DT <- copy(baseline_mcid)
```

*Graduates.*   A summary code chunk for ready reference.

``` r

# Gather graduates, degree CIPs and terms
DT <- add_timely_term(DT, term)
DT <- add_completion_status(DT, degree)
DT <- DT[completion_status == "timely"]
DT <- degree[DT, .(mcid, term_degree, cip6), on = c("mcid")]

# Filter by programs and first degree terms
DT <- study_programs[DT, on = c("cip6"), nomatch = NULL]
DT <- DT[, .SD[which.min(term_degree)], by = "mcid"]
DT[, c("cip6", "term_degree") := NULL]
DT <- unique(DT)
```

## References
