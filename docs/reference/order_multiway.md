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

  Character. Vector of names of the two multiway categorical variables,
  in any order.

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- method:

  Character. Method of ordering the levels of the categories; possible
  values are “median” (default) or “percent”. The median method
  determines medians of the quantitative column grouped by category. The
  percent method sums dividends and divisors by category and calculates
  their quotients by category.

- ratio_of:

  Character. Vector of column names of the dividend and the divisor that
  produced the quantitative variable. Names must be in order, as in
  `c(dividend, divisor).` Required when `method = "percent,"` ignored
  otherwise.

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Row order is preserved. Duplicated rows are removed.

- Column specified by `quantity` is converted to type double. Columns
  specified by `categories` are converted to factors and ordered.

- Columns with names different from the two new columns (named below)
  are not modified; columns with matching names are replaced. The two
  new column names have the form:

  - `CATEGORY_1_LABEL`

  - `CATEGORY_2_LABEL`

The `CATEGORY` placeholder in the new column names is replaced with the
column names from `categories.` The `LABEL` placeholder depends on the
method. For `method = median`, the label is `median`. For
`method = percent`, the label is `metric,` indicating that the metric in
percent has been recalculated for the entire category. For example, if
`categories = c("program", "people")` and `method = "median",` the new
column names would be `program_median` and `people_median.` For
`method = "percent",` the new column names would be `program_metric` and
`people_metric.`

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
data.table::setcolorder(DT, c("prgm", "people", "grad", "ever", "stk"))
DT[]
#>       prgm          people  grad  ever   stk
#>     <char>          <char> <int> <int> <num>
#>  1:     EE    Asian Female    12    21  57.1
#>  2:     EE    Black Female     3     6  50.0
#>  3:     EE Hispanic Female     3     8  37.5
#>  4:     EE    White Female    56   118  47.5
#>  5:     EE      Asian Male    71   123  57.7
#>  6:     EE      Black Male    17    29  58.6
#>  7:     EE   Hispanic Male    17    45  37.8
#>  8:     EE      White Male   439   864  50.8
#>  9:     ME    Asian Female     1     7  14.3
#> 10:     ME    Black Female     2     3  66.7
#> 11:     ME Hispanic Female     8    12  66.7
#> 12:     ME    White Female   134   213  62.9
#> 13:     ME      Asian Male    49    76  64.5
#> 14:     ME      Black Male    19    30  63.3
#> 15:     ME   Hispanic Male    42    79  53.2
#> 16:     ME      White Male   955  1596  59.8

# Factor levels ordered by median
DT1 <- data.table::copy(DT)
DT1 <- DT1[, c("ever", "grad") := NULL]
mw1 <- order_multiway(DT1, 
                      quantity = "stk", 
                      categories = c("prgm", "people"))
data.table::setorderv(mw1, c("prgm_median", "people_median"))
mw1
#>       prgm          people   stk prgm_median people_median
#>     <fctr>          <fctr> <num>       <num>         <num>
#>  1:     EE    Asian Female  57.1        50.4         35.70
#>  2:     EE   Hispanic Male  37.8        50.4         45.50
#>  3:     EE Hispanic Female  37.5        50.4         52.10
#>  4:     EE    White Female  47.5        50.4         55.20
#>  5:     EE      White Male  50.8        50.4         55.30
#>  6:     EE    Black Female  50.0        50.4         58.35
#>  7:     EE      Black Male  58.6        50.4         60.95
#>  8:     EE      Asian Male  57.7        50.4         61.10
#>  9:     ME    Asian Female  14.3        63.1         35.70
#> 10:     ME   Hispanic Male  53.2        63.1         45.50
#> 11:     ME Hispanic Female  66.7        63.1         52.10
#> 12:     ME    White Female  62.9        63.1         55.20
#> 13:     ME      White Male  59.8        63.1         55.30
#> 14:     ME    Black Female  66.7        63.1         58.35
#> 15:     ME      Black Male  63.3        63.1         60.95
#> 16:     ME      Asian Male  64.5        63.1         61.10

# Levels in increasing order
levels(mw1$prgm)
#> [1] "EE" "ME"
levels(mw1$people)
#> [1] "Asian Female"    "Hispanic Male"   "Hispanic Female" "White Female"   
#> [5] "White Male"      "Black Female"    "Black Male"      "Asian Male"     

# Ordering using percent method
mw2 <- order_multiway(DT, 
               quantity = "stk", 
               categories = c("prgm", "people"), 
               method = "percent", 
               ratio_of = c("grad", "ever"))
data.table::setorderv(mw2, c("prgm_metric", "people_metric"))

# The two ratio_of variables `ever` and `grad` are retained
mw2
#>       prgm          people  grad  ever   stk prgm_metric people_metric
#>     <fctr>          <fctr> <num> <num> <num>       <num>         <num>
#>  1:     EE    Asian Female    12    21  57.1        50.9          46.4
#>  2:     EE   Hispanic Male    17    45  37.8        50.9          47.6
#>  3:     EE Hispanic Female     3     8  37.5        50.9          55.0
#>  4:     EE    Black Female     3     6  50.0        50.9          55.6
#>  5:     EE      White Male   439   864  50.8        50.9          56.7
#>  6:     EE    White Female    56   118  47.5        50.9          57.4
#>  7:     EE      Asian Male    71   123  57.7        50.9          60.3
#>  8:     EE      Black Male    17    29  58.6        50.9          61.0
#>  9:     ME    Asian Female     1     7  14.3        60.0          46.4
#> 10:     ME   Hispanic Male    42    79  53.2        60.0          47.6
#> 11:     ME Hispanic Female     8    12  66.7        60.0          55.0
#> 12:     ME    Black Female     2     3  66.7        60.0          55.6
#> 13:     ME      White Male   955  1596  59.8        60.0          56.7
#> 14:     ME    White Female   134   213  62.9        60.0          57.4
#> 15:     ME      Asian Male    49    76  64.5        60.0          60.3
#> 16:     ME      Black Male    19    30  63.3        60.0          61.0

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
