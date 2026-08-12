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
#'        categorical variables.
#'
#' @param ... `r param_dots`
#'
#' @param method Character. Method of ordering the levels of the categories;
#'        possible values are “median” (default) or “percent”. The median
#'        method determines medians of the quantitative column grouped by
#'        category. The percent method sums dividends and divisors by category
#'        and calculates their quotients (again, by category).
#'
#' @param ratio_of Character. Vector of names of the dividend and the divisor
#'        that produced the quantitative variable. Required when
#'        `method = "percent,"` ignored otherwise. Names can be in any order;
#'        the algorithm assumes that the parameter with the larger column sum
#'        is the denominator of the ratio.
#'
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * Row order is preserved. Duplicated rows are removed.
#' * Column specified by `quantity` is converted to type double.
#'   Columns specified by `categories` are converted to factors and ordered.
#' * Columns with names different from the two new columns (named below) are not
#'   modified; columns with matching names are replaced. The new column names,
#'   depending on the method, have the following forms:
#'   - `CATEGORY_median` for the "median" method. For example, if
#'     `categories = c("program", "people"),` the new column names would be
#'     `program_median` and `people_median.`
#'   - `CATEGORY_QUANTITY` for the "percent" method. For example, using the
#'      same categories as above with `quantity = "grad_rate",`  new column
#'      names would be `program_grad_rate` and `people_grad_rate.`
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

  # bind names due to NSE notes in R CMD check
  IDX <- NULL

  # ---------- do the work

  # add temp col to restore row order
  dframe[, IDX := .I,
    env = list(IDX = idx_chr)
  ]

  # treatment the same both methods
  dframe[, (categories) := lapply(.SD, as.factor), .SDcols = categories]
  dframe[, (quantity) := lapply(.SD, as.double), .SDcols = quantity]

  # call subroutine for percent or median method
  if (method == "percent") {
    dframe <- order_by_percent(
      dframe,
      categories,
      quantity,
      ratio_of
    )
  } else { # method = "median"
    dframe <- order_by_median(
      dframe,
      categories,
      quantity,
      method
    )
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


# --------------------------------------------------------------------------
# internal functions
# --------------------------------------------------------------------------
order_by_percent <- function(dframe,
                             categories,
                             quantity,
                             ratio_of) {
  # bind names due to NSE notes in R CMD check
  A <- NULL
  B <- NULL
  CATEG_I <- NULL
  COUNT_I <- NULL
  NEW_COL <- NULL

  # replace NA in count columns with zero
  dframe[, (ratio_of) := lapply(.SD, function(quantity) {
    fifelse(is.na(quantity), 0, quantity)
  }), .SDcols = ratio_of]

  # ensure dividend and divisor are double, not integer
  dframe[, (ratio_of) := lapply(.SD, as.double), .SDcols = ratio_of]

  # sum the two counts by the individual categories
  # provides columns needed to determine row and panel order
  for (categ_i in categories) {
    for (count_i in ratio_of) {
      new_col <- paste(categ_i, count_i, sep = "_")
      dframe[, (new_col) := sum(COUNT_I),
        by = categ_i,
        env = list(COUNT_I = count_i)
      ]
    }
  }

  # Determine the names of the columns used as the numerator and
  # denominator of the ratio. Assumes the smaller number is the numerator,
  # e.g., grad / ever or grad / start. Always more starters or ever-enrolled
  # overall (summing across all programs) than grads.
  count_col_totals <- colSums(dframe[, ratio_of, with = FALSE])
  count_col_min <- names(which.min(count_col_totals))
  count_col_max <- names(which.max(count_col_totals))

  # computing the metric for individual categories
  # used for ordering rows and panels
  for (categ_i in categories) {
    #
    # names of new columns, numerator and denominator of
    # category summary metric
    a <- paste(categ_i, count_col_min, sep = "_")
    b <- paste(categ_i, count_col_max, sep = "_")
    new_col <- paste(categ_i, quantity, sep = "_")
    
    # percent-based metric by individual category
    dframe[, NEW_COL := round(100 * A / B, 1),
      env = list(
        A = a,
        B = b,
        NEW_COL = new_col
      )
    ]

    # order factor levels by values in new column
    dframe[, CATEG_I := reorder(CATEG_I, NEW_COL),
      env = list(
        CATEG_I = categ_i,
        NEW_COL = new_col
      )
    ]

    # drop temp columns
    dframe[, `:=`(A = NULL, B = NULL),
      env = list(A = a, B = b)
    ]
  }
  dframe[]
}

# --------------------------------------------------------------------------
order_by_median <- function(dframe,
                            categories,
                            quantity,
                            method) {
  #
  # bind names due to NSE notes in R CMD check
  CATEG_1 <- NULL # e.g., program
  CATEG_2 <- NULL # e.g., people
  ORDER_1 <- NULL # e.g., program_median
  ORDER_2 <- NULL # e.g., people_median
  QUANTITY <- NULL # e.g., grad_rate or stickiness

  # create names for value variables
  categ_1 <- categories[[1]]
  categ_2 <- categories[[2]]
  order_1 <- paste(categ_1, method, sep = "_")
  order_2 <- paste(categ_2, method, sep = "_")

  # add new columns
  dframe[, ORDER_1 := median(QUANTITY, na.rm = TRUE),
    by = CATEG_1,
    env = list(
      ORDER_1 = order_1,
      QUANTITY = quantity,
      CATEG_1 = categ_1
    )
  ]
  dframe[, ORDER_2 := median(QUANTITY, na.rm = TRUE),
    by = CATEG_2,
    env = list(
      ORDER_2 = order_2,
      QUANTITY = quantity,
      CATEG_2 = categ_2
    )
  ]
  dframe[, CATEG_1 := reorder(CATEG_1, ORDER_1),
    env = list(
      CATEG_1 = categ_1,
      ORDER_1 = order_1
    )
  ]
  dframe[, CATEG_2 := reorder(CATEG_2, ORDER_2),
    env = list(
      CATEG_2 = categ_2,
      ORDER_2 = order_2
    )
  ]

  dframe[]
}
