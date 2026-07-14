# Order multiway categories

Condition data for Cleveland multiway charts. Two independent
categorical variables are converted to factors with their levels ordered
by the single quantitative response variable.

## Usage

``` r
order_multiway(
  dframe,
  quantity,
  categories,
  ...,
  method = NULL,
  ratio_of = NULL
)
```

## Arguments

- dframe:

  Data frame or data frame extension (e.g., data.table or tibble) with
  the following required variables: two independent categorical
  variables, one quantitative response variable, and, if
  `method = percent`, its dividend and divisor variables.

- quantity:

  Character. Name of the single multiway quantitative variable.

- categories:

  Character. Vector of names of the two multiway categorical variables.

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- method:

  Character. Method of ordering the levels of the categories; possible
  values are “median” (default) or “percent”. The median method
  determines medians of the quantitative column grouped by category. The
  percent method sums dividends and divisors by category and calculates
  their quotients (again, by category).

- ratio_of:

  Character. Vector of names of the dividend and the divisor that
  produced the quantitative variable. Required when
  `method = "percent,"` ignored otherwise. Names can be in any order;
  the algorithm assumes that the parameter with the larger column sum is
  the denominator of the ratio.

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Rows are preserved, though the row order may change.

- Numerical variables are converted to type double. Columns specified by
  `categories` are converted to factors and ordered.

- New columns are added or replace existing columns of the same name (if
  any). Other columns are not modified. New columns are added as
  described below.

- With `method = median`, two columns are added with names of the form
  `CATEGORY_median,` with `CATEGORY` replaced with the values from the
  `categories` argument. For example, if
  `categories = c("program", "people"),` the two new column names would
  be:

  - `program_median`

  - `people_median`

- With `method = percent`, two columns are added with names of the form
  `CATEGORY_QUANTITY,` with `CATEGORY` replaced with the values from the
  `categories` argument and `QUANTITY` from the `quantity` argument. For
  example, if `categories = c("program", "people")` and
  `quantity = "grad_rate",` the two new column names would be:

  - `program_grad_rate`

  - `people_grad_rate`

- Groups and keys are not preserved.

## Details

Multiway data comprise a single quantitative value (or response) for
every combination of levels of two categorical variables. The ordering
of the rows and panels, based on the response quantity, is crucial to
the perception of effects (Cleveland, 1993).

Multiway data comprise three variables: a categorical variable of
\\\small m\\ levels; a second independent categorical variable of
\\\small n\\ levels; and a quantitative variable (or *response*) of
length \\\small m \times n\\ that cross-classifies the categories, that
is, there is a value of the response for each combination of levels of
the two categorical variables. If a response value is missing, it is
assumed that a response for every combination is at least feasible.

In a multiway dot plot, one category is encoded by the panels, the
second category is encoded by the rows of each panel, and the
quantitative variable is encoded along identical horizontal scales.

## References

Cleveland WS (1993). *Visualizing Data*. Hobart Press, Summit, NJ.

## Examples

