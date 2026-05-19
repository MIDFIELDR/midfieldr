# Groupings

We add grouping variables from the MIDFIELD data tables to our blocs in
progress. We select these variables to provide the aggregating
categories we want for a particular metric. Program labels and student
demographics are two of the most common sets of grouping variables we
use.

This vignette in the MIDFIELD workflow.

1.  Planning  
2.  Initial processing
3.  Blocs  
4.  Groupings
    - Program labels
    - Demographics
    - Other variables
5.  Metrics  
6.  Displays

## Definitions

- bloc:

  A grouping of student-level data dealt with as a unit, for example,
  starters, students ever-enrolled, graduates, transfer students,
  traditional and non-traditional students, migrators, etc.

- grouping variables:

  Detailed information in the student-level data that further
  characterize a bloc of records, typically used to create bloc subsets
  for comparison, for example, program, race/ethnicity, sex, age, grade
  level, grades, etc.

## Method

We join grouping variables to a bloc after initial processing (data
sufficiency and degree seeking) and any other subsetting criteria that
define a bloc. The two most common join operations to add grouping
variables are:

- *Program labels*   using an [inner
  join](https://midfieldr.github.io/midfieldr/articles/art-030-degree-seeking.html#inner-joins)
  on CIPs.

- *Demographics*   using a [left
  join](https://midfieldr.github.io/midfieldr/articles/art-050-blocs.html#left-joins)
  on IDs.

Other variables too can be usefully joined for grouping operations. We
include examples from `student`, `term`, and `degree`.

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
degree-seeking criteria. Applied to the practice data, this procedure
yields the `baseline_mcid` data frame derived in
[Blocs](https://midfieldr.github.io/midfieldr/articles/art-050-blocs.html#initial-processing)
and included with midfieldr.

``` r

# Working data frame
DT <- copy(baseline_mcid)
```

We join a CIP variable for examples that join by CIP.

``` r

# Reusable starting state with CIP
baseline_cip <- term[DT, .(mcid, cip6), on = c("mcid")]
baseline_cip <- unique(baseline_cip)
baseline_cip
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

## Program labels

At this point in a typical workflow, we have a bloc of student-level
records in progress and a data frame of program labels (similar to
`study_programs`). Both data frames have a 6-digit CIP variable to join
by.

Program labels serve two main functions:

- *Filtering variable*   to finalize a bloc. For example, “starters” or
  “graduates” usually mean starters or graduates *in specific programs*.
  Thus a bloc procedure typically concludes with a program filter as in
  [Ever-enrolled](https://midfieldr.github.io/midfieldr/articles/art-050-blocs.html#filter-by-program),
  [Starters](https://midfieldr.github.io/midfieldr/articles/art-070-starters.html#filter-by-program),
  or
  [Graduates](https://midfieldr.github.io/midfieldr/articles/art-080-graduates.html#filter-by-program).

- *Grouping variable*   for summarizing data. Having filtered a bloc to
  retain records in specific programs, the program label is retained and
  used with other grouping variables such as race/ethnicity and sex when
  computing and comparing metrics. Because of its role in groupings, the
  program label join is developed in detail in this vignette.

*Rationale for the inner join.*   An inner join accomplishes two tasks:
adds a column of program labels to the bloc; and filters the bloc to
retain only those observations with CIPs matching the desired programs.

*Reset*   The CIP baseline data frame we preserved earlier is the intake
for this section.

``` r

# Reusable starting state
DT <- copy(baseline_cip)
```

*Filter.*   An inner join adds the program label and filters for
matching CIPs.

``` r

# Join program labels via inner join
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

We can see the filtering effect by noting that the baseline data frame
had 127,349 observations while the inner join on the selected programs
returned 5657 observations. We can also verify the selected programs,
e.g.,

``` r

# Verify program labels
sort(unique(DT$program))
#> [1] "CE"  "EE"  "ISE" "ME"

# Verify program CIP codes
sort(unique(DT$cip6))
#> [1] "140801" "141001" "141901" "142701" "143501"
```

Students can migrate between majors having different 6-digit CIP codes,
but those codes might be grouped under a single program label. A common
example in Engineering is the “Industrial/Systems Engineering” label we
assign to following CIP codes:

- 142701 Systems Engineering
- 143501 Industrial Engineering
- 143601 Manufacturing Engineering
- 143701 Operations Research

A student migrating among these CIPs would appear in multiple rows in
the current bloc, yet we would not consider their change of CIP a change
of major. The next step addresses this anomaly.

*Select.*   Drop the CIP code.

``` r

# Prepare to filter
DT[, cip6 := NULL]
DT
#>       program           mcid
#>        <char>         <char>
#>    1:      EE MCID3111142965
#>    2:      EE MCID3111145102
#>    3:      EE MCID3111146537
#>   ---                       
#> 5655:      ME MCID3112641399
#> 5656:      ME MCID3112641535
#> 5657:      ME MCID3112698681
```

*Filter.*   Filter for unique observations.

``` r

# Case study ever enrolled
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

The difference in the number of observations indicates that this example
includes one student in ISE with two CIPs. We examine that student’s
record below.

### Closer look

Examining the records of selected students in detail.

*Example 1.*   This student’s `term` record includes CIP 142701 (Systems
Engineering) and CIP 143501 (Industrial Engineering), both of which are
majors in our combined Industrial/Systems Engineering (ISE) major,
illustrating our rationale for filtering for unique observations by
ID/program pairs and not ID/CIP pairs.

``` r

# All terms, one ID
x <- term[mcid == "MCID3111251565", .(mcid, cip6)]

# Join case study program labels
x <- study_programs[x, on = c("cip6"), nomatch = NULL]

# Unique CIPs for this student
unique(x)
#>      cip6 program           mcid
#>    <char>  <char>         <char>
#> 1: 143501     ISE MCID3111251565
#> 2: 142701     ISE MCID3111251565
```

## Demographics

Demographic variables (race/ethnicity and sex) are regularly left-joined
to blocs for grouping and summarizing.

*Reset*   The data frame of baseline IDs is the intake for this section.

``` r

# Reusable starting state
DT <- copy(baseline_mcid)
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

*Select.*   From `student`, select the join-by variable (student ID) and
the variables we want to add. By selecting columns here, we don’t have
to select columns in the join operation to follow.

``` r

# Extract desired columns
cols_we_want <- student[, .(mcid, race, sex)]
cols_we_want
#>                  mcid          race    sex
#>                <char>        <char> <char>
#>     1: MCID3111142225         Asian   Male
#>     2: MCID3111142283         Asian Female
#>     3: MCID3111142290         Asian   Male
#>    ---                                    
#> 97553: MCID3112898894         White Female
#> 97554: MCID3112898895         White Female
#> 97555: MCID3112898940 Other/Unknown   Male
```

*Add variables.*   Left join two data frames, retaining all variables
from both.

``` r

# Add demographics
DT <- cols_we_want[DT, on = c("mcid")]
DT
#>                  mcid          race    sex
#>                <char>        <char> <char>
#>     1: MCID3111142689      Hispanic Female
#>     2: MCID3111142782      Hispanic Female
#>     3: MCID3111142881 International   Male
#>    ---                                    
#> 76873: MCID3112785480         White   Male
#> 76874: MCID3112800920         White Female
#> 76875: MCID3112870009         White   Male
```

### Unknown `race` or `sex`

We often want to remove records for which race/ethnicity or sex are
“unknown”.

``` r

# Display values
unique(DT$race)
#> [1] "Hispanic"        "International"   "White"           "Asian"          
#> [5] "Black"           "Native American" "Other/Unknown"
unique(DT$sex)
#> [1] "Female"  "Male"    "Unknown"
```

*Filter.*   In data.table syntax, we can use `x %ilike% pattern` as a
case-insensitive wrapper around
[`grepl()`](https://rdrr.io/r/base/grep.html) to find matches and
partial matches.

``` r

# Remove records with unknown sex, if any
x <- copy(DT)
x <- x[!sex %ilike% "unknown"]
x
#>                  mcid          race    sex
#>                <char>        <char> <char>
#>     1: MCID3111142689      Hispanic Female
#>     2: MCID3111142782      Hispanic Female
#>     3: MCID3111142881 International   Male
#>    ---                                    
#> 76872: MCID3112785480         White   Male
#> 76873: MCID3112800920         White Female
#> 76874: MCID3112870009         White   Male
```

Removing unknown race observations is similar.

``` r

# Remove records with unknown sex, if any
x <- x[!race %ilike% "unknown"]
x
#>                  mcid          race    sex
#>                <char>        <char> <char>
#>     1: MCID3111142689      Hispanic Female
#>     2: MCID3111142782      Hispanic Female
#>     3: MCID3111142881 International   Male
#>    ---                                    
#> 73774: MCID3112785480         White   Male
#> 73775: MCID3112800920         White Female
#> 73776: MCID3112870009         White   Male
```

Alternatively, these statements can be combined.

``` r

# Remove unknowns in either of two columns
DT <- DT[!(sex %ilike% "unknown" | race %ilike% "unknown")]

# Verify equivalence
check_equiv_frames(x, DT)
#> [1] TRUE
```

With “unknowns” removed, the `race` and `sex` values are:

``` r

sort(unique(DT$race))
#> [1] "Asian"           "Black"           "Hispanic"        "International"  
#> [5] "Native American" "White"
sort(unique(DT$sex))
#> [1] "Female" "Male"
```

### Add `origin`

`origin` is a demographic variable we use to distinguish “domestic”
students from “international” students. The variable is a recoding of
the `race` variable.

*Add a variable.*   Assuming that race/ethnicity “unknown” have been
removed, we use a conditional assignment to create the “origin”
variable.

``` r

# Two values for origin
x <- copy(DT)
x <- x[, origin := fifelse(race == "International", "International", "Domestic")]
x[]
#>                  mcid          race    sex        origin
#>                <char>        <char> <char>        <char>
#>     1: MCID3111142689      Hispanic Female      Domestic
#>     2: MCID3111142782      Hispanic Female      Domestic
#>     3: MCID3111142881 International   Male International
#>    ---                                                  
#> 73774: MCID3112785480         White   Male      Domestic
#> 73775: MCID3112800920         White Female      Domestic
#> 73776: MCID3112870009         White   Male      Domestic
```

With “unknowns” removed, the `origin` values are:

``` r

sort(unique(x$origin))
#> [1] "Domestic"      "International"
```

### Add `people`

`people` is a demographic variable we use in many of our summaries. The
variable combines the `race` and `sex` variables.

*Add a variable.*   We combine race/ethnicity and sex to create a
grouping variable.

``` r

x <- copy(DT)
x <- x[, people := paste(race, sex)]
x
```

With “unknowns” removed, the `people` values are:

``` r

sort(unique(x$people))
#>  [1] "Asian Female"           "Asian Male"             "Black Female"          
#>  [4] "Black Male"             "Hispanic Female"        "Hispanic Male"         
#>  [7] "International Female"   "International Male"     "Native American Female"
#> [10] "Native American Male"   "White Female"           "White Male"
```

### Add `people` by `origin`

Combining the two ideas above, again assuming that the observations on
unknown race/ethnicity and sex have been removed,

``` r

# Two values for origin
x <- copy(DT)
x <- x[, origin := fifelse(race == "International", "International", "Domestic")]

# Combine with sex
x[, people := paste(origin, sex)]

# Omit unnecessary variables
x <- x[, .(mcid, people)]
x
#>                  mcid             people
#>                <char>             <char>
#>     1: MCID3111142689    Domestic Female
#>     2: MCID3111142782    Domestic Female
#>     3: MCID3111142881 International Male
#>    ---                                  
#> 73774: MCID3112785480      Domestic Male
#> 73775: MCID3112800920    Domestic Female
#> 73776: MCID3112870009      Domestic Male
```

The possible `people` values are:

``` r

sort(unique(x$people))
#> [1] "Domestic Female"      "Domestic Male"        "International Female"
#> [4] "International Male"
```

## Other variables

Depending on one’s research question, any number of MIDFIELD variables
might be used for grouping records. In this section we illustrate
joining other variables from `student`, `term`, and `degree` to a
working data frame.

We use the original source files copied earlier because some variables
we want to use were removed when we applied
[`select_required()`](https://midfieldr.github.io/midfieldr/reference/select_required.md).

### From `student`

*Reset*   Reset the working data frame.

``` r

# Reusable starting state
DT <- copy(baseline_mcid)
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

The available variables in the source `student` data are:

``` r

# Variables in the practice data set
names(source_student)
#>  [1] "mcid"           "institution"    "transfer"       "hours_transfer"
#>  [5] "race"           "sex"            "age_desc"       "us_citizen"    
#>  [9] "home_zip"       "high_school"    "sat_math"       "sat_verbal"    
#> [13] "act_comp"
```

*Select.*   Select our variables and the key (ID).

``` r

# Extract desired columns
cols_we_want <- source_student[, .(mcid, transfer, hours_transfer)]
```

*Add variables.*   Left join to add new columns.

``` r

# Add desired columns
cols_we_want[DT, on = c("mcid")]
#>                  mcid            transfer hours_transfer
#>                <char>              <char>          <num>
#>     1: MCID3111142689 First-Time Transfer             NA
#>     2: MCID3111142782 First-Time Transfer             NA
#>     3: MCID3111142881 First-Time Transfer             NA
#>    ---                                                  
#> 76873: MCID3112785480 First-Time Transfer              1
#> 76874: MCID3112800920 First-Time Transfer             15
#> 76875: MCID3112870009 First-Time Transfer             80
```

### From `term`

*Reset*   Reset the working data frame.

``` r

# Reusable starting state
DT <- copy(baseline_mcid)
```

The available variables in the source `term` data are:

``` r

# Variables in the practice data set
names(source_term)
#>  [1] "mcid"                "institution"         "term"               
#>  [4] "cip6"                "level"               "standing"           
#>  [7] "coop"                "hours_term"          "hours_term_attempt" 
#> [10] "hours_cumul"         "hours_cumul_attempt" "gpa_term"           
#> [13] "gpa_cumul"
```

*Select.*   Select our variables and the key (ID).

``` r

# Extract desired columns
cols_we_want <- source_term[, .(mcid, term, hours_term, gpa_term)]
```

*Add variables.*   Left join to add new columns.

``` r

# Add desired columns
cols_we_want[DT, on = c("mcid")]
#>                   mcid   term hours_term gpa_term
#>                 <char> <char>      <num>    <num>
#>      1: MCID3111142689  19883          9     3.33
#>      2: MCID3111142782  19883         16     2.80
#>      3: MCID3111142782  19885          4     3.00
#>     ---                                          
#> 531417: MCID3112870009  19953         12     3.57
#> 531418: MCID3112870009  19954          1     4.00
#> 531419: MCID3112870009  19983          7     4.00
```

*Rows in X with multiple matches in Y.*   Consistent with the left join
matching rules, students in enrolled in multiple terms will have
multiple rows in the joined data frame. Thus this result has 531,419
observations of 76,875 unique students.

### From `degree`

*Reset*   Reset the working data frame.

``` r

# Reusable starting state
DT <- copy(baseline_mcid)
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

The available variables in the source `degree` data are:

``` r

# Variables in the practice data set
names(source_degree)
#> [1] "mcid"        "institution" "term_degree" "cip6"        "degree"
```

*Select.*   Select two variables and the key (ID).

``` r

# Extract desired columns
cols_we_want <- source_degree[, .(mcid, cip6, degree)]
```

*Add variables.*   Left join to add new columns.

``` r

# Add desired columns
cols_we_want[DT, on = c("mcid")]
#>                  mcid   cip6                                     degree
#>                <char> <char>                                     <char>
#>     1: MCID3111142689 090401             Bachelor of Arts in Journalism
#>     2: MCID3111142782 260101 Bachelor of Science in Biological Sciences
#>     3: MCID3111142881 450601              Bachelor of Arts in Economics
#>    ---                                                                 
#> 76990: MCID3112785480   <NA>                                       <NA>
#> 76991: MCID3112800920   <NA>                                       <NA>
#> 76992: MCID3112870009   <NA>                                       <NA>
```

*Rows in X with no match in Y.*   Consistent with the left join matching
rules, students in `DT` who do not graduate will have NA values in the
`term_degree` and `cip6` columns of the joined data tables. Thus this
result has 76,875 unique students of whom 43,786 earned degrees.

## Reusable code

*Program labels preparation.*   The CIP baseline data frame we preserved
earlier is the intake for this section.

``` r

DT <- copy(baseline_cip)
```

*Program labels.*   A summary code chunk for ready reference. In
gathering a bloc of *starters*, the join-by variable might be `start`
instead of `cip6`.

``` r

# Filter by program
DT <- study_programs[DT, on = c("cip6"), nomatch = NULL]
DT[, cip6 := NULL]
DT <- unique(DT)
```

*Demographics preparation.*   The data frame of baseline IDs is the
intake for this section.

``` r

DT <- copy(baseline_mcid)
```

*Demographics.*   A summary code chunk for ready reference.

``` r

# Join race/ethnicity and sex
cols_we_want <- student[, .(mcid, race, sex)]
DT <- cols_we_want[DT, on = c("mcid")]
```

------------------------------------------------------------------------

[◁
Graduates](https://midfieldr.github.io/midfieldr/articles/art-080-graduates.md)
   [▲ top of page](#top)    [Graduation rate
▷](https://midfieldr.github.io/midfieldr/articles/art-100-grad-rate.md)

------------------------------------------------------------------------

## References
