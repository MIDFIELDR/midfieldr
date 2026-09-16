# Introduction to midfieldr


In this document, we introduce midfieldr’s basic tools and show how to
apply them to data frames of student-level records (registrar’s data).
We organize the topics around a typical workflow:

- data
- population
- records
- blocs
- special conditioning

*Packages.* We load midfielddata for its practice data and data.table
for its data manipulation syntax.

``` r
library("midfieldr")
library("midfielddata")
library("data.table")
```

## Data

### *Student records*

midfieldr is designed to work with the MIDFIELD research database or any
database with a similar structure such as the practice data in the
[midfielddata](https://midfieldr.github.io/midfielddata/index.html)
package. If you are new to MIDFIELD, the best place to start is the
article on [Data
structure](https://midfieldr.github.io/midfielddata/articles/data-structure.html).

For this article we load all four midfielddata tables.

``` r
data(student, term, course, degree)
```

`select_basic_cols()` returns a subset of each table with the variables
most often encountered in the early stages of a project. The tables are
linked by the anonymized student ID variable `mcid.`

``` r
select_basic_cols(student)
#>                  mcid          race    sex
#>                <char>        <char> <char>
#>     1: MCID3111142225         Asian   Male
#>     2: MCID3111142283         Asian Female
#>     3: MCID3111142290         Asian   Male
#>    ---                                    
#> 97553: MCID3112898894         White Female
#> 97554: MCID3112898895         White Female
#> 97555: MCID3112898940 Other/Unknown   Male

select_basic_cols(term)
#>                   mcid   term   cip6   institution         level
#>                 <char> <char> <char>        <char>        <char>
#>      1: MCID3111142225  19881 140901 Institution B 01 First-year
#>      2: MCID3111142283  19881 240102 Institution J 01 First-year
#>      3: MCID3111142283  19883 240102 Institution J 01 First-year
#>     ---                                                         
#> 639913: MCID3112898894  20181 451001 Institution B 01 First-year
#> 639914: MCID3112898895  20181 302001 Institution B 01 First-year
#> 639915: MCID3112898940  20181 050103 Institution B 01 First-year

select_basic_cols(course)
#>                    mcid term_course abbrev number
#>                  <char>      <char> <char> <char>
#>       1: MCID3111142225       19881   ECEN   2230
#>       2: MCID3111142225       19881   ECEN   4811
#>       3: MCID3111142225       19881   MCEN   4147
#>      ---                                         
#> 3289530: MCID3112898940       20181   JPNS   1010
#> 3289531: MCID3112898940       20181   MATH   1150
#> 3289532: MCID3112898940       20181   SOCY   1004

select_basic_cols(degree)
#>                  mcid term_degree   cip6
#>                <char>      <char> <char>
#>     1: MCID3111142225       19881 141001
#>     2: MCID3111142290       19921 141001
#>     3: MCID3111142294       19903 141001
#>    ---                                  
#> 49663: MCID3112839623       20181 160102
#> 49664: MCID3112845220       20181 270101
#> 49665: MCID3112845673       20174 090101
```

*Notes.*

1.  Like the data frames above, all data frames in midfieldr are
    `data.table` enhanced. However, if you convert these tables to
    another class such as `tbl_df` (tibbles) or `data.frame` (base R),
    midfieldr functions attempt to return data frames of the same class
    to support your preferred syntax.

2.  Term variables `{term, term_course, term_degree}` are encoded as
    character strings `YYYYT`, where `YYYY` is the year at the start of
    the academic year and `T` encodes the semester or quarter within an
    academic year as Fall (1), Winter (2), Spring (3), or Summer (4, 5,
    and 6).

3.  The `cip6` columns contain 6-digit CIP program codes.

### *CIP data*

The US Classification of Instructional Programs (CIP) is a taxonomy of
fields of study ([NCES 2010](#ref-NCES:2010)). The dataset `cip` that
loads with midfieldr contains program names and codes at the 2-digit,
4-digit, and 6-digit level.

``` r
cip
#>                                             cip6name   cip6
#>                                               <char> <char>
#>    1:                           Agriculture, General 010000
#>    2:  Agricultural Business and Management, General 010101
#>    3: Agribusiness, Agricultural Business Operations 010102
#>   ---                                                      
#> 1580:                               Military History 540108
#> 1581:                                 History, Other 540199
#> 1582:              NonIPEDS - Undecided, Unspecified 999999
#>                                   cip4name   cip4
#>                                     <char> <char>
#>    1:                 Agriculture, General   0100
#>    2: Agricultural Business and Management   0101
#>    3: Agricultural Business and Management   0101
#>   ---                                            
#> 1580:                              History   5401
#> 1581:                              History   5401
#> 1582:    NonIPEDS - Undecided, Unspecified   9999
#>                                                        cip2name   cip2
#>                                                          <char> <char>
#>    1: Agriculture, Agricultural Operations and Related Sciences     01
#>    2: Agriculture, Agricultural Operations and Related Sciences     01
#>    3: Agriculture, Agricultural Operations and Related Sciences     01
#>   ---                                                                 
#> 1580:                                                   History     54
#> 1581:                                                   History     54
#> 1582:                         NonIPEDS - Undecided, Unspecified     99
```

## Population

Relevant functions:

- `timely_term()`
- `data_sufficiency()`

### timely_term()

The *timely-completion term* is the latest term by which a student’s
program completion would be considered timely (default 6 academic years
after admission). *Program completion* means satisfying the requirements
for a degree.

`timely_term()` determines the timely completion term for each student.
The principal data frame must include the variable `{mcid}.` Entry term
and level are pulled from the `term` table. The data frame is returned
with the following variables added:

<div id="mewssnnzbl" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:80%;">
<style>#mewssnnzbl table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#mewssnnzbl thead, #mewssnnzbl tbody, #mewssnnzbl tfoot, #mewssnnzbl tr, #mewssnnzbl td, #mewssnnzbl th {
  border-style: none;
}
&#10;#mewssnnzbl p {
  margin: 0;
  padding: 0;
}
&#10;#mewssnnzbl .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 80%;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#mewssnnzbl .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#mewssnnzbl .gt_title {
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
&#10;#mewssnnzbl .gt_subtitle {
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
&#10;#mewssnnzbl .gt_heading {
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
&#10;#mewssnnzbl .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#mewssnnzbl .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#mewssnnzbl .gt_col_heading {
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
&#10;#mewssnnzbl .gt_column_spanner_outer {
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
&#10;#mewssnnzbl .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#mewssnnzbl .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#mewssnnzbl .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#mewssnnzbl .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#mewssnnzbl .gt_group_heading {
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
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#mewssnnzbl .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#mewssnnzbl .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#mewssnnzbl .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#mewssnnzbl .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#mewssnnzbl .gt_stub {
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
}
&#10;#mewssnnzbl .gt_stub_row_group {
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
&#10;#mewssnnzbl .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#mewssnnzbl .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#mewssnnzbl .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#mewssnnzbl .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#mewssnnzbl .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#mewssnnzbl .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#mewssnnzbl .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#mewssnnzbl .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#mewssnnzbl .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#mewssnnzbl .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#mewssnnzbl .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#mewssnnzbl .gt_footnotes {
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
&#10;#mewssnnzbl .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#mewssnnzbl .gt_sourcenotes {
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
&#10;#mewssnnzbl .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#mewssnnzbl .gt_left {
  text-align: left;
}
&#10;#mewssnnzbl .gt_center {
  text-align: center;
}
&#10;#mewssnnzbl .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#mewssnnzbl .gt_font_normal {
  font-weight: normal;
}
&#10;#mewssnnzbl .gt_font_bold {
  font-weight: bold;
}
&#10;#mewssnnzbl .gt_font_italic {
  font-style: italic;
}
&#10;#mewssnnzbl .gt_super {
  font-size: 65%;
}
&#10;#mewssnnzbl .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#mewssnnzbl .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#mewssnnzbl .gt_indent_1 {
  text-indent: 5px;
}
&#10;#mewssnnzbl .gt_indent_2 {
  text-indent: 10px;
}
&#10;#mewssnnzbl .gt_indent_3 {
  text-indent: 15px;
}
&#10;#mewssnnzbl .gt_indent_4 {
  text-indent: 20px;
}
&#10;#mewssnnzbl .gt_indent_5 {
  text-indent: 25px;
}
&#10;#mewssnnzbl .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#mewssnnzbl div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="var">variable</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="val">description</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="var" class="gt_row gt_left"><span data-qmd-base64="YGVudHJ5X3Rlcm1g"><span class='gt_from_md'><code>entry_term</code></span></span></td>
<td headers="val" class="gt_row gt_left">term when admitted</td></tr>
    <tr><td headers="var" class="gt_row gt_left"><span data-qmd-base64="YGVudHJ5X2xldmVsYA=="><span class='gt_from_md'><code>entry_level</code></span></span></td>
