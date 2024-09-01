
<!-- README.md is generated from README.Rmd. Please edit that file -->

<br>midfieldr is an R package that provides tools and methods for
studying undergraduate student-level records from the MIDFIELD database.

<img src="man/figures/logo.png" width="15%" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/midfieldr)](https://CRAN.R-project.org/package=midfieldr)  
[![R-CMD-check](https://github.com/MIDFIELDR/midfieldr/workflows/R-CMD-check/badge.svg)](https://github.com/MIDFIELDR/midfieldr/actions)  
[![codecov](https://codecov.io/gh/MIDFIELDR/midfieldr/branch/main/graph/badge.svg?token=KcuCzBkLBP)](https://app.codecov.io/gh/MIDFIELDR/midfieldr)  
[![status](https://tinyverse.netlify.app/badge/midfieldr)](https://CRAN.R-project.org/package=midfieldr)  
[![downloads](http://cranlogs.r-pkg.org/badges/grand-total/midfieldr?color=blue)](https://cran.r-project.org/package=midfieldr)  
<!-- badges: end -->

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

- `add_completion_status()` Determine completion status for every
  student
- `add_data_sufficiency()` Determine data sufficiency for every student
- `add_timely_term()` Calculate a timely completion term for every
  student
- `filter_cip()` Filter CIP data to match search strings
- `prep_fye_mice()` Prepare FYE data for multiple imputation
- `select_required()` Select required midfieldr variables

Additional functions for processing intermediate results:

- `order_multiway()` Order categorical variables of multiway data

R packages in examples and vignettes

- *Data preparation.*   We use the data.table system and some base R for
  data manipulation ([Dowle and Srinivasan
  2022](#ref-Dowle+Srinivasan:2022:data.table)). To assist users who
  might prefer other systems, the MIDFIELD Institute website ([Lord et
  al. 2024](#ref-midfieldinstitute:2024)) includes tutorials providing
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

<div id="eqofwcdnfm" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#eqofwcdnfm table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#eqofwcdnfm thead, #eqofwcdnfm tbody, #eqofwcdnfm tfoot, #eqofwcdnfm tr, #eqofwcdnfm td, #eqofwcdnfm th {
  border-style: none;
}
&#10;#eqofwcdnfm p {
  margin: 0;
  padding: 0;
}
&#10;#eqofwcdnfm .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: small;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #000000;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #000000;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#eqofwcdnfm .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#eqofwcdnfm .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#eqofwcdnfm .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#eqofwcdnfm .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#eqofwcdnfm .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #5F5F5F;
}
&#10;#eqofwcdnfm .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #5F5F5F;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #5F5F5F;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#eqofwcdnfm .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#eqofwcdnfm .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#eqofwcdnfm .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#eqofwcdnfm .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#eqofwcdnfm .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #5F5F5F;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#eqofwcdnfm .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#eqofwcdnfm .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #5F5F5F;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #5F5F5F;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#eqofwcdnfm .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #5F5F5F;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #5F5F5F;
  vertical-align: middle;
}
&#10;#eqofwcdnfm .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#eqofwcdnfm .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#eqofwcdnfm .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: none;
  border-top-width: 1px;
  border-top-color: #D5D5D5;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D5D5D5;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D5D5D5;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#eqofwcdnfm .gt_stub {
  color: #FFFFFF;
  background-color: #5F5F5F;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #5F5F5F;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#eqofwcdnfm .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#eqofwcdnfm .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#eqofwcdnfm .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#eqofwcdnfm .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#eqofwcdnfm .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #5F5F5F;
}
&#10;#eqofwcdnfm .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#eqofwcdnfm .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #5F5F5F;
}
&#10;#eqofwcdnfm .gt_grand_summary_row {
  color: #333333;
  background-color: #D5D5D5;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#eqofwcdnfm .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #5F5F5F;
}
&#10;#eqofwcdnfm .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #5F5F5F;
}
&#10;#eqofwcdnfm .gt_striped {
  background-color: #F4F4F4;
}
&#10;#eqofwcdnfm .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #5F5F5F;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #5F5F5F;
}
&#10;#eqofwcdnfm .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#eqofwcdnfm .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#eqofwcdnfm .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#eqofwcdnfm .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#eqofwcdnfm .gt_left {
  text-align: left;
}
&#10;#eqofwcdnfm .gt_center {
  text-align: center;
}
&#10;#eqofwcdnfm .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#eqofwcdnfm .gt_font_normal {
  font-weight: normal;
}
&#10;#eqofwcdnfm .gt_font_bold {
  font-weight: bold;
}
&#10;#eqofwcdnfm .gt_font_italic {
  font-style: italic;
}
&#10;#eqofwcdnfm .gt_super {
  font-size: 65%;
}
&#10;#eqofwcdnfm .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#eqofwcdnfm .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#eqofwcdnfm .gt_indent_1 {
  text-indent: 5px;
}
&#10;#eqofwcdnfm .gt_indent_2 {
  text-indent: 10px;
}
&#10;#eqofwcdnfm .gt_indent_3 {
  text-indent: 15px;
}
&#10;#eqofwcdnfm .gt_indent_4 {
  text-indent: 20px;
}
&#10;#eqofwcdnfm .gt_indent_5 {
  text-indent: 25px;
}
&#10;#eqofwcdnfm .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#eqofwcdnfm div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <caption>Table 1: Completion status of engineering undergraduates in the practice data</caption>
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="background-color: #C7EAE5;" scope="col" id="People">People</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="background-color: #C7EAE5;" scope="col" id="Timely completion">Timely completion</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="background-color: #C7EAE5;" scope="col" id="Late completion">Late completion</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="background-color: #C7EAE5;" scope="col" id="Did not complete">Did not complete</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="People" class="gt_row gt_left">Asian Female</td>
<td headers="Timely completion" class="gt_row gt_right">87</td>
<td headers="Late completion" class="gt_row gt_right">4</td>
<td headers="Did not complete" class="gt_row gt_right">43</td></tr>
    <tr><td headers="People" class="gt_row gt_left gt_striped">Asian Male</td>
