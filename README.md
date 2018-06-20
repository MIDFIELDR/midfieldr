
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr <a href="https://engineering.purdue.edu/MIDFIELD" target="blank"><img src="man/figures/midfieldcut.png" align="right"/></a>

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/midfieldr)](http://cran.r-project.org/package=midfieldr)
[![Build
Status](https://travis-ci.org/MIDFIELDR/midfieldr.svg?branch=master)](https://travis-ci.org/MIDFIELDR/midfieldr)
[![Coverage
Status](https://img.shields.io/codecov/c/github/MIDFIELDR/midfieldr/master.svg)](https://codecov.io/github/MIDFIELDR/midfieldr?branch=master)
[![](https://cranlogs.r-pkg.org/badges/grand-total/midfieldr)](https://cran.r-project.org/package=midfieldr)
[![License: GPL
v3](man/figures/License-GPL-v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A package for investigating student record data provided by registrars
at US universities participating in the MIDFIELD project.

midfieldr provides tools for accessing and analyzing a stratified sample
of the MIDFIELD database. The sample comprises demographic, term,
course, and degree information for 97,640 undergraduate students from
1987 to 2016. The sample data are provided in a separate data package.

midfieldr includes functions for selecting specific fields of study and
aggregating, computing, and graphing student persistence metrics.

## Installation

To use midfieldr, the
[midfielddata](https://midfieldr.github.io/midfielddata) package should
also be installed.

Not yet submitted to CRAN, but development versions can be downloaded
from GitHub.

``` r
install.packages("devtools")
devtools::install_github("MIDFIELDR/midfieldr")
devtools::install_github("MIDFIELDR/midfielddata")
```

## Data

The midfieldr package includes:

  - `cip` A data frame with 1584 observations and 6 CIP variables of
    program codes and names at the 2, 4, and 6-digit levels. Each
    observation is a unique program. Occupies 364 kb of memory.

The [midfielddata](https://midfieldr.github.io/midfielddata) package
contains the four datasets that comprise a stratified sample of the
MIDFIELD database.

  - `midfieldstudents` A data frame with 97,640 observations and 15
    demographic variables. Each observation is a unique student.
    Occupies 19 Mb of memory.

  - `midfieldcourses` A data frame with 3.5 M observations and 12
    academic course variables. Each observation is one course in one
    term for one student. Occupies 348 Mb of memory.

  - `midfieldterms` A data frame with 729,014 observations and 13
    academic term variables. Each observation is one term for one
    student. Occupies 82 Mb of memory.

  - `midfielddegrees` A data frame with 97,640 observations and 5
    graduation variables. Each observation is a unique student. Occupies
    10 Mb of memory.

## Usage

We illustrate a number of midfieldr functions by demonstrating how to
compute and graph the “stickiness” metric. Stickiness is the ratio of
the number of students graduating from a program to the number ever
enrolled in the program (Ohland et al. 2012).

Packages to install and load:

``` r
library(midfieldr)
library(seplyr)
library(dplyr)
library(ggplot2)
```

### Select programs to study

In this example we compare the stickiness of three engineering programs:
Chemical, Electrical, and Industrial.

We use `cip_filter()` to search the `cip` dataset first for
“Engineering” and then filter the result for “Chemical”,
“Electrical”, and “Industrial”.

``` r
cip_filter(cip, series = "Engineering") %>%
  cip_filter(., series = c("Chemical", "Electrical", "Industrial")) %>%
  head(., n = 10L)
#> # A tibble: 10 x 6
#>    cip2  cip2name               cip4  cip4name       cip6  cip6name       
#>    <chr> <chr>                  <chr> <chr>          <chr> <chr>          
#>  1 14    Engineering            1407  Chemical Engi~ 1407~ Chemical Engin~
#>  2 14    Engineering            1407  Chemical Engi~ 1407~ Chemical and B~
#>  3 14    Engineering            1407  Chemical Engi~ 1407~ Chemical Engin~
#>  4 14    Engineering            1410  Electrical, E~ 1410~ Electrical, El~
#>  5 14    Engineering            1410  Electrical, E~ 1410~ Laser and Opti~
#>  6 14    Engineering            1410  Electrical, E~ 1410~ Telecommunicat~
#>  7 14    Engineering            1410  Electrical, E~ 1410~ Electrical, El~
#>  8 14    Engineering            1435  Industrial En~ 1435~ Industrial Eng~
#>  9 15    Engineering Technology 1503  Electrical En~ 1503~ Electrical, El~
#> 10 15    Engineering Technology 1503  Electrical En~ 1503~ Laser and Opti~
```

The results show that the codes we want are 1407 Chemical Engineering,
1410 Electrical Engineering, and 1435 Industrial Engineering.

We extract the series for each major and assign our own program label
using `cip_label()`. We can assign the default code name, e.g., using
“cip4name” or we can assign our own label. Here for example, I’ve used
“Electrical Engineering” instead of the longer, default 4-digit code
name “Electrical/Electronics and Communications Engineering.”

``` r
set1 <- cip_filter(cip, series = "^1407") %>%
  cip_label(., program = "cip4name")
set2 <- cip_filter(cip, series = "^1410") %>%
  cip_label(., program = "Electrical Engineering")
set3 <- cip_filter(cip, series = "^1435") %>%
  cip_label(., program = "cip4name")
```

Combine the data frames.

``` r
cip_group <- bind_rows(set1, set2, set3)

cip_group
#> # A tibble: 8 x 7
#>   cip2  cip2name    cip4  cip4name        cip6   cip6name        program  
#>   <chr> <chr>       <chr> <chr>           <chr>  <chr>           <chr>    
#> 1 14    Engineering 1407  Chemical Engin~ 140701 Chemical Engin~ Chemical~
#> 2 14    Engineering 1407  Chemical Engin~ 140702 Chemical and B~ Chemical~
#> 3 14    Engineering 1407  Chemical Engin~ 140799 Chemical Engin~ Chemical~
#> 4 14    Engineering 1410  Electrical, El~ 141001 Electrical, El~ Electric~
#> 5 14    Engineering 1410  Electrical, El~ 141003 Laser and Opti~ Electric~
#> 6 14    Engineering 1410  Electrical, El~ 141004 Telecommunicat~ Electric~
#> 7 14    Engineering 1410  Electrical, El~ 141099 Electrical, El~ Electric~
#> 8 14    Engineering 1435  Industrial Eng~ 143501 Industrial Eng~ Industri~
```

For additional information, try the help page `?cip_filter()` and the
[Selecting CIP codes](cip_filter.html) vignette.

### Compute the metric

Use `gather_ever()` to access the `midfieldterms` dataset and extract
all students who ever enrolled in these programs. Use `race_sex_join()`
to access the `midfieldstudents` dataset and append students’ race and
sex to the data frame.

``` r
students <- gather_ever(cip_group) %>%
  race_sex_join(.)

students
#> # A tibble: 6,444 x 5
#>    id          cip6   program              race  sex   
#>    <chr>       <chr>  <chr>                <chr> <chr> 
#>  1 MID25783178 140701 Chemical Engineering Black Male  
#>  2 MID25783197 140701 Chemical Engineering White Male  
#>  3 MID25783257 140701 Chemical Engineering White Male  
#>  4 MID25785896 140701 Chemical Engineering White Male  
#>  5 MID25786299 140701 Chemical Engineering White Female
#>  6 MID25786339 140701 Chemical Engineering White Male  
#>  7 MID25786745 140701 Chemical Engineering White Male  
#>  8 MID25787174 140701 Chemical Engineering White Male  
#>  9 MID25787361 140701 Chemical Engineering White Male  
#> 10 MID25787468 140701 Chemical Engineering White Male  
#> # ... with 6,434 more rows
```

We create a vector of grouping variables and use the seplyr
`group_summarize()` function to count the numbers of students ever
enrolled in these programs. We define the new variable `ever` to denote
the count.

``` r
grouping_variables <- c("program", "race", "sex")
ever_enrolled <- students %>%
  group_summarize(., grouping_variables, ever = n())
```

Following similar steps, we use `gather_grad()` to access the
`midfielddegrees` dataset and extract all students who graduated from
these programs. We group and summarize the counts using `grad` as the
new count variable.

``` r
graduated <- gather_grad(cip_group) %>%
  race_sex_join(.) %>%
  group_summarize(., grouping_variables, grad = n())
```

We join the two data frames by the grouping
variables.

``` r
stickiness <- left_join(ever_enrolled, graduated, by = grouping_variables)
```

We suggest omitting observations with 5 or fewer students ever enrolled.

``` r
stickiness <- stickiness %>%
  filter(., ever > 5)
```

And we compute stickiness, the ratio of `grad` to `ever`.

``` r
stickiness <- stickiness %>%
  mutate(., stick = round(grad / ever, 3))

stickiness
#> # A tibble: 41 x 6
#>    program              race            sex     ever  grad stick
#>    <chr>                <chr>           <chr>  <int> <int> <dbl>
#>  1 Chemical Engineering Asian           Female    56    26 0.464
#>  2 Chemical Engineering Asian           Male      98    35 0.357
#>  3 Chemical Engineering Black           Female   148    52 0.351
#>  4 Chemical Engineering Black           Male      98    26 0.265
#>  5 Chemical Engineering Hispanic        Female    38    11 0.289
#>  6 Chemical Engineering Hispanic        Male      57    18 0.316
#>  7 Chemical Engineering International   Female     8     4 0.5  
#>  8 Chemical Engineering International   Male      23     7 0.304
#>  9 Chemical Engineering Native American Female     7     1 0.143
#> 10 Chemical Engineering Native American Male       8     3 0.375
#> # ... with 31 more rows
```

For a discussion of each step in greater detail, see the [Stickiness
metric](stickiness.html) vignette.

### Graph the results

To prepare the stickiness data for graphing, we remove ambiguous race
levels (Unknown, International, or Other) and then combine race and sex
into a single variable.

``` r
stickiness_mw_data <- stickiness %>%
  filter(., !race %in% c("Unknown", "International", "Other")) %>%
  filter(., !sex %in% "Unknown") %>%
  mutate(., race_sex = paste(race, sex))
```

We graph these results in a *multiway dot plot* (Cleveland 1993), a
display type based on a data structure of two categorical variables
(program and race/ethnicity/sex) and one quantitative variable
(stickiness).

`multiway_order()` converts the two categorical variables to factors and
orders their levels by median stickiness.

``` r
stickiness_mw_data <- stickiness_mw_data %>%
  select(., program, race_sex, stick) %>%
  multiway_order(.)
```

We use conventional ggplot2 functions to graph stickiness in a multiway
dot plot. We also apply our own `midfield_theme()` to edit the visual
properties of the graph.

``` r
ggplot(stickiness_mw_data, aes(x = stick, y = race_sex)) +
  facet_wrap(~program, ncol = 1, as.table = FALSE) +
  geom_point(na.rm = TRUE) +
  labs(x = "Stickiness", y = "") +
  theme_midfield()
```

<img src="man/figures/README-fig1-1.png" width="70%" style="display: block; margin: auto;" />

The ordering of the rows and panels of the multiway plot tell us that
for these three engineering majors, Industrial Engineering has the
greatest stickiness and Electrical the least; that Asian men have the
greatest stickiness and Native American Women the least. The visual
anomalies are White women in Electrical with lower stickiness than
expected by the ranking overall and Asian men in Chemical, also lower
than expected.

Results will vary depending on the programs one compares. Variations can
also be expected if one uses the whole population data available to
MIDFIELD member institutions.

For additional information on multiways, see the [Multiway data, graphs,
and tables](multiway.html) vignette.

For additional midfieldr functionality and metrics see the
[vignettes](articles/index.html).

# Meta

  - License: [GPL-3](https://www.gnu.org/licenses/gpl-3.0).
  - Please report any [issues or
    bugs](https://github.com/MIDFIELDR/midfieldr/issues).
  - Get citation information with `citation("midfieldr")`.
  - Please note that this project is released with a [Code of
    Conduct](CONDUCT.md). If you contribute to this project you agree to
    abide by its terms.

# References

<div id="refs" class="references">

<div id="ref-cleveland1993">

Cleveland, William S. 1993. *Visualizing Data*. Summit, NJ: Hobart
Press.

</div>

<div id="ref-stickiness2012">

Ohland, Matthew, Marisa Orr, Richard Layton, Susan Lord, and Russell
Long. 2012. “Introducing Stickiness as a Versatile Metric of Engineering
Persistence.” In *Proceedings of the Frontiers in Education Conference*,
1–5.

</div>

</div>
