# Introduction to midfieldr


When working with student-level records to develop quantitative metrics,
you should:

- Know the structure of your data
- Define your metrics and the relevant blocs of students
- Develop data manipulation procedures to shape your information into
  useful form

The midfieldr package contributes to your data manipulation procedures,
helping you to:

- Normalize student-level records
- Identify program codes
- Assemble blocs of people (starters, graduates, ever-enrolled, etc.)
  for your metrics
- Prepare results for tables and charts

This document introduces you to midfieldr’s tools. If you are writing
your own script to follow along, we use the following packages.

``` r
library(midfieldr)
library(midfielddata)
library(data.table)
```

## Data: Student-level records

*Research data.*   MIDFIELD ([Ohland 2023](#ref-ohland:midfield:2023))
is a database of 2.4M students that has been managed since 2023 by the
American Society for Engineering Education (ASEE). Contact ASEE for
further information.

*Practice data.*   The midfielddata package provides a sample of the
MIDFIELD database organized in four tables (student, course, term,
degree) as shown in Table 1. midfielddata is used throughout these
articles to demonstrate how midfieldr is used. However, midfielddata
must not be used to draw inferences about program attributes or student
experiences. midfielddata is for *practice*, not *research*.

Data dictionaries are documented in `?student`, `?course`, `?term`, and
`?degree`.

<div id="asvehturvp" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#asvehturvp table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#asvehturvp thead, #asvehturvp tbody, #asvehturvp tfoot, #asvehturvp tr, #asvehturvp td, #asvehturvp th {
  border-style: none;
}
&#10;#asvehturvp p {
  margin: 0;
  padding: 0;
}
&#10;#asvehturvp .gt_table {
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
&#10;#asvehturvp .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#asvehturvp .gt_title {
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
&#10;#asvehturvp .gt_subtitle {
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
&#10;#asvehturvp .gt_heading {
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
&#10;#asvehturvp .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #5F5F5F;
}
&#10;#asvehturvp .gt_col_headings {
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
&#10;#asvehturvp .gt_col_heading {
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
&#10;#asvehturvp .gt_column_spanner_outer {
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
&#10;#asvehturvp .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#asvehturvp .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#asvehturvp .gt_column_spanner {
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
&#10;#asvehturvp .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#asvehturvp .gt_group_heading {
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
&#10;#asvehturvp .gt_empty_group_heading {
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
&#10;#asvehturvp .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#asvehturvp .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#asvehturvp .gt_row {
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
&#10;#asvehturvp .gt_stub {
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
&#10;#asvehturvp .gt_stub_row_group {
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
&#10;#asvehturvp .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#asvehturvp .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#asvehturvp .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#asvehturvp .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #5F5F5F;
}
&#10;#asvehturvp .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#asvehturvp .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #5F5F5F;
}
&#10;#asvehturvp .gt_grand_summary_row {
  color: #333333;
  background-color: #D5D5D5;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#asvehturvp .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #5F5F5F;
}
&#10;#asvehturvp .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #5F5F5F;
}
&#10;#asvehturvp .gt_striped {
  background-color: #F4F4F4;
}
&#10;#asvehturvp .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #5F5F5F;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #5F5F5F;
}
&#10;#asvehturvp .gt_footnotes {
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
&#10;#asvehturvp .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#asvehturvp .gt_sourcenotes {
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
&#10;#asvehturvp .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#asvehturvp .gt_left {
  text-align: left;
}
&#10;#asvehturvp .gt_center {
  text-align: center;
}
&#10;#asvehturvp .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#asvehturvp .gt_font_normal {
  font-weight: normal;
}
&#10;#asvehturvp .gt_font_bold {
  font-weight: bold;
}
&#10;#asvehturvp .gt_font_italic {
  font-style: italic;
}
&#10;#asvehturvp .gt_super {
  font-size: 65%;
}
&#10;#asvehturvp .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#asvehturvp .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#asvehturvp .gt_indent_1 {
  text-indent: 5px;
}
&#10;#asvehturvp .gt_indent_2 {
  text-indent: 10px;
}
&#10;#asvehturvp .gt_indent_3 {
  text-indent: 15px;
}
&#10;#asvehturvp .gt_indent_4 {
  text-indent: 20px;
}
&#10;#asvehturvp .gt_indent_5 {
  text-indent: 25px;
}
&#10;#asvehturvp .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#asvehturvp div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <caption>Table 1. Student-level records in midfielddata</caption>
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="background-color: #C7EAE5;" scope="col" id="Table">Table</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="background-color: #C7EAE5;" scope="col" id="Each-row-is">Each row is</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="background-color: #C7EAE5;" scope="col" id="N-students">N students</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="background-color: #C7EAE5;" scope="col" id="N-rows">N rows</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="background-color: #C7EAE5;" scope="col" id="N-columns">N columns</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="background-color: #C7EAE5;" scope="col" id="Mb-memory">Mb memory</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Table" class="gt_row gt_left">student</td>
<td headers="Each row is" class="gt_row gt_left">one student</td>
<td headers="N students" class="gt_row gt_right">97,555</td>
<td headers="N rows" class="gt_row gt_right">97,555</td>
<td headers="N columns" class="gt_row gt_right">13</td>
<td headers="Mb memory" class="gt_row gt_right">17.3</td></tr>
    <tr><td headers="Table" class="gt_row gt_left gt_striped">course</td>
