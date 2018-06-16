
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

midfieldr provides tools for accessing and analyizing s stratified
sample of the MIDFIELD database. The sample comprises demographic, term,
course, and degree information for 97,640 undergraduate students from
1987 to 2016. The sample data are provided in a separate data package.

midfieldr includes functions for selecting specific fields of study and
aggregating, computing, and graphing student persistence metrics.

## Installation

To use midfieldr, the
[midfielddata](https://github.com/MIDFIELDR/midfielddata) package should
also be installed. From CRAN,

``` r
install.packages("midfieldr")
install.packages("midfielddata")
```

Or you can obtain the most recent devlopment version from GitHub.

``` r
install.packages("devtools")
devtools::install_github("MIDFIELDR/midfieldr")
devtools::install_github("MIDFIELDR/midfielddata")
```

## Data

The midfieldr package includes:

  - `cip` A data frame with 1546 observations and 6 CIP variables of
    program codes and names at the 2, 4, and 6-digit levels. Each
    observation is a unique program. Occupies 362 kb of memory.

The [midfielddata](https://github.com/MIDFIELDR/midfielddata) package
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

We illustrate usage by demonstrating how to compute and graph the
stickiness metric. “Stickiness” is the ratio of the number of students
graduating from a program to the number ever enrolled in the program
(Ohland et al. 2012).

The demonstration requires that the midfielddata package be installed
(though not loaded).

Packages to load:

``` r
library(midfieldr)
library(tidyverse)
```

### Select programs to study

In this example we compare the stickiness of three engineering programs:
Chemical, Electrical, and Industrial.

We use `cip_filter()` to search first for “Engineering” and then filter
the result for “Chemical”, “Electrical”, and “Industrial”. The results
show that the 2-digit code “14” describes Engineering programs (wht we
want) while “15” denotes Engineering Technology programs (not what we
want).

``` r
search_results <- cip_filter(series = "Engineering") %>% 
    cip_filter(series = c("Chemical", "Electrical", "Industrial"))

search_results
#> # A tibble: 24 x 6
#>    cip2  cip2name               cip4  cip4name       cip6  cip6name       
#>    <chr> <chr>                  <chr> <chr>          <chr> <chr>          
#>  1 14    Engineering            1407  Chemical Engi~ 1407~ Chemical Engin~
#>  2 14    Engineering            1407  Chemical Engi~ 1407~ Chemical and B~
#>  3 14    Engineering            1407  Chemical Engi~ 1407~ Chemical Engin~
#>  4 14    Engineering            1410  Electrical/El~ 1410~ Electrical/Ele~
#>  5 14    Engineering            1410  Electrical/El~ 1410~ Laser and Opti~
#>  6 14    Engineering            1410  Electrical/El~ 1410~ Telecommunicat~
#>  7 14    Engineering            1410  Electrical/El~ 1410~ Electrical/Ele~
#>  8 14    Engineering            1435  Industrial En~ 1435~ Industrial Eng~
#>  9 15    Engineering Technology 1503  Electrical En~ 1503~ Electrical/Ele~
#> 10 15    Engineering Technology 1503  Electrical En~ 1503~ Laser and Opti~
#> 11 15    Engineering Technology 1503  Electrical En~ 1503~ Telecommunicat~
#> 12 15    Engineering Technology 1503  Electrical En~ 1503~ Integrated Cir~
#> # ... with 12 more rows
```

Running the search again with “^14” (starts with 14), we find that the
codes we want are 1407 Chemical Engineering, 1410 Electrical
Engineering, and 1435 Industrial Engineering.

``` r
search_results <- cip_filter(series = "^14") %>%
  cip_filter(series = c("Chemical", "Electrical", "Industrial"))

search_results
#> # A tibble: 8 x 6
#>   cip2  cip2name    cip4  cip4name             cip6  cip6name             
#>   <chr> <chr>       <chr> <chr>                <chr> <chr>                
#> 1 14    Engineering 1407  Chemical Engineering 1407~ Chemical Engineering 
#> 2 14    Engineering 1407  Chemical Engineering 1407~ Chemical and Biomole~
#> 3 14    Engineering 1407  Chemical Engineering 1407~ Chemical Engineering~
#> 4 14    Engineering 1410  Electrical/Electron~ 1410~ Electrical/Electroni~
#> 5 14    Engineering 1410  Electrical/Electron~ 1410~ Laser and Optical En~
#> 6 14    Engineering 1410  Electrical/Electron~ 1410~ Telecommunications E~
#> 7 14    Engineering 1410  Electrical/Electron~ 1410~ Electrical/Electroni~
#> 8 14    Engineering 1435  Industrial Engineer~ 1435~ Industrial Engineeri~
```

We extract the series for each major and assign our own program label
using `cip_label()`. We can assign the default code name, e.g., using
“cip4name” or we can assign our own label. Here for example, I’ve used
“Electrical Engineering” instead of the longer, default 4-digit code
name “Electrical/Electronics and Communications Engineering.”

``` r
set1 <- cip_filter(series = "^1407") %>% 
    cip_label(program = "cip4name") # use the default 4-digit code name
set2 <- cip_filter(series = "^1410") %>% 
    cip_label(program = "Electrical Engineering")
set3 <- cip_filter(series = "^1435") %>% 
    cip_label(program = "cip4name")
```

Combine the data frames.

``` r
cip_group <- bind_rows(set1, set2, set3)
```

For additional information, try the help page `?cip_filter()` and the
[Selecting CIP codes](cip_filter.html) vignette.

### Compute the metric

Use `gather_ever()` to access the `midfieldterms` dataset and extract
all students who ever enrolled in these programs.

``` r
students <- gather_ever(cip_group)
```

Use `race_sex_join()` to access the `midfieldstudents` dataset and
append students’ race and sex to the data frame.

``` r
students <- students %>%
  race_sex_join()
```

Count the numbers of students grouped by program, race, and sex using
the dplyr `group_by()` and `summarize()` functions. We define the new
variable `ever` to denote the count.

``` r
ever_enrolled <- students %>%
  group_by(program, race, sex) %>%
  summarize(ever = n()) %>%
  ungroup()
```

Use `zero_fill()` to expand the data frame to include all missing
combinations of variables (if any) and insert a count of zero in the
numerical column. The arguments of `zero_fill()` must be identical to
the arguments of `group_by()` above.

``` r
ever_enrolled <- ever_enrolled %>%
  zero_fill(program, race, sex)
```

Use `gather_grad()` to access the `midfielddegrees` dataset and extract
all students who graduated from these programs. We group and summarize
the counts using `grad` as the new count variable.

``` r
graduated <- gather_grad(cip_group) %>%
  race_sex_join() %>%
  group_by(program, race, sex) %>%
  summarize(grad = n()) %>%
  ungroup() %>%
  zero_fill(program, race, sex)
```

The two data frames `ever_enrolled` and `graduated` are the arguments
for the `tally_stickiness()` function that joins the two data frames by
their common variables and computes stickiness.

``` r
stickiness <- tally_stickiness(ever = ever_enrolled, grad = graduated)

glimpse(stickiness)
#> Observations: 48
#> Variables: 6
#> $ program <chr> "Chemical Engineering", "Chemical Engineering", "Chemi...
#> $ race    <chr> "Asian", "Asian", "Black", "Black", "Hispanic", "Hispa...
#> $ sex     <chr> "Female", "Male", "Female", "Male", "Female", "Male", ...
#> $ ever    <dbl> 56, 98, 148, 98, 38, 57, 8, 23, 7, 8, 12, 29, 6, 4, 46...
#> $ grad    <dbl> 26, 35, 52, 26, 11, 18, 4, 7, 1, 3, 1, 3, 3, 2, 170, 3...
#> $ stick   <dbl> 0.464, 0.357, 0.351, 0.265, 0.289, 0.316, 0.500, 0.304...
```

For a discussion of each step in greater detail, see the [Stickiness
metric](stickiness.html) vignette.

### Graph the results

To prepare the stickiness data for graphing, we remove ambiguous race
levels (Unknown, International, or Other) and then combine race and sex
into a single variable.

``` r
stickiness_mw_data <- stickiness %>%
  filter(!race %in% c("Unknown", "International", "Other")) %>%
  mutate(race_sex = str_c(race, sex, sep = " "))
```

We graph these results in a *multiway dot plot* (Cleveland 1993), a
display type based on a data structure of two categorical variables
(program and race/ethnicity/sex) and one quantitative variable
(stickiness).

`multiway_order()` converts the two categorical variables to factors and
orders their levels by median stickiness.

``` r
stickiness_mw_data <- stickiness_mw_data %>%
  select(program, race_sex, stick) %>%
  multiway_order()

glimpse(stickiness_mw_data)
#> Observations: 30
#> Variables: 3
#> $ program  <fct> Chemical Engineering, Chemical Engineering, Chemical ...
#> $ race_sex <fct> Asian Female, Asian Male, Black Female, Black Male, H...
#> $ stick    <dbl> 0.464, 0.357, 0.351, 0.265, 0.289, 0.316, 0.143, 0.37...
```

We use conventional ggplot2 functions to graph stickiness in a multiway
dot plot. We also apply our own `midfield_theme()` to edit the visual
properties of the graph. For additional information on multiways, see
the [Multiway data, graphs, and tables](multiway.html) vignette.

``` r
ggplot(stickiness_mw_data, aes(x = stick, y = race_sex)) +
  facet_wrap(~ program, ncol = 1, as.table = FALSE) +
  geom_point(na.rm = TRUE) +
  labs(x = "Stickiness", y = "") +
  theme_midfield()
```

<img src="man/figures/README-fig1-1.png" width="70%" style="display: block; margin: auto;" />

## Meta

  - License: [GPL-3](https://www.gnu.org/licenses/gpl-3.0).
  - Please report any [issues or
    bugs](https://github.com/MIDFIELDR/midfieldr/issues).
  - Get citation information with `citation("midfieldr")`.
  - Please note that this project is released with a [Code of
    Conduct](CONDUCT.md). If you contribute to this project you agree to
    abide by its terms.

## References

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