<td headers="val" class="gt_row gt_left">level when admitted</td></tr>
    <tr><td headers="var" class="gt_row gt_left"><span data-qmd-base64="YGFkal9zcGFuYA=="><span class='gt_from_md'><code>adj_span</code></span></span></td>
<td headers="val" class="gt_row gt_left">default span adjusted to account for entry level</td></tr>
    <tr><td headers="var" class="gt_row gt_left"><span data-qmd-base64="YHRpbWVseV90ZXJtYA=="><span class='gt_from_md'><code>timely_term</code></span></span></td>
<td headers="val" class="gt_row gt_left">timely completion term</td></tr>
  </tbody>
  &#10;</table>
</div>

``` r
# setup
DT <- student[, .(mcid)]

# apply
DT <- timely_term(DT)

# result
DT[order(-adj_span)]
#>                  mcid entry_term    entry_level adj_span timely_term
#>                <char>     <char>         <char>    <num>      <char>
#>     1: MCID3111142225      19881  01 First-year        6       19933
#>     2: MCID3111142283      19881  01 First-year        6       19933
#>     3: MCID3111142290      19881  01 First-year        6       19933
#>    ---                                                              
#> 97553: MCID3111858641      20013  03 Third-year        4       20051
#> 97554: MCID3111860641      20013  03 Third-year        4       20051
#> 97555: MCID3111602161      19991 04 Fourth-year        3       20013
```