<td headers="Each row is" class="gt_row gt_left gt_striped">one student per course per term</td>
<td headers="N students" class="gt_row gt_right gt_striped">97,555</td>
<td headers="N rows" class="gt_row gt_right gt_striped">3,289,532</td>
<td headers="N columns" class="gt_row gt_right gt_striped">12</td>
<td headers="Mb memory" class="gt_row gt_right gt_striped">324.3</td></tr>
    <tr><td headers="Table" class="gt_row gt_left">term</td>
<td headers="Each row is" class="gt_row gt_left">one student per term</td>
<td headers="N students" class="gt_row gt_right">97,555</td>
<td headers="N rows" class="gt_row gt_right">639,915</td>
<td headers="N columns" class="gt_row gt_right">13</td>
<td headers="Mb memory" class="gt_row gt_right">72.8</td></tr>
    <tr><td headers="Table" class="gt_row gt_left gt_striped">degree</td>
<td headers="Each row is" class="gt_row gt_left gt_striped">one student per degree</td>
<td headers="N students" class="gt_row gt_right gt_striped">49,543</td>
<td headers="N rows" class="gt_row gt_right gt_striped">49,665</td>
<td headers="N columns" class="gt_row gt_right gt_striped">5</td>
<td headers="Mb memory" class="gt_row gt_right gt_striped">5.2</td></tr>
  </tbody>
  &#10;</table>
</div>

*Resources.*   If you are new to these data, the best place to start is
the midfielddata website:

