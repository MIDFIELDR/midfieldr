# FYE proxies

Before we can treat “starters”, we have to introduce “FYE
proxies”—estimates of the degree-granting engineering programs
First-Year Engineering (FYE) students would have declared had they not
been required to enroll in FYE.

Users of midfielddata practice data are not required to reproduce this
vignette—the results are included with midfieldr in the `fye_proxy` data
set.

This article in the MIDFIELD workflow:

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

## Potential for starter miscounts

At some US institutions, engineering students are required to complete a
First-Year Engineering (FYE) program as a prerequisite for declaring an
engineering major. Administratively, degree-granting engineering
programs such as Electrical Engineering or Mechanical Engineering treat
their incoming post-FYE students as their “starting” cohorts. However,
when computing a metric such as graduation rate that requires a count of
starters, FYE records must be treated with special care to avoid a
miscount.

To illustrate the potential for miscounting starters, suppose we wish to
calculate a Mechanical Engineering (ME) graduation rate. Students
starting in ME constitute the starting pool and the fraction of that
pool graduating in ME is the graduation rate.

At FYE institutions, an ME program would typically define their starting
pool as the post-FYE cohort entering their program. This may be the best
information available, but it invariably undercounts starters by failing
to account for FYE students who leave the institution or switch to
non-engineering majors. In the absence of the FYE requirement some of
these students would have been ME starters. By neglecting these
students, the count of ME starters is artificially low resulting in an
ME graduation rate that is artificially high. The same is true for every
degree-granting engineering major in an FYE institution.

Because of the special nature of FYE programs, we cannot address starter
miscounts by grouping FYE students with those admitted with “undecided”
or “unknown” CIP codes—FYE students are neither. They were admitted as
Engineering majors (2-digit CIP 14). We simply don’t know to which
degree-granting program (6-digit CIP) they intended to transition.

Therefore, to avoid miscounting starters at FYE institutions, we
estimate the 6-digit CIP codes of the degree-granting engineering
programs that FYE students would have declared had they not been
required to enroll in FYE.

## Definitions

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

- bloc:

  A grouping of student-level data dealt with as a unit, for example,
  starters, students ever-enrolled, graduates, transfer students,
  traditional and non-traditional students, migrators, etc.

- starters:

  Bloc of degree-seeking students in their initial terms enrolled in
  degree-granting programs.

- migrators:

  Bloc of students who leave one program to enroll in another. Also
  called *switchers.*

- multiple imputation:

  Method of imputing missing categorical data, in this case, imputing
  the FYE proxy 6-digit CIP codes.

## Method

We apply
[`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)
to the `student` and `term` source files to construct a data frame
suitable for imputation using the mice R package. The procedure has four
steps:

1.  Use
    [`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)
    from the midfieldr package to estimate some of the FYE proxy CIPs,
    treat the remainder as missing values, and structure the data frame
    for imputation.

2.  Optional. If the default predictor variables (institution,
    race/ethnicity, and sex) do not meet the needs of your study, you
    can define your own.