The optional `span` argument allows you to change the time span you
consider “timely.”

``` r
DT <- student[, .(mcid)]
timely_term(DT, span = 8)[order(-adj_span)]
#>                  mcid entry_term    entry_level adj_span timely_term
#>                <char>     <char>         <char>    <num>      <char>
#>     1: MCID3111142225      19881  01 First-year        8       19953
#>     2: MCID3111142283      19881  01 First-year        8       19953
#>     3: MCID3111142290      19881  01 First-year        8       19953
#>    ---                                                              
#> 97553: MCID3111858641      20013  03 Third-year        6       20071
#> 97554: MCID3111860641      20013  03 Third-year        6       20071
#> 97555: MCID3111602161      19991 04 Fourth-year        5       20033
```

### data_sufficiency()

*Data sufficiency* is a necessary condition for including a student in a
population if a metric depends on program completion. To meet the
condition, an institution’s data range must bracket a student’s entry
and timely completion terms.

`data_sufficiency()` evaluates whether the condition is met for each
student. The principal data frame must include the variables
`{mcid, entry_term, timely_term}.` Institutions’ data ranges are pulled
from the `term` table. The data frame is returned with the following
variables added:

<div id="uidgbwofmy" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:80%;">
<style>#uidgbwofmy table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#uidgbwofmy thead, #uidgbwofmy tbody, #uidgbwofmy tfoot, #uidgbwofmy tr, #uidgbwofmy td, #uidgbwofmy th {
  border-style: none;
}
&#10;#uidgbwofmy p {
  margin: 0;
  padding: 0;
}
&#10;#uidgbwofmy .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 80%;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#uidgbwofmy .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#uidgbwofmy .gt_title {
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
&#10;#uidgbwofmy .gt_subtitle {
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
&#10;#uidgbwofmy .gt_heading {
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
&#10;#uidgbwofmy .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#uidgbwofmy .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#uidgbwofmy .gt_col_heading {
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
&#10;#uidgbwofmy .gt_column_spanner_outer {
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
&#10;#uidgbwofmy .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#uidgbwofmy .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#uidgbwofmy .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#uidgbwofmy .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#uidgbwofmy .gt_group_heading {
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
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#uidgbwofmy .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#uidgbwofmy .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#uidgbwofmy .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#uidgbwofmy .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#uidgbwofmy .gt_stub {
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
}
&#10;#uidgbwofmy .gt_stub_row_group {
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
&#10;#uidgbwofmy .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#uidgbwofmy .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#uidgbwofmy .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#uidgbwofmy .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#uidgbwofmy .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#uidgbwofmy .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#uidgbwofmy .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#uidgbwofmy .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#uidgbwofmy .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#uidgbwofmy .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#uidgbwofmy .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#uidgbwofmy .gt_footnotes {
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
&#10;#uidgbwofmy .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#uidgbwofmy .gt_sourcenotes {
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
&#10;#uidgbwofmy .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#uidgbwofmy .gt_left {
  text-align: left;
}
&#10;#uidgbwofmy .gt_center {
  text-align: center;
}
&#10;#uidgbwofmy .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#uidgbwofmy .gt_font_normal {
  font-weight: normal;
}
&#10;#uidgbwofmy .gt_font_bold {
  font-weight: bold;
}
&#10;#uidgbwofmy .gt_font_italic {
  font-style: italic;
}
&#10;#uidgbwofmy .gt_super {
  font-size: 65%;
}
&#10;#uidgbwofmy .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#uidgbwofmy .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#uidgbwofmy .gt_indent_1 {
  text-indent: 5px;
}
&#10;#uidgbwofmy .gt_indent_2 {
  text-indent: 10px;
}
&#10;#uidgbwofmy .gt_indent_3 {
  text-indent: 15px;
}
&#10;#uidgbwofmy .gt_indent_4 {
  text-indent: 20px;
}
&#10;#uidgbwofmy .gt_indent_5 {
  text-indent: 25px;
}
&#10;#uidgbwofmy .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#uidgbwofmy div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="var">variable</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="val">description</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="var" class="gt_row gt_left"><span data-qmd-base64="YGRhdGFfcmFuZ2Vg"><span class='gt_from_md'><code>data_range</code></span></span></td>
<td headers="val" class="gt_row gt_left">an institution's min and max terms in the database</td></tr>
    <tr><td headers="var" class="gt_row gt_left"><span data-qmd-base64="YHN1ZmZpY2llbmN5YA=="><span class='gt_from_md'><code>sufficiency</code></span></span></td>
