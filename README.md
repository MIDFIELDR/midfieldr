
<!-- README.md is generated from README.Rmd. Please edit that file -->

# midfieldr <a href="https://engineering.purdue.edu/MIDFIELD" target="blank"><img src="man/figures/logo.png" align="right"/></a>

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

midfieldr provides access to
[midfielddata](https://midfieldr.github.io/midfielddata/), a data
package containing a stratified sample of the MIDFIELD database. The
sample comprises demographic, term, course, and degree information for
97,640 undergraduate students from 1987 to 2016.

midfieldr provides functions for investigating these data to determine
persistence metrics such as graduation rates or program stickiness and
for grouping findings by institution, program, sex, and race/ethnicity.
The goal of the package is to share data, methods, and metrics for
intersectional research in student persistence.

## Installation

midfieldr depends on midfielddata, a data package available from a [drat
repository](https://midfieldr.github.io/drat/) on GitHub. Install
midfielddata before installing midfieldr.

``` r
install.packages("drat")
drat::addRepo("midfieldr")
install.packages("midfielddata")
```

The development version of midfieldr can be installed from GitHub.

``` r
install.packages("devtools")
devtools::install_github("MIDFIELDR/midfieldr")
```

## Data

The midfieldr package includes:

  - `cip` A data frame with 1584 observations and 6 CIP variables of
    program codes and names at the 2, 4, and 6-digit levels. Each
    observation is a unique program. Occupies 364 kb of memory.

The midfielddata package contains the four datasets that comprise a
stratified sample of the MIDFIELD database.

  - `midfieldstudents` A data frame with 97,640 observations and 15
    demographic variables. Each observation is a unique student.
    Occupies 19 Mb of memory.

  - `midfieldcourses` A data frame with 3.5 M observations and 12
    academic course variables. Each observation is one course in one
    term for one student. Occupies 348 Mb of memory.

  - `midfieldterms` A data frame with 727,369 observations and 13
    academic term variables. Each observation is one term for one
    student. Occupies 82 Mb of memory.

  - `midfielddegrees` A data frame with 97,640 observations and 5
    graduation variables. Each observation is a unique student. Occupies
    10 Mb of memory.

## Usage

To introduce using the package, we show how to determine program
“stickiness,” the ratio of the number of students graduating from a
program to the number ever enrolled in the program (Ohland et al. 2012).
We compare the stickiness of three programs: Chemical Engineering,
Electrical Engineering, and Industrial Engineering.

For more detail, please see the individual
[vignettes](articles/index.html).

Packages to install and load:

``` r
library(dplyr)
library(ggplot2)
library(midfieldr)
library(seplyr)
```

**Step 1. Select programs to study**

We use `cip_filter()` to search the `cip` dataset first for
“Engineering” and then filter the result for “Chemical”,
“Electrical”, and “Industrial”.

``` r
cip_filter(series = "Engineering") %.>%
  cip_filter(
    series = c("Chemical", "Electrical", "Industrial"),
    reference = .
  ) %.>%
  print(.)
#> # A tibble: 24 x 6
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
#> # ... with 14 more rows
```

The results show that the codes we want are 1407 Chemical Engineering,
1410 Electrical Engineering, and 1435 Industrial Engineering.

We extract the series for each major and assign our own program label
using `cip_label()`. We can assign the default code name, e.g., using
“cip4name” or we can assign our own label. Here for example, I’ve used
“Electrical Engineering” instead of the longer, default 4-digit code
name “Electrical/Electronics and Communications Engineering.”

``` r
set1 <- cip_filter(series = "^1407") %.>%
  cip_label(., program = "cip4name")
set2 <- cip_filter(series = "^1410") %.>%
  cip_label(., program = "Electrical Engineering")
set3 <- cip_filter(series = "^1435") %.>%
  cip_label(., program = "cip4name")
```

Combine the data frames.

``` r
program_group <- bind_rows(set1, set2, set3) %.>%
  print(.)
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

**Step 2. Gather the data and compute the metric**

First we extract the 6-digit CIP codes from our program group to use as
search terms.

``` r
program_group_cip6 <- program_group[["cip6"]]
```

Use `gather_ever()` to access the `midfieldterms` dataset and extract
all students who ever enrolled in these programs. Use `race_sex_join()`
to access the `midfieldstudents` dataset and append students’ race and
sex to the data frame.

``` r
students <- gather_ever(series = program_group_cip6) %.>%
  race_sex_join(.) %.>%
  print(.)
#> # A tibble: 6,444 x 4
#>    id          cip6   race          sex  
#>    <chr>       <chr>  <chr>         <chr>
#>  1 MID25783178 140701 Black         Male 
#>  2 MID25783178 143501 Black         Male 
#>  3 MID25783197 140701 White         Male 
#>  4 MID25783257 140701 White         Male 
#>  5 MID25783491 141001 White         Male 
#>  6 MID25783606 141001 White         Male 
#>  7 MID25783912 143501 White         Male 
#>  8 MID25784118 141001 White         Male 
#>  9 MID25784209 141001 International Male 
#> 10 MID25784234 143501 White         Male 
#> # ... with 6,434 more rows
```

Next we join our custom program names to the student data.

``` r
students <- left_join(students, program_group, by = "cip6") %.>%
  print(.)
#> # A tibble: 6,444 x 10
#>    id     cip6  race  sex   cip2  cip2name cip4  cip4name cip6name program
#>    <chr>  <chr> <chr> <chr> <chr> <chr>    <chr> <chr>    <chr>    <chr>  
#>  1 MID25~ 1407~ Black Male  14    Enginee~ 1407  Chemica~ Chemica~ Chemic~
#>  2 MID25~ 1435~ Black Male  14    Enginee~ 1435  Industr~ Industr~ Indust~
#>  3 MID25~ 1407~ White Male  14    Enginee~ 1407  Chemica~ Chemica~ Chemic~
#>  4 MID25~ 1407~ White Male  14    Enginee~ 1407  Chemica~ Chemica~ Chemic~
#>  5 MID25~ 1410~ White Male  14    Enginee~ 1410  Electri~ Electri~ Electr~
#>  6 MID25~ 1410~ White Male  14    Enginee~ 1410  Electri~ Electri~ Electr~
#>  7 MID25~ 1435~ White Male  14    Enginee~ 1435  Industr~ Industr~ Indust~
#>  8 MID25~ 1410~ White Male  14    Enginee~ 1410  Electri~ Electri~ Electr~
#>  9 MID25~ 1410~ Inte~ Male  14    Enginee~ 1410  Electri~ Electri~ Electr~
#> 10 MID25~ 1435~ White Male  14    Enginee~ 1435  Industr~ Industr~ Indust~
#> # ... with 6,434 more rows
```

We create a vector of grouping variables and use the seplyr
`group_summarize()` function to count the numbers of students ever
enrolled in these programs. We define the new variable `ever` to denote
the count.

``` r
grouping_variables <- c("program", "race", "sex")

ever_enrolled <- students %.>%
  group_summarize(., grouping_variables, ever = n()) %.>%
  print(.)
#> # A tibble: 48 x 4
#>    program              race            sex     ever
#>    <chr>                <chr>           <chr>  <int>
#>  1 Chemical Engineering Asian           Female    56
#>  2 Chemical Engineering Asian           Male      98
#>  3 Chemical Engineering Black           Female   148
#>  4 Chemical Engineering Black           Male      98
#>  5 Chemical Engineering Hispanic        Female    38
#>  6 Chemical Engineering Hispanic        Male      57
#>  7 Chemical Engineering International   Female     8
#>  8 Chemical Engineering International   Male      23
#>  9 Chemical Engineering Native American Female     7
#> 10 Chemical Engineering Native American Male       8
#> # ... with 38 more rows
```

Following similar steps, we use `gather_grad()` to access the
`midfielddegrees` dataset and extract all students who graduated from
these programs. We group and summarize the counts using `grad` as the
new count variable.

``` r
graduated <- gather_grad(series = program_group_cip6) %.>%
  race_sex_join(.) %.>%
  left_join(., program_group, by = "cip6") %.>%
  group_summarize(., grouping_variables, grad = n())
```

We join the two data frames by the grouping
variables.

``` r
stickiness <- left_join(ever_enrolled, graduated, by = grouping_variables)
```

We suggest omitting observations with 5 or fewer students ever enrolled.

``` r
stickiness <- stickiness %.>%
  filter(., ever > 5)
```

And we compute stickiness, the ratio of `grad` to `ever`.

``` r
stickiness <- stickiness %.>%
  mutate(., stick = round(grad / ever, 3)) %.>%
  print(.)
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

**Step 3. Graph the results**

To prepare the stickiness data for graphing, we remove ambiguous race
levels (Unknown, International, or Other) and then combine race and sex
into a single variable.

``` r
stickiness_mw <- stickiness %.>%
  filter(., !race %in% c("Unknown", "International", "Other")) %.>%
  filter(., !sex %in% "Unknown") %.>%
  mutate(., race_sex = paste(race, sex))
```

We graph these results in a *multiway dot plot* (Cleveland 1993), a
display type based on a data structure of two categorical variables
(program and race/ethnicity/sex) and one quantitative variable
(stickiness).

`multiway_order()` converts the two categorical variables to factors and
orders their levels by median stickiness.

``` r
stickiness_mw <- stickiness_mw %.>%
  select(., program, race_sex, stick) %.>%
  multiway_order(., return_medians = TRUE) %>%
  print(.)
#> # A tibble: 27 x 5
#>    program              race_sex            stick med_program med_race_sex
#>    <fct>                <fct>               <dbl>       <dbl>        <dbl>
#>  1 Chemical Engineering Asian Female        0.464       0.354        0.44 
#>  2 Chemical Engineering Asian Male          0.357       0.354        0.471
#>  3 Chemical Engineering Black Female        0.351       0.354        0.4  
#>  4 Chemical Engineering Black Male          0.265       0.354        0.331
#>  5 Chemical Engineering Hispanic Female     0.289       0.354        0.289
#>  6 Chemical Engineering Hispanic Male       0.316       0.354        0.352
#>  7 Chemical Engineering Native American Fe~ 0.143       0.354        0.143
#>  8 Chemical Engineering Native American Ma~ 0.375       0.354        0.229
#>  9 Chemical Engineering White Female        0.366       0.354        0.366
#> 10 Chemical Engineering White Male          0.391       0.354        0.424
#> # ... with 17 more rows
```

We use conventional ggplot2 functions to graph stickiness in a multiway
dot plot. We also apply our own `theme_midfield()` to edit the visual
properties of the graph.

``` r
ggplot(stickiness_mw, aes(x = stick, y = race_sex)) +
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

## Meta

  - Data provided by the
    [MIDFIELD](%7Bhttps://engineering.purdue.edu/MIDFIELD) project
  - Get citation information with `citation("midfieldr")`
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
