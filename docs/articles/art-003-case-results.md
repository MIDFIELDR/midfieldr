# Case study: Results

Part 3 of a case study in three parts, illustrating how we work with
longitudinal student-level records.

1.  *Goals.*   Introducing the study.

2.  *Data.*   Transforming the data to yield the observations of
    interest.

3.  *Results.*   Summary statistics, metric, chart, and table.

## Method

Our goal in this segment is to group and summarize the observations we
saved previously, calculate the stickiness metric, and display the
results.

*Reminder.*   midfielddata datasets are for practice, not research.

## Load data

*Start.*   If you are writing your own script to follow along, we use
these packages in this article:

``` r

library(midfieldr)
library(data.table)
library(ggplot2)
```

*Loads with midfieldr.*   Prepared data. View data dictionary via
[`?study_observations`](https://midfieldr.github.io/midfieldr/reference/study_observations.md).

- `study_observations` (derived in [Case study:
  Data](https://midfieldr.github.io/midfieldr/articles/art-002-case-data.md)).

## Group and summarize

*Initialize.*   Assign a working data frame.

``` r

# Working data frame
DT <- copy(study_observations)
DT
#>                 mcid          race    sex program          bloc
#>               <char>        <char> <char>  <char>        <char>
#>    1: MCID3111142965 International   Male      EE ever_enrolled
#>    2: MCID3111142965 International   Male      EE     graduates
#>    3: MCID3111145102         White   Male      EE ever_enrolled
#>   ---                                                          
#> 8915: MCID3112641535         White   Male      ME ever_enrolled
#> 8916: MCID3112641535         White   Male      ME     graduates
#> 8917: MCID3112698681         White   Male      ME ever_enrolled
```

The study observations data frame is designed with one column for each
grouping variable: `race`, `sex`, `program`, and `bloc`.

- **grouping variables**:

  Detailed information in the student-level data that further
  characterize a bloc of records, typically used to create bloc subsets
  for comparison, for example, program, race/ethnicity, sex, age, grade
  level, grades, etc.

*Summarize.*   Count the numbers of observations for each combination of
the grouping variables.

``` r

# Group and summarize
DT <- DT[, .N, by = c("bloc", "program", "race", "sex")]
DT
#>              bloc program            race    sex     N
#>            <char>  <char>          <char> <char> <int>
#>  1: ever_enrolled      EE   International   Male   195
#>  2:     graduates      EE   International   Male    90
#>  3: ever_enrolled      EE           White   Male   864
#> ---                                                   
#> 96: ever_enrolled      CE Native American Female     1
#> 97:     graduates      CE Native American Female     1
#> 98:     graduates      EE   Other/Unknown Female     3
```

## Reshape

*Reshape.*   Transform from block-record form to row-record form to set
up the stickiness metric calculation. Transforms the *N* column into two
columns, one for ever-enrolled and one for graduates. This operation is
essentially a transformation from block records to row records—a process
known by a number of different names, e.g., pivot, crosstab, unstack,
spread, or widen ([Mount and Zumel
2019](#ref-Mount+Zumel:2019:fluid-data)). This step leaves the graphing
variables (program, race/ethnicity, and sex) in place.

``` r

# Prepare to compute metric
DT <- dcast(DT, program + sex + race ~ bloc, value.var = "N", fill = 0)
DT
#> Key: <program, sex, race>
#>     program    sex            race ever_enrolled graduates
#>      <char> <char>          <char>         <int>     <int>
#>  1:      CE Female           Asian            15        10
#>  2:      CE Female           Black             4         1
#>  3:      CE Female   International            23        13
#> ---                                                       
#> 48:      ME   Male Native American             5         1
#> 49:      ME   Male   Other/Unknown            80        41
#> 50:      ME   Male           White          1596       953
```

## Compute the metric

- **metric**:

  A quantitative measure derived from student-level data. Includes
  statistical measures such as counts of program starters or graduates
  as well as comparative ratios such as graduation rate or stickiness.
  Typically involves comparisons of specific blocs of students and
  programs.

- **stickiness**:

  Program “stickiness” \$\small\left(S\right)\$ is the ratio of the
  number of graduates of a program \$\small\left(N_g\right)\$ to the
  number ever enrolled in the program \$\small\left(N_e\right)\$.
  ``` math
  S = \frac{N_g}{N_e}
  ```

*Create a variable.*   Compute stickiness.

``` r

# Compute the metric
DT[, stickiness := round(100 * graduates / ever_enrolled, 1)]
setkey(DT, NULL)
DT
#>     program    sex            race ever_enrolled graduates stickiness
#>      <char> <char>          <char>         <int>     <int>      <num>
#>  1:      CE Female           Asian            15        10       66.7
#>  2:      CE Female           Black             4         1       25.0
#>  3:      CE Female   International            23        13       56.5
#> ---                                                                  
#> 48:      ME   Male Native American             5         1       20.0
#> 49:      ME   Male   Other/Unknown            80        41       51.2
#> 50:      ME   Male           White          1596       953       59.7
```

*Verify built-in data.* To avoid deriving this data frame each time it
is needed in other articles, the same information is provided in the
`study_results` data frame included with midfieldr. Here we verify that
the two data frames are identical.

``` r

# Demonstrate equivalence
check_equiv_frames(DT, study_results)
#> [1] TRUE
```

## Prepare for dissemination

We take several additional steps to prepare the data for dissemination
in tables or charts.

*Filtering.* To preserve the anonymity of the people involved, we remove
observations with fewer than 10 graduates.

``` r

# Preserve anonymity
DT <- DT[graduates >= 10]

# Display the result
DT
#>     program    sex          race ever_enrolled graduates stickiness
#>      <char> <char>        <char>         <int>     <int>      <num>
#>  1:      CE Female         Asian            15        10       66.7
#>  2:      CE Female International            23        13       56.5
#>  3:      CE Female         White           263       162       61.6
#> ---                                                                
#> 27:      ME   Male        Latine            79        42       53.2
#> 28:      ME   Male Other/Unknown            80        41       51.2
#> 29:      ME   Male         White          1596       953       59.7
```

*Note.*   MIDFIELD research findings are regularly grouped by program,
race/ethnicity, and sex. However, applied to the practice data these
groupings produce several groups with totals below the threshold we
impose to preserve anonymity, introducing a number of NA values in the
resulting charts and tables. These NAs are largely an artifact of
applying these groupings to practice data.

*Filtering.* Let us assume that our study focuses on “domestic” students
of known race/ethnicity. In that case, we omit observations labeled
“International” and Other/Unknown”.

``` r

# Filter by study design
DT <- DT[!race %chin% c("International", "Other/Unknown")]

# Display the result
DT
#>     program    sex   race ever_enrolled graduates stickiness
#>      <char> <char> <char>         <int>     <int>      <num>
#>  1:      CE Female  Asian            15        10       66.7
#>  2:      CE Female  White           263       162       61.6
#>  3:      CE   Male  Asian            30        25       83.3
#> ---                                                         
#> 18:      ME   Male  Black            30        19       63.3
#> 19:      ME   Male Latine            79        42       53.2
#> 20:      ME   Male  White          1596       953       59.7
```

*Creating variables.* We have found it useful to report such data with a
variable that combines race/ethnicity and sex.

``` r

# Create a variable
DT[, people := paste(race, sex)]
DT[, c("race", "sex") := NULL]
setcolorder(DT, c("program", "people"))

# Display the result
DT
#>     program       people ever_enrolled graduates stickiness
#>      <char>       <char>         <int>     <int>      <num>
#>  1:      CE Asian Female            15        10       66.7
#>  2:      CE White Female           263       162       61.6
#>  3:      CE   Asian Male            30        25       83.3
#> ---                                                        
#> 18:      ME   Black Male            30        19       63.3
#> 19:      ME  Latine Male            79        42       53.2
#> 20:      ME   White Male          1596       953       59.7
```

*Recoding values.* Readers can more readily interpret our charts and
tables if the programs are unabbreviated.

``` r

# Recode values for charts and tables
DT[, program := fcase(
  program %like% "CE", "Civil",
  program %like% "EE", "Electrical",
  program %like% "ME", "Mechanical",
  program %like% "ISE", "Industrial/Systems"
)]

# Display the result
DT
#>        program       people ever_enrolled graduates stickiness
#>         <char>       <char>         <int>     <int>      <num>
#>  1:      Civil Asian Female            15        10       66.7
#>  2:      Civil White Female           263       162       61.6
#>  3:      Civil   Asian Male            30        25       83.3
#> ---                                                           
#> 18: Mechanical   Black Male            30        19       63.3
#> 19: Mechanical  Latine Male            79        42       53.2
#> 20: Mechanical   White Male          1596       953       59.7
```

With one quantitative variable (stickiness) for every combination of the
levels of two categorical variables (program and race/ethnicity/sex),
these data are *multiway data* ([Cleveland 1993](#ref-Cleveland:1993)).
How one orders the categorical variables is critical for visualizing
effects.

- multiway data:

  A data set of three variables: a category with *m* levels; a second
  independent category with *n* levels; and a quantitative variable (the
  response) of length *mn* such that there is a value of the response
  for each combination of levels of the two categorical variables.

*Conditioning.* Convert the two categorical variables to ordered factors
to support the ordering of rows and panels in the chart.

``` r

# Convert categorical variables to factors
DT <- order_multiway(DT,
  quantity = "stickiness",
  categories = c("program", "people"),
  method = "percent",
  ratio_of = c("graduates", "ever_enrolled")
)

# Display the result
DT
#>        program       people graduates ever_enrolled stickiness
#>         <fctr>       <fctr>     <num>         <num>      <num>
#>  1:      Civil Asian Female        10            15       66.7
#>  2:      Civil White Female       162           263       61.6
#>  3:      Civil   Asian Male        25            30       83.3
#> ---                                                           
#> 18: Mechanical   Black Male        19            30       63.3
#> 19: Mechanical  Latine Male        42            79       53.2
#> 20: Mechanical   White Male       953          1596       59.7
#>     program_stickiness people_stickiness
#>                  <num>             <num>
#>  1:               63.5              62.7
#>  2:               63.5              60.5
#>  3:               63.5              62.8
#> ---                                     
#> 18:               60.0              61.0
#> 19:               60.0              47.4
#> 20:               60.0              59.3
```

The column `program_stickiness` determines the order of the programs in
the chart; `people_stickiness` determines the order of the
race/ethnicity/sex groupings; the values in `stickiness` are the
quantitative values to be graphed.

## Charts

In the first multiway chart, the rows are programs and panels are
people, facilitating comparisons of different program for a single
group. Rows and panels are both ordered from bottom to top in order of
increasing stickiness.

- **multiway chart**:

  A multi-panel dot plot: horizontal, quantitative scales; rows that
  encode one category; and panels that encode the second category. All
  panels have identical axes. The ordering of the rows and panels is
  crucial to the perception of effects.

``` r

ggplot(DT, aes(x = stickiness, y = program)) +
  facet_wrap(vars(people), ncol = 1, as.table = FALSE) +
  geom_vline(aes(xintercept = people_stickiness), linetype = 2, color = "gray60") +
  geom_point() +
  labs(x = "Stickiness (%)", y = "")
```

![Figure 1: Stickiness with programs on
rows.](figures/art-003-fig01-1.png)

Figure 1: Stickiness with programs on rows.

The vertical reference line is the overall stickiness of the people in a
panel.

Alternatively, we can consider the dual chart, swapping the roles of the
panels and rows. Here the rows are people and panels are programs,
facilitating comparisons of different people within a program. Over many
years of publishing research using MIDFIELD data, placing people on the
rows of the multiway chart has been perhaps our most frequently used
design.

``` r

ggplot(DT, aes(x = stickiness, y = people)) +
  facet_wrap(vars(program), ncol = 1, as.table = FALSE) +
  geom_vline(aes(xintercept = program_stickiness), linetype = 2, color = "gray60") +
  geom_point() +
  labs(x = "Stickiness (%)", y = "")
```

![Figure 1: Stickiness with programs in
panels.](figures/art-003-fig02-1.png)

Figure 1: Stickiness with programs in panels.

The vertical reference line is the overall stickiness of the program in
a panel.

The chart illustrates the importance of ordering the rows and panels. We
would conclude that Industrial/Systems Engineering is the stickiest
program of the four, followed by Civil, Mechanical, and Electrical in
descending order.

Because rows are ordered, one expects a generally increasing trend
within a panel. A response greater or smaller than expected creates a
visual asymmetry. For example, Asian students are asymmetrically lower
in Industrial/Systems Engineering.

## Tables

Data tables are often needed for publication. In this example, we format
the data in a conventional row-record form with the groups of people in
the first column labeling the rows and the program names labeling the
remaining columns.

``` r

# Select the columns I want for the table
tbl <- DT[, .(program, people, stickiness)]

# Change factors to characters so rows/columns can be alphabetized
tbl[, people := as.character(people)]
tbl[, program := as.character(program)]

# Transform from block records to row records
tbl <- dcast(tbl, people ~ program, value.var = "stickiness")

# Edit one column header
setnames(tbl, old = "people", new = "People", skip_absent = TRUE)
```

Groups with numbers below our reporting threshold are denoted NA or
omitted.

| People       | Civil | Electrical | Industrial/Systems | Mechanical |
|--------------|-------|------------|--------------------|------------|
| Asian Female | 66.7  | 57.1       | 66.7               | NA         |
| Asian Male   | 83.3  | 57.7       | 58.3               | 64.5       |
| Black Male   | NA    | 58.6       | NA                 | 63.3       |
| Latine Male  | 47.0  | 37.8       | NA                 | 53.2       |
| White Female | 61.6  | 47.5       | 70.1               | 62.9       |
| White Male   | 64.5  | 50.8       | 69.5               | 59.7       |

Table 1. Progrm stickiness (%) {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

## References

Cleveland, William S. 1993. *Visualizing Data*. Hobart Press.

Mount, John, and Nina Zumel. 2019. *Coordinatized data: A fluid data
specification*. Win Vector LLC.
[http://winvector.github.io/FluidData/RowsAndColumns.html](http://winvector.github.io/FluidData/RowsAndColumns.md).