<td headers="val" class="gt_row gt_left">indicates whether a record satisfies the condition</td></tr>
  </tbody>
  &#10;</table>
</div>

``` r
# setup
DT <- student[, .(mcid)]
DT <- timely_term(DT)
DT <- DT[, .(mcid, entry_term, timely_term)]

# apply
DT <- data_sufficiency(DT)

# result
DT[order(-sufficiency)]
#>                  mcid entry_term timely_term  data_range sufficiency
#>                <char>     <char>      <char>      <char>      <char>
#>     1: MCID3111142689      19883       19941 19881-20181   satisfied
#>     2: MCID3111142782      19883       19941 19881-20096   satisfied
#>     3: MCID3111142881      19893       19951 19881-20181   satisfied
#>    ---                                                              
#> 97553: MCID3111824139      19901       19953 19901-20154  fail-lower
#> 97554: MCID3111869416      19901       19953 19901-20154  fail-lower
#> 97555: MCID3112056754      19881       19933 19881-20096  fail-lower
```

We usually filter to retain rows with sufficiency labeled “satisfied,”
indicating that the entry term is at least one term later than the lower
limit of the data range and the timely completion term is no later than
the upper limit.

## Records

Relevant functions:

- `is_undergrad()`

### is_undergrad()

*Undergraduate terms* are those prior to (and including) the first
degree term.

`is_undergrad()` evaluates whether a term is before or after a student’s
first degree. The principal data frame is any of the data tables having
a term-value variable:

``` r
term <- is_undergrad(term)
course <- is_undergrad(course)
degree <- is_undergrad(degree)
```

In all cases, the term of the student’s first degree is pulled from the
`degree` table. The input data frame is returned with the following
variables added:

<div id="iywuscmpsr" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:80%;">
<style>#iywuscmpsr table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#iywuscmpsr thead, #iywuscmpsr tbody, #iywuscmpsr tfoot, #iywuscmpsr tr, #iywuscmpsr td, #iywuscmpsr th {
  border-style: none;
}
&#10;#iywuscmpsr p {
  margin: 0;
  padding: 0;
}
&#10;#iywuscmpsr .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 80%;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#iywuscmpsr .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#iywuscmpsr .gt_title {
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
&#10;#iywuscmpsr .gt_subtitle {
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
&#10;#iywuscmpsr .gt_heading {
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
&#10;#iywuscmpsr .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#iywuscmpsr .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#iywuscmpsr .gt_col_heading {
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
&#10;#iywuscmpsr .gt_column_spanner_outer {
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
&#10;#iywuscmpsr .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#iywuscmpsr .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#iywuscmpsr .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#iywuscmpsr .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#iywuscmpsr .gt_group_heading {
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
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#iywuscmpsr .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#iywuscmpsr .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#iywuscmpsr .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#iywuscmpsr .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#iywuscmpsr .gt_stub {
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
}
&#10;#iywuscmpsr .gt_stub_row_group {
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
&#10;#iywuscmpsr .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#iywuscmpsr .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#iywuscmpsr .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#iywuscmpsr .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#iywuscmpsr .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#iywuscmpsr .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#iywuscmpsr .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#iywuscmpsr .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#iywuscmpsr .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#iywuscmpsr .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#iywuscmpsr .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#iywuscmpsr .gt_footnotes {
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
&#10;#iywuscmpsr .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#iywuscmpsr .gt_sourcenotes {
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
&#10;#iywuscmpsr .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#iywuscmpsr .gt_left {
  text-align: left;
}
&#10;#iywuscmpsr .gt_center {
  text-align: center;
}
&#10;#iywuscmpsr .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#iywuscmpsr .gt_font_normal {
  font-weight: normal;
}
&#10;#iywuscmpsr .gt_font_bold {
  font-weight: bold;
}
&#10;#iywuscmpsr .gt_font_italic {
  font-style: italic;
}
&#10;#iywuscmpsr .gt_super {
  font-size: 65%;
}
&#10;#iywuscmpsr .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#iywuscmpsr .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#iywuscmpsr .gt_indent_1 {
  text-indent: 5px;
}
&#10;#iywuscmpsr .gt_indent_2 {
  text-indent: 10px;
}
&#10;#iywuscmpsr .gt_indent_3 {
  text-indent: 15px;
}
&#10;#iywuscmpsr .gt_indent_4 {
  text-indent: 20px;
}
&#10;#iywuscmpsr .gt_indent_5 {
  text-indent: 25px;
}
&#10;#iywuscmpsr .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#iywuscmpsr div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="var">variable</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="val">description</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="var" class="gt_row gt_left"><span data-qmd-base64="YGJhY2NfdGVybWA="><span class='gt_from_md'><code>bacc_term</code></span></span></td>
<td headers="val" class="gt_row gt_left">term of a student's first baccalaureate or NA</td></tr>
    <tr><td headers="var" class="gt_row gt_left"><span data-qmd-base64="YHRlcm1fZm9jdXNg"><span class='gt_from_md'><code>term_focus</code></span></span></td>
