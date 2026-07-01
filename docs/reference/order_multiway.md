# Order multiway categories

Transform a data frame such that two independent categorical variables
are factors with levels ordered for display in a multiway dot plot.

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

  Data frame containing a single quantitative value (or response) for
  every combination of levels of two categorical variables. Categories
  may be class character or factor. Two additional numeric columns are
  required when using the "percent" ordering method.

- quantity:

  Character, name (in quotes) of the single multiway quantitative
  variable

- categories:

  Character, vector of names (in quotes) of the two multiway categorical
  variables

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- method:

  Character, “median” (default) or “percent”, method of ordering the
  levels of the categories. The median method computes the medians of
  the quantitative column grouped by category. The percent method
  computes percentages based on the same ratio underlying the
  quantitative percentage variable except grouped by category.

- ratio_of:

  Character vector with the names (in quotes) of the numerator and
  denominator columns that produced the quantitative variable, required
  when `method` is "percent". Names can be in any order; the algorithm
  assumes that the parameter with the larger column sum is the
  denominator of the ratio.

## Value

A data frame in `data.table` format with the following properties: rows
are preserved; columns specified by `categories` are converted to
factors and ordered; the column specified by `quantity` is converted to
type double; other columns are preserved with the exception that columns
added by the function overwrite existing columns of the same name (if
any); grouping structures are not preserved. The added columns are:

- `CATEGORY_median` columns (when ordering method is "median"):

  Numeric. Two columns of medians of the quantitative variable grouped
  by the categorical variables. The `CATEGORY` placeholder in the column
  name is replaced by a category name from the `categories` argument.
  For example, suppose `categories = c("program", "people")` and
  `method = "median"`. The two new column names would be
  `program_median` and `people_median.`

- `CATEGORY_QUANTITY` columns (when ordering method is "percent"):

  Numeric. Two columns of percentages based on the same ratio that
  produces the quantitative variable except grouped by the categorical
  variables. The `CATEGORY` placeholder in the column name is replaced
  by a category name from the `categories` argument; the `QUANTITY`
  placeholder is replaced by the quantitative variable name in the
  `quantity` argument. For example, suppose
  `categories = c("program", "people")`, and `quantity = "grad_rate"`,
  and `method = "percent"`. The two new column names would be
  `program_grad_rate` and `people_grad_rate.`

## Details

Multiway data comprise a single quantitative value (or response) for
every combination of levels of two categorical variables. The ordering
of the rows and panels is crucial to the perception of effects
(Cleveland, 1993).

In our context, "multiway" refers to the data structure and graph design
defined by Cleveland (1993), not to the methods of analysis described by
Kroonenberg (2008).

Multiway data comprise three variables: a categorical variable of *m*
levels; a second independent categorical variable of *n* levels; and a
quantitative variable (or *response*) of length *mn* that
cross-classifies the categories, that is, there is a value of the
response for each combination of levels of the two categorical
variables.

In a multiway dot plot, one category is encoded by the panels, the
second category is encoded by the rows of each panel, and the
quantitative variable is encoded along identical horizontal scales.

## References

Cleveland WS (1993). *Visualizing Data*. Hobart Press, Summit, NJ.

Kroonenberg PM (2008). *Applied Multiway Data Analysis*. Wiley, Hoboken,
NJ.

## Examples

