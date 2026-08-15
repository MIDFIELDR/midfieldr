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
#'
#' @param quantity Character. Name of the single multiway quantitative
#'        variable.
#'
#' @param categories Character. Vector of names of the two multiway
#'        categorical variables, in any order.
#'
#' @param ... `r param_dots`
#'
#' @param method Character. Method of ordering the levels of the categories;
#'        possible values are “median” (default) or “percent”. The median
#'        method determines medians of the quantitative column grouped by
#'        category. The percent method sums dividends and divisors by category
#'        and calculates their quotients by category.
#'
#' @param ratio_of Character. Vector of column names of the dividend
#'        and the divisor that produced the quantitative variable. Names
#'        must be in order, as in `c(dividend, divisor).` Required
#'        when `method = "percent,"` ignored otherwise.
#'
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * Row order is preserved. Duplicated rows are removed.
#' * Column specified by `quantity` is converted to type double.
#'   Columns specified by `categories` are converted to factors and ordered.
#' * Columns with names different from the two new columns (named below) are not
#'   modified; columns with matching names are replaced. The two new column 
#'   names have the form: 
#'   - `CATEGORY_1_method_abbr` 
#'   - `CATEGORY_2_method_abbr`
#'   - For example, if 
#'   `categories = c("program", "people")` and `method = "median",` the new 
#'   column names would be `program_med` and `people_med.` 
#'   For `method = "percent",` the new column names would be `program_pct` 
#'   and `people_pct.`
#'
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
  # ---------- base R checks (all data frame classes)
  
  # arguments after ... must be named
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    "Arguments after ... must be named, as in arg = val."
  )
  
  # required data frame(s) and required columns
  qassert(dframe, "d+") # data frame, missing values OK, length 1 or more
  assert_names(colnames(dframe), must.include = c(quantity, categories))
  
  # required arguments
  qassert(quantity, "S1") # string, missing values prohibited, length 1
  qassert(categories, "S2") # string, missing values prohibited, length 2
  
  # class of required columns
  qassert(dframe[[quantity]], "n+") # numeric, length 1 or more
  
  # categories class factor or character
  x <- copy(dframe)
  one_row_df <- as.data.frame(x)[1, categories, drop = FALSE]
  col_class <- unlist(lapply(one_row_df, class))
  assert_subset(
    col_class,
    choices = c("character", "factor"),
    empty.ok = FALSE,
    .var.name = "categories"
  )
  
  # optional arguments
  method <- method %?% "median"
  qassert(method, "S1")
  assert_subset(
    method,
    choices = c("median", "percent"),
    empty.ok = FALSE,
    .var.name = "method"
  )
  
  if (method == "percent") {
    qassert(ratio_of, "S2")
    assert_subset(
      ratio_of,
      choices = colnames(dframe),
      empty.ok = FALSE,
      .var.name = "ratio_of"
    )
    # columns must be numeric
    x <- copy(dframe)
    one_row_df <- as.data.frame(x)[1, ratio_of, drop = FALSE]
    col_class <- unlist(lapply(one_row_df, class))
    checkmate::assert_subset(
      col_class,
      choices = c("numeric", "double", "integer"),
      empty.ok = FALSE,
      .var.name = "ratio_of"
    )
  } else {
    if (!is.null(ratio_of)) {
      warning("Argument 'ratio_of' is not used when `method = median.`")
    }
  }
  
  # ---------- preparation
  
  # to restore class except grouped tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")
  
  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  setDT(dframe)
  
  # avoid overwriting columns that match names of temporary columns
  init_temp_vars <- c("idx")
  temp_vars <- edit_new_col_names(dframe, init_temp_vars)
  idx_chr <- temp_vars[1]
  
  ### protect overwriting by temp col names
  
  # bind names due to NSE notes in R CMD check
  CATEGORY <- NULL
  DEN <- NULL
  IDX <- NULL
  NUM <- NULL
  ORDER_COL <- NULL
  QUANTITY <- NULL
  
  # ---------- do the work
  
  # add temp col to restore row order
  dframe[, IDX := .I,
         env = list(IDX = idx_chr)
  ]
  
  # convert categories to factors
  dframe[, (categories) := lapply(.SD, as.factor), .SDcols = categories]
  
  # ensure numerical values are double
  if (method == "percent") {
    dframe[, (ratio_of) := lapply(.SD, as.double), .SDcols = ratio_of]
  }
  dframe[, (quantity) := lapply(.SD, as.double), .SDcols = quantity]
  
  # column names for ordering the factor levels
  col_label <- fifelse (method == "percent", "pct", "med")
  order_col <- paste(categories, col_label, sep = "_")
  
  # functions for creating the ordering columns
  f_percent <- function(x, y) {
    round(100 * sum(x, na.rm = TRUE) / sum(y, na.rm = TRUE), 1)
  }
  f_median <- function(x) {
    median(x, na.rm = TRUE)
  }
  
  # create the ordering columns and order the factor levels by category
  for (jj in seq_along(categories)) {
    
    # apply functions to create ordering columns
    dframe[, ORDER_COL := fcase(
      method == "percent", f_percent(NUM, DEN),
      method == "median", f_median(QUANTITY),
      default = f_median(QUANTITY)
    ),
    by = CATEGORY,
    env = list(
      ORDER_COL = order_col[jj],
      QUANTITY = quantity,
      CATEGORY = categories[jj],
      NUM = ratio_of[1],
      DEN = ratio_of[2]
    )
    ]
    
    # order the factor levels
    dframe[, CATEGORY := reorder(CATEGORY, ORDER_COL),
           env = list(
             CATEGORY = categories[jj],
             ORDER_COL = order_col[jj]
           )
    ]
  }
  
  # ---------- prepare to return
  
  # restore row order
  setkeyv(dframe, idx_chr)
  
  # drop temporary cols
  dframe[, IDX := NULL,
         env = list(IDX = idx_chr)
  ]
  
  # ensure unique rows
  dframe <- unique(dframe)
  
  # restore class
  setattr(dframe, "class", prior_class)
  
  # done
  dframe[]
}