<td headers="val" class="gt_row gt_left">indicates whether a term is before or after a first degree</td></tr>
  </tbody>
  &#10;</table>
</div>

For example,

``` r
is_undergrad(term)
#>                   mcid   term   cip6   institution         level
#>                 <char> <char> <char>        <char>        <char>
#>      1: MCID3111142225  19881 140901 Institution B 01 First-year
#>      2: MCID3111142283  19881 240102 Institution J 01 First-year
#>      3: MCID3111142283  19883 240102 Institution J 01 First-year
#>     ---                                                         
#> 639913: MCID3112898894  20181 451001 Institution B 01 First-year
#> 639914: MCID3112898895  20181 302001 Institution B 01 First-year
#> 639915: MCID3112898940  20181 050103 Institution B 01 First-year
#>                   standing   coop hours_term hours_term_attempt hours_cumul
#>                     <char> <char>      <num>              <num>       <num>
#>      1:      Good Standing     No          7                  7           7
#>      2: Academic Probation     No          6                  6           6
#>      3: Academic Probation     No         12                 12          18
#>     ---                                                                    
#> 639913:      Good Standing     No         13                 13          13
#> 639914:      Good Standing     No         18                 18          18
#> 639915:      Good Standing     No         15                 15          15
#>         hours_cumul_attempt gpa_term gpa_cumul bacc_term term_focus
#>                       <num>    <num>     <num>    <char>     <char>
#>      1:                   7     2.56      2.56     19881  undergrad
#>      2:                   6     1.85      1.85      <NA>  undergrad
#>      3:                  18     1.93      1.90      <NA>  undergrad
#>     ---                                                            
#> 639913:                  13     3.52      3.52      <NA>  undergrad
#> 639914:                  18     3.50      3.50      <NA>  undergrad
#> 639915:                  15     2.18      2.18      <NA>  undergrad
```

While we usually retain all columns, the results are easier to examine
if we view a selection of columns,

``` r
term <- is_undergrad(term)
term[order(-term_focus), .(mcid, term, bacc_term, term_focus)]
#>                   mcid   term bacc_term term_focus
#>                 <char> <char>    <char>     <char>
#>      1: MCID3111142225  19881     19881  undergrad
#>      2: MCID3111142283  19881      <NA>  undergrad
#>      3: MCID3111142283  19883      <NA>  undergrad
#>     ---                                           
#> 639913: MCID3112760306  20181     20174  post-bacc
#> 639914: MCID3112768322  20181     20174  post-bacc
#> 639915: MCID3112773810  20181     20174  post-bacc
```

In all cases, we filter to retain terms with an “undergrad” focus,
dropping the post-baccalaureate terms.

## Blocs

A *bloc* is a grouping of student-level data dealt with as a unit, for
example, administrative groupings such as transfer students and
traditional or non-traditional students, as well as program-based
groupings such as students starting in, ever-enrolling in, migrating
into or out of, or graduating from a program.

Relevant functions:

- `filter_programs()`
- `completion_status()`

### filter_programs()

Contributes to assembling a bloc of programs.

*Programs* are academic fields of study—specialties within a field or a
collection of fields within a Department, College, or University—encoded
in the `cip` dataset.

`filter_programs()` acts on a CIP data frame to choose rows that match
or partially match search strings. Search strings are case-independent.
For example, to search for music programs, we might start with,

``` r
filter_programs(cip, "music")
#>                                      cip6name   cip6
#>                                        <char> <char>
#>  1:                   Music Teacher Education 131312
#>  2:                                     Music 360115
#>  3:                   Religious, Sacred Music 390501
#>  4: Musical Instrument Fabrication and Repair 470404
#>  5:                              Digital Arts 500102
#>  6:                           Musical Theatre 500509
#>  7:                            Music, General 500901
#>  8:      Music History, Literature and Theory 500902
#> ---                                                 
#> 18:                            Music Pedagogy 500912
#> 19:                          Music Technology 500913
#> 20:                         Brass Instruments 500914
#> 21:                      Woodwind Instruments 500915
#> 22:                    Percussion Instruments 500916
#> 23:                              Music, Other 500999
#> 24:                          Music Management 501003
#> 25:                  Music Therapy, Therapist 512305
#>                                                                   cip4name
#>                                                                     <char>
#>  1: Teacher Education and Professional Development, Specific Subject Areas
#>  2:                                    Leisure and Recreational Activities
#>  3:                                                Religious, Sacred Music
#>  4:                  Precision Systems Maintenance and Repair Technologies
#>  5:                                          General Art and Music Studies
#>  6:                                     Drama, Theatre Arts and Stagecraft
#>  7:                                                                  Music
#>  8:                                                                  Music
#> ---                                                                       
#> 18:                                                                  Music
#> 19:                                                                  Music
#> 20:                                                                  Music
#> 21:                                                                  Music
#> 22:                                                                  Music
#> 23:                                                                  Music
#> 24:                               Arts, Entertainment and Media Management
#> 25:                             Rehabilitation and Therapeutic Professions
#>       cip4                                         cip2name   cip2
#>     <char>                                           <char> <char>
#>  1:   1313                                        Education     13
#>  2:   3601              Leisure and Recreational Activities     36
#>  3:   3905      Theological Studies and Religious Vocations     39
#>  4:   4704                   Mechanic and Repair Technology     47
#>  5:   5001                       Visual and Performing Arts     50
#>  6:   5005                       Visual and Performing Arts     50
#>  7:   5009                       Visual and Performing Arts     50
#>  8:   5009                       Visual and Performing Arts     50
#> ---                                                               
#> 18:   5009                       Visual and Performing Arts     50
#> 19:   5009                       Visual and Performing Arts     50
#> 20:   5009                       Visual and Performing Arts     50
#> 21:   5009                       Visual and Performing Arts     50
#> 22:   5009                       Visual and Performing Arts     50
#> 23:   5009                       Visual and Performing Arts     50
#> 24:   5010                       Visual and Performing Arts     50
#> 25:   5123 Health Professions and Related Clinical Sciences     51
```

