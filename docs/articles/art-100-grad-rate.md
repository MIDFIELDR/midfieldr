# Graduation rate

Graduation rate is a widely used, though flawed, measure of academic
achievement.

The American Council on Education estimates that the conventional
definition of graduation rate may exclude up to 60% of students at
4-year institutions ([Cook and Hartle 2011](#ref-Cook+Hartle:2011)).
Nevertheless, as Cook and Hartle explain,

> … in the eyes of the public, policy makers, and the media, graduation
> rate is a clear, simple, and logical—if often misleading—number.

Recognizing that graduation rate is a popular metric, we propose a
definition of graduation rate that includes all conventionally excluded
students except migrators. You can skip the FYE content in this vignette
if your study includes no FYE-style Engineering programs.

This article in the MIDFIELD workflow:

1.  Planning  
2.  Initial processing  
3.  Blocs  
4.  Groupings  
5.  Metrics
    - Graduation rate
    - Stickiness  
6.  Displays

## Definitions

- graduation rate:

  Graduation rate (G) is the ratio of the number of program
  “starter-graduates” (N\_{sg}) (i.e., graduates from the program in
  which they started) to the number of program starters (N_s).
  G=\frac{N\_{sg}}{N_s}

- bloc:

  A grouping of student-level data dealt with as a unit, for example,
  starters, students ever-enrolled, graduates, transfer students,
  traditional and non-traditional students, migrators, etc.

- starters:

  Bloc of degree-seeking students in their initial terms enrolled in
  degree-granting programs.

- starter-graduates:

  Subset of the starters bloc who are graduates (timely completers) from
  their starting programs.

- timely completion criterion:

  Completing a program in no more than a specified span of years, in
  many cases, within 6 years after admission (150% of the “normal”
  4-year span), or possibly less for some transfer students.

- migrators:

  Bloc of students who leave one program to enroll in another. Also
  called *switchers.*

- undecided/unspecified:

  The MIDFIELD taxonomy includes the non-IPEDS code (CIP 999999) for
  Undecided or Unspecified indicating instances in which a student has
  not declared a major or an institution had not recorded a program.

## Starters and migrators

As they pertain to the graduation rate metric, relationships among
starters, migrators, and graduates (timely completers) of a given
program *P* are illustrated in Figure 1.

- The overall rectangle represents the set of students ever enrolled in
  program *P*.

- The interior rectangle represents the set of graduates (timely
  completers) of program *P*.

- Region 1 (shaded) represents the graduation rate denominator (N_s),
  the set of starters in program *P*.

- Region 2 (shaded) represents the graduation rate numerator (N\_{sg}),
  the subset of starters who are also graduates of program *P*.

- Region 3 (unshaded) represents the set of students excluded from the
  graduation rate metric, depending on how “program” is defined as
  discussed below.

![Figure 1. Graduation rate metric. Starters, migrators, and timely
completers.](figures/art-100-fig01-1.png)

Figure 1. Graduation rate metric. Starters, migrators, and timely
completers.

  
When calculating graduation rate, whether migrator-graduates are
included in the count of graduates depends how a program is defined in
terms of CIP codes.

- *Institution level*. Graduation rate computed at the institution level
  includes all migrators within the institution. For example, starters
  in Engineering (CIP 14) who graduate in Business (CIP 52) are both
  starters and timely completers at the institution level. IPEDS defines
  this rate as the *institution completion rate.*

- *2-digit CIP*. Graduation rate includes migrator graduates within the
  same 2-digit CIP. For example, starters in Engineering (CIP 14)
  graduating in Business (CIP 52) are excluded from the count of
  Business graduates, but migrators within Engineering (all 6-digit CIP
  codes starting with 14) are both starters and timely completers in
  Engineering.

- *4-digit CIP*. Similar to the 2-digit case. For example, starters in
  Electrical Engineering (CIP 1410) graduating in Mechanical Engineering
  (CIP 1419) are excluded from the count of Mechanical Engineering
  graduates, but migrators within Electrical Engineering (all 6-digit
  CIP codes starting with 1410) are both starters and timely completers
  in Electrical Engineering.

- *6-digit CIP*. Rarely used. Graduation rate at this CIP level excludes
  all migrators from the count of graduates.

- *Multiple CIPs*. In some cases, a single program or major includes
  different 4-digit CIPs. For example, migrators between Systems
  Engineering (CIP 1427), Industrial Engineering (CIP 1435),
  Manufacturing Engineering (CIP 1436), and Operations Research
  (CIP 1437) might be considered both starters and timely completers in
  a general program of Industrial & Systems Engineering.

## Who is a starter?

In the US, the predominant definition of graduation rate is that
established by the US Department of Education, Integrated Postsecondary
Education Data System (IPEDS). The IPEDS definition underlies the
finding cited earlier that a graduation rate metric may exclude up to
60% of students.

Many of the IPEDS exclusions relate to how starters are defined. By
expanding the starters definition, MIDFIELD proposes a graduation rate
definition that includes all conventionally excluded students except
migrators.

- graduation rate (IPEDS):

  The fraction of a cohort of full-time, first-time, degree-seeking
  undergraduates who complete their program within a percentage (100%,
  150%, or 200%) of the “normal” time (typically 4 years) as defined by
  the institution. IPEDS excludes students who attend college part-time,
  who transfer between institutions, and who start in Winter or Spring
  terms ([NCES-IPEDS 2020](#ref-IPEDS:2020)).

- graduation rate (MIDFIELD):

  The fraction of a cohort of degree-seeking undergraduates who complete
  their program in a timely manner (typically 6 years). MIDFIELD
  includes students who attend college part-time, who transfer between
  institutions, and who start in any term. Table 1 summarizes the
  comparison between the IPEDS and MIDFIELD graduation rate definitions.

| Item | IPEDS | MIDFIELD | MIDFIELD notes |
|----|----|----|----|
| completion span: | 4, 6, or 8 years | 4, 6, or 8 years | Typical usage is 6 years |
| students admitted in: | Summer/Fall only | any term |  |
| part-time students are: | excluded | included | Timely completion same as full-time students |
| transfer students are: | excluded | included | Timely completion span adjusted for level at entry |

Table 1. Comparing graduation rate definitions {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

  

- First-Year Engineering (FYE) starters:

  We estimate the degree-granting engineering program in which an FYE
  student would have enrolled had they not been required to enroll in
  FYE. The FYE proxy, a 6-digit CIP code, denotes the program of which
  the FYE student can be considered a starter. For additional details,
  see the vignette [FYE
  proxies](https://midfieldr.github.io/midfieldr/articles/art-060-fye-proxies.md).

## Method

Demonstrating the following elements of a MIDFIELD workflow.

1.  *Planning.*   The metric is graduation rate. Required blocs are
    starters and the subset of starters who graduate in their starting
    major. Grouping variables are program, race/ethnicity, and sex.
    Programs are the four Engineering programs used throughout.

2.  *Initial processing.*   Filter the student-level records for data
    sufficiency and degree-seeking.

3.  *Blocs.*   Gather starters, filter by program. Gather graduates,
    filter by program, filter by starters’ IDs and programs.

4.  *Groupings.*   Add grouping variables.

5.  *Metrics*   Summarize by grouping variables and compute graduation
    rate.

6.  *Displays*   Create multiway chart and results table.

*Reminder.*   midfielddata is for practice, not research.

## Load data

*Start.*   If you are writing your own script to follow along, we use
these packages in this article:

``` r

library(midfieldr)
library(midfielddata)
library(data.table)
library(ggplot2)
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
source_degree <- copy(degree)

# Optional. Select variables required by midfieldr functions
student <- select_basic_cols(source_student)
term <- select_basic_cols(source_term)
degree <- select_basic_cols(source_degree)
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

## Starters

*Starters.*   The summary code chunk from
[Starters](https://midfieldr.github.io/midfieldr/articles/art-070-starters.html#reusable-code)

``` r

# Isolate starting term
DT <- term[DT, .(mcid, term, cip6), on = c("mcid")]
DT <- DT[!cip6 %like% "999999"]
setorderv(DT, cols = c("mcid", "term"))
DT <- DT[, .SD[term == min(term)], by = "mcid"]
DT <- DT[, .(mcid, cip6)]
DT <- unique(DT)

# Continue for starters with FYE
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
DT[, start := NULL]
DT <- unique(DT)
```

*Copy.*   To prepare for joining with graduates.

``` r

# Prepare for joining
setcolorder(DT, c("mcid"))
starters <- copy(DT)
starters
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

## Graduates

*Initialize.*   The data frame of baseline IDs is the intake for this
section.

``` r

# Working data frame
DT <- copy(baseline_mcid)
```

*Graduates*   The summary code chunk from
[Graduates](https://midfieldr.github.io/midfieldr/articles/art-080-graduates.html#reusable-code)

``` r

# Gather graduates, degree CIPs and terms
DT <- add_timely_term(DT, term)
DT <- add_completion_status(DT, degree)
DT <- DT[completion_status == "timely"]
DT <- degree[DT, .(mcid, term_degree, cip6), on = c("mcid")]

# Filter by programs and first degree terms
DT <- study_programs[DT, on = c("cip6"), nomatch = NULL]
DT <- DT[, .SD[term_degree == min(term_degree)], by = "mcid"]
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

## Starter-graduates

This section introduces new material—not adapted from the reusable code
sections of other vignettes.

For a graduation rate metric, a timely completer is counted among the
graduates only if they start and complete the same program.

*Filter.*   Use an inner join to filter the graduates by ID and program
to match the IDs and programs of starters.

``` r

# Starter-graduates
DT <- starters[DT, on = c("mcid", "program"), nomatch = NULL]
```

*Copy.*   To prepare for joining with starters.

``` r

# Prepare for joining
setcolorder(DT, c("mcid"))
graduates <- copy(DT)
graduates
#>                 mcid program
#>               <char>  <char>
#>    1: MCID3111142965      EE
#>    2: MCID3111145102      EE
#>    3: MCID3111150194     ISE
#>   ---                       
#> 1789: MCID3112617717      ME
#> 1790: MCID3112618976      ME
#> 1791: MCID3112619484      EE
```

### Closer look

Examining the records of selected students in detail.

*Example 1.*   The student is a starter and a timely completer in
Industrial/Systems Engineering (ISE). They appear in both blocs.

``` r

# Same ID in different blocs
mcid_we_want <- "MCID3111150194"
starters[mcid == mcid_we_want]
#>              mcid program
#>            <char>  <char>
#> 1: MCID3111150194     ISE

graduates[mcid == mcid_we_want]
#>              mcid program
#>            <char>  <char>
#> 1: MCID3111150194     ISE
```

*Example 2.*   The student is a starter in Electrical Engineering (EE).
They are excluded from the graduation rate starter-graduate bloc because
they did not complete EE. From `degree` we find that they completed CIP
143501 (ISE), one of the study programs. They are also excluded from a
count of ISE graduates because they weren’t a ISE starter.

``` r

# Same ID in different blocs
mcid_we_want <- "MCID3111235261"
starters[mcid == mcid_we_want]
#>              mcid program
#>            <char>  <char>
#> 1: MCID3111235261      EE

graduates[mcid == mcid_we_want]
#> Empty data.table (0 rows and 2 cols): mcid,program

degree[mcid == mcid_we_want, .(mcid, cip6)]
#>              mcid   cip6
#>            <char> <char>
#> 1: MCID3111235261 143501
```

*Example 3.*   The student is a starter in Civil Engineering (CE). They
are excluded from the graduation rate starter-graduate bloc because they
did not complete CE. From `degree` we find that they completed CIP
521401 (Marketing). They would also be excluded from a count of
Marketing graduates because they weren’t a Marketing starter.

``` r

# Same ID in different blocs
mcid_we_want <- "MCID3111158691"
starters[mcid == mcid_we_want]
#>              mcid program
#>            <char>  <char>
#> 1: MCID3111158691      CE

graduates[mcid == mcid_we_want]
#> Empty data.table (0 rows and 2 cols): mcid,program

degree[mcid == mcid_we_want, .(mcid, cip6)]
#>              mcid   cip6
#>            <char> <char>
#> 1: MCID3111158691 521401
```

## Groupings

One of our grouping variables (`program`) is already included in the
data frames. The next grouping variable is `bloc` to distinguish
starters from graduates when the two data frames are combined.

*Add a variable.*   Label starters and graduates.

``` r

# For grouping by bloc
starters[, bloc := "starters"]
graduates[, bloc := "graduates"]
```

*Join.*   Combine the two blocs to prepare for summarizing. A student
starting and graduating in the same program now has two observations in
these data: one as a starter and one as a graduate.

``` r

# Prepare for summarizing
DT <- rbindlist(list(starters, graduates))
DT
#>                 mcid program      bloc
#>               <char>  <char>    <char>
#>    1: MCID3111142965      EE  starters
#>    2: MCID3111145102      EE  starters
#>    3: MCID3111150194     ISE  starters
#>   ---                                 
#> 5837: MCID3112617717      ME graduates
#> 5838: MCID3112618976      ME graduates
#> 5839: MCID3112619484      EE graduates
```

*Add variables.*   Demographics from
[Groupings](https://midfieldr.github.io/midfieldr/articles/art-090-groupings.html#reusable-code)

``` r

# Join race/ethnicity and sex
cols_we_want <- student[, .(mcid, race, sex)]
DT <- cols_we_want[DT, on = c("mcid")]
DT
#>                 mcid          race    sex program      bloc
#>               <char>        <char> <char>  <char>    <char>
#>    1: MCID3111142965 International   Male      EE  starters
#>    2: MCID3111145102         White   Male      EE  starters
#>    3: MCID3111150194         Black   Male     ISE  starters
#>   ---                                                      
#> 5837: MCID3112617717 International   Male      ME graduates
#> 5838: MCID3112618976         White   Male      ME graduates
#> 5839: MCID3112619484         White   Male      EE graduates
```

*Note.*   MIDFIELD research findings are regularly grouped by program,
race/ethnicity, and sex. However, applied to the practice data these
groupings produce several groups with totals below the threshold we
impose to preserve anonymity, introducing a number of NA values in the
resulting charts and tables. These NAs are largely an artifact of
applying these groupings to practice data.

## Graduation rate

*Summarize.*   Count the numbers of observations for each combination of
the grouping variables.

``` r

# Count observations by group
grouping_variables <- c("bloc", "program", "race", "sex")
DT <- DT[, .N, by = grouping_variables]
setorderv(DT, grouping_variables)
DT
#>          bloc program          race    sex     N
#>        <char>  <char>        <char> <char> <int>
#>  1: graduates      CE         Asian Female     4
#>  2: graduates      CE         Asian   Male     9
#>  3: graduates      CE         Black Female     1
#> ---                                             
#> 95:  starters      ME Other/Unknown   Male    53
#> 96:  starters      ME         White Female   146
#> 97:  starters      ME         White   Male  1225
```

*Reshape.*   Transform to row-record form to set up the graduation rate
calculation. Transform the *N* column into two columns, one for starters
and one for graduates.

``` r

# Prepare to compute metric
DT <- dcast(DT, program + race + sex ~ bloc, value.var = "N", fill = 0)
DT
#> Key: <program, race, sex>
#>     program          race    sex graduates starters
#>      <char>        <char> <char>     <int>    <int>
#>  1:      CE         Asian Female         4        7
#>  2:      CE         Asian   Male         9       17
#>  3:      CE         Black Female         1        2
#> ---                                                
#> 50:      ME Other/Unknown   Male        24       53
#> 51:      ME         White Female        71      146
#> 52:      ME         White   Male       568     1225
```

*Create a variable.*   Compute the metric.

``` r

# Compute metric
DT[, rate := round(100 * graduates / starters, 1)]
DT
#> Key: <program, race, sex>
#>     program          race    sex graduates starters  rate
#>      <char>        <char> <char>     <int>    <int> <num>
#>  1:      CE         Asian Female         4        7  57.1
#>  2:      CE         Asian   Male         9       17  52.9
#>  3:      CE         Black Female         1        2  50.0
#> ---                                                      
#> 50:      ME Other/Unknown   Male        24       53  45.3
#> 51:      ME         White Female        71      146  48.6
#> 52:      ME         White   Male       568     1225  46.4
```

## Prepare for dissemination

*Filter.*   To preserve the anonymity of the people involved, we remove
observations with fewer than `N_threshold` graduates. With the research
data, we typically set this threshold to 10; with the practice data, we
demonstrate the procedure using a threshold of 5.

``` r

# Preserve anonymity
N_threshold <- 5 # 10 for research data
DT <- DT[graduates >= N_threshold]
DT
#> Key: <program, race, sex>
#>     program          race    sex graduates starters  rate
#>      <char>        <char> <char>     <int>    <int> <num>
#>  1:      CE         Asian   Male         9       17  52.9
#>  2:      CE      Hispanic   Male        10       33  30.3
#>  3:      CE International Female         6       14  42.9
#> ---                                                      
#> 25:      ME Other/Unknown   Male        24       53  45.3
#> 26:      ME         White Female        71      146  48.6
#> 27:      ME         White   Male       568     1225  46.4
```

*Recode.*   Readers can more readily interpret our charts and tables if
the programs are unabbreviated.

``` r

# Recode values for chart and table readability
DT[, program := fcase(
  program %like% "CE", "Civil",
  program %like% "EE", "Electrical",
  program %like% "ME", "Mechanical",
  program %like% "ISE", "Industrial/Systems"
)]
DT
#>        program          race    sex graduates starters  rate
#>         <char>        <char> <char>     <int>    <int> <num>
#>  1:      Civil         Asian   Male         9       17  52.9
#>  2:      Civil      Hispanic   Male        10       33  30.3
#>  3:      Civil International Female         6       14  42.9
#> ---                                                         
#> 25: Mechanical Other/Unknown   Male        24       53  45.3
#> 26: Mechanical         White Female        71      146  48.6
#> 27: Mechanical         White   Male       568     1225  46.4
```

*Add a variable.*   We combine race/ethnicity and sex to create a
combined grouping variable.

``` r

# Create a combined category
DT[, people := paste(race, sex)]
DT[, `:=`(race = NULL, sex = NULL)]
setcolorder(DT, c("program", "people"))
DT
#>        program               people graduates starters  rate
#>         <char>               <char>     <int>    <int> <num>
#>  1:      Civil           Asian Male         9       17  52.9
#>  2:      Civil        Hispanic Male        10       33  30.3
#>  3:      Civil International Female         6       14  42.9
#> ---                                                         
#> 25: Mechanical   Other/Unknown Male        24       53  45.3
#> 26: Mechanical         White Female        71      146  48.6
#> 27: Mechanical           White Male       568     1225  46.4
```

## Chart

*Order factors.*   Order the levels of the categories. Code adapted from
[Multiway data and
charts](https://midfieldr.github.io/midfieldr/articles/art-120-multiway.html#percentage-ordered-data).

``` r

# Order the categories
DT <- order_multiway(DT,
  quantity   = "rate",
  categories = c("program", "people"),
  method     = "percent",
  ratio_of   = c("graduates", "starters")
)
DT
#>        program               people graduates starters  rate program_rate
#>         <fctr>               <fctr>     <num>    <num> <num>        <num>
#>  1:      Civil           Asian Male         9       17  52.9         47.0
#>  2:      Civil        Hispanic Male        10       33  30.3         47.0
#>  3:      Civil International Female         6       14  42.9         47.0
#> ---                                                                      
#> 25: Mechanical   Other/Unknown Male        24       53  45.3         46.4
#> 26: Mechanical         White Female        71      146  48.6         46.4
#> 27: Mechanical           White Male       568     1225  46.4         46.4
#>     people_rate
#>           <num>
#>  1:        48.8
#>  2:        34.2
#>  3:        42.9
#> ---            
#> 25:        37.5
#> 26:        46.6
#> 27:        45.7
```

*Multiway chart.*   Code adapted from [Multiway data and
charts](https://midfieldr.github.io/midfieldr/articles/art-120-multiway.html#percentage-ordered-charts).

The vertical reference line is the aggregate graduation rate of the
program, independent of race/ethnicity and sex. A missing data marker or
missing group indicates the number of graduates was below the threshold
set to preserve anonymity—largely an artifact of applying these
groupings to practice data.

``` r

ggplot(DT, aes(x = rate, y = people)) +
  facet_wrap(vars(program), ncol = 1, as.table = FALSE) +
  geom_vline(aes(xintercept = program_rate), linetype = 2, color = "gray60") +
  geom_point() +
  labs(x = "Graduation rate (%)", y = "") +
  scale_x_continuous(limits = c(20, 90), breaks = seq(0, 100, 10))
```

![Figure 2: Graduation rates of four Engineering
majors.](figures/art-100-fig02-1.png)

Figure 2: Graduation rates of four Engineering majors.

## Table

*Results table.*   Code adapted from [Multiway data and
charts](https://midfieldr.github.io/midfieldr/articles/art-120-multiway.html#tabulating-counts).

``` r

# Select variables and remove factors
display_table <- copy(DT)
display_table <- display_table[, .(program, people, rate)]
display_table[, people := as.character(people)]
display_table[, program := as.character(program)]

# Construct table
display_table <- dcast(display_table, people ~ program, value.var = "rate")
setnames(display_table,
  old = c("people"),
  new = c("People"),
  skip_absent = TRUE
)
display_table
#> Key: <People>
#>                 People Civil Electrical Industrial/Systems Mechanical
#>                 <char> <num>      <num>              <num>      <num>
#>  1:       Asian Female    NA       33.3                 NA         NA
#>  2:         Asian Male  52.9       41.2               42.9       59.3
#>  3:         Black Male    NA       20.7                 NA       33.3
#> ---                                                                  
#>  8: Other/Unknown Male  27.3       31.0                 NA       45.3
#>  9:       White Female  46.5       41.9               47.7       48.6
#> 10:         White Male  48.3       41.1               49.3       46.4
```

(Optional) Format the table nearer to publication quality. Here I use
the ‘gt’ package.

``` r

library(gt)
display_table |>
  gt() |>
  tab_caption("Table 2: Graduation rates (%) of four Engineering majors") |>
  tab_options(table.font.size = "small") |>
  opt_stylize(style = 1, color = "gray") |>
  tab_style(
    style = list(cell_fill(color = "#c7eae5")),
    locations = cells_column_labels(columns = everything())
  )
```

| People               | Civil | Electrical | Industrial/Systems | Mechanical |
|----------------------|-------|------------|--------------------|------------|
| Asian Female         | NA    | 33.3       | NA                 | NA         |
| Asian Male           | 52.9  | 41.2       | 42.9               | 59.3       |
| Black Male           | NA    | 20.7       | NA                 | 33.3       |
| Hispanic Female      | NA    | NA         | NA                 | 62.5       |
| Hispanic Male        | 30.3  | 34.3       | NA                 | 37.0       |
| International Female | 42.9  | NA         | NA                 | NA         |
| International Male   | 50.9  | 39.7       | 44.4               | 43.1       |
| Other/Unknown Male   | 27.3  | 31.0       | NA                 | 45.3       |
| White Female         | 46.5  | 41.9       | 47.7               | 48.6       |
| White Male           | 48.3  | 41.1       | 49.3               | 46.4       |

Table 2: Graduation rates (%) of four Engineering majors {.table
.gt_table quarto-disable-processing="false" quarto-bootstrap="false"}

A value of NA indicates a group removed because the number of graduates
was below the threshold set to preserve anonymity. As noted earlier,
these are largely an artifact of applying these groupings to practice
data.

------------------------------------------------------------------------

[◁
Groupings](https://midfieldr.github.io/midfieldr/articles/art-090-groupings.md)
   [▲ top of page](#top)    [Stickiness
▷](https://midfieldr.github.io/midfieldr/articles/art-110-stickiness.md)

------------------------------------------------------------------------

## References

Cook, Bryan, and Terry W. Hartle. 2011. “Why graduation rates matter—and
why they don’t.” *The Presidency Magazine*, nos. Spring/Summer 2011.

NCES-IPEDS. 2020. *IPEDS Survey Methodology*. National Center for
Education Statistics; \[Online; accessed 2020-07-29\].
<https://nces.ed.gov/ipeds/ReportYourData/IpedsSurveyMethodology>.
