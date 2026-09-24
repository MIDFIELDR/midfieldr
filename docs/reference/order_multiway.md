# Order multiway categories

Conditions multiway data for Cleveland multiway charts. Two independent
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

- New columns are added unless they are redundant (see Details). The new
  columns, with capital letters denoting placeholders, have the form:

  - `CATEGORY_1_LABEL`

  - `CATEGORY_2_LABEL`

  The `CATEGORY` placeholder is replaced with the column names from
  `categories.` The `LABEL` placeholder depends on the method. For
  example, suppose `categories = c("program", "people").`For the
  `median` method, the new column names would be `program_median` and
  `people_median.` For the `percent` method, the new column names would
  be `program_metric` and `people_metric,` indicating that the metric
  had been calculated for each category independently.

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

*Redundant columns.* To prevent overwriting, a variable such as
`program_median` is not added to the data frame if it duplicates an
existing variable. The test for redundancy is managed internally by
calling
[`rm_redundant_cols()`](https://midfieldr.github.io/midfieldr/reference/rm_redundant_cols.md)
before the final data frame is returned. For documentation, see
[`?rm_redundant_cols`](https://midfieldr.github.io/midfieldr/reference/rm_redundant_cols.md).

## References

Cleveland WS (1993). *Visualizing Data*. Hobart Press, Summit, NJ.

## Examples

``` r
# Reconfigure built-in data set
DT <- case_results[grepl("^Elec|^Mech", program)]
DT <- DT[grepl("^Asian|^Black|^Hispanic|^White", people)]
DT
#>        program          people  ever  grad stick
#>         <char>          <char> <num> <num> <num>
#>  1: Electrical    Asian Female    21    12  57.1
#>  2: Electrical      Asian Male   122    71  58.2
#>  3: Electrical    Black Female     6     3  50.0
#>  4: Electrical      Black Male    29    17  58.6
#>  5: Electrical Hispanic Female     8     3  37.5
#>  6: Electrical   Hispanic Male    44    17  38.6
#>  7: Electrical    White Female   117    56  47.9
#>  8: Electrical      White Male   848   439  51.8
#>  9: Mechanical      Asian Male    77    49  63.6
#> 10: Mechanical    Black Female     3     2  66.7
#> 11: Mechanical      Black Male    29    19  65.5
#> 12: Mechanical Hispanic Female    12     8  66.7
#> 13: Mechanical   Hispanic Male    78    42  53.8
#> 14: Mechanical    White Female   213   134  62.9
#> 15: Mechanical      White Male  1587   952  60.0

# Order factor levels by median
DT1 <- data.table::copy(DT)
DT1 <- DT1[, c("ever", "grad") := NULL]
mw1 <- order_multiway(DT1, 
                      quantity = "stick", 
                      categories = c("program", "people"))
data.table::setorderv(mw1, c("program_median", "people_median"))
mw1
#>        program          people stick program_median people_median
#>         <fctr>          <fctr> <num>          <num>         <num>
#>  1: Electrical   Hispanic Male  38.6           50.9         46.20
#>  2: Electrical Hispanic Female  37.5           50.9         52.10
#>  3: Electrical    White Female  47.9           50.9         55.40
#>  4: Electrical      White Male  51.8           50.9         55.90
#>  5: Electrical    Asian Female  57.1           50.9         57.10
#>  6: Electrical    Black Female  50.0           50.9         58.35
#>  7: Electrical      Asian Male  58.2           50.9         60.90
#>  8: Electrical      Black Male  58.6           50.9         62.05
#>  9: Mechanical   Hispanic Male  53.8           63.6         46.20
#> 10: Mechanical Hispanic Female  66.7           63.6         52.10
#> 11: Mechanical    White Female  62.9           63.6         55.40
#> 12: Mechanical      White Male  60.0           63.6         55.90
#> 13: Mechanical    Black Female  66.7           63.6         58.35
#> 14: Mechanical      Asian Male  63.6           63.6         60.90
#> 15: Mechanical      Black Male  65.5           63.6         62.05

# Levels in increasing order
levels(mw1$program)
#> [1] "Electrical" "Mechanical"
levels(mw1$people)
#> [1] "Hispanic Male"   "Hispanic Female" "White Female"    "White Male"     
#> [5] "Asian Female"    "Black Female"    "Asian Male"      "Black Male"     

# No change if added columns are redundant
mw1a <- order_multiway(mw1, 
                       quantity = "stick", 
                       categories = c("program", "people"))
check_equiv_frames(mw1, mw1a)
#> [1] TRUE

# Retain the `ratio_of` variables and order by percentage
mw2 <- order_multiway(DT, 
                      quantity = "stick", 
                      categories = c("program", "people"), 
                      method = "percent", 
                      ratio_of = c("grad", "ever"))
data.table::setorderv(mw2, c("program_metric", "people_metric"))
mw2
#>        program          people  ever  grad stick program_metric people_metric
#>         <fctr>          <fctr> <num> <num> <num>          <num>         <num>
#>  1: Electrical   Hispanic Male    44    17  38.6           51.7          48.4
#>  2: Electrical Hispanic Female     8     3  37.5           51.7          55.0
#>  3: Electrical    Black Female     6     3  50.0           51.7          55.6
#>  4: Electrical    Asian Female    21    12  57.1           51.7          57.1
#>  5: Electrical      White Male   848   439  51.8           51.7          57.1
#>  6: Electrical    White Female   117    56  47.9           51.7          57.6
#>  7: Electrical      Asian Male   122    71  58.2           51.7          60.3
#>  8: Electrical      Black Male    29    17  58.6           51.7          62.1
#>  9: Mechanical   Hispanic Male    78    42  53.8           60.3          48.4
#> 10: Mechanical Hispanic Female    12     8  66.7           60.3          55.0
#> 11: Mechanical    Black Female     3     2  66.7           60.3          55.6
#> 12: Mechanical      White Male  1587   952  60.0           60.3          57.1
#> 13: Mechanical    White Female   213   134  62.9           60.3          57.6
#> 14: Mechanical      Asian Male    77    49  63.6           60.3          60.3
#> 15: Mechanical      Black Male    29    19  65.5           60.3          62.1

# Order of factor levels depends on the method. Here, for example, 
# program levels are the same for median and percent methods, 
all.equal(levels(mw1$program), levels(mw2$program))
#> [1] TRUE

# but people levels do not have the same order. 
all.equal(levels(mw1$people), levels(mw2$people))
#> [1] "4 string mismatches"
levels(mw1$people)
#> [1] "Hispanic Male"   "Hispanic Female" "White Female"    "White Male"     
#> [5] "Asian Female"    "Black Female"    "Asian Male"      "Black Male"     
levels(mw2$people)
#> [1] "Hispanic Male"   "Hispanic Female" "Black Female"    "Asian Female"   
#> [5] "White Male"      "White Female"    "Asian Male"      "Black Male"     
```