<td headers="Timely completion" class="gt_row gt_right gt_striped">315</td>
<td headers="Late completion" class="gt_row gt_right gt_striped">19</td>
<td headers="Did not complete" class="gt_row gt_right gt_striped">163</td></tr>
    <tr><td headers="People" class="gt_row gt_left">Black Female</td>
<td headers="Timely completion" class="gt_row gt_right">26</td>
<td headers="Late completion" class="gt_row gt_right">3</td>
<td headers="Did not complete" class="gt_row gt_right">39</td></tr>
    <tr><td headers="People" class="gt_row gt_left gt_striped">Black Male</td>
<td headers="Timely completion" class="gt_row gt_right gt_striped">80</td>
<td headers="Late completion" class="gt_row gt_right gt_striped">5</td>
<td headers="Did not complete" class="gt_row gt_right gt_striped">84</td></tr>
    <tr><td headers="People" class="gt_row gt_left">International Female</td>
<td headers="Timely completion" class="gt_row gt_right">110</td>
<td headers="Late completion" class="gt_row gt_right">9</td>
<td headers="Did not complete" class="gt_row gt_right">51</td></tr>
    <tr><td headers="People" class="gt_row gt_left gt_striped">International Male</td>
<td headers="Timely completion" class="gt_row gt_right gt_striped">501</td>
<td headers="Late completion" class="gt_row gt_right gt_striped">41</td>
<td headers="Did not complete" class="gt_row gt_right gt_striped">280</td></tr>
    <tr><td headers="People" class="gt_row gt_left">Latine Female</td>
<td headers="Timely completion" class="gt_row gt_right">36</td>
<td headers="Late completion" class="gt_row gt_right">3</td>
<td headers="Did not complete" class="gt_row gt_right">31</td></tr>
    <tr><td headers="People" class="gt_row gt_left gt_striped">Latine Male</td>
<td headers="Timely completion" class="gt_row gt_right gt_striped">181</td>
<td headers="Late completion" class="gt_row gt_right gt_striped">19</td>
<td headers="Did not complete" class="gt_row gt_right gt_striped">102</td></tr>
    <tr><td headers="People" class="gt_row gt_left">Native American Female</td>
<td headers="Timely completion" class="gt_row gt_right">2</td>
<td headers="Late completion" class="gt_row gt_right">0</td>
<td headers="Did not complete" class="gt_row gt_right">2</td></tr>
    <tr><td headers="People" class="gt_row gt_left gt_striped">Native American Male</td>
<td headers="Timely completion" class="gt_row gt_right gt_striped">13</td>
<td headers="Late completion" class="gt_row gt_right gt_striped">3</td>
<td headers="Did not complete" class="gt_row gt_right gt_striped">6</td></tr>
    <tr><td headers="People" class="gt_row gt_left">White Female</td>
<td headers="Timely completion" class="gt_row gt_right">985</td>
<td headers="Late completion" class="gt_row gt_right">51</td>
<td headers="Did not complete" class="gt_row gt_right">386</td></tr>
    <tr><td headers="People" class="gt_row gt_left gt_striped">White Male</td>
<td headers="Timely completion" class="gt_row gt_right gt_striped">4100</td>
<td headers="Late completion" class="gt_row gt_right gt_striped">269</td>
<td headers="Did not complete" class="gt_row gt_right gt_striped">2034</td></tr>
  </tbody>
  &#10;  
</table>
</div>

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
institutions from 1987-2022. Access to this database requires a
confidentiality agreement and Institutional Review Board (IRB) approval
for human subjects research.

[midfielddata](https://midfieldr.github.io/midfielddata/).   An R data
package that supplies anonymized student-level records for 98,000
undergraduates at three US institutions from 1988-2018. A sample of the
MIDFIELD database, midfielddata provides practice data for the tools and
methods in the midfieldr package.

## Acknowledgments

This work was supported by the US National Science Foundation through
grant numbers 1545667 and 2142087.

## References

<div id="refs">
&#10;
&#10;

<style type="text/css">
blockquote {
    padding:     10px 20px;
    margin:      0 0 20px;
    border-left: 0px
}
caption {
    color:       #525252;
    text-align:  left;
    font-weight: normal;
    font-size:   medium;
    line-height: 1.5;
}
</style>

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-Dowle+Srinivasan:2022:data.table" class="csl-entry">

Dowle, Matt, and Arun Srinivasan. 2022.
*<span class="nocase">d</span>ata.table: Extension of ‘Data.frame‘*.
R package version 1.14.6.
<https://CRAN.R-project.org/package=data.table>.

</div>

<div id="ref-midfieldinstitute:2024" class="csl-entry">

Lord, Susan, Richard Layton, Russell Long, Matthew Ohland, and Marisa
Orr. 2024. *MIDFIELD Institute*.
<https://midfieldr.github.io/2024-midfield-institute/>.

</div>

<div id="ref-Sarkar:2008" class="csl-entry">

Sarkar, Deepayan. 2008. *<span class="nocase">lattice: Multivariate Data
Visualization with R</span>*. New York: Springer.
<http://lmdvr.r-forge.r-project.org>.

</div>

<div id="ref-Wickham:2016:ggplot2" class="csl-entry">

Wickham, Hadley. 2016. *<span class="nocase">ggplot2: Elegant Graphics
for Data Analysis</span>*. ISBN 978-3-319-24277-4; Springer-Verlag New
York. <https://ggplot2.tidyverse.org>.

</div>

</div>