``` r
# Reconfigure built-in data set
DT <- study_results[program == "EE" | program == "ME"]
DT <- DT[race %chin% c("Asian", "Black", "Hispanic", "White")]
DT[, people := paste(race, sex)]
#>     program    sex     race ever_enrolled graduates stickiness          people
#>      <char> <char>   <char>         <int>     <int>      <num>          <char>
#>  1:      EE Female    Asian            21        12       57.1    Asian Female
#>  2:      EE Female    Black             6         3       50.0    Black Female
#>  3:      EE Female Hispanic             8         3       37.5 Hispanic Female
#>  4:      EE Female    White           118        56       47.5    White Female
#>  5:      EE   Male    Asian           123        71       57.7      Asian Male
#>  6:      EE   Male    Black            29        17       58.6      Black Male
#>  7:      EE   Male Hispanic            45        17       37.8   Hispanic Male
#>  8:      EE   Male    White           864       439       50.8      White Male
#>  9:      ME Female    Asian             7         1       14.3    Asian Female
#> 10:      ME Female    Black             3         2       66.7    Black Female
#> 11:      ME Female Hispanic            12         8       66.7 Hispanic Female
#> 12:      ME Female    White           213       134       62.9    White Female
#> 13:      ME   Male    Asian            76        49       64.5      Asian Male
#> 14:      ME   Male    Black            30        19       63.3      Black Male
#> 15:      ME   Male Hispanic            79        42       53.2   Hispanic Male
#> 16:      ME   Male    White          1596       955       59.8      White Male
DT[, c("race", "sex") := NULL]
#>     program ever_enrolled graduates stickiness          people
#>      <char>         <int>     <int>      <num>          <char>
#>  1:      EE            21        12       57.1    Asian Female
#>  2:      EE             6         3       50.0    Black Female
#>  3:      EE             8         3       37.5 Hispanic Female
#>  4:      EE           118        56       47.5    White Female
#>  5:      EE           123        71       57.7      Asian Male
#>  6:      EE            29        17       58.6      Black Male
#>  7:      EE            45        17       37.8   Hispanic Male
#>  8:      EE           864       439       50.8      White Male
#>  9:      ME             7         1       14.3    Asian Female
#> 10:      ME             3         2       66.7    Black Female
#> 11:      ME            12         8       66.7 Hispanic Female
#> 12:      ME           213       134       62.9    White Female
#> 13:      ME            76        49       64.5      Asian Male
#> 14:      ME            30        19       63.3      Black Male
#> 15:      ME            79        42       53.2   Hispanic Male
#> 16:      ME          1596       955       59.8      White Male
data.table::setnames(DT, 
         old = c("program", "graduates", "ever_enrolled", "stickiness"), 
         new = c("prgm", "grad", "ever", "stk"))
DT[]
#>       prgm  ever  grad   stk          people
#>     <char> <int> <int> <num>          <char>
#>  1:     EE    21    12  57.1    Asian Female
#>  2:     EE     6     3  50.0    Black Female
#>  3:     EE     8     3  37.5 Hispanic Female
#>  4:     EE   118    56  47.5    White Female
#>  5:     EE   123    71  57.7      Asian Male
#>  6:     EE    29    17  58.6      Black Male
#>  7:     EE    45    17  37.8   Hispanic Male
#>  8:     EE   864   439  50.8      White Male
#>  9:     ME     7     1  14.3    Asian Female
#> 10:     ME     3     2  66.7    Black Female
#> 11:     ME    12     8  66.7 Hispanic Female
#> 12:     ME   213   134  62.9    White Female
#> 13:     ME    76    49  64.5      Asian Male
#> 14:     ME    30    19  63.3      Black Male
#> 15:     ME    79    42  53.2   Hispanic Male
#> 16:     ME  1596   955  59.8      White Male

# Factor levels ordered by median
mw1 <- order_multiway(DT, 
                      quantity = "stk", 
                      categories = c("prgm", "people"))
data.table::setorderv(mw1, c("prgm_median", "people_median"))

# The unused variables `ever` and `grad` are dropped
mw1
#>       prgm  ever  grad   stk          people prgm_median people_median
#>     <fctr> <int> <int> <num>          <fctr>       <num>         <num>
#>  1:     EE    21    12  57.1    Asian Female        50.4         35.70
#>  2:     EE    45    17  37.8   Hispanic Male        50.4         45.50
#>  3:     EE     8     3  37.5 Hispanic Female        50.4         52.10
#>  4:     EE   118    56  47.5    White Female        50.4         55.20
#>  5:     EE   864   439  50.8      White Male        50.4         55.30
#>  6:     EE     6     3  50.0    Black Female        50.4         58.35
#>  7:     EE    29    17  58.6      Black Male        50.4         60.95
#>  8:     EE   123    71  57.7      Asian Male        50.4         61.10
#>  9:     ME     7     1  14.3    Asian Female        63.1         35.70
#> 10:     ME    79    42  53.2   Hispanic Male        63.1         45.50
#> 11:     ME    12     8  66.7 Hispanic Female        63.1         52.10
#> 12:     ME   213   134  62.9    White Female        63.1         55.20
#> 13:     ME  1596   955  59.8      White Male        63.1         55.30
#> 14:     ME     3     2  66.7    Black Female        63.1         58.35
#> 15:     ME    30    19  63.3      Black Male        63.1         60.95
#> 16:     ME    76    49  64.5      Asian Male        63.1         61.10

# Levels in same increasing order as shown above
levels(mw1$prgm)
#> [1] "EE" "ME"
levels(mw1$people)
#> [1] "Asian Female"    "Hispanic Male"   "Hispanic Female" "White Female"   
#> [5] "White Male"      "Black Female"    "Black Male"      "Asian Male"     

# Ordering using percent method
mw2 <-order_multiway(DT, 
               quantity = "stk", 
               categories = c("prgm", "people"), 
               method = "percent", 
               ratio_of = c("grad", "ever"))
data.table::setorderv(mw2, c("prgm_stk", "people_stk"))

# The two ratio_of variables `ever` and `grad` are retained
mw2
#>       prgm  ever  grad   stk          people prgm_stk people_stk
#>     <fctr> <num> <num> <num>          <fctr>    <num>      <num>
#>  1:     EE    21    12  57.1    Asian Female     50.9       46.4
#>  2:     EE    45    17  37.8   Hispanic Male     50.9       47.6
#>  3:     EE     8     3  37.5 Hispanic Female     50.9       55.0
#>  4:     EE     6     3  50.0    Black Female     50.9       55.6
#>  5:     EE   864   439  50.8      White Male     50.9       56.7
#>  6:     EE   118    56  47.5    White Female     50.9       57.4
#>  7:     EE   123    71  57.7      Asian Male     50.9       60.3
#>  8:     EE    29    17  58.6      Black Male     50.9       61.0
#>  9:     ME     7     1  14.3    Asian Female     60.0       46.4
#> 10:     ME    79    42  53.2   Hispanic Male     60.0       47.6
#> 11:     ME    12     8  66.7 Hispanic Female     60.0       55.0
#> 12:     ME     3     2  66.7    Black Female     60.0       55.6
#> 13:     ME  1596   955  59.8      White Male     60.0       56.7
#> 14:     ME   213   134  62.9    White Female     60.0       57.4
#> 15:     ME    76    49  64.5      Asian Male     60.0       60.3
#> 16:     ME    30    19  63.3      Black Male     60.0       61.0

# Levels in same increasing order as shown above
levels(mw2$prgm)
#> [1] "EE" "ME"
levels(mw2$people)
#> [1] "Asian Female"    "Hispanic Male"   "Hispanic Female" "Black Female"   
#> [5] "White Male"      "White Female"    "Asian Male"      "Black Male"     

# Order of factor levels depends on the method. Here, for example, 
# program levels are the same for median and percent methods, 
all.equal(levels(mw1$prgm), levels(mw2$prgm))
#> [1] TRUE

# but people levels do not have the same order. 
all.equal(levels(mw1$people), levels(mw2$people))
#> [1] "4 string mismatches"
levels(mw1$people)
#> [1] "Asian Female"    "Hispanic Male"   "Hispanic Female" "White Female"   
#> [5] "White Male"      "Black Female"    "Black Male"      "Asian Male"     
levels(mw2$people)
#> [1] "Asian Female"    "Hispanic Male"   "Hispanic Female" "Black Female"   
#> [5] "White Male"      "White Female"    "Asian Male"      "Black Male"     
```
