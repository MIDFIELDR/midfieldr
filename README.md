
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr <span class="border-wrap"><img src="man/figures/logo.png" align="right" height="122" width="106" alt="logo.png"></span>

[![License: GPL
v3](man/figures/License-GPL-v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/midfieldr)](https://cran.r-project.org/package=midfieldr)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/midfieldr)](http://cran.r-project.org/package=midfieldr)
[![Build
Status](https://travis-ci.org/MIDFIELDR/midfieldr.svg?branch=master)](https://travis-ci.org/MIDFIELDR/midfieldr)
[![Coverage
Status](https://img.shields.io/codecov/c/github/MIDFIELDR/midfieldr/master.svg)](https://codecov.io/github/MIDFIELDR/midfieldr?branch=master)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

## Undergoing major revision

Based on feedback from workshop attendees, the package is undergoing
major revision to the vignettes and the underlying functionality.

While in this ambiguous state, the package should be used experimentally
only. We hope to have the update complete by the end of August 2020.

## Tools for student records research

The *Multiple-Institution Database for Investigating Engineering
Longitudinal Development*
[(MIDFIELD)](https://engineering.purdue.edu/MIDFIELD) is a partnership
of US higher education institutions with engineering programs. MIDFIELD
contains registrar’s data for 1.7M undergraduates in all majors at 19
institutions from 1987–2019. The data are organized in four related
tables: students, courses, terms, and degrees. A MIDFIELD sample is
provided in the midfielddata package.

**midfielddata** [(link)](https://midfieldr.github.io/midfielddata/) A
stratified sample of MIDFIELD data. Contains data for 97,640
undergraduates at 12 institutions from 1987–2016 in four datasets:
`midfieldstudents`, `midfieldcourses`, `midfieldterms`, and
`midfielddegrees`.

**midfieldr** Tools for studying student records from midfielddata or
the larger MIDFIELD database. Enables research in the intersectionality
of race/ethnicity, sex, and discipline with metrics such as stickiness
(retention by a discipline), migrator graduation rate, and migration
yield (attraction of a discipline).

For MIDFIELD partner researchers: In making the midfielddata package
public, confidentiality required some MIDFIELD variables to be
anonymized and others to be omitted. Thus the midfielddata data
dictionary is a subset of the MIDFIELD data dictionary.

<br> <a href="#top">▲ top of page</a>

## Installation

Install midfielddata first.

Because of its size, the data package is stored in a drat repository.
Installation takes time; please be patient and wait for the Console
prompt “\>” to reappear.

``` r
# install midfielddata first 
install.packages("midfielddata", 
                 repos = "https://MIDFIELDR.github.io/drat/", 
                 type = "source")
```

To confirm a successful installation, run the following to view the
package help page.

``` r
library(midfielddata)
? midfielddata
```

If the installation is successful, the code chunk above should produce a
view of the help page as shown here.

<img src="man/figures/README-fig0-midfielddata-help-page2.png" alt="midfielddata help page" class="center" width="80%">

Once you have conformed that midfielddata is successfully installed,
install midfieldr. The package is currently available from GitHub, but
should be submitted to CRAN by September 2020.

``` r
# install from CRAN (not yet available)
# install.packages("midfieldr")

# or install the development version from GitHub (available now)
# install.packages("devtools")
devtools::install_github("MIDFIELDR/midfieldr")
```

<br> <a href="#top">▲ top of page</a>

## Data

The midfieldr package includes:

  - `cip` Data frame with 1584 observations and 6 CIP variables of
    program codes and names at the 2, 4, and 6-digit levels. Each
    observation is a unique program keyed by a 6-digit CIP code.
    Occupies 380 kB of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfieldr/reference/cip.html).

The midfielddata package contains four datasets that constitute a
stratified sample of the MIDFIELD database.

  - `midfieldstudents` Data frame with 97,640 observations and 15
    demographic variables. Each observation is a unique student keyed by
    student ID. Occupies 19 MB of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfieldstudents.html).

  - `midfieldcourses` Data frame with 3.5 M observations and 12 academic
    course variables keyed by student ID, term, and course. Each
    observation is one course in one term for one student. Occupies 349
    MB of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfieldcourses.html).

  - `midfieldterms` Data frame with 727,369 observations and 13 academic
    term variables keyed by student ID and term. Each observation is one
    term for one student. Occupies 82 MB of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfieldterms.html).

  - `midfielddegrees` A data frame with 97,640 observations and 5
    graduation variables keyed by student ID. Each observation is a
    unique student. Occupies 10.2 MB of memory. Data dictionary
    [(link)](https://midfieldr.github.io/midfielddata/reference/midfielddegrees.html).

<br> <a href="#top">▲ top of page</a>

## Usage

**data carpentry** The default data frame structure is `data.table`. A
user who prefers a dplyr or strictly base R ecosystem should find the
translation to be straightforward. midfieldr functions attempt to
preserve data frame extensions such as tibble.

**graphs** We use ggplot2 in the examples. A translation to lattice or
base R graphics should be easily managed by users familiar with those
systems.

**midfieldr functions** are designed to work with MIDFIELD-structured
data to access and manipulate student records. A typical workflow might
include:

  - `get_cip()` search the CIP data set for program codes  
  - `label_programs()` isolate and label specific programs to study  
  - `get_enrollees()` gather students ever enrolled in the programs
  - `completion_feasible()` subset students for 6-year completion
    feasibility
  - `get_race_sex()` obtain student sex and race/ethnicity
  - `order_multiway()` condition multiway data for graphing

**example** Suppose we want to graph the number of students ever
enrolled in Engineering, grouped by sex and race/ethnicity, for whom
6-year graduation is feasible within the range of data available.

``` r
# packages used
library(midfieldr)
library(data.table)
library(ggplot2)

# data.table printing options
options(datatable.print.nrows = 20, datatable.print.topn = 3)
```

We start with the CIP code—engineering CIP codes all start with 14.
`get_cip()` accesses the `cip` dataset. The output shows that 56
engineering programs are defined.

``` r
# gather the program CIPs
engr_cip <- get_cip(keep_any = "^14")
engr <- label_programs(data = engr_cip, label = "Engineering")

# examine the result
engr
#>       cip6                                                     cip6name
#>  1: 140101                                         Engineering, General
#>  2: 140102                                              Pre-Engineering
#>  3: 140201 Aerospace, Aeronautical and Astronautical, Space Engineering
#> ---                                                                    
#> 54: 149999                                           Engineering, Other
#> 55: 14XXXX                    NonIPEDS - First-Year Engineering Program
#> 56: 14YYYY                          NonIPEDS - Undesignated Engineering
#>         program
#>  1: Engineering
#>  2: Engineering
#>  3: Engineering
#> ---            
#> 54: Engineering
#> 55: Engineering
#> 56: Engineering
```

The 6-digit CIP name is no longer needed.

``` r
# the 6-digit name can be omitted
engr[, cip6name := NULL]

# examine the result
engr
#>       cip6     program
#>  1: 140101 Engineering
#>  2: 140102 Engineering
#>  3: 140201 Engineering
#> ---                   
#> 54: 149999 Engineering
#> 55: 14XXXX Engineering
#> 56: 14YYYY Engineering
```

`get_enrollees()` accesses the `midfieldterms` dataset using the `engr`
6-digit CIP column to obtain the IDs of all students ever enrolled in
these programs. The output shows that we have 26,042 unique combinations
of student and program.

``` r
# extract students ever enrolled
enrollees <- get_enrollees(codes = engr$cip6)

# examine the result
enrollees
#>                 id   cip6
#>     1: MID25783162 14XXXX
#>     2: MID25783166 14XXXX
#>     3: MID25783167 14XXXX
#>    ---                   
#> 26040: MID26697444 141901
#> 26041: MID26697447 140701
#> 26042: MID26697447 141001
```

In this example, all students are in the same program (Engineering), so
we can delete the CIP code and delete duplicated IDs due to students
changing majors.

``` r
# one program, omit duplicate IDs
enrollees[, cip6 := NULL]
enrollees <- unique(enrollees)

# examine the result
enrollees
#>                 id
#>     1: MID25783162
#>     2: MID25783166
#>     3: MID25783167
#>    ---            
#> 19034: MID26697367
#> 19035: MID26697444
#> 19036: MID26697447
```

We now have 19,036 unique students. `completion_feasible()` accesses the
students, terms, and degrees datasets to filter for feasible program
completion within the limits of the data. The output shows we have
14,241 students for whom program completion is feasible.

``` r
# apply the feasible completion filter
feasible_ids <- completion_feasible(id = enrollees$id)
rows_we_want <- enrollees$id %in% feasible_ids
enrollees <- enrollees[rows_we_want]

# examine the result
enrollees
#>                 id
#>     1: MID25783162
#>     2: MID25783178
#>     3: MID25783197
#>    ---            
#> 14239: MID26697367
#> 14240: MID26697444
#> 14241: MID26697447
```

`get_race_sex()` accesses the `midfieldstudents` dataset using the
enrollees IDs.

``` r
# get student demographics
demographics <- get_race_sex(keep_id = feasible_ids)

# examine the result
demographics
#>                 id     race  sex
#>     1: MID25783162    White Male
#>     2: MID25783178    Black Male
#>     3: MID25783197    White Male
#>    ---                          
#> 14239: MID26697367 Hispanic Male
#> 14240: MID26697444    White Male
#> 14241: MID26697447    Asian Male
```

Routinely we would join the demographics data to the enrollees data.
However, this example illustrates students in one program only, so the
information in `demographics` is all we need.

Group and summarize by race/ethnicity. For viewing the data, we order
the rows by sex and race.

``` r
# aggregate
grouped_enrollees <- demographics[, .(ever = .N), by = c("sex", "race")]

# examine the result
grouped_enrollees[order(sex, race)]
#>        sex            race ever
#>  1: Female           Asian  217
#>  2: Female           Black  615
#>  3: Female        Hispanic  110
#>  4: Female   International   42
#>  5: Female Native American   16
#>  6: Female           Other   38
#>  7: Female         Unknown   21
#>  8: Female           White 2169
#>  9:   Male           Asian  724
#> 10:   Male           Black  966
#> 11:   Male        Hispanic  374
#> 12:   Male   International  238
#> 13:   Male Native American   58
#> 14:   Male           Other  161
#> 15:   Male         Unknown   45
#> 16:   Male           White 8447
```

Prepare data for graphing.

``` r
# remove ambiguous levels of race/ethnicity
race_to_drop <- c("International", "Other", "Unknown")
rows_we_want <- !grouped_enrollees$race %in% race_to_drop
columns_we_want <- c("sex", "race", "ever")

# complete the transformation to multiway form
pre_mw <- grouped_enrollees[rows_we_want, ..columns_we_want]

# examine the result
str(pre_mw)
#> Classes 'data.table' and 'data.frame':   10 obs. of  3 variables:
#>  $ sex : chr  "Male" "Male" "Female" "Male" ...
#>  $ race: chr  "White" "Black" "White" "Native American" ...
#>  $ ever: int  8447 966 2169 58 217 615 374 724 110 16
#>  - attr(*, ".internal.selfref")=<externalptr>
```

`order_multiway()` converts the categorical variables to factors and
orders the levels by the median of the quantitative variable. `str()`
reveals that the previous character variables are now factors.

``` r
data_mw <- order_multiway(pre_mw)

# examine the result
str(data_mw)
#> Classes 'data.table' and 'data.frame':   10 obs. of  3 variables:
#>  $ sex : Factor w/ 2 levels "Female","Male": 2 2 1 2 1 1 2 2 1 1
#>  $ race: Factor w/ 5 levels "Native American",..: 5 4 5 1 3 4 2 3 2 1
#>  $ ever: num  8447 966 2169 58 217 ...
#>  - attr(*, ".internal.selfref")=<externalptr>

# total number of students for graph subtitle
n_ever <- sum(data_mw$ever)
n_ever
#> [1] 13696
```

We graph the results. We use a logarithmic scale to compare numbers that
differ by orders of magnitude and a log-2 scale in particular because a
grid line represents a doubling of the previous grid line.

``` r
ggplot(data = data_mw, mapping = aes(x = ever, y = race)) +
  facet_wrap(facets = vars(sex), ncol = 1, as.table = FALSE) +
  geom_point(na.rm = TRUE) +
  scale_x_continuous(trans = "log2", breaks = 2^seq(0, 15)) +
  labs(
    x = "Number of students, log-2 scale",
    y = "",
    title = "Ever enrolled in Engineering",
    subtitle = bquote(N == .(n_ever)),
    caption = "Source: midfielddata"
  ) +
  theme(panel.grid.minor.x = element_blank())
```

<img src="man/figures/README-fig1-1.png" width="80%" style="display: block; margin: auto;" />

## Vignettes

[vignette (“Using midfieldr”)](articles/using_midfieldr.html)
illustrates a complete example that starts with program selection and
concludes with a persistence metric.

Additional vignettes go into even more detail
[(link)](articles/index.html).

## Meta

  - Data provided by MIDFIELD
    [(link)](https://engineering.purdue.edu/MIDFIELD)  
  - Get citation information with `citation("midfieldr")`
  - This project is released with a Code of Conduct
    [(link)](https://midfieldr.github.io/midfieldr/CONDUCT.html). If you
    contribute to this project you agree to abide by its terms.

<br> <a href="#top">▲ top of page</a>
