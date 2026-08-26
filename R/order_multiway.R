# See R/roxygen.R for documentation below that uses inline R code

#' Order multiway categories
#'
#' Condition data for Cleveland multiway charts. Two independent categorical
#' variables are converted to factors with their levels ordered by the
#' single quantitative response variable.
#'
#' Multiway data comprise a single quantitative value (or response) for
#' every combination of levels of two categorical variables. The ordering of
#' the rows and panels, based on the response quantity, is crucial to the
#' perception of effects (Cleveland, 1993).
#'
#' Multiway data comprise three variables: a categorical variable of
#' \eqn{\small m} levels; a second independent categorical variable of
#' \eqn{\small n} levels; and a quantitative variable (or _response_) of
#' length \eqn{\small m \times n} that cross-classifies the categories,
#' that is, there is a value of the response for each combination of levels
#' of the two categorical variables. If a response value is missing, it is
#' assumed that a response for every combination is at least feasible.
#'
#' In a multiway dot plot, one category is encoded by the panels, the second
#' category is encoded by the rows of each panel, and the quantitative variable
#' is encoded along identical horizontal scales.
#'
#' @param dframe `r dframe` with the following required variables: two
#'        independent categorical variables, one quantitative response
#'        variable, and, if `method = percent`, its dividend and divisor
#'        variables.
#' @param quantity Character. Name of the single multiway quantitative
#'        variable.
#' @param categories Character. Vector of names of the two multiway
#'        categorical variables, in any order.
#' @param ... `r param_dots`
#' @param method Character. Method of ordering the levels of the categories;
#'        possible values are “median” (default) or “percent”. The median
#'        method determines medians of the quantitative column grouped by
#'        category. The percent method sums dividends and divisors by category
#'        and calculates their quotients by category.
#' @param ratio_of Character. Vector of column names of the dividend
#'        and the divisor that produced the quantitative variable. Names
#'        must be in order, as in `c(dividend, divisor).` Required
#'        when `method = "percent,"` ignored otherwise.
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * Row order is preserved. Duplicated rows are removed.
#' * Column specified by `quantity` is converted to type double.
#'   Columns specified by `categories` are converted to factors and ordered.
#' * Columns with names different from the two new columns (named below) are not
#'   modified; columns with matching names are replaced. The two new column
#'   names have the form:
#'   - `CATEGORY_1_LABEL`
#'   - `CATEGORY_2_LABEL`
#'
#' The `CATEGORY` placeholder in the new column names is replaced with the
#' column names from `categories.` The `LABEL` placeholder depends on the method.
#' For `method = median`, the label is `median`. For `method = percent`, the
#' label is `metric,` indicating that the metric in percent has been
#' recalculated for the entire category. For example, if
#' `categories = c("program", "people")` and `method = "median",` the new
#'  column names would be `program_median` and `people_median.`
#'  For `method = "percent",` the new column names would be `program_metric`
#'  and `people_metric.`
#' @references
#'   Cleveland WS (1993). \emph{Visualizing Data}. Hobart Press, Summit, NJ.
#' @example man/examples/exa_order_multiway.R
#' @export
#'
order_multiway <- function(dframe,
                           quantity,
                           categories,
                           ...,
                           method = NULL,
                           ratio_of = NULL) {
  #
  # ---------- initial assertions
  
  # data frames
  qassert(dframe, "d+")

  # arguments after ... must be named
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    "Arguments after ... must be named, as in arg = val."
  )
  
  # ---------- declarations

  # optional variable defaults
  method <- method %?% "median"

  # bind names for R CMD check
  CATEGORY <- NULL
  DEN <- NULL
  IDX <- NULL
  NUM <- NULL
  METHOD_ORDER <- NULL
  QUANTITY <- NULL

  # ---------- variable assertions

  # class of required arguments
  qassert(quantity, "S1") # string, length 1, missing prohibited
  qassert(categories, "S2") # string, length 2, missing prohibited

  # required columns exist
  assert_names(colnames(dframe), must.include = c(quantity, categories))

  # class of column values
  phi <- function(x) {
    assert_subset(class(x),
      choices = c("character", "factor"),
      empty.ok = FALSE,
      .var.name = "categories"
    )
  }
  phi(dframe[[categories[1]]])
  phi(dframe[[categories[2]]])
  qassert(dframe[[quantity]], "n+") # numeric, length 1 or more

  # method class, string, length 1, missing prohibited
  qassert(method, "S1")
  assert_subset(
    method,
    choices = c("median", "percent"),
    empty.ok = FALSE,
    .var.name = "method"
  )

  # percent method requires dividend and divisor columns
  if (method == "percent") {
    qassert(ratio_of, "S2") # string, length 2, missing prohibited
    assert_subset( # the two column names are present
      ratio_of,
      choices = colnames(dframe),
      empty.ok = FALSE,
      .var.name = "ratio_of"
    )
    psi <- function(x) { # the two columns are numeric
      assert_subset(
        class(x),
        choices = c("numeric", "double", "integer"),
        empty.ok = FALSE,
        .var.name = "ratio_of"
      )
    }
    psi(dframe[[ratio_of[1]]])
    psi(dframe[[ratio_of[2]]])
  }

  # ---------- preparation

  # to restore class except grouped tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)

  # convert class for analysis
  setDT(dframe)
  
  # prevent overwriting by temporary columns
  temp_vars <- c("idx")
  temp_vars <- utils_edit_colnames(dframe, temp_vars)
  idx <- temp_vars[1]

  # for restoring row order
  dframe[, IDX := .I, env = list(IDX = idx)]

  # ---------- do the work
  
  # convert categories to factors
  dframe[, (categories) := lapply(.SD, as.factor), .SDcols = categories]

  # ensure numerical values are double
  if (method == "percent") {
    dframe[, (ratio_of) := lapply(.SD, as.double), .SDcols = ratio_of]
  }
  dframe[, (quantity) := lapply(.SD, as.double), .SDcols = quantity]

  # new column names for ordering the factor levels
  method_label <- fifelse(method == "percent", "metric", "median")
  method_order <- paste(categories, method_label, sep = "_")

  # functions for creating the new ordering columns
  f_percent <- function(x, y) {
    round(100 * sum(x, na.rm = TRUE) / sum(y, na.rm = TRUE), 1)
  }
  f_median <- function(x) {
    median(x, na.rm = TRUE)
  }

  # create the ordering columns and order the factor levels by category
  for (jj in seq_along(categories)) {
    # apply functions to create ordering columns
    dframe[, METHOD_ORDER := fcase(
      method == "percent", f_percent(NUM, DEN),
      method == "median", f_median(QUANTITY),
      default = f_median(QUANTITY)
    ),
    by = CATEGORY,
    env = list(
      METHOD_ORDER = method_order[jj],
      CATEGORY = categories[jj],
      NUM = ratio_of[1],
      DEN = ratio_of[2],
      QUANTITY = quantity
    )
    ]
    # order the factor levels
    dframe[, CATEGORY := reorder(CATEGORY, METHOD_ORDER),
      env = list(
        METHOD_ORDER = method_order[jj],
        CATEGORY = categories[jj]
      )
    ]
  }

  # ---------- prepare to return
  # restore row and column order, select return columns, restore class
  dframe <- utils_prepare_return(dframe,
    idx,
    returned_vars = NULL,
    prior_class
  )
  
  # done
  dframe[]
}
