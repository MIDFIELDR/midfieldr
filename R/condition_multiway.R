

#' Condition multiway data by ordering category levels
#'
#' Transform a data frame such that two independent categorical variables are 
#' factors with levels ordered for display in a multiway dot plot. Multiway 
#' data comprise a single quantitative value (or response) for every 
#' combination of levels of two categorical variables. The ordering of the 
#' rows and panels is crucial to the perception of effects (Cleveland, 1993). 
#' 
#' In our context, "multiway" refers to the data structure and graph
#' design defined by Cleveland (1993), not to the methods of analysis described 
#' by Kroonenberg (2008).
#' 
#' Multiway data comprise three variables: a categorical variable of \emph{m} 
#' levels; a second independent categorical variable of \emph{n} levels; and a 
#' quantitative variable (or \emph{response}) of length \emph{mn} that 
#' cross-classifies the categories, that is, there is a value of the 
#' response for each combination of levels of the two categorical variables.
#' 
#' In a multiway dot plot, one category is encoded by the panels, the second 
#' category is encoded by the rows of each panel, and the quantitative variable 
#' is encoded along identical horizontal scales.  
#'
#'
#'
#' @param dframe Data frame with one numeric variable and two 
#'        categorical variables of class character or factor. Two additional 
#'        numeric columns required when using the "percent" ordering method. 
#' @param x Character, name (in quotes) of the single multiway quantitative 
#'        variable
#' @param yy Character, vector of names (in quotes) of the two multiway 
#'        categorical variables
#' @param ... Not used, forces later arguments to be used by name.
#' @param order_by Character, “median” (default) or “percent”, method of 
#'        ordering the levels of the categories. The median method computes the 
#'        medians of the quantitative column grouped by category. The percent 
#'        method computes percentages based on the same ratio that produced the 
#'        quantitative variable except grouped by category. 
#' @param param_col Character vector with the names (in quotes) of the 
#'        numerator and denominator columns that produced the quantitative 
#'        variable, required when \code{order_by} is "percent". Names can be 
#'        in any order; the algorithm assumes that the parameter with the 
#'        larger column sum is the denominator of the ratio.
#'        
#' 
#' @return A \code{data.table}  with the following properties:
#' \itemize{
#'  \item Rows are not modified.
#'  \item Grouping structures are not preserved.
#'  \item The columns specified by \code{yy} are converted to factors and 
#'      ordered. Other columns are not modified. 
#'  \item Two columns are added. \strong{Caution!} An existing column 
#'  with the same name as one of the added columns is silently overwritten. 
#' }
#' Columns added:
#' \describe{
#'  \item{\code{Y_median} columns (when ordering method is "median")}{Numeric. 
#'      Two columns of medians of the quantitative variable grouped by the 
#'      categorical variables. The \code{Y} placeholder in the column name is 
#'      replaced by a category name from \code{yy}. For example, suppose  
#'      \code{yy = c("program", "people")} and \code{order_by = "median"}. 
#'      The two new column names would be \code{program_median} and 
#'      \code{people_median}.} 
#'      
#'  \item{\code{Y_X} columns (when ordering method is "percent")}{Numeric. Two 
#'      columns of percentages based on the same ratio that produces the 
#'      quantitative variable except grouped by the categorical variables. 
#'      The \code{Y}  
#'      placeholder in the column name is 
#'      replaced by a category name from \code{yy}; the \code{X}  placeholder 
#'      is replaced by the quantitative variable name in \code{x}. For example, 
#'      suppose \code{yy = c("program", "people")}, and \code{x = "grad_rate"}, 
#'      and \code{order_by = "percent"}. The two new column names  would be  
#'      \code{program_grad_rate} and \code{people_grad_rate}.} 
#'      
#' }
#' 
#' 
#' 
#' 
#'
#'
#' @references
#'   Cleveland WS (1993). \emph{Visualizing Data}. Hobart Press, Summit, NJ.
#'   
#'   Kroonenberg PM (2008). \emph{Applied Multiway Data Analysis}. Wiley, 
#'   Hoboken, NJ.
#'
#'
#' @family condition_*
#'
#'
#' @export
#'
#'
condition_multiway <- function(dframe,
                               x,
                               yy,
                               ...,
                               order_by = NULL,
                               param_col = NULL) {
  on.exit(setkey(DT, NULL), add = TRUE)

  # assert arguments after dots used by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    paste(
      "Arguments after ... must be named.\n",
      "* Did you forget to write `order_by = `\n",
      "* or `param_col = ` ?\n"
    )
  )

  # required data frame(s)
  qassert(dframe, "d+") # data frame, missing values OK, length 1 or more
  DT <- copy(dframe)
  setDT(DT)

  # required columns
  assert_names(colnames(DT), must.include = c(x, yy))

  # class of required columns
  qassert(DT[[x]], "n+") # numeric, length 1 or more

  col_class <- DT[, yy, with = FALSE]
  col_class <- unlist(lapply(col_class, class))
  assert_subset(
    col_class,
    choices = c("character", "factor"),
    empty.ok = FALSE,
    .var.name = "yy"
  )

  # other required arguments
  qassert(x, "S1") # string, missing values prohibited, length 1
  qassert(yy, "S2") # string, missing values prohibited, length 2

  # optional arguments
  order_by <- order_by %?% "median"
  qassert(order_by, "S1")
  assert_subset(
    order_by,
    # choices = c("median", "mean", "sum", "percent", "alphabet"),
    choices = c("median", "percent"), 
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

  # all methods treat categories as factors
  DT[, (yy) := lapply(.SD, as.factor), .SDcols = yy]

  # multiway must have two and only two categories
  categ_1 <- yy[[1]]
  categ_2 <- yy[[2]]

  # if (order_by == "alphabet") {
  # 
  #   # alphabetical order returns categories as factors with levels
  #   # ordered in reverse alphabetical order such that the graph rows and
  #   # panels are in alphabetical order from the top down
  #   DT <- order_by_alphabet(
  #     DT,
  #     categ_1,
  #     categ_2
  #   )
  # 
  #   # organize the return column order
  #   setcolorder(DT, c(yy, x))
  # } else 
      
if (order_by == "percent") {

    # percent-based metrics, e.g., stickiness or graduation rate
    # returns categories as factors with levels ordered by the metric
    DT <- order_by_percent(
      DT,
      yy,
      x,
      param_col
    )

    # organize the return column order
    setcolorder(DT, c(yy, param_col, x))
  } else { # order_by = "median"

    # function-based ordering returns categories as factors with levels
    # ordered by category median()
    DT <- order_by_function(
      DT,
      categ_1,
      categ_2,
      x,
      order_by
    )

    # organize the return column order
    setcolorder(DT, c(yy, x))
  }
  DT[]
}
# --------------------------------------------------------------------------
# internal functions
# --------------------------------------------------------------------------
order_by_percent <- function(dframe,
                             yy,
                             x,
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
  for (categ_i in yy) {
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
  for (categ_i in yy) {

    # names of new columns, numerator and denominator of
    # category summary metric
    a <- paste(categ_i, count_col_min, sep = "_")
    b <- paste(categ_i, count_col_max, sep = "_")
    new_col <- paste(categ_i, x, sep = "_")

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
        
        # drop A and B with the intermediate sums
        DT[, A := NULL]
        DT[, B := NULL]
      }
    )
  }
  DT[]
}
# --------------------------------------------------------------------------
# order_by_alphabet <- function(dframe,
#                               categ_1,
#                               categ_2) {
# 
#   # avoid possible copy-by-reference side effects
#   DT <- copy(dframe)
# 
#   # bind names due to NSE notes in R CMD check
#   CATEG_1 <- NULL
#   CATEG_2 <- NULL
# 
#   # execute expressions with column names as parameters
#   wrapr::let(
#     c(
#       CATEG_1 = categ_1,
#       CATEG_2 = categ_2
#     ),
#     {
#         setDT(DT)
#         DT[, CATEG_1 := as.character(CATEG_1)]
#         DT[, CATEG_2 := as.character(CATEG_2)]
#         setorder(DT, -CATEG_1, -CATEG_2)
#         DT[, CATEG_1 := as.factor(CATEG_1)]
#         DT[, CATEG_2 := as.factor(CATEG_2)]
#     }
#   )
#   DT[]
# }
# --------------------------------------------------------------------------
order_by_function <- function(dframe,
                              categ_1,
                              categ_2,
                              x,
                              order_by) {

  # avoid possible copy-by-reference side effects
  DT <- copy(dframe)

  # bind names due to NSE notes in R CMD check
  CATEG_1 <- NULL
  CATEG_2 <- NULL
  ORDER_1 <- NULL
  ORDER_2 <- NULL
  X <- NULL

  # select function to apply 
  if (order_by == "median") {
      f <- stats::median
  }
  # if (order_by == "sum") {
  #   f <- sum
  # }
  # if (order_by == "mean") {
  #   f <- mean
  # }

  # create names for value variables
  order_1 <- paste(categ_1, order_by, sep = "_")
  order_2 <- paste(categ_2, order_by, sep = "_")
  
  # execute expressions with column names as parameters
  wrapr::let(
    c(
      CATEG_1 = categ_1,
      CATEG_2 = categ_2,
      ORDER_1 = order_1,
      ORDER_2 = order_2,
      X = x
    ),
    {
      DT[, ORDER_1 := f(X, na.rm = TRUE), by = CATEG_1]
      DT[, ORDER_2 := f(X, na.rm = TRUE), by = CATEG_2]
      DT[, CATEG_1 := reorder(CATEG_1, ORDER_1)]
      DT[, CATEG_2 := reorder(CATEG_2, ORDER_2)]
    }
  )
  DT[]
}
