

#' Condition multiway data for graphing
#'
#' Transform a data frame such that two categorical variables are factors
#' with levels ordered for display in a Cleveland "multiway dot plot," where
#' the ordering of the panels and rows are crucial to the perception of
#' effects. In multiway data---as defined by
#' \insertCite{Cleveland:1993;textual}{midfieldr}---there is a single
#' quantitative value (or response) for every combination of levels
#' of two categorical variables. Typically the quantitative column is used to
#' order the levels of the two categorical columns.
#'
#' In the multiway dot plot, there are panels, the individual dot plots
#' of the display, and there are levels, the rows of each panel. One category
#' is encoded by the panels; the other by the rows. All panels have the same
#' quantitative scale on the x-axis and the same organization of category
#' levels on the y-axis. Panels and rows are ordered so that ordering scheme
#' increases in "graph order", that is, increases from left to right and from
#' bottom to top.
#'
#' Note that "multiway" in our context refers to the data structure and graph
#' design defined by Cleveland, not to the methods of analysis described by
#' \insertCite{Kroonenberg:2008;textual}{midfieldr}.
#'
#'
#' @param dframe Data frame with at least three columns: two categorical
#'        variables (columns can be character or factor) and one quantitative
#'        response variable (column must be numeric).
#' @param categ_col Character vector with the names (in quotes) of the two
#'        categorical columns.
#' @param quant_col Character scalar with the name (in quotes) of the
#'        quantitative response column.
#' @param ... Not used, forces later arguments to be used by name.
#' @param detail Optional flag to retain the columns created to implement the
#'        ordering scheme, default FALSE. When TRUE, the extra columns are
#'        useful for graphing vertical reference lines---indicating, for
#'        instance, the panel median, mean, or total count---to visualize the
#'        quantity by which the panels are ordered.
#' @param order_by Optional character scalar (in quotes) assigning the
#'        method for ordering the levels of the categorical variables.
#'        The following values are possible:
#'        \itemize{
#'
#'        \item{"median"} {(default) Orders by the median of values in the
#'        quantitative column grouped by category.}
#'
#'        \item{"mean"} {Orders by the mean of values in the quantitative
#'        column grouped by category.}
#'
#'        \item{"sum"} {Orders by the sum of values in the quantitative
#'        column grouped by category. Useful when the quantitative variable
#'        is a count or frequency.}
#'
#'        \item{"percent"} {Orders by ratios computed by category. Used when
#'        the quantitative response variable is the ratio (in percent) of two
#'        columns of integer counts (frequencies). The counts are summed by
#'        category to obtain grouped percentages used to order the levels of
#'        the categorical variables. Requires two parameter columns be
#'        identified in \code{param_col} and assumes that the parameter with
#'        the larger column sum is the denominator of the ratio.}
#'
#'        \item{"alphabet"} {Orders the levels of the categorical variables
#'        alphabetically. Rarely useful for perceiving effects, but can be
#'        useful for value look up.}
#'
#'        }
#' @param param_col Optional character vector with the names (in quotes)
#'        of the columns used as parameters in the \code{order_by} method.
#'        Currently supports \code{"percent"} method only---expects two column
#'        names (in any order) of the integer count columns used to construct
#'        the percentage response column.
#'
#'
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'   \item Rows are not modified.
#'   \item The quantitative column is not modified.
#'   \item The two categorical columns are factors with levels ordered by
#'         the method selected. Optionally, the additional columns (if any)
#'         created to implement the ordering scheme can be retained.
#'   \item Grouping structures are not preserved.
#' }
#'
#'
#' @references
#'   \insertAllCited{}
#'
#'
#' @family condition_*
#'
#'
#' @export
#'
#'
condition_multiway <- function(dframe,
                               categ_col,
                               quant_col,
                               ...,
                               detail = NULL,
                               order_by = NULL,
                               param_col = NULL) {
  on.exit(setkey(DT, NULL), add = TRUE)

  # assert arguments after dots used by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    paste(
      "Arguments after ... must be named.\n",
      "* Did you forget to write `detail = `\n",
      "* or `order_by = ` or `param_col = ` ?\n"
    )
  )

  # required data frame(s)
  qassert(dframe, "d+") # data frame, missing values OK, length 1 or more
  DT <- copy(dframe)
  setDT(DT)

  # required columns
  assert_names(colnames(DT), must.include = c(categ_col, quant_col))

  # class of required columns
  qassert(DT[[quant_col]], "n+") # numeric, length 1 or more

  col_class <- DT[, categ_col, with = FALSE]
  col_class <- unlist(lapply(col_class, class))
  assert_subset(
    col_class,
    choices = c("character", "factor"),
    empty.ok = FALSE,
    .var.name = "categ_col"
  )

  # other required arguments
  qassert(categ_col, "S2") # string, missing values prohibited, length 2
  qassert(quant_col, "S1") # string, missing values prohibited, length 1

  # optional arguments
  detail <- detail %?% FALSE
  qassert(detail, "B1") # boolean, missing values prohibited, length 1

  order_by <- order_by %?% "median"
  qassert(order_by, "S1")
  assert_subset(
    order_by,
    choices = c("median", "mean", "sum", "percent", "alphabet"),
    empty.ok = FALSE,
    .var.name = "order_by"
  )

  if (order_by == "percent") {
    qassert(param_col, "S2")
    assert_subset(
      param_col,
      choices = names(DT),
      empty.ok = FALSE,
      .var.name = "param_col"
    )
    # columns must be numeric
    col_class <- DT[, param_col, with = FALSE]
    col_class <- unlist(lapply(col_class, class))
    checkmate::assert_subset(
      col_class,
      choices = c("numeric", "double", "integer"),
      empty.ok = FALSE,
      .var.name = "param_col"
    )
  } else {
    if (!is.null(param_col)) {
      warning("Unused argument 'param_col'.")
    }
  }

  # do the work
  # column names to return if detail = FALSE
  original_columns <- names(DT)

  # all methods treat categories as factors
  DT[, (categ_col) := lapply(.SD, as.factor), .SDcols = categ_col]

  # multiway must have two and only two categories
  categ_1 <- categ_col[[1]]
  categ_2 <- categ_col[[2]]

  if (order_by == "alphabet") {

    # alphabetical order returns categories as factors with levels
    # ordered in reverse alphabetical order such that the graph rows and
    # panels are in alphabetical order from the top down
    DT <- order_by_alphabet(
      DT,
      categ_1,
      categ_2
    )

    # organize the return column order
    setcolorder(DT, c(categ_col, quant_col))
  } else if (order_by == "percent") {

    # percent-based metrics, e.g., stickiness or graduation rate
    # returns categories as factors with levels ordered by the metric
    DT <- order_by_percent(
      DT,
      categ_col,
      quant_col,
      param_col
    )

    # organize the return column order
    setcolorder(DT, c(categ_col, param_col, quant_col))
  } else { # order_by = c("sum", "mean", "median")

    # function-based ordering returns categories as factors with levels
    # ordered by category sum(), mean(), or median()
    DT <- order_by_function(
      DT,
      categ_1,
      categ_2,
      quant_col,
      order_by
    )

    # organize the return column order
    setcolorder(DT, c(categ_col, quant_col))
  }
  if (!detail) {
    DT <- DT[, original_columns, with = FALSE]
  }
  DT[]
}
# --------------------------------------------------------------------------
# internal functions
# --------------------------------------------------------------------------
order_by_percent <- function(dframe,
                             categ_col,
                             quant_col,
                             param_col) {

  # avoid possible copy-by-reference side effects
  DT <- copy(dframe)

  # bind names due to NSE notes in R CMD check
  A <- NULL
  B <- NULL
  CATEG_I <- NULL
  COUNT_I <- NULL
  NEW_COL <- NULL

  # replace NA in count columns with zero
  DT[, (param_col) := lapply(.SD, function(x) {
    fifelse(is.na(x), 0, x)
  }), .SDcols = param_col]

  # sum the two counts by the individual categories
  # provides columns needed to determine row and panel order
  for (categ_i in categ_col) {
    for (count_i in param_col) {
      # execute expressions with column names as parameters
      wrapr::let(
        c(COUNT_I = count_i),
        {
          new_col <- paste(categ_i, count_i, sep = "_")
          DT[, (new_col) := sum(COUNT_I), by = categ_i]
        }
      )
    }
  }

  # Determine the names of the columns used as the numerator and
  # denominator of the percent. Assumes the smaller number is the numerator,
  # e.g., grad / ever or grad / start. Always more starters or ever-enrolled
  # overall (summing across all programs) than grads.
  count_col_totals <- colSums(DT[, param_col, with = FALSE])
  count_col_min <- names(which.min(count_col_totals))
  count_col_max <- names(which.max(count_col_totals))

  # computing the metric for individual categories
  # used for ordering rows and panels
  for (categ_i in categ_col) {

    # names of new columns, numerator and denominator of
    # category summary metric
    a <- paste(categ_i, count_col_min, sep = "_")
    b <- paste(categ_i, count_col_max, sep = "_")
    new_col <- paste(categ_i, quant_col, sep = "_")

    # execute expressions with column names as parameters
    wrapr::let(
      c(
        A = a,
        B = b,
        CATEG_I = categ_i,
        NEW_COL = new_col
      ),
      {
        # percent-based metric by individual category
        DT[, NEW_COL := round(100 * A / B, 1)]

        # order factor levels by values in new column
        DT[, CATEG_I := reorder(CATEG_I, NEW_COL)]
      }
    )
  }
  DT[]
}
# --------------------------------------------------------------------------
order_by_alphabet <- function(dframe,
                              categ_1,
                              categ_2) {

  # avoid possible copy-by-reference side effects
  DT <- copy(dframe)

  # bind names due to NSE notes in R CMD check
  CATEG_1 <- NULL
  CATEG_2 <- NULL

  # execute expressions with column names as parameters
  wrapr::let(
    c(
      CATEG_1 = categ_1,
      CATEG_2 = categ_2
    ),
    {
      temp <- DT[, CATEG_1]
      DT[, CATEG_1 := factor(
        temp,
        levels = sort((levels(temp)), decreasing = TRUE)
      )]
      temp <- DT[, CATEG_2]
      DT[, CATEG_2 := factor(
        temp,
        levels = sort((levels(temp)), decreasing = TRUE)
      )]
    }
  )
  DT[]
}
# --------------------------------------------------------------------------
order_by_function <- function(dframe,
                              categ_1,
                              categ_2,
                              quant_col,
                              order_by) {

  # avoid possible copy-by-reference side effects
  DT <- copy(dframe)

  # bind names due to NSE notes in R CMD check
  CATEG_1 <- NULL
  CATEG_2 <- NULL
  ORDER_1 <- NULL
  ORDER_2 <- NULL
  QUANT_COL <- NULL

  # create names for value variables
  order_1 <- paste(categ_1, quant_col, sep = "_")
  order_2 <- paste(categ_2, quant_col, sep = "_")

  # select function to apply
  if (order_by == "sum") {
    f <- sum
  }
  if (order_by == "median") {
    f <- stats::median
  }
  if (order_by == "mean") {
    f <- mean
  }

  # execute expressions with column names as parameters
  wrapr::let(
    c(
      CATEG_1 = categ_1,
      CATEG_2 = categ_2,
      ORDER_1 = order_1,
      ORDER_2 = order_2,
      QUANT_COL = quant_col
    ),
    {
      DT[, ORDER_1 := f(QUANT_COL, na.rm = TRUE), by = CATEG_1]
      DT[, ORDER_2 := f(QUANT_COL, na.rm = TRUE), by = CATEG_2]
      DT[, CATEG_1 := reorder(CATEG_1, ORDER_1)]
      DT[, CATEG_2 := reorder(CATEG_2, ORDER_2)]
    }
  )
  DT[]
}
