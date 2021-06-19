

#' @import data.table
#' @importFrom stats median reorder
#' @importFrom wrapr let stop_if_dot_args `%?%`
#' @importFrom checkmate qassert assert_data_frame
#' @importFrom Rdpack reprompt
# Rdpack reprompt is used for citations in an Roxygen document
NULL


#' Condition multiway data for graphing
#'
#' Transform a data frame such that two categorical variables are factors
#' with levels ordered by medians of the quantitative variable. Rows and
#' columns of the data frame are otherwise unaffected. The primary goal is to
#' structure the data for display in a Cleveland "multiway dot plot," where
#' the ordering of the levels and panels are crucial to the perception of
#' effects.
#'
#' In multiway data---as defined by
#' \insertCite{Cleveland:1993;textual}{midfieldr}---there is a single
#' quantitative value (or response) for every combination of levels
#' of two categorical variables. \code{condition_multiway()} converts
#' the columns of categorical variables to factors and orders the factor
#' levels by increasing medians of the quantitative response variable.
#'
#' Note that "multiway" in our context refers to the data structure and graph
#' design defined by Cleveland, not to the methods of analysis described by
#' \insertCite{Kroonenberg:2008;textual}{midfieldr}.
#'
#' In the multiway dot plot, there are panels, the individual dot plots
#' of the display, and there are levels, the rows of each panel. One category
#' is encoded by the panels; the other by the rows. All panels have the same
#' quantitative scale on the x-axis and the same organization of category
#' levels on the y-axis. Panels and rows are ordered so that medians increase
#' in "graph order", that is, from left to right and from bottom to top. Hence
#' the importance of the medians reported by the \code{details} argument.
#'
#' In our implementation, the \code{dframe} argument must have three
#' columns only: two categorical columns (type character or factor) and one
#' quantitative column (type numeric).
#'
#'
#' @param dframe Data frame of multiway data.
#' @param ... Not used, forces later arguments to be used by name.
#' @param details Optional flag to add columns reporting the medians on which
#'        the order of the levels is based, default FALSE.
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'   \item Rows are not modified.
#'   \item Quantitative column is not modified.
#'   \item Categorical columns are factors with levels ordered by median
#'         quantitative values with an option to add columns of group medians.
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
#' @examples
#' catg1 <- rep(c("urban", "rural", "suburb", "village"), each = 2)
#' catg2 <- rep(c("men", "women"), times = 4)
#' value <- c(0.22, 0.14, 0.43, 0.58, 0.81, 0.46, 0.15, 0.20)
#'
#'
#' # structure before
#' dframe <- data.frame(catg1, catg2, value)
#' str(dframe)
#'
#'
#' # structure after
#' mw <- condition_multiway(dframe)
#' str(mw)
#'
#'
#' # incoming columns can be factor if not character
#' mw2 <- condition_multiway(mw)
#' str(mw2)
#'
#'
#' # report median values
#' mw <- condition_multiway(dframe, details = TRUE)
#' str(mw)
#' levels(mw$catg1) # note: not alphabetical
#' levels(mw$catg2)
#'
#'
#' @export
#'
#'
condition_multiway <- function(dframe, ..., details = NULL) {

  # remove all keys
  on.exit(setkey(dframe, NULL))

  # assert arguments after dots used by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    msg = paste(
      "Arguments after ... must be named.\n",
      "* Did you forget to write `details = ` ?\n *"
    )
  )

  # required arguments
  assert_data_frame(
    dframe,
    types = c("numeric", "character", "factor"),
    ncols = 3
  )

  # optional arguments
  details <- details %?% FALSE
  qassert(details, "b1") # boolean, length = 1

  # input modified (or not) by reference
  setDT(dframe)

  # required columns
  # any factors to characters
  factor_cols <- names(dframe)[sapply(dframe, is.factor)]
  if (length(factor_cols) > 0) {
    dframe[, (factor_cols) := lapply(.SD, as.character), .SDcols = factor_cols]
  }
  # any integers to double (comes after factors converted)
  numeric_cols <- names(dframe)[sapply(dframe, is.numeric)]
  if (length(numeric_cols) > 0) {
    dframe[, (numeric_cols) := lapply(.SD, as.double), .SDcols = numeric_cols]
  }

  # class of required columns
  char_cols <- names(dframe)[sapply(dframe, is.character)]
  num_cols  <- names(dframe)[sapply(dframe, is.numeric)]
  qassert(dframe[[char_cols[1]]], "s+")
  qassert(dframe[[char_cols[2]]], "s+")
  qassert(dframe[[num_cols]], "r+")

  # bind names due to NSE notes in R CMD check
  VALUE <- NULL
  CAT1 <- NULL
  CAT2 <- NULL
  MED1 <- NULL
  MED2 <- NULL

  # do the work
  # name of the one quantitative variable name
  value <- names(dframe)[sapply(dframe, is.numeric)]

  # names of two categorical variables
  cat_var <- names(dframe)[sapply(dframe, is.character)]
  cat1 <- cat_var[1]
  cat2 <- cat_var[2]

  # create names for median value variables
  med1 <- paste0("med_", cat1)
  med2 <- paste0("med_", cat2)

  # should be able to do this using data.table syntax only
  # wrapr::let for parameterized column names
  # https://winvector.github.io/wrapr/reference/let.html
  wrapr::let(
    alias = c(
      VALUE = value,
      CAT1 = cat1,
      CAT2 = cat2,
      MED1 = med1,
      MED2 = med2
    ),
    expr = {
      dframe[, MED1 := stats::median(VALUE, na.rm = TRUE), by = CAT1]
      dframe[, MED2 := stats::median(VALUE, na.rm = TRUE), by = CAT2]

      dframe[, CAT1 := as.factor(CAT1)]
      dframe[, CAT2 := as.factor(CAT2)]

      dframe[, CAT1 := reorder(CAT1, MED1)]
      dframe[, CAT2 := reorder(CAT2, MED2)]

      if (details) {
        dframe <- dframe[, .(CAT1, CAT2, MED1, MED2, VALUE)]
      } else {
        dframe <- dframe[, .(CAT1, CAT2, VALUE)]
      }
    }
  )

  # enable printing (see data.table FAQ 2.23)
  dframe[]
}