For music as a component of the Visual and Performing Arts, we filter
`cip` again using a regular expression. We can also select specific
columns for a more compact display.

``` r
filter_programs(cip, "^5009")[, .(cip6name, cip6, cip4name)]
#>                                                 cip6name   cip6 cip4name
#>                                                   <char> <char>   <char>
#>  1:                                       Music, General 500901    Music
#>  2:                 Music History, Literature and Theory 500902    Music
#>  3:                           Music Performance, General 500903    Music
#>  4:                         Music Theory and Composition 500904    Music
#>  5:                       Musicology and Ethnomusicology 500905    Music
#>  6:                                           Conducting 500906    Music
#>  7:                                      Piano and Organ 500907    Music
#>  8:                                      Voice and Opera 500908    Music
#>  9:                   Music Management and Merchandising 500909    Music
#> 10:                                   Jazz, Jazz Studies 500910    Music
#> 11: Violin, Viola, Guitar and Other Stringed Instruments 500911    Music
#> 12:                                       Music Pedagogy 500912    Music
#> 13:                                     Music Technology 500913    Music
#> 14:                                    Brass Instruments 500914    Music
#> 15:                                 Woodwind Instruments 500915    Music
#> 16:                               Percussion Instruments 500916    Music
#> 17:                                         Music, Other 500999    Music
```

The `negate` argument allows you to invert the logic drop

and delete rows that match the search patterns.

``` r
x <- filter_programs(cip, "^5009")[, .(cip6name, cip6, cip4name)]
filter_programs(x, c("Other", "General"), negate = TRUE)
#>                                 cip6name   cip6 cip4name
#>                                   <char> <char>   <char>
#>  1: Music History, Literature and Theory 500902    Music
#>  2:         Music Theory and Composition 500904    Music
#>  3:       Musicology and Ethnomusicology 500905    Music
#>  4:                           Conducting 500906    Music
#>  5:                      Piano and Organ 500907    Music
#>  6:                      Voice and Opera 500908    Music
#>  7:   Music Management and Merchandising 500909    Music
#>  8:                   Jazz, Jazz Studies 500910    Music
#>  9:                       Music Pedagogy 500912    Music
#> 10:                     Music Technology 500913    Music
#> 11:                    Brass Instruments 500914    Music
#> 12:                 Woodwind Instruments 500915    Music
#> 13:               Percussion Instruments 500916    Music
```

In a study, we would continue in a similar fashion until we had merged
all the 6-digit codes we needed into one data frame.

### completion_status()

Contributes to assembling a bloc of graduates.

*Completion status* is “timely” for students graduating no later than
their timely-completion term; “late” or “NA” otherwise. Only records
satisfying data sufficiency can be processed for completion status.

`completion_status()` yields a status label for each student. The
principal data frame must include the variables `{mcid, timely_term}.`
The first degree term is pulled from the `degree` table. The data frame
is returned with the following variables added:

