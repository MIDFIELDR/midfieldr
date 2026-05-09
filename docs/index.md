  
midfieldr is an R package that provides tools and methods for studying
undergraduate student-level records from the MIDFIELD database.

![](reference/figures/logo.png)

## Introduction

Provides tools and demonstrates methods for working with individual
undergraduate student-level records (registrar’s data) in R. Tools
include filters for program codes, data sufficiency, and timely
completion. Methods include gathering blocs of records, computing
quantitative metrics such as graduation rate, and creating charts to
visualize comparisons. midfieldr is designed to work with data from the
MIDFIELD research database, a sample of which is available in the
midfielddata data package.

midfieldr provides these functions for manipulating student-level data:

- [`add_completion_status()`](https://midfieldr.github.io/midfieldr/reference/add_completion_status.md)
  Determine completion status for every student
- [`add_data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/add_data_sufficiency.md)
  Determine data sufficiency for every student
- [`add_timely_term()`](https://midfieldr.github.io/midfieldr/reference/add_timely_term.md)
  Calculate a timely completion term for every student
- [`filter_cip()`](https://midfieldr.github.io/midfieldr/reference/filter_cip.md)
  Filter CIP data to match search strings
- [`prep_fye_mice()`](https://midfieldr.github.io/midfieldr/reference/prep_fye_mice.md)
  Prepare FYE data for multiple imputation
- [`select_required()`](https://midfieldr.github.io/midfieldr/reference/select_required.md)
  Select required midfieldr variables

Additional functions for processing intermediate results:

- [`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)
  Order categorical variables of multiway data

R packages in examples and vignettes

- *Data preparation.*   We use the data.table system and some base R for
  data manipulation ([Dowle and Srinivasan
  2022](#ref-Dowle+Srinivasan:2022:data.table)). To assist users who
  might prefer other systems, the MIDFIELD Institute website ([Lord et
  al. 2024](#ref-midfieldinstitute:2024)) includes tutorials providing
  side-by-side base R, data.table, and dplyr solutions to common data
  shaping tasks using MIDFIELD practice data.  
- *Charts.*   Our preferred package for charts is ggplot2 ([Wickham
  2016](#ref-Wickham:2016:ggplot2)). The lattice package ([Sarkar
  2008](#ref-Sarkar:2008)) also offers users comprehensive control over
  graphical elements (though our lattice experience is no longer
  current).

## Usage

In this example, we gather all students ever enrolled in Engineering and
summarize their graduation status (in any major), grouping by
race/ethnicity and sex. If you are writing your own script to follow
along, we use these packages in this example:

``` r

library(midfieldr)
library(midfielddata)
library(data.table)
```

Load the practice data. Reduce initial dimensions of data tables.

``` r

# Load the practice data
data(student, term, degree)

# Reduce dimensions of source data tables
student <- select_required(student)
term <- select_required(term)
degree <- select_required(degree)

# View example result
term
#>                   mcid   institution   term   cip6         level
#>                 <char>        <char> <char> <char>        <char>
#>      1: MCID3111142225 Institution B  19881 140901 01 First-year
#>      2: MCID3111142283 Institution J  19881 240102 01 First-year
#>      3: MCID3111142283 Institution J  19883 240102 01 First-year
#>     ---                                                         
#> 639913: MCID3112898894 Institution B  20181 451001 01 First-year
#> 639914: MCID3112898895 Institution B  20181 302001 01 First-year
#> 639915: MCID3112898940 Institution B  20181 050103 01 First-year
```

Filter for data sufficiency.

``` r

# Initialize the working data frame
DT <- term[, .(mcid, cip6)]

# Filter observations for data sufficiency
DT <- add_timely_term(DT, term)
DT <- add_data_sufficiency(DT, term)
DT <- DT[data_sufficiency == "include"]
DT
#>                   mcid   cip6       level_i adj_span timely_term term_i
#>                 <char> <char>        <char>    <num>      <char> <char>
#>      1: MCID3111142689 090401 01 First-year        6       19941  19883
#>      2: MCID3111142782 260101 01 First-year        6       19941  19883
#>      3: MCID3111142782 260101 01 First-year        6       19941  19883
#>     ---                                                                
#> 531417: MCID3112870009 240102 01 First-year        6       20003  19951
#> 531418: MCID3112870009 240102 01 First-year        6       20003  19951
#> 531419: MCID3112870009 240102 01 First-year        6       20003  19951
#>         lower_limit upper_limit data_sufficiency
#>              <char>      <char>           <char>
#>      1:       19881       20181          include
#>      2:       19881       20096          include
#>      3:       19881       20096          include
#>     ---                                         
#> 531417:       19881       20181          include
#> 531418:       19881       20181          include
#> 531419:       19881       20181          include
```

Filter for degree-seeking students ever enrolled in Engineering.

``` r

# Inner join to filter observations for degree-seeking
cols_we_want <- student[, .(mcid)]
DT <- cols_we_want[DT, on = c("mcid"), nomatch = NULL]

# Filter observations for engineering programs
DT <- DT[cip6 %like% "^14"]

# Filter observations for unique students (first instance)
DT <- DT[, .SD[1], by = c("mcid")]
DT
#>                  mcid   cip6        level_i adj_span timely_term term_i
#>                <char> <char>         <char>    <num>      <char> <char>
#>     1: MCID3111142965 140102  01 First-year        6       19941  19883
#>     2: MCID3111145102 140102  01 First-year        6       19941  19883
#>     3: MCID3111146537 141001 02 Second-year        5       19931  19883
#>    ---                                                                 
#> 10399: MCID3112641399 141901  01 First-year        6       20181  20123
#> 10400: MCID3112641535 141901  01 First-year        6       20173  20121
#> 10401: MCID3112698681 141901  01 First-year        6       20171  20113
#>        lower_limit upper_limit data_sufficiency
#>             <char>      <char>           <char>
#>     1:       19881       20096          include
#>     2:       19881       20096          include
#>     3:       19881       20096          include
#>    ---                                         
#> 10399:       19881       20181          include
#> 10400:       19881       20181          include
#> 10401:       19881       20181          include
```

Determine completion status.

``` r

# Add completion status variable
DT <- add_completion_status(DT, degree)
DT
#>                  mcid   cip6        level_i adj_span timely_term term_i
#>                <char> <char>         <char>    <num>      <char> <char>
#>     1: MCID3111142965 140102  01 First-year        6       19941  19883
#>     2: MCID3111145102 140102  01 First-year        6       19941  19883
#>     3: MCID3111146537 141001 02 Second-year        5       19931  19883
#>    ---                                                                 
#> 10399: MCID3112641399 141901  01 First-year        6       20181  20123
#> 10400: MCID3112641535 141901  01 First-year        6       20173  20121
#> 10401: MCID3112698681 141901  01 First-year        6       20171  20113
#>        lower_limit upper_limit data_sufficiency term_degree completion_status
#>             <char>      <char>           <char>      <char>            <char>
#>     1:       19881       20096          include       19901            timely
#>     2:       19881       20096          include       19893            timely
#>     3:       19881       20096          include       19913            timely
#>    ---                                                                       
#> 10399:       19881       20181          include       20163            timely
#> 10400:       19881       20181          include       20143            timely
#> 10401:       19881       20181          include       20181              late
```

Aggregate observations by groupings.

``` r

# Left join to add race/ethnicity and sex variables (omit unknowns)
cols_we_want <- student[, .(mcid, race, sex)]
DT <- student[DT, on = c("mcid")]
DT <- DT[!(race %ilike% "unknown" | sex %ilike% "unknown")]

# Create a variable combining race/ethnicity and sex
DT[, people := paste(race, sex)]

# Aggregate observations by groupings
DT_display <- DT[, .N, by = c("completion_status", "people")]
setorderv(DT_display, c("completion_status", "people"))
DT_display
#>     completion_status               people     N
#>                <char>               <char> <int>
#>  1:              <NA>         Asian Female    43
#>  2:              <NA>           Asian Male   163
#>  3:              <NA>         Black Female    39
#> ---                                             
#> 33:            timely Native American Male    13
#> 34:            timely         White Female   985
#> 35:            timely           White Male  4100
```

Reshape and display results.

``` r

# Transform to row-record form
DT_display <- dcast(DT_display, people ~ completion_status, value.var = "N", fill = 0)

# Prepare the table for display
setcolorder(DT_display, c("people", "timely", "late"))
setkeyv(DT_display, c("people"))
setnames(DT_display,
  old = c("people", "timely", "late", "NA"),
  new = c("People", "Timely completion", "Late completion", "Did not complete")
)
```

| People                 | Timely completion | Late completion | Did not complete |
|------------------------|-------------------|-----------------|------------------|
| Asian Female           | 87                | 4               | 43               |
| Asian Male             | 315               | 19              | 163              |
| Black Female           | 26                | 3               | 39               |
| Black Male             | 80                | 5               | 84               |
| Hispanic Female        | 36                | 3               | 31               |
| Hispanic Male          | 181               | 19              | 102              |
| International Female   | 110               | 9               | 51               |
| International Male     | 501               | 41              | 280              |
| Native American Female | 2                 | 0               | 2                |
| Native American Male   | 13                | 3               | 6                |
| White Female           | 985               | 51              | 386              |
| White Male             | 4100              | 269             | 2034             |

Table 1: Completion status of engineering undergraduates in the practice
data {.table .gt_table quarto-disable-processing="false"
quarto-bootstrap="false"}

“Timely completion” is the count of graduates completing their programs
in no more than 6 years; “Late completion” is the count of those
graduating in more than 6 years; “Did not complete” is the count of
non-graduates.

*Reminder.*   midfielddata is suitable for learning to work with
student-level data but not for drawing inferences about program
attributes or student experiences. midfielddata supplies practice data,
not research data.

## Installation

Install from CRAN with:

``` r

install.packages("midfieldr")
```

Install latest development version from GitHub with:

``` r

install.packages("pak")
pak::pkg_install("MIDFIELDR/midfieldr")
```

midfieldr interacts with practice data provided in the midfielddata data
package. Install midfielddata from its repository with:

``` r

install.packages("midfielddata",
  repos = "https://MIDFIELDR.github.io/drat/",
  type = "source"
)
```

The installed size of midfielddata is about 24 Mb, so the installation
takes some time.

## More information

[MIDFIELD](https://midfield.online/).   A database of anonymized
student-level records for approximately 2.4M undergraduates at 21 US
institutions from 1987-2022. In 2023, control and management of the
database was transferred to the American Society for Engineering
Education (ASEE). For further information, contact ASEE.

[midfielddata](https://midfieldr.github.io/midfielddata/).   An R data
package that supplies anonymized student-level records for 98,000
undergraduates at three US institutions from 1988-2018. A sample of the
MIDFIELD database, midfielddata provides practice data for the tools and
methods in the midfieldr package.

## Acknowledgments

As of the transfer of MIDFIELD to the American Society for Engineering
Education (ASEE) in 2023, the development, expansion, and study of
MIDFIELD has been supported by the National Science Foundation grants
0337629, 0646441, 0729596, 0734062, 0835914, 0935157, 0935058, 0969474,
1025171, 1129383, 1232740, 1329283, 1361058, 1545667, 2142087, 2141903,
and 2152441.

## References

Dowle, Matt, and Arun Srinivasan. 2022. *data.table: Extension of
‘Data.frame‘*. R package version 1.14.6.
<https://CRAN.R-project.org/package=data.table>.

Lord, Susan, Richard Layton, Russell Long, Matthew Ohland, and Marisa
Orr. 2024. *MIDFIELD Institute*.
<https://midfieldr.github.io/2024-midfield-institute/>.

Sarkar, Deepayan. 2008. *lattice: Multivariate Data Visualization with
R*. Springer. <http://lmdvr.r-forge.r-project.org>.

Wickham, Hadley. 2016. *ggplot2: Elegant Graphics for Data Analysis*.
ISBN 978-3-319-24277-4; Springer-Verlag New York.
<https://ggplot2.tidyverse.org>.
