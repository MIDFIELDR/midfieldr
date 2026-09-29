# midfieldr

## Overview

midfieldr is an R package with tools for working with longitudinal
undergraduate records from the MIDFIELD database ([Ohland & Long,
2016](#ref-Ohland+Long:2016)) or similarly structured data tables
([ASEE, 2023](#ref-ATLAS:2023)). These tools help you develop credible
populations, subset records to calculate quantitative metrics, and
prepare results for dissemination.

- [`completion_status()`](https://midfieldr.github.io/midfieldr/reference/completion_status.md)
  Identifies students completing a program in a timely manner.
- [`data_sufficiency()`](https://midfieldr.github.io/midfieldr/reference/data_sufficiency.md)
  Identifies records to exclude due to insufficient data.
- [`filter_programs()`](https://midfieldr.github.io/midfieldr/reference/filter_programs.md)
  Helps in finding 6-digit program codes.
- [`initialize_fye_proxies()`](https://midfieldr.github.io/midfieldr/reference/initialize_fye_proxies.md)
  Conditions data for imputing starting majors of First-Year Engineering
  (FYE) students.
- [`order_multiway()`](https://midfieldr.github.io/midfieldr/reference/order_multiway.md)
  Conditions multiway data for Cleveland multiway charts.
- [`pre_or_post_bacc()`](https://midfieldr.github.io/midfieldr/reference/pre_or_post_bacc.md)
  Distinguishes between pre- and post-baccalaureate terms.
- [`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md)
  Determines the latest term by which program completion would be
  considered timely.

## Installation

``` r

# Install from CRAN:
install.packages("midfieldr")

# Or install the development version from GitHub:
pak::pak("MIDFIELDR/midfieldr")

# Also install the midfielddata package for practice data
install.packages("midfielddata",
  repos = "https://MIDFIELDR.github.io/drat/",
  type = "source"
)
```

## Usage

Data that load with midfieldr include `cip` for program codes and small
samples of the four data tables (`toy_*`) for terse examples.

``` r

library("midfieldr")
library("data.table")

# assign default names to toy tables
student <- copy(toy_student)
term <- copy(toy_term)
course <- copy(toy_course)
degree <- copy(toy_degree)

# pull IDs of degree-seeking students
DT <- student[, .(mcid)]
DT
#>                mcid
#>              <char>
#>   1: MCID3111142897
#>   2: MCID3111157634
#>   3: MCID3111158724
#>  ---               
#> 349: MCID3112868072
#> 350: MCID3112869843
#> 351: MCID3112885339

# determine data sufficiency
DT <- timely_term(DT)
DT <- data_sufficiency(DT)

# summarize data sufficiency
DT[, .N, by = "sufficiency"][order(-N)]
#>    sufficiency     N
#>         <char> <int>
#> 1:   satisfied   240
#> 2:  fail-upper    99
#> 3:  fail-lower    12

# subset to obtain baseline population
population <- DT[sufficiency == "satisfied", .(mcid)]
population
#>                mcid
#>              <char>
#>   1: MCID3111198701
#>   2: MCID3111208924
#>   3: MCID3111213539
#>  ---               
#> 238: MCID3112592592
#> 239: MCID3112593368
#> 240: MCID3112617577

# inner join to filter records to match the population
student <- population[student, on = "mcid", nomatch = NULL]
term <- population[term, on = "mcid", nomatch = NULL]
course <- population[course, on = "mcid", nomatch = NULL]
degree <- population[degree, on = "mcid", nomatch = NULL]

# distinguish undergraduate and post-baccalaureate terms
term <- pre_or_post_bacc(term)
course <- pre_or_post_bacc(course)
degree <- pre_or_post_bacc(degree)

# summarize term types
term[, .N, by = "pre_or_post"][order(-pre_or_post)]
#>    pre_or_post     N
#>         <char> <int>
#> 1:    pre-bacc  1330
#> 2:   post-bacc    17
course[, .N, by = "pre_or_post"][order(-pre_or_post)]
#>    pre_or_post     N
#>         <char> <int>
#> 1:    pre-bacc  6380
#> 2:   post-bacc    41
degree[, .N, by = "pre_or_post"][order(-pre_or_post)]
#>    pre_or_post     N
#>         <char> <int>
#> 1:    pre-bacc   169
#> 2:   post-bacc     1

# retain undergraduate terms
term <- term[pre_or_post == "pre-bacc"]
course <- course[pre_or_post == "pre-bacc"]
degree <- degree[pre_or_post == "pre-bacc"]

# obtain 6-digit CIP codes of 3 programs
programs <- filter_programs(cip, c("^14", "^42", "^52"))
programs <- programs[, .(cip6name, cip6)]

# construct the programs table
programs[, program := fcase(
  cip6 %like% "^14", "Engineering",
  cip6 %like% "^42", "Psychology",
  cip6 %like% "^52", "Business"
)]
programs <- programs[, .(cip6, program)]
programs
#>        cip6     program
#>      <char>      <char>
#>   1: 140101 Engineering
#>   2: 140102 Engineering
#>   3: 140201 Engineering
#>  ---                   
#> 173: 522001    Business
#> 174: 522101    Business
#> 175: 529999    Business

# determine completion status
DT <- timely_term(population)
DT <- completion_status(DT)

# summarize completion status
DT[, .N, by = "completion"][order(-N)]
#>    completion     N
#>        <char> <int>
#> 1:     timely   161
#> 2:       <NA>    71
#> 3:       late     8

# filter for timely graduates
DT <- DT[completion == "timely", .(mcid)]
DT
#>                mcid
#>              <char>
#>   1: MCID3111213539
#>   2: MCID3111213856
#>   3: MCID3111254225
#>  ---               
#> 159: MCID3112587501
#> 160: MCID3112592592
#> 161: MCID3112593368

# join degree CIP codes
degree_cip6 <- degree[, .(mcid, cip6)]
DT <- degree_cip6[DT, on = "mcid"]
DT
#>                mcid   cip6
#>              <char> <char>
#>   1: MCID3111213539 030103
#>   2: MCID3111213856 261399
#>   3: MCID3111254225 270101
#>  ---                      
#> 159: MCID3112587501 420101
#> 160: MCID3112592592 520201
#> 161: MCID3112593368 090101

# inner join to filter by our program selection
programs <- programs[, .(cip6, program)]
DT <- programs[DT, on = "cip6", nomatch = NULL]
DT <- DT[, .(mcid, program, cip6 = NULL)]
DT
#>               mcid     program
#>             <char>      <char>
#>  1: MCID3111254412 Engineering
#>  2: MCID3111262210 Engineering
#>  3: MCID3111265287  Psychology
#> ---                           
#> 53: MCID3112467463  Psychology
#> 54: MCID3112587501  Psychology
#> 55: MCID3112592592    Business

# join demographics
demographics <- student[, .(mcid, sex)]
DT <- demographics[DT, on = "mcid"]
DT
#>               mcid    sex     program
#>             <char> <char>      <char>
#>  1: MCID3111254412   Male Engineering
#>  2: MCID3111262210   Male Engineering
#>  3: MCID3111265287   Male  Psychology
#> ---                                  
#> 53: MCID3112467463 Female  Psychology
#> 54: MCID3112587501 Female  Psychology
#> 55: MCID3112592592   Male    Business

# group and summarize timely graduates
DT[, .(grad = .N), by = c("sex", "program")][order(sex, program)]
#>       sex     program  grad
#>    <char>      <char> <int>
#> 1: Female    Business     8
#> 2: Female Engineering     3
#> 3: Female  Psychology    12
#> 4:   Male    Business    12
#> 5:   Male Engineering    16
#> 6:   Male  Psychology     4
```

## Acknowledgments

The development of midfieldr and midfielddata was supported by the US
National Science Foundation through grant numbers 1545667 and 2142087.

## References

ASEE. (2023). *ATLAS: Academic Trajectory and Longitudinal Attainment
System*. American Society for Engineering Education.
<https://ira.asee.org/atlas-academic-trajectory-and-longitudinal-attainment-system/>

Ohland, M. W., & Long, R. A. (2016). The Multiple-Institution Database
for Investigating Engineering Longitudinal Development: An experiential
case study of data sharing and reuse. *Advances in Engineering
Education*, *5*(2), 398–404.
<http://advances.asee.org/wp-content/uploads/vol05/issue02/Papers/AEE-18-Ohland.pdf>