<div id="diskvyuthr" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:80%;">
<style>#diskvyuthr table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#diskvyuthr thead, #diskvyuthr tbody, #diskvyuthr tfoot, #diskvyuthr tr, #diskvyuthr td, #diskvyuthr th {
  border-style: none;
}
&#10;#diskvyuthr p {
  margin: 0;
  padding: 0;
}
&#10;#diskvyuthr .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 80%;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#diskvyuthr .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#diskvyuthr .gt_title {
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
&#10;#diskvyuthr .gt_subtitle {
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
&#10;#diskvyuthr .gt_heading {
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
&#10;#diskvyuthr .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#diskvyuthr .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#diskvyuthr .gt_col_heading {
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
&#10;#diskvyuthr .gt_column_spanner_outer {
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
&#10;#diskvyuthr .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#diskvyuthr .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#diskvyuthr .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#diskvyuthr .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#diskvyuthr .gt_group_heading {
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
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#diskvyuthr .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#diskvyuthr .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#diskvyuthr .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#diskvyuthr .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#diskvyuthr .gt_stub {
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
}
&#10;#diskvyuthr .gt_stub_row_group {
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
&#10;#diskvyuthr .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#diskvyuthr .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#diskvyuthr .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#diskvyuthr .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#diskvyuthr .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#diskvyuthr .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#diskvyuthr .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#diskvyuthr .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#diskvyuthr .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#diskvyuthr .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#diskvyuthr .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#diskvyuthr .gt_footnotes {
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
&#10;#diskvyuthr .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#diskvyuthr .gt_sourcenotes {
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
&#10;#diskvyuthr .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#diskvyuthr .gt_left {
  text-align: left;
}
&#10;#diskvyuthr .gt_center {
  text-align: center;
}
&#10;#diskvyuthr .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#diskvyuthr .gt_font_normal {
  font-weight: normal;
}
&#10;#diskvyuthr .gt_font_bold {
  font-weight: bold;
}
&#10;#diskvyuthr .gt_font_italic {
  font-style: italic;
}
&#10;#diskvyuthr .gt_super {
  font-size: 65%;
}
&#10;#diskvyuthr .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#diskvyuthr .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#diskvyuthr .gt_indent_1 {
  text-indent: 5px;
}
&#10;#diskvyuthr .gt_indent_2 {
  text-indent: 10px;
}
&#10;#diskvyuthr .gt_indent_3 {
  text-indent: 15px;
}
&#10;#diskvyuthr .gt_indent_4 {
  text-indent: 20px;
}
&#10;#diskvyuthr .gt_indent_5 {
  text-indent: 25px;
}
&#10;#diskvyuthr .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#diskvyuthr div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="var">variable</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="val">description</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="var" class="gt_row gt_left"><span data-qmd-base64="YGJhY2NfdGVybWA="><span class='gt_from_md'><code>bacc_term</code></span></span></td>
<td headers="val" class="gt_row gt_left">term of a student's first baccalaureate</td></tr>
    <tr><td headers="var" class="gt_row gt_left"><span data-qmd-base64="YGNvbXBsZXRpb25g"><span class='gt_from_md'><code>completion</code></span></span></td>
<td headers="val" class="gt_row gt_left">indicates whether status is timely, late, or NA</td></tr>
  </tbody>
  &#10;</table>
</div>

``` r
# setup
DT <- student[, .(mcid)]
DT <- timely_term(DT)
DT <- data_sufficiency(DT)
DT <- DT[sufficiency == "satisfied"]
DT <- DT[, .(mcid, timely_term)]

# apply
DT <- completion_status(DT)

# result
DT[order(-completion)]
#>                  mcid timely_term bacc_term completion
#>                <char>      <char>    <char>     <char>
#>     1: MCID3111142689       19941     19913     timely
#>     2: MCID3111142782       19941     19903     timely
#>     3: MCID3111142881       19951     19894     timely
#>    ---                                                
#> 76919: MCID3112785480       20123      <NA>       <NA>
#> 76920: MCID3112800920       20153      <NA>       <NA>
#> 76921: MCID3112870009       20003      <NA>       <NA>
```

When we want of bloc of timely graduates, we filter to retain rows with
completion “timely.”

## Commonalities

You may have noticed similarities in several of the midfieldr functions.
For example, in these functions,

- `timely_term(dframe, midf_table = term)`
- `data_sufficiency(dframe, midf_table = term)`
- `is_undergraduate(dframe, midf_table = degree)`
- `completion status(dframe, midf_table = degree)`

the similarities include:

- The first argument is a data frame.
- The second argument is one of the MIDFIELD data tables.
- The result is a new data frame with columns added that support the
  main finding.
- You can use the main finding to subset the result by rows.

Moreover, because in each case the `midf_table` argument has a default
value, it can be assigned explicitly or not. For example, the three
formulations below all yield the same result as long as term data table
in the computing environment is named `term.`

``` r
# setup
DT <- student[, .(mcid)]

# equivalent statements
x <- timely_term(dframe = DT, midf_table = term)
y <- timely_term(DT, term)
z <- timely_term(DT)

# equivalent results
check_equiv_frames(x, y)
#> [1] TRUE
check_equiv_frames(x, z)
#> [1] TRUE
```

Of other functions used earlier,

- `filter_programs()`
- `select_basic_cols()`

have in common that:

- The first argument is a data frame.
- The result is a new data frame, a subset of the input: “filter”
  chooses rows; “select” chooses columns.

## Special conditioning

Relevant functions:

- `initialize_fye_proxies()`
- `order_multiway()`

### initialize_fye_proxies()

Contributes to assembling a bloc of starters.