``` r
# Subset of built-in data set
dframe <- study_results[program == "EE" | program == "ME"]
dframe[, people := paste(race, sex)]
#>     program    sex            race ever_enrolled graduates stickiness
#>      <char> <char>          <char>         <int>     <int>      <num>
#>  1:      EE Female           Asian            21        12       57.1
#>  2:      EE Female           Black             6         3       50.0
#>  3:      EE Female        Hispanic             8         3       37.5
#>  4:      EE Female   International            28         9       32.1
#>  5:      EE Female Native American             1         0        0.0
#>  6:      EE Female   Other/Unknown             7         3       42.9
#>  7:      EE Female           White           118        56       47.5
#>  8:      EE   Male           Asian           123        71       57.7
#>  9:      EE   Male           Black            29        17       58.6
#> 10:      EE   Male        Hispanic            45        17       37.8
#> 11:      EE   Male   International           195        90       46.2
#> 12:      EE   Male Native American             3         0        0.0
#> 13:      EE   Male   Other/Unknown            42        16       38.1
#> 14:      EE   Male           White           864       439       50.8
#> 15:      ME Female           Asian             7         1       14.3
#> 16:      ME Female           Black             3         2       66.7
#> 17:      ME Female        Hispanic            12         8       66.7
#> 18:      ME Female   International            19        11       57.9
#> 19:      ME Female   Other/Unknown             8         4       50.0
#> 20:      ME Female           White           213       134       62.9
#> 21:      ME   Male           Asian            76        49       64.5
#> 22:      ME   Male           Black            30        19       63.3
#> 23:      ME   Male        Hispanic            79        42       53.2
#> 24:      ME   Male   International           178        89       50.0
#> 25:      ME   Male Native American             5         1       20.0
#> 26:      ME   Male   Other/Unknown            80        41       51.2
#> 27:      ME   Male           White          1596       955       59.8
#>     program    sex            race ever_enrolled graduates stickiness
#>      <char> <char>          <char>         <int>     <int>      <num>
#>                     people
#>                     <char>
#>  1:           Asian Female
#>  2:           Black Female
#>  3:        Hispanic Female
#>  4:   International Female
#>  5: Native American Female
#>  6:   Other/Unknown Female
#>  7:           White Female
#>  8:             Asian Male
#>  9:             Black Male
#> 10:          Hispanic Male
#> 11:     International Male
#> 12:   Native American Male
#> 13:     Other/Unknown Male
#> 14:             White Male
#> 15:           Asian Female
#> 16:           Black Female
#> 17:        Hispanic Female
#> 18:   International Female
#> 19:   Other/Unknown Female
#> 20:           White Female
#> 21:             Asian Male
#> 22:             Black Male
#> 23:          Hispanic Male
#> 24:     International Male
#> 25:   Native American Male
#> 26:     Other/Unknown Male
#> 27:             White Male
#>                     people
#>                     <char>
dframe[, c("race", "sex") := NULL]
#>     program ever_enrolled graduates stickiness                 people
#>      <char>         <int>     <int>      <num>                 <char>
#>  1:      EE            21        12       57.1           Asian Female
#>  2:      EE             6         3       50.0           Black Female
#>  3:      EE             8         3       37.5        Hispanic Female
#>  4:      EE            28         9       32.1   International Female
#>  5:      EE             1         0        0.0 Native American Female
#>  6:      EE             7         3       42.9   Other/Unknown Female
#>  7:      EE           118        56       47.5           White Female
#>  8:      EE           123        71       57.7             Asian Male
#>  9:      EE            29        17       58.6             Black Male
#> 10:      EE            45        17       37.8          Hispanic Male
#> 11:      EE           195        90       46.2     International Male
#> 12:      EE             3         0        0.0   Native American Male
#> 13:      EE            42        16       38.1     Other/Unknown Male
#> 14:      EE           864       439       50.8             White Male
#> 15:      ME             7         1       14.3           Asian Female
#> 16:      ME             3         2       66.7           Black Female
#> 17:      ME            12         8       66.7        Hispanic Female
#> 18:      ME            19        11       57.9   International Female
#> 19:      ME             8         4       50.0   Other/Unknown Female
#> 20:      ME           213       134       62.9           White Female
#> 21:      ME            76        49       64.5             Asian Male
#> 22:      ME            30        19       63.3             Black Male
#> 23:      ME            79        42       53.2          Hispanic Male
#> 24:      ME           178        89       50.0     International Male
#> 25:      ME             5         1       20.0   Native American Male
#> 26:      ME            80        41       51.2     Other/Unknown Male
#> 27:      ME          1596       955       59.8             White Male
#>     program ever_enrolled graduates stickiness                 people
#>      <char>         <int>     <int>      <num>                 <char>
data.table::setcolorder(dframe, c("program", "people"))

# Class before ordering
class(dframe$program)
#> [1] "character"
class(dframe$people)
#> [1] "character"

# Class and levels after ordering
mw1 <- order_multiway(dframe, 
                      quantity = "stickiness", 
                      categories = c("program", "people"))
class(mw1$program)
#> [1] "factor"
levels(mw1$program)
#> [1] "EE" "ME"
class(mw1$people)
#> [1] "factor"
levels(mw1$people)
#>  [1] "Native American Female" "Native American Male"   "Asian Female"          
#>  [4] "Other/Unknown Male"     "International Female"   "Hispanic Male"         
#>  [7] "Other/Unknown Female"   "International Male"     "Hispanic Female"       
#> [10] "White Female"           "White Male"             "Black Female"          
#> [13] "Black Male"             "Asian Male"            

# Display category medians 
mw1
#>     program                 people stickiness ever_enrolled graduates
#>      <fctr>                 <fctr>      <num>         <int>     <int>
#>  1:      EE           Asian Female       57.1            21        12
#>  2:      EE           Black Female       50.0             6         3
#>  3:      EE        Hispanic Female       37.5             8         3
#>  4:      EE   International Female       32.1            28         9
#>  5:      EE Native American Female        0.0             1         0
#>  6:      EE   Other/Unknown Female       42.9             7         3
#>  7:      EE           White Female       47.5           118        56
#>  8:      EE             Asian Male       57.7           123        71
#>  9:      EE             Black Male       58.6            29        17
#> 10:      EE          Hispanic Male       37.8            45        17
#> 11:      EE     International Male       46.2           195        90
#> 12:      EE   Native American Male        0.0             3         0
#> 13:      EE     Other/Unknown Male       38.1            42        16
#> 14:      EE             White Male       50.8           864       439
#> 15:      ME           Asian Female       14.3             7         1
#> 16:      ME           Black Female       66.7             3         2
#> 17:      ME        Hispanic Female       66.7            12         8
#> 18:      ME   International Female       57.9            19        11
#> 19:      ME   Other/Unknown Female       50.0             8         4
#> 20:      ME           White Female       62.9           213       134
#> 21:      ME             Asian Male       64.5            76        49
#> 22:      ME             Black Male       63.3            30        19
#> 23:      ME          Hispanic Male       53.2            79        42
#> 24:      ME     International Male       50.0           178        89
#> 25:      ME   Native American Male       20.0             5         1
#> 26:      ME     Other/Unknown Male       51.2            80        41
#> 27:      ME             White Male       59.8          1596       955
#>     program                 people stickiness ever_enrolled graduates
#>      <fctr>                 <fctr>      <num>         <int>     <int>
#>     program_median people_median
#>              <num>         <num>
#>  1:          44.55         35.70
#>  2:          44.55         58.35
#>  3:          44.55         52.10
#>  4:          44.55         45.00
#>  5:          44.55          0.00
#>  6:          44.55         46.45
#>  7:          44.55         55.20
#>  8:          44.55         61.10
#>  9:          44.55         60.95
#> 10:          44.55         45.50
#> 11:          44.55         48.10
#> 12:          44.55         10.00
#> 13:          44.55         44.65
#> 14:          44.55         55.30
#> 15:          57.90         35.70
#> 16:          57.90         58.35
#> 17:          57.90         52.10
#> 18:          57.90         45.00
#> 19:          57.90         46.45
#> 20:          57.90         55.20
#> 21:          57.90         61.10
#> 22:          57.90         60.95
#> 23:          57.90         45.50
#> 24:          57.90         48.10
#> 25:          57.90         10.00
#> 26:          57.90         44.65
#> 27:          57.90         55.30
#>     program_median people_median
#>              <num>         <num>

# Existing factors (if any) are re-ordered
mw2 <- dframe
mw2$program <- factor(mw2$program, levels = c("ME", "EE"))

# Levels before conditioning
levels(mw2$program) 
#> [1] "ME" "EE"

# Levels after conditioning
mw2 <- order_multiway(dframe, 
                      quantity = "stickiness", 
                      categories = c("program", "people"))
levels(mw2$program) 
#> [1] "EE" "ME"

# Ordering using percent method
order_multiway(dframe, 
               quantity = "stickiness", 
               categories = c("program", "people"), 
               method = "percent", 
               ratio_of = c("graduates", "ever_enrolled"))
#>     program                 people graduates ever_enrolled stickiness
#>      <fctr>                 <fctr>     <num>         <num>      <num>
#>  1:      EE           Asian Female        12            21       57.1
#>  2:      EE           Black Female         3             6       50.0
#>  3:      EE        Hispanic Female         3             8       37.5
#>  4:      EE   International Female         9            28       32.1
#>  5:      EE Native American Female         0             1        0.0
#>  6:      EE   Other/Unknown Female         3             7       42.9
#>  7:      EE           White Female        56           118       47.5
#>  8:      EE             Asian Male        71           123       57.7
#>  9:      EE             Black Male        17            29       58.6
#> 10:      EE          Hispanic Male        17            45       37.8
#> 11:      EE     International Male        90           195       46.2
#> 12:      EE   Native American Male         0             3        0.0
#> 13:      EE     Other/Unknown Male        16            42       38.1
#> 14:      EE             White Male       439           864       50.8
#> 15:      ME           Asian Female         1             7       14.3
#> 16:      ME           Black Female         2             3       66.7
#> 17:      ME        Hispanic Female         8            12       66.7
#> 18:      ME   International Female        11            19       57.9
#> 19:      ME   Other/Unknown Female         4             8       50.0
#> 20:      ME           White Female       134           213       62.9
#> 21:      ME             Asian Male        49            76       64.5
#> 22:      ME             Black Male        19            30       63.3
#> 23:      ME          Hispanic Male        42            79       53.2
#> 24:      ME     International Male        89           178       50.0
#> 25:      ME   Native American Male         1             5       20.0
#> 26:      ME     Other/Unknown Male        41            80       51.2
#> 27:      ME             White Male       955          1596       59.8
#>     program                 people graduates ever_enrolled stickiness
#>      <fctr>                 <fctr>     <num>         <num>      <num>
#>     program_stickiness people_stickiness
#>                  <num>             <num>
#>  1:               49.4              46.4
#>  2:               49.4              55.6
#>  3:               49.4              55.0
#>  4:               49.4              42.6
#>  5:               49.4               0.0
#>  6:               49.4              46.7
#>  7:               49.4              57.4
#>  8:               49.4              60.3
#>  9:               49.4              61.0
#> 10:               49.4              47.6
#> 11:               49.4              48.0
#> 12:               49.4              12.5
#> 13:               49.4              46.7
#> 14:               49.4              56.7
#> 15:               58.8              46.4
#> 16:               58.8              55.6
#> 17:               58.8              55.0
#> 18:               58.8              42.6
#> 19:               58.8              46.7
#> 20:               58.8              57.4
#> 21:               58.8              60.3
#> 22:               58.8              61.0
#> 23:               58.8              47.6
#> 24:               58.8              48.0
#> 25:               58.8              12.5
#> 26:               58.8              46.7
#> 27:               58.8              56.7
#>     program_stickiness people_stickiness
#>                  <num>             <num>
```