3.  Use [`mice()`](https://amices.org/mice/reference/mice.html) from the
    mice package to impute the 6-digit CIP missing values.

4.  Post-processing to convert the results to useful form and to remove
    migrators.

Three outcomes are possible, depending on your goals and available data:

- Use midfielddata practice data to recreate the `fye_proxy` data set
  included with midfieldr—as we do in this vignette.

- Use midfielddata practice data to create an alternate set of FYE
  proxies based on a different random number seed or different predictor
  variables. The result would have the same IDs as `fye_proxy` but
  different ID-proxy pairings.

- Use MIDFIELD research data and construct your own FYE proxies.

For a given set of source files, FYE proxies need be created only once
and written to file. The result can be used as needed unless the source
files change.

*Reminder.*   midfielddata is for practice, not research.

## Load data

*Start.*   If you are writing your own script to follow along, we use
these packages in this article:

``` r

library("midfieldr")
library("midfielddata")
library("data.table")
library("ggplot2")
library("mice")
```

*Load.*   Practice datasets. View data dictionaries via
[`?student`](https://midfieldr.github.io/midfielddata/reference/student.html),
[`?term`](https://midfieldr.github.io/midfielddata/reference/term.html).

``` r

# Load practice data
data(student, term)
```

*Loads with midfieldr.*   Prepared data, derived in
[Programs](https://midfieldr.github.io/midfieldr/articles/art-040-programs.html#reusable-code).
View data dictionary via
[`?study_programs`](https://midfieldr.github.io/midfieldr/reference/study_programs.md).

- `study_programs`

## Initial processing

Unlike the initial processing in previous articles, we do not filter for
data sufficiency and degree seeking.

*Select (optional).*   Reduce the number of columns. Code reproduced
from [Getting
started](https://midfieldr.github.io/midfieldr/articles/art-000-getting-started.html#reusable-code).

``` r

# Optional. Copy of source files with all variables
source_student <- copy(student)
source_term <- copy(term)

# Optional. Select variables required by midfieldr functions
student <- select_basic_cols(source_student)
term <- select_basic_cols(source_term)
```

## `prep_fye_mice()`

The purpose of
[`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)
is preparing a data frame for the mice R package. Operates on the
complete, unfiltered `student` and `term` source data to create a data
frame with three predictor variables and an FYE proxy variable. The
values in `proxy` are determined by a student’s first post-FYE program
code, as follows:

1.  *Post-FYE in Engineering.*   The student completes FYE and enrolls
    in an engineering major. For this outcome, we know that at the
    student’s first opportunity, they enrolled in an engineering major
    of their choosing. The CIP code of that program is returned as the
    student’s FYE proxy.

2.  *Post-FYE not in Engineering.*   The student migrates to a
    non-engineering major or has no post-FYE records in the database.
    The data provide no indication of the student’s preferred
    degree-granting engineering major. Thus their FYE proxy value is
    returned as NA, to be treated as missing data to be imputed.

*Arguments.*

- **`midfield_student`**   Data frame of student observations, keyed by
  student ID. Default is `student`. Required variables are `mcid`,
  `race`, and `sex`. Use all rows of your source `student` data table.

- **`midfield_term`**   Data frame of term observations keyed by student
  ID. Default is `term`. Required variables are `mcid`, `institution`,
  `term`, and `cip6`. Use all rows of your source `term` data table.

- **`fye_codes`**   Optional character vector of 6-digit CIP codes
  assigned to FYE programs. Default is “140102”. Argument to be used by
  name.

*Implicit arguments.*   The following implementations yield identical
results.

``` r

# Required arguments in order and explicitly named
x <- prep_fye_mice(m_student = student, m_term = term)

# Required arguments in order, but not named
y <- prep_fye_mice(student, term)

# Demonstrate equivalence
check_equiv_frames(x, y)
#> [1] TRUE
```

*Output.*   The function returns one row per FYE student keyed by
student ID. All variables except ID are returned as factors to meet the
requirements of [`mice()`](https://amices.org/mice/reference/mice.html).

``` r

# Working data frame
DT <- prep_fye_mice(student, term)
DT
#>                 mcid   institution          race    sex  proxy
#>               <char>        <fctr>        <fctr> <fctr> <fctr>
#>    1: MCID3111142290 Institution J         Asian   Male 141001
#>    2: MCID3111142294 Institution J         Asian   Male 141001
#>    3: MCID3111142961 Institution J International   Male 142101
#>   ---                                                         
#> 5787: MCID3112447659 Institution J         White   Male   <NA>
#> 5788: MCID3112447663 Institution J         White   Male   <NA>
#> 5789: MCID3112447664 Institution J         White   Male   <NA>
```

## Missing data

The output of `prep_fye_mive()` should contain missing values in the
proxy column only. Other variables are complete. A race/ethnicity or sex
value of “unknown” is treated as an observed value, not missing data.
And while no values of ID or institution are unknown or missing in this
example, such observations (if they existed) would have to be removed.

Checking that all variables except `proxy` are complete.

``` r

# Number of unique IDs
x <- length(unique(DT$mcid))

# Number of complete cases on four variables
y <- sum(complete.cases(DT[, .(mcid, race, sex, institution)]))

# Demonstrate equivalence
all.equal(x, y)
#> [1] TRUE
```

Number of missing observations in `proxy`.

``` r

# Number NAs in proxy
sum(is.na(DT$proxy))
#> [1] 2129

# Percentage NAs in proxy
100 * round(sum(is.na(DT$proxy)) / nrow(DT), 3)
#> [1] 36.8
```

*Missing at random (MAR).*   These missing `proxy` data are caused by a
student’s decision to migrate to a non-engineering major or to leave the
database. At the time of making that decision, the FYE student would not
yet have enrolled in a degree-granting engineering major, thus their
decision is unlikely to be related to any specific engineering major.

That a CIP is missing, therefore, is unlikely to be related to a
specific CIP value—but may be related to other observations such as
institution, race/ethnicity, or sex. Missing data of this type are
classified as “missing at random” (MAR) which are suitable for multiple
imputation and yield unbiased results ([Grace-Martin
2012](#ref-GraceMartin:2012)).

*Multiple imputation.*   Lastly, while 5–10 imputations are generally
considered adequate for unbiasedness, Bodner ([2008](#ref-Bodner:2008))
recommends having as many imputations as the percentage of missing data.

``` r

# Number of proxies to be imputed
(N_impute <- sum(is.na(DT$proxy)))
#> [1] 2129

# Number of observations with complete predictor information
(N_complete <- sum(complete.cases(DT[, .(mcid, race, sex, institution)])))
#> [1] 5789

# Percent missing proxies
(percent_missing <- round(100 * N_impute / N_complete, 3))
#> [1] 36.777
```

As shown here, the overall percentage of missing data is 36.78%,
suggesting we set the number of imputations to 37.

``` r

# For the "m" argument in mice()
(m_imputations <- round(percent_missing, 0))
#> [1] 37
```

*Chart.*   The chart displays the percent missing data by category. The
`institution` category isn’t used because the practice data contain FYE
students in one institution only. The vertical dashed line indicates the
37% percent missing data overall.

![Figure 1: Percent missing data by
category.](figures/art-060-fig01-1.png)

Figure 1: Percent missing data by category.

## Setting up `mice()`

The mice package ([van Buuren and Groothuis-Oudshoorn
2011](#ref-vanBuuren+Oudshoorn:2011)) implements multiple imputation by
chained equations (MICE). MICE is also known as “fully conditional
specification” or “sequential regression multiple imputation” and is
suitable for categorical variables such as ours ([Azur et al.
2011](#ref-azur2011)). Our computational procedure follows the approach
suggested by Dhana ([2017](#ref-dhana2017)).

### Standard predictors

*Framework.*   Our first use of
[`mice()`](https://amices.org/mice/reference/mice.html) is to examine
the imputation framework by calling the function with zero iterations on
the `DT` data frame.
[`mice()`](https://amices.org/mice/reference/mice.html) produces a
“multiply-imputed data set”, an R object of class “mids”.

``` r

# Imputation framework
framework <- mice(DT, maxit = 0)
#> Warning: Number of logged events: 2
framework
#> Class: mids
#> Number of multiple imputations:  5 
#> Imputation methods:
#>        mcid institution        race         sex       proxy 
#>          ""          ""          ""          ""   "polyreg" 
#> PredictorMatrix:
#>             mcid institution race sex proxy
#> mcid           0           0    1   1     1
#> institution    0           0    1   1     1
#> race           0           0    0   1     1
#> sex            0           0    1   0     1
#> proxy          0           0    1   1     0
#> Number of logged events:  2 
#>   it im dep     meth         out
#> 1  0  0     constant        mcid
#> 2  0  0     constant institution
```

*Logged events warning.*   The printout above includes a warning about
two “logged events”—an indication that two variables will not be used as
predictors. We can isolate the warning for a closer look,

``` r

# Examine the warning
framework$loggedEvents
#>   it im dep     meth         out
#> 1  0  0     constant        mcid
#> 2  0  0     constant institution
```

The two variables are `mcid` and `institution`.

- `mcid` was never intended to be a predictor variable. We retain the ID
  column so that imputed CIP values are assigned to specific IDs.

- `institution` usually is a predictor. In this case, however, the FYE
  students are all at the same institution—a characteristic of the
  midfielddata practice data only.

*Imputation methods.*   We look more closely at two elements of this
framework. The first is the imputation method vector.

``` r

# Imputation method
method_vector <- framework[["method"]]
method_vector
#>        mcid institution        race         sex       proxy 
#>          ""          ""          ""          ""   "polyreg"
```

The “polyreg” imputation method (polytomous logistic regression) is
appropriate for data, like ours, comprising unordered categorical
variables. Variable `proxy` is imputed using the polyreg method; the
other variables, being predictors, are not imputed, thus their methods
are empty.

Had the method not been correctly assigned, we would assign it as
follows,

``` r

# Manually assign the variable(s) being imputed
method_vector[c("proxy")] <- "polyreg"

# Manually assign the variable(s) not being imputed
method_vector[c("mcid", "institution", "race", "sex")] <- ""
method_vector
#>        mcid institution        race         sex       proxy 
#>          ""          ""          ""          ""   "polyreg"
```

*Predictor matrix.*   The second element to review is the predictor
matrix. A row label identifies the variable being predicted; the columns
indicate the predictor variables.

``` r

# Imputation predictor matrix
predictor_matrix <- framework[["predictorMatrix"]]
predictor_matrix
#>             mcid institution race sex proxy
#> mcid           0           0    1   1     1
#> institution    0           0    1   1     1
#> race           0           0    0   1     1
#> sex            0           0    1   0     1
#> proxy          0           0    1   1     0
```

However, only those variables assigned a method are imputed. In our
case, the only variable to be imputed is `proxy`, so the only row of
this matrix that gets used is the last row.

``` r

# Predictor row for this example
predictor_matrix["proxy", ]
#>        mcid institution        race         sex       proxy 
#>           0           0           1           1           0
```

The zeros and ones tell us that `proxy` is going to be predicted by race
and sex. Again, the institution variable is not a predictor because the
practice data contain one FYE institution only. (This would not be the
case if one were using the MIDFIELD research database.)

Had the default setting been incorrect, we can set them manually. Again,
note that the bottom row is the only row we need because only the
`proxy` variable is being imputed.

``` r

# Manually assign zero columns
predictor_matrix[, c("mcid", "proxy", "institution")] <- 0

# Manually assign predictor columns
predictor_matrix[, c("race", "sex")] <- c(0, 0, 0, 0, 1)
predictor_matrix
#>             mcid institution race sex proxy
#> mcid           0           0    0   0     0
#> institution    0           0    0   0     0
#> race           0           0    0   0     0
#> sex            0           0    0   0     0
#> proxy          0           0    1   1     0
```

If the data included more than one FYE institution, the manual
assignment would be,

``` r

# Not run
predictor_matrix[, c("mcid", "proxy")] <- 0
predictor_matrix[, c("race", "sex", "institution")] <- c(0, 0, 0, 0, 1)
```

### Optional predictors

The default predictors set up by
[`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)
are institution (required), race/ethnicity, and sex. If these are
acceptable, you can skip to the next section, [Imputing missing
values](#imputing-missing-values).

Predictors can be edited or added before invoking
[`mice()`](https://amices.org/mice/reference/mice.html). As before,
ensure that the only missing values are in the proxy column. Other
variables are expected to be complete (no NA values). A value of
“unknown” in a predictor column, e.g., race/ethnicity or sex, is an
acceptable value, not missing data. Observations with missing or unknown
values in the ID or institution columns should be removed.

For example, suppose we wish to replace race/ethnicity and sex with a
`people` variable that has four possible values (`Domestic Female`,
`Domestic Male`, `International Female`, and `International Male`) where
“domestic” means a US citizen; and we want to add a variable that
encodes the `year` of a student’s first term in FYE.

*Creating variables.*   Remove any unknown observations of
race/ethnicity and sex to create the desired `people` variable.

``` r

# Data frame to illustrate optional predictors
opt_DT <- copy(DT)

# Factor to character
cols_to_edit <- c("race", "sex")
opt_DT[, (cols_to_edit) := lapply(.SD, as.character), .SDcols = cols_to_edit]

# Filter unknown race and sex
opt_DT <- opt_DT[sex != "Unknown"]
opt_DT <- opt_DT[race != "Other/Unknown"]

# Create origin variable
opt_DT[, origin := fcase(
  race != "International", "Domestic",
  race == "International", "International",
  default = NA_character_
)]
opt_DT <- opt_DT[!is.na(origin)]

# Create people variable
opt_DT[, people := paste(origin, sex)]
opt_DT[, people := as.factor(people)]
opt_DT[, c("race", "sex", "origin") := NULL]

# Display result
setcolorder(opt_DT, c("mcid", "people", "institution", "proxy"))
opt_DT
#>                 mcid             people   institution  proxy
#>               <char>             <fctr>        <fctr> <fctr>
#>    1: MCID3111142290      Domestic Male Institution J 141001
#>    2: MCID3111142294      Domestic Male Institution J 141001
#>    3: MCID3111142961 International Male Institution J 142101
#>   ---                                                       
#> 5569: MCID3112447659      Domestic Male Institution J   <NA>
#> 5570: MCID3112447663      Domestic Male Institution J   <NA>
#> 5571: MCID3112447664      Domestic Male Institution J   <NA>
```

Check the unique values.

``` r

# Display unique people
sort(unique(opt_DT$people))
#> [1] Domestic Female      Domestic Male        International Female
#> [4] International Male  
#> 4 Levels: Domestic Female Domestic Male ... International Male
```

*Adding a variable.*   Obtain the student’s first term in the data set
from the `term` data table using a left-outer join.

``` r

# Add all term variables by ID
cols_to_join <- term[, .(mcid, term)]
opt_DT <- cols_to_join[opt_DT, on = c("mcid")]

# Filter for first term
setkeyv(opt_DT, c("mcid", "term"))
opt_DT <- opt_DT[, .SD[1], by = c("mcid")]

# Create year variable
opt_DT[, year := substr(term, 1, 4)]
opt_DT[, year := as.factor(year)]
opt_DT[, term := NULL]

# Display result
setcolorder(opt_DT, c("mcid", "people", "institution", "year", "proxy"))
opt_DT
#> Key: <mcid>
#>                 mcid             people   institution   year  proxy
#>               <char>             <fctr>        <fctr> <fctr> <fctr>
#>    1: MCID3111142290      Domestic Male Institution J   1988 141001
#>    2: MCID3111142294      Domestic Male Institution J   1988 141001
#>    3: MCID3111142961 International Male Institution J   1988 142101
#>   ---                                                              
#> 5569: MCID3112447659      Domestic Male Institution J   2009   <NA>
#> 5570: MCID3112447663      Domestic Male Institution J   2009   <NA>
#> 5571: MCID3112447664      Domestic Male Institution J   2009   <NA>
```

*Filtering.*   Ensure complete cases except in `proxy`.

``` r

# Identify complete cases in predictor variables
rows_we_want <- complete.cases(opt_DT[, .(mcid, people, institution, year)])

# Filter for complete predictors
opt_DT <- opt_DT[rows_we_want]
opt_DT
#> Key: <mcid>
#>                 mcid             people   institution   year  proxy
#>               <char>             <fctr>        <fctr> <fctr> <fctr>
#>    1: MCID3111142290      Domestic Male Institution J   1988 141001
#>    2: MCID3111142294      Domestic Male Institution J   1988 141001
#>    3: MCID3111142961 International Male Institution J   1988 142101
#>   ---                                                              
#> 5569: MCID3112447659      Domestic Male Institution J   2009   <NA>
#> 5570: MCID3112447663      Domestic Male Institution J   2009   <NA>
#> 5571: MCID3112447664      Domestic Male Institution J   2009   <NA>
```

*Framework*   for optional predictors.

``` r

# Imputation framework
opt_framework <- mice(opt_DT, maxit = 0)
#> Warning: Number of logged events: 2
opt_framework
#> Class: mids
#> Number of multiple imputations:  5 
#> Imputation methods:
#>        mcid      people institution        year       proxy 
#>          ""          ""          ""          ""   "polyreg" 
#> PredictorMatrix:
#>             mcid people institution year proxy
#> mcid           0      1           0    1     1
#> people         0      0           0    1     1
#> institution    0      1           0    1     1
#> year           0      1           0    0     1
#> proxy          0      1           0    1     0
#> Number of logged events:  2 
#>   it im dep     meth         out
#> 1  0  0     constant        mcid
#> 2  0  0     constant institution
```

*Imputation method*   for optional predictors.

``` r

# Imputation framework
opt_method_vector <- opt_framework[["method"]]
opt_method_vector
#>        mcid      people institution        year       proxy 
#>          ""          ""          ""          ""   "polyreg"
```

*Predictor matrix*   for optional predictors.

``` r

# Imputation predictor matrix
opt_predictor_matrix <- opt_framework[["predictorMatrix"]]
opt_predictor_matrix
#>             mcid people institution year proxy
#> mcid           0      1           0    1     1
#> people         0      0           0    1     1
#> institution    0      1           0    1     1
#> year           0      1           0    0     1
#> proxy          0      1           0    1     0
```

*Percent missing data*   for setting the number of multiple imputations.

``` r

N_impute <- sum(is.na(opt_DT$proxy))
N_fye <- nrow(opt_DT)

# Percent missing data
round(100 * N_impute / N_fye, 0)
#> [1] 37
```

## Imputing missing values

The three essential arguments for
[`mice()`](https://amices.org/mice/reference/mice.html) are the `DT`
data frame, the `method_vector`, and the `predictor_matrix`. The number
of multiple imputations `m` is set to 37 as discussed in [Missing
data](#missing-data). Setting `printFlag = TRUE` displays progress in
the console.

The default `seed` argument is NULL, but by setting the seed as shown
the vignette results are reproducible.

For the practice data, 5 iterations of 37 imputations takes about 3
minutes (depending on your machine). For MIDFIELD research data,
however, imputation runs significantly longer.

``` r

# Impute missing proxy data
DT_mids <- mice(
  data = DT,
  m = m_imputations,
  maxit = 5, # default
  method = method_vector,
  predictorMatrix = predictor_matrix,
  seed = 20180624,
  printFlag = TRUE
)
```

``` r

# output in console with printFlag = TRUE
# >  iter imp variable
# >   1   1  proxy
# >   1   2  proxy
# >   1   3  proxy
# >   1   4  proxy
# >   1   5  proxy
# >   ---
# >   5  33  proxy
# >   5  34  proxy
# >   5  35  proxy
# >   5  36  proxy
# >   5  37  proxy
```

## Post-processing

*Extracting the result.*   We apply
[`mice::complete()`](https://tidyr.tidyverse.org/reference/complete.html)
to extract the data from the `mids` object. The missing data have been
replaced by imputed values.

``` r

# Revert to default random number generation
set.seed(NULL)

# Extract data from the mids object
DT <- mice::complete(DT_mids)

# Convert to data.table structure
setDT(DT)
DT <- DT[order(mcid)]
DT
#>                 mcid   institution          race    sex  proxy
#>               <char>        <fctr>        <fctr> <fctr> <fctr>
#>    1: MCID3111142290 Institution J         Asian   Male 141001
#>    2: MCID3111142294 Institution J         Asian   Male 141001
#>    3: MCID3111142961 Institution J International   Male 142101
#>   ---                                                         
#> 5787: MCID3112447659 Institution J         White   Male 141101
#> 5788: MCID3112447663 Institution J         White   Male 141901
#> 5789: MCID3112447664 Institution J         White   Male 141001
```

*Selecting columns.*   To use the result, we need only two columns: IDs
and the the predicted starting programs.

``` r

# Subset the data
DT <- DT[, .(mcid, proxy)]
DT
#>                 mcid  proxy
#>               <char> <fctr>
#>    1: MCID3111142290 141001
#>    2: MCID3111142294 141001
#>    3: MCID3111142961 142101
#>   ---                      
#> 5787: MCID3112447659 141101
#> 5788: MCID3112447663 141901
#> 5789: MCID3112447664 141001
```

*Recoding.*   We convert the CIP codes from factor to character.

``` r

# Convert factors
DT[, proxy := as.character(proxy)]
DT
#>                 mcid  proxy
#>               <char> <char>
#>    1: MCID3111142290 141001
#>    2: MCID3111142294 141001
#>    3: MCID3111142961 142101
#>   ---                      
#> 5787: MCID3112447659 141101
#> 5788: MCID3112447663 141901
#> 5789: MCID3112447664 141001
```

*Verify prepared data.*   To avoid deriving this data frame each time it
is needed in other vignettes, the same information is provided in the
`fye_proxy` data frame included with midfieldr. Here we verify that the
two data frames have the same content.

``` r

# Demonstrate equivalence
check_equiv_frames(DT, fye_proxy)
#> [1] TRUE
```

## References

Azur, Melissa J., Elizabeth A. Stuart, Constantine Frangakis, and Philip
J. Leaf. 2011. “Multiple Imputation by Chained Equations: What Is It and
How Does It Work?” *International Journal of Methods in Psychiatric
Research* 20 (1): 40–49.

Bodner, Todd E. 2008. “What improves with increased missing data
imputations?” *Structural Equation Modeling: A Multidisciplinary
Journal* 15 (4): 651–75. <https://doi.org/10.1080/10705510802339072>.

Dhana, Klodian. 2017. *Handling Missing Data with MICE Package: A Simple
Approach*. Edited by Data Science Plus. \[Online; accessed 2018-06-24\];
<https://datascienceplus.com/handling-missing-data-with-mice-package-a-simple-approach/>.

Grace-Martin, Karen. 2012. *Two recommended solutions for missing data:
Multiple imputation and maximum likelihood*. Blog post.
<https://www.theanalysisfactor.com/missing-data-two-recommended-solutions/>.

van Buuren, Stef, and Karin Groothuis-Oudshoorn. 2011. “mice:
Multivariate Imputation by Chained Equations in R.” *Journal of
Statistical Software* 45 (3): 1–67.
<https://doi.org/10.18637/jss.v045.i03>.