At some U.S. institutions, completing a *First-Year Engineering (FYE)*
program is a prerequisite for admission to specific engineering majors.
FYE programs complicate the identification of *starters* because the
student’s preferred starting major is unknown.

`initialize_fye_proxies()` takes a first pass at

helps us develop an *FYE proxy,* a likely CIP code of the student’s
starting program had FYE not been required. Results are a CIP code or
NA, treated as missing data to be imputed.

``` r
initialize_fye_proxies(student, term)
#>                 mcid   institution          race    sex  proxy
#>               <char>        <fctr>        <fctr> <fctr> <fctr>
#>    1: MCID3111142290 Institution J         Asian   Male 141001
#>    2: MCID3111142294 Institution J         Asian   Male 141001
#>    3: MCID3111142961 Institution J International   Male 142101
#>    4: MCID3111142965 Institution J International   Male 141001
#>    5: MCID3111143894 Institution J         White Female 140701
#>   ---                                                         
#> 5785: MCID3112447650 Institution J         White   Male   <NA>
#> 5786: MCID3112447657 Institution J         White   Male   <NA>
#> 5787: MCID3112447659 Institution J         White   Male   <NA>
#> 5788: MCID3112447663 Institution J         White   Male   <NA>
#> 5789: MCID3112447664 Institution J         White   Male   <NA>
```

If FYE programs are involved in your study,

- [FYE proxies](art-060-fye-proxies.html) describes the inner workings
  of the function and how to process the results using the R mice
  package for multiple imputation.
- [Starters](art-070-starters.html) describes how FYE proxies are
  incorporated in a starter bloc.

### order_multiway()

Conditions data for Cleveland multiway charts.

*Multiway data* comprise two independent categorical variables and one
quantitative variable with a value for each combination of levels of the
two categories.

`order_multiway()` converts the categorical variables to factors ordered
by the quantitative variable. This ordering determines the order of the
panels and rows in a multiway chart, crucial to our ability to perceive
effects.

In this example, we use the `case_results` multiway data that loads with
midfieldr. The two categories are `program` and `people`. The quantity
is `stick` (program stickiness) which is the ratio of `grad` (number of
program graduates) to `ever` (number ever enrolled in the program).

``` r
case_results
#>        program               people  ever  grad stick
#>         <char>               <char> <num> <num> <num>
#>  1:      Civil         Asian Female    14    10  71.4
#>  2:      Civil           Asian Male    33    25  75.8
#>  3:      Civil           Black Male     8     5  62.5
#>  4:      Civil      Hispanic Female    13     6  46.2
#>  5:      Civil        Hispanic Male    66    31  47.0
#> ---                                                  
#> 39: Mechanical   International Male   176    89  50.6
#> 40: Mechanical Other/Unknown Female     8     4  50.0
#> 41: Mechanical   Other/Unknown Male    81    41  50.6
#> 42: Mechanical         White Female   213   134  62.9
#> 43: Mechanical           White Male  1587   952  60.0
```

In the data frame returned, the factor levels are ordered by the
aggregate stickiness calculated separately by category and reported in
the new columns (suffix `_metric`). A multiway chart can be constructed
from the data in this form.

``` r
DT <- order_multiway(case_results,
  quantity = "stick",
  categories = c("program", "people"),
  method = "percent",
  ratio_of = c("grad", "ever")
)
DT[, c("grad", "ever") := NULL]
DT
#>        program               people stick program_metric people_metric
#>         <fctr>               <fctr> <num>          <num>         <num>
#>  1:      Civil         Asian Female  71.4           62.4          64.0
#>  2:      Civil           Asian Male  75.8           62.4          62.8
#>  3:      Civil           Black Male  62.5           62.4          62.7
#>  4:      Civil      Hispanic Female  46.2           62.4          51.5
#>  5:      Civil        Hispanic Male  47.0           62.4          48.5
#> ---                                                                   
#> 39: Mechanical   International Male  50.6           59.2          50.2
#> 40: Mechanical Other/Unknown Female  50.0           59.2          50.0
#> 41: Mechanical   Other/Unknown Male  50.6           59.2          45.6
#> 42: Mechanical         White Female  62.9           59.2          61.1
#> 43: Mechanical           White Male  60.0           59.2          59.9
```

Complete information on using `order_multiway()` and constructing
multiway charts can be found in [Multiway data and
charts](art-120-multiway.html).

## Utilities

See the relevant help page for more information, e.g. `?catch_error`.

- `catch_error()` wraps base `tryCatch()` for errors with preset
  arguments.
- `check_equiv_frames()` re-exported from the wrapr package.
- `look_at()` for data frames, wraps base `str()` with preset arguments.
- `select_unique_cols()` primarily used internally to drop duplicate
  columns.
- `sort_uniq()` for vectors, wraps base `sort(unique())` with preset
  arguments.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-NCES:2010" class="csl-entry">

NCES. 2010. *<span class="nocase">IPEDS Classification of Instructional
Programs (CIP)</span>*. National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>.

</div>

</div>