- [MIDFIELD data
  structure.](https://midfieldr.github.io/midfielddata/articles/data-structure.html)
  We examine the structure of the four data tables in midfielddata:
  number of observations, number and class of variables, representative
  values, and database keys.

- [Data linked by student
  ID.](https://midfieldr.github.io/midfielddata/articles/individual-students.html)
  To examine the variables and some representative values in
  midfielddata, we take a closer look at the records of individual
  students across the four data tables.

*Load data.*   Data tables from midfielddata can be loaded individually
or collectively as needed.

``` r
data(student)
data(course, term, degree)
```

Example of one of the data tables.

``` r
student
#>                  mcid   institution              transfer hours_transfer
#>                <char>        <char>                <char>          <num>
#>     1: MCID3111142225 Institution B   First-Time Transfer             NA
#>     2: MCID3111142283 Institution J   First-Time Transfer             NA
#>     3: MCID3111142290 Institution J   First-Time Transfer             NA
#>    ---                                                                  
#> 97553: MCID3112898894 Institution B First-Time in College             NA
#> 97554: MCID3112898895 Institution B First-Time in College             NA
#> 97555: MCID3112898940 Institution B First-Time in College             NA
#>                 race    sex age_desc us_citizen home_zip high_school sat_math
#>               <char> <char>   <char>     <char>   <char>      <char>    <num>
#>     1:         Asian   Male Under 25        Yes     <NA>        <NA>       NA
#>     2:         Asian Female Under 25        Yes    22020        <NA>      560
#>     3:         Asian   Male Under 25        Yes    23233      471872      510
#>    ---                                                                       
#> 97553:         White Female Under 25        Yes    53716      501160      510
#> 97554:         White Female Under 25        Yes    53029      500853      420
#> 97555: Other/Unknown   Male Under 25        Yes    20016      090073      470
#>        sat_verbal act_comp
#>             <num>    <num>
#>     1:         NA       NA
#>     2:        230       NA
#>     3:        380       NA
#>    ---                    
#> 97553:        590       24
#> 97554:        590       32
#> 97555:        540       32
```

*midfieldr uses data.table.*   Data frames in midfieldr and midfielddata
have the attributes of the “data.table” class, designed for fast
manipulation of large data sets.

``` r
class(student)
#> [1] "data.table" "data.frame"
```

Users can transform midfieldr data frames to tidyverse-style tibbles if
they prefer. One of the distinguishing attributes of tibbles (and
data.tables as well) is their particular format for displaying data
frames.

``` r
library(tibble)
student_tbl <- as_tibble(student)
class(student_tbl)
#> [1] "tbl_df"     "tbl"        "data.frame"

student_tbl
#> # A tibble: 97,555 × 13
#>    mcid      institution transfer hours_transfer race  sex   age_desc us_citizen
#>    <chr>     <chr>       <chr>             <dbl> <chr> <chr> <chr>    <chr>     
#>  1 MCID3111… Institutio… First-T…             NA Asian Male  Under 25 Yes       
#>  2 MCID3111… Institutio… First-T…             NA Asian Fema… Under 25 Yes       
#>  3 MCID3111… Institutio… First-T…             NA Asian Male  Under 25 Yes       
#>  4 MCID3111… Institutio… First-T…             NA Asian Male  Under 25 Yes       
#>  5 MCID3111… Institutio… First-T…             NA Asian Male  Under 25 Yes       
#>  6 MCID3111… Institutio… First-T…             NA Asian Male  Under 25 Yes       
#>  7 MCID3111… Institutio… First-T…             NA Black Male  Under 25 Yes       
#>  8 MCID3111… Institutio… First-T…             NA Hisp… Fema… Under 25 Yes       
#>  9 MCID3111… Institutio… First-T…             NA Hisp… Male  25 and … Yes       
#> 10 MCID3111… Institutio… First-T…             NA Hisp… Male  Under 25 Yes       
#> # ℹ 97,545 more rows
#> # ℹ 5 more variables: home_zip <chr>, high_school <chr>, sat_math <dbl>,
#> #   sat_verbal <dbl>, act_comp <dbl>
```

## Data: CIP codes

*Classification of Instructional Programs (CIP)* is a taxonomy of
academic programs, encoded by 6-digit numeric codes curated by the US
Department of Education ([NCES 2010](#ref-NCES:2010)).

The `cip` data set, loaded with midfieldr, is a subset of the NCES
CIP2010 data that contains codes and names for 1582 instructional
programs organized on three levels—a 2-digit series, a 4-digit series,
and a 6-digit series—keyed by the `cip6` variable and documented in
`?cip`.

``` r
cip
#>         cip2                                                  cip2name   cip4
#>       <char>                                                    <char> <char>
#>    1:     01 Agriculture, Agricultural Operations and Related Sciences   0100
#>    2:     01 Agriculture, Agricultural Operations and Related Sciences   0101
#>    3:     01 Agriculture, Agricultural Operations and Related Sciences   0101
#>   ---                                                                        
#> 1580:     54                                                   History   5401
#> 1581:     54                                                   History   5401
#> 1582:     99                         NonIPEDS - Undecided, Unspecified   9999
#>                                   cip4name   cip6
#>                                     <char> <char>
#>    1:                 Agriculture, General 010000
#>    2: Agricultural Business and Management 010101
#>    3: Agricultural Business and Management 010102
#>   ---                                            
#> 1580:                              History 540108
#> 1581:                              History 540199
#> 1582:    NonIPEDS - Undecided, Unspecified 999999
#>                                             cip6name
#>                                               <char>
#>    1:                           Agriculture, General
#>    2:  Agricultural Business and Management, General
#>    3: Agribusiness, Agricultural Business Operations
#>   ---                                               
#> 1580:                               Military History
#> 1581:                                 History, Other
#> 1582:              NonIPEDS - Undecided, Unspecified
```

## midfieldr functions

midfieldr helps you extract the information you need from student-level
records and refine it such that you can compute a metric, e.g.,
graduation rate or stickiness. midfieldr does not provide functions for
specific metrics—its tools are designed to help you prepare the data in
such a way that you can compute your metric credibly.

We can organize midfieldr functions into four areas of a typical
workflow that we designate broadly as records, programs, people, and
displays. Function documentation is provided, as usual, by
`?<function_name>`, for example, `?select_required`.

Records  
- `select_required()`  
- `term_wrt_degree()`

Programs  
- `filter_cip()`

People  
- `add_timely_term()`  
- `add_data_sufficiency()`  
- `prep_fye_mice()`  
- `add_completion_status()`

Displays  
- `order_multiway()`

<br>

## `select_required()`

*Subset columns of source data, retain a minimum required set.*

`select_required()` is typically applied to source data tables
(`student`, `course`, `term` `degree`) with the original columns, such
as that loaded from midfielddata. It reduces the number of columns to
the minimum required by other midfieldr functions and retains the key or
composite key columns. Rows are unaffected. Records are significantly
more compact as a result.

For example, while the `term` data table has 13 columns, the data frame
returned by `select_required()` has 5. In this example, the composite
key is `mcid` and `term`. The other columns are required by at least one
other midfieldr function.

``` r
select_required(term)
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

You can specify any additional columns and use regular expressions if
desired,

``` r
select_required(term, select_add = c("^gpa"))
#>                   mcid   institution   term   cip6         level gpa_term
#>                 <char>        <char> <char> <char>        <char>    <num>
#>      1: MCID3111142225 Institution B  19881 140901 01 First-year     2.56
#>      2: MCID3111142283 Institution J  19881 240102 01 First-year     1.85
#>      3: MCID3111142283 Institution J  19883 240102 01 First-year     1.93
#>     ---                                                                  
#> 639913: MCID3112898894 Institution B  20181 451001 01 First-year     3.52
#> 639914: MCID3112898895 Institution B  20181 302001 01 First-year     3.50
#> 639915: MCID3112898940 Institution B  20181 050103 01 First-year     2.18
#>         gpa_cumul
#>             <num>
#>      1:      2.56
#>      2:      1.85
#>      3:      1.90
#>     ---          
#> 639913:      3.52
#> 639914:      3.50
#> 639915:      2.18
```

## `term_wrt_degree()`

*Subset rows, retain academic terms through the first baccalaureate.*

We are often interested in students’ records only as they work towards
their first degree and can safely filter out any subsequent academic
terms. `term_wrt_degree()` labels those terms for us.

`term_wrt_degree()` obtains the term of a student’s first degree (if
any), adds it as a new column to the working data frame, then adds a
second column to label every term *with respect to (wrt)* that first
degree term. The set of possible labels is `pre-first-degree`,
`first-degree`, and `post-first-degree`.

``` r
DT <- term[, .(mcid, term)]
DT <- term_wrt_degree(DT, degree)
DT
#>                   mcid   term first_degree_term  term_wrt_degree
#>                 <char> <char>            <char>           <char>
#>      1: MCID3111142225  19881             19881     first-degree
#>      2: MCID3111142283  19881              <NA> pre-first-degree
#>      3: MCID3111142283  19883              <NA> pre-first-degree
#>      4: MCID3111142283  19885              <NA> pre-first-degree
#>      5: MCID3111142283  19891              <NA> pre-first-degree
#>     ---                                                         
#> 639911: MCID3112898886  20181              <NA> pre-first-degree
#> 639912: MCID3112898890  20181              <NA> pre-first-degree
#> 639913: MCID3112898894  20181              <NA> pre-first-degree
#> 639914: MCID3112898895  20181              <NA> pre-first-degree
#> 639915: MCID3112898940  20181              <NA> pre-first-degree
```

We can then drop rows with terms later than the first degree term. Once
that’s done, we often drop the columns added by the function.

``` r
DT <- DT[!term_wrt_degree %chin% "post-first-degree"]
DT
#>                   mcid   term first_degree_term  term_wrt_degree
#>                 <char> <char>            <char>           <char>
#>      1: MCID3111142225  19881             19881     first-degree
#>      2: MCID3111142283  19881              <NA> pre-first-degree
#>      3: MCID3111142283  19883              <NA> pre-first-degree
#>      4: MCID3111142283  19885              <NA> pre-first-degree
#>      5: MCID3111142283  19891              <NA> pre-first-degree
#>     ---                                                         
#> 632913: MCID3112898886  20181              <NA> pre-first-degree
#> 632914: MCID3112898890  20181              <NA> pre-first-degree
#> 632915: MCID3112898894  20181              <NA> pre-first-degree
#> 632916: MCID3112898895  20181              <NA> pre-first-degree
#> 632917: MCID3112898940  20181              <NA> pre-first-degree

first_bacc_terms <- DT[, .(mcid, term)]
first_bacc_terms
#>                   mcid   term
#>                 <char> <char>
#>      1: MCID3111142225  19881
#>      2: MCID3111142283  19881
#>      3: MCID3111142283  19883
#>      4: MCID3111142283  19885
#>      5: MCID3111142283  19891
#>     ---                      
#> 632913: MCID3112898886  20181
#> 632914: MCID3112898890  20181
#> 632915: MCID3112898894  20181
#> 632916: MCID3112898895  20181
#> 632917: MCID3112898940  20181
```

The number of rows has dropped from 639,915 to 632,917 (a drop of about
7000 rows). This procedure would be repeated for the other data tables
having term variables: `course` (if used) and `degree`.

## Refining the records

To conclude the initial “records” stage of our workflow, we subset our
source data tables such that they contain only the terms obtained above,
grouped by ID. First we copy the source data frame to a new object name
in case we need the full, original source data for any reason.

``` r
source_term <- copy(term)
dim(source_term)
#> [1] 639915     13
```

Use an inner join to retain all rows of the records with IDs and terms
that match those in our `first_bacc_terms` data frame.

``` r
term <- select_required(term)
term <- first_bacc_terms[term, on = c("mcid", "term"), nomatch = NULL]
dim(term)
#> [1] 632917      5
```

Repeat for the `degree` data, but first edit the name of the term
variable in `first_bacc_terms` to let the ineer join work.

``` r
source_degree <- copy(degree)

degree <- copy(source_degree)
degree <- select_required(degree)
degree
#>                  mcid   institution term_degree   cip6
#>                <char>        <char>      <char> <char>
#>     1: MCID3111142225 Institution B       19881 141001
#>     2: MCID3111142290 Institution J       19921 141001
#>     3: MCID3111142294 Institution J       19903 141001
#>     4: MCID3111142299 Institution J       19921 141001
#>     5: MCID3111142689 Institution B       19913 090401
#>    ---                                                
#> 49661: MCID3112829602 Institution B       20173 451001
#> 49662: MCID3112831015 Institution B       20181 450701
#> 49663: MCID3112839623 Institution B       20181 160102
#> 49664: MCID3112845220 Institution B       20181 270101
#> 49665: MCID3112845673 Institution B       20174 090101

first_bacc_terms <- first_bacc_terms[, .(mcid, term_degree = term)]
first_bacc_terms
#>                   mcid term_degree
#>                 <char>      <char>
#>      1: MCID3111142225       19881
#>      2: MCID3111142283       19881
#>      3: MCID3111142283       19883
#>      4: MCID3111142283       19885
#>      5: MCID3111142283       19891
#>     ---                           
#> 632913: MCID3112898886       20181
#> 632914: MCID3112898890       20181
#> 632915: MCID3112898894       20181
#> 632916: MCID3112898895       20181
#> 632917: MCID3112898940       20181

degree <- first_bacc_terms[degree, on = c("mcid", "term_degree"), nomatch = NULL]
dim(degree)
#> [1] 34484     4
# [1] 34484     4
```

``` r
# source_degree <- copy(degree)
degree <- copy(source_degree)
degree <- select_required(degree)
degree
#>                  mcid   institution term_degree   cip6
#>                <char>        <char>      <char> <char>
#>     1: MCID3111142225 Institution B       19881 141001
#>     2: MCID3111142290 Institution J       19921 141001
#>     3: MCID3111142294 Institution J       19903 141001
#>     4: MCID3111142299 Institution J       19921 141001
#>     5: MCID3111142689 Institution B       19913 090401
#>    ---                                                
#> 49661: MCID3112829602 Institution B       20173 451001
#> 49662: MCID3112831015 Institution B       20181 450701
#> 49663: MCID3112839623 Institution B       20181 160102
#> 49664: MCID3112845220 Institution B       20181 270101
#> 49665: MCID3112845673 Institution B       20174 090101

DT <- degree[, .(mcid, term_degree)]
DT <- term_wrt_degree(DT, degree)
DT
#>                  mcid term_degree first_degree_term term_wrt_degree
#>                <char>      <char>            <char>          <char>
#>     1: MCID3111142225       19881             19881    first-degree
#>     2: MCID3111142290       19921             19921    first-degree
#>     3: MCID3111142294       19903             19903    first-degree
#>     4: MCID3111142299       19921             19921    first-degree
#>     5: MCID3111142689       19913             19913    first-degree
#>    ---                                                             
#> 49661: MCID3112829602       20173             20173    first-degree
#> 49662: MCID3112831015       20181             20181    first-degree
#> 49663: MCID3112839623       20181             20181    first-degree
#> 49664: MCID3112845220       20181             20181    first-degree
#> 49665: MCID3112845673       20174             20174    first-degree

DT <- DT[!term_wrt_degree %chin% "post-first-degree"]
DT
#>                  mcid term_degree first_degree_term term_wrt_degree
#>                <char>      <char>            <char>          <char>
#>     1: MCID3111142225       19881             19881    first-degree
#>     2: MCID3111142290       19921             19921    first-degree
#>     3: MCID3111142294       19903             19903    first-degree
#>     4: MCID3111142299       19921             19921    first-degree
#>     5: MCID3111142689       19913             19913    first-degree
#>    ---                                                             
#> 49614: MCID3112829602       20173             20173    first-degree
#> 49615: MCID3112831015       20181             20181    first-degree
#> 49616: MCID3112839623       20181             20181    first-degree
#> 49617: MCID3112845220       20181             20181    first-degree
#> 49618: MCID3112845673       20174             20174    first-degree

first_bacc_terms <- DT[, .(mcid, term_degree)]
first_bacc_terms
#>                  mcid term_degree
#>                <char>      <char>
#>     1: MCID3111142225       19881
#>     2: MCID3111142290       19921
#>     3: MCID3111142294       19903
#>     4: MCID3111142299       19921
#>     5: MCID3111142689       19913
#>    ---                           
#> 49614: MCID3112829602       20173
#> 49615: MCID3112831015       20181
#> 49616: MCID3112839623       20181
#> 49617: MCID3112845220       20181
#> 49618: MCID3112845673       20174

degree <- first_bacc_terms[degree, on = c("mcid", "term_degree"), nomatch = NULL]
dim(degree)
#> [1] 49768     4
# [1] 50668     4
```

## `filter_cip()`

*To identify program codes.*

`filter_cip()` acts on the `cip` data frame or equivalent to select rows
that match or partially match search strings. Search strings are
case-independent and can include regular expressions.

``` r
filter_cip("sociology")
#>      cip2        cip2name   cip4                   cip4name   cip6
#>    <char>          <char> <char>                     <char> <char>
#> 1:     45 Social Sciences   4511                  Sociology 451101
#> 2:     45 Social Sciences   4513 Sociology and Anthropology 451301
#> 3:     45 Social Sciences   4514            Rural Sociology 451401
#>                      cip6name
#>                        <char>
#> 1:                  Sociology
#> 2: Sociology and Anthropology
#> 3:            Rural Sociology

filter_cip("music")
#>       cip2                                         cip2name   cip4
#>     <char>                                           <char> <char>
#>  1:     13                                        Education   1313
#>  2:     36              Leisure and Recreational Activities   3601
#>  3:     39      Theological Studies and Religious Vocations   3905
#>  4:     47                   Mechanic and Repair Technology   4704
#>  5:     50                       Visual and Performing Arts   5001
#> ---                                                               
#> 21:     50                       Visual and Performing Arts   5009
#> 22:     50                       Visual and Performing Arts   5009
#> 23:     50                       Visual and Performing Arts   5009
#> 24:     50                       Visual and Performing Arts   5010
#> 25:     51 Health Professions and Related Clinical Sciences   5123
#>                                                                   cip4name
#>                                                                     <char>
#>  1: Teacher Education and Professional Development, Specific Subject Areas
#>  2:                                    Leisure and Recreational Activities
#>  3:                                                Religious, Sacred Music
#>  4:                  Precision Systems Maintenance and Repair Technologies
#>  5:                                          General Art and Music Studies
#> ---                                                                       
#> 21:                                                                  Music
#> 22:                                                                  Music
#> 23:                                                                  Music
#> 24:                               Arts, Entertainment and Media Management
#> 25:                             Rehabilitation and Therapeutic Professions
#>       cip6                                  cip6name
#>     <char>                                    <char>
#>  1: 131312                   Music Teacher Education
#>  2: 360115                                     Music
#>  3: 390501                   Religious, Sacred Music
#>  4: 470404 Musical Instrument Fabrication and Repair
#>  5: 500102                              Digital Arts
#> ---                                                 
#> 21: 500915                      Woodwind Instruments
#> 22: 500916                    Percussion Instruments
#> 23: 500999                              Music, Other
#> 24: 501003                          Music Management
#> 25: 512305                  Music Therapy, Therapist
```

To refine the results of a first pass, assign those results to the `cip`
argument in a second pass. The `select` argument allows to to select
specific columns, dropping all others.

``` r
first_pass <- filter_cip("music")
second_pass <- filter_cip("^50", cip = first_pass, select = c("cip6", "cip6name"))
second_pass
#>       cip6                                             cip6name
#>     <char>                                               <char>
#>  1: 500102                                         Digital Arts
#>  2: 500509                                      Musical Theatre
#>  3: 500901                                       Music, General
#>  4: 500902                 Music History, Literature and Theory
#>  5: 500903                           Music Performance, General
#>  6: 500904                         Music Theory and Composition
#>  7: 500905                       Musicology and Ethnomusicology
#>  8: 500906                                           Conducting
#>  9: 500907                                      Piano and Organ
#> 10: 500908                                      Voice and Opera
#> 11: 500909                   Music Management and Merchandising
#> 12: 500910                                   Jazz, Jazz Studies
#> 13: 500911 Violin, Viola, Guitar and Other Stringed Instruments
#> 14: 500912                                       Music Pedagogy
#> 15: 500913                                     Music Technology
#> 16: 500914                                    Brass Instruments
#> 17: 500915                                 Woodwind Instruments
#> 18: 500916                               Percussion Instruments
#> 19: 500999                                         Music, Other
#> 20: 501003                                     Music Management
#>       cip6                                             cip6name
#>     <char>                                               <char>
```

## `add_timely_term()`

*Helps refine the population.*

`add_timely_term()` estimates for every student the latest term by which
their program completion would be considered timely. It helps you refine
your population by identifying:

- students for whom data sufficiency is not satisfied. See
  `add_data_sufficiency()`.
- graduates whose completion is not timely. See
  `add_timely_completion()`.

`add_timely_term()` adds four columns: `term_i` and `level_i` are a
student’s initial term and level (first-year, second-year, etc.);
`adj_span` denotes the time span for timely completion (default 6 years)
adjusted to account for their level when admitted; and their
`timely_term`.

``` r
DT <- term[, .(mcid)]
DT <- unique(DT)
DT <- add_timely_term(DT, term)
DT 
#>                  mcid term_i       level_i adj_span timely_term
#>                <char> <char>        <char>    <num>      <char>
#>     1: MCID3111142225  19881 01 First-year        6       19933
#>     2: MCID3111142283  19881 01 First-year        6       19933
#>     3: MCID3111142290  19881 01 First-year        6       19933
#>     4: MCID3111142294  19881 01 First-year        6       19933
#>     5: MCID3111142299  19881 01 First-year        6       19933
#>    ---                                                         
#> 97532: MCID3112898886  20181 01 First-year        6       20233
#> 97533: MCID3112898890  20181 01 First-year        6       20233
#> 97534: MCID3112898894  20181 01 First-year        6       20233
#> 97535: MCID3112898895  20181 01 First-year        6       20233
#> 97536: MCID3112898940  20181 01 First-year        6       20233
```

We can drop all but the ID and timely term for the next step.

``` r
DT <- DT[, .(mcid, timely_term)]
DT
#>                  mcid timely_term
#>                <char>      <char>
#>     1: MCID3111142225       19933
#>     2: MCID3111142283       19933
#>     3: MCID3111142290       19933
#>     4: MCID3111142294       19933
#>     5: MCID3111142299       19933
#>    ---                           
#> 97532: MCID3112898886       20233
#> 97533: MCID3112898890       20233
#> 97534: MCID3112898894       20233
#> 97535: MCID3112898895       20233
#> 97536: MCID3112898940       20233
```

## `add_data_sufficiency()`

*Helps refine your population.*

Some student records at the upper and lower limits of an institution’s
data range must be excluded to prevent false counts due to insufficient
data.

`add_data_sufficiency()` adds four columns: initial term`term_i` again;
`lower_limit` and `upper_limit` defining the range of the institution’s
data; and `data_sufficiency`, identifying those IDs that can be included
and those that can be excluded and why.

We run the example starting with the data frame from the previous
example.

``` r
DT <- add_data_sufficiency(DT, term)
DT
#>                  mcid timely_term term_i lower_limit upper_limit
#>                <char>      <char> <char>      <char>      <char>
#>     1: MCID3111142225       19933  19881       19881       20181
#>     2: MCID3111142283       19933  19881       19881       20096
#>     3: MCID3111142290       19933  19881       19881       20096
#>     4: MCID3111142294       19933  19881       19881       20096
#>     5: MCID3111142299       19933  19881       19881       20096
#>    ---                                                          
#> 97532: MCID3112898886       20233  20181       19881       20181
#> 97533: MCID3112898890       20233  20181       19881       20181
#> 97534: MCID3112898894       20233  20181       19881       20181
#> 97535: MCID3112898895       20233  20181       19881       20181
#> 97536: MCID3112898940       20233  20181       19881       20181
#>        data_sufficiency
#>                  <char>
#>     1:    exclude-lower
#>     2:    exclude-lower
#>     3:    exclude-lower
#>     4:    exclude-lower
#>     5:    exclude-lower
#>    ---                 
#> 97532:    exclude-upper
#> 97533:    exclude-upper
#> 97534:    exclude-upper
#> 97535:    exclude-upper
#> 97536:    exclude-upper
```

Subset rows to retain records with sufficient data, and drop columns no
longer required.

``` r
DT[data_sufficiency %chin% "include", .(mcid)]
#>                  mcid
#>                <char>
#>     1: MCID3111142689
#>     2: MCID3111142782
#>     3: MCID3111142881
#>     4: MCID3111142884
#>     5: MCID3111142893
#>    ---               
#> 76861: MCID3112727985
#> 76862: MCID3112730841
#> 76863: MCID3112785480
#> 76864: MCID3112800920
#> 76865: MCID3112870009
```

When working on refining the population, it is useful to reduce the
ongoing results to a single column of student IDs as a reminder that
this particular data frame is addressing the “people” stage of our
workflow.

## `prep_fye_mice()`

*Helps construct starter blocs.*

<br>

<br>

## `add_completion_status()`

*Helps construct graduate blocs.*

<br>

<br>

## `order_multiway()`

*Helps prepare tables and charts.*

<br>

<br>

<br>

<br>

<br>

<br>

<br>

<br>

------------------------------------------------------------------------

[◁ midfieldr](../index.html)   <a href="#top">▲ top of page</a>  [Case
study goals ▷](art-001-case-goals.html)

------------------------------------------------------------------------

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-Layton+Long+Ohland:2026:midfielddata" class="csl-entry">

Layton, Richard, Russell Long, Susan Lord, Matthew Ohland, and Marisa
Orr. 2026a. *<span class="nocase">midfielddata: MIDFIELD Data
Sample</span>*. R package version 0.2.3.
<https://midfieldr.github.io/midfielddata/>.

</div>

<div id="ref-Layton+Long+Ohland:2026:midfieldr" class="csl-entry">

Layton, Richard, Russell Long, Susan Lord, Matthew Ohland, and Marisa
Orr. 2026b. *<span class="nocase">midfieldr: Tools and Methods for
Working with MIDFIELD Data in R</span>*. R package version 1.0.3.
<https://github.com/MIDFIELDR/midfieldr>.

</div>

<div id="ref-NCES:2010" class="csl-entry">

NCES. 2010. *<span class="nocase">IPEDS Classification of Instructional
Programs (CIP)</span>*. National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>.

</div>

<div id="ref-ohland:midfield:2023" class="csl-entry">

Ohland, Matthew. 2023. *MIDFIELD, 2004–2023*.
<https://midfield.online/>.

</div>

</div>
