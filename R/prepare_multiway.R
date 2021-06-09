#' @import data.table
#' @importFrom stats median reorder
#' @importFrom wrapr let
#' @importFrom Rdpack reprompt
NULL

# Rdpack reprompt is used for citations in an Roxygen document

#' Prepare multiway data for graphing
#'
#' Transform a data frame such that two categorical variables are factors
#' with levels ordered by medians of the quantitative variable. Rows and
#' columns of the data frame are otherwise unaffected.
#'
#' In multiway data, there is a single quantitative value (or response)
#' for every combination of levels of two categorical variables.
#' \code{prepare_multiway()} converts the columns of categorical variables
#' to factors and orders the factor levels by increasing medians of the
#' quantitative response variable.
#'
#' The \code{dframe} argument, therefore, must have three columns only. One
#' column is a quantitative variable (type numeric) and two columns are
#' categorical variables (type character or factor).
#'
#' Note that "multiway" in our context refers to the data structure and graph
#' design defined by \insertCite{Cleveland:1993;textual}{midfieldr}, not to
#' the methods of analysis described by
#' \insertCite{Kroonenberg:2008;textual}{midfieldr}.
#'
#' @param dframe data frame of multiway data
#' @param ... not used, forces later arguments to be used by name
#' @param details logical scalar to add columns reporting the medians on which
#'        the order of the levels is based, default FALSE
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'   \item Rows are not modified
#'   \item Quantitative column is not modified
#'   \item Categorical columns are factors with levels ordered by
#'         median quantitative values
#'   \item Grouping structures, if any, are not preserved
#' }
#' @references
#'   \insertAllCited{}
#' @export
#' @examples
#' catg1 <- rep(c("urban", "rural", "suburb", "village"), each = 2)
#' catg2 <- rep(c("men", "women"), times = 4)
#' value <- c(0.22, 0.14, 0.43, 0.58, 0.81, 0.46, 0.15, 0.20)
#'
#' # structure before
#' dframe <- data.frame(catg1, catg2, value)
#' str(dframe)
#'
#' # structure after
#' mw <- prepare_multiway(dframe)
#' str(mw)
prepare_multiway <- function(dframe, ..., details = NULL) {

  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named,"
  )

  # default arguments if NULL
  details <- details %||% FALSE

  # argument checks
  assert_explicit(dframe)
  assert_class(dframe, "data.frame")
  assert_class(details, "logical")
  # if (ncol(dframe) != 3) {
  #   stop("`dframe` must have exactly three columns")
  # }

  # # to manage multiway column classes
  # col_class <- get_col_class(dframe)
  # # typical result
  # #     col_class     col_name
  # # 1   character     cat1
  # # 2   character     cat2
  # # 3   numeric       val
  #
  # mw_names <- col_class$col_name
  # mw_class <- col_class$col_class

  # The dframe argument is modified "by reference." Thus changing its value
  # inside the function immediately changes its value in the calling frame
  # --- a data.table feature designed for fast data manipulation,
  # especially for data that occupies a lot of memory.
  setDT(dframe)

  # # factors to characters
  # if ("factor" %in% mw_class) {
  #   idx <- which(mw_class == "factor")
  #   cols <- mw_names[idx]
  #   dframe[, (cols) := lapply(.SD, as.character), .SDcols = cols]
  # }
  # # integer to double
  # if ("integer" %in% mw_class) {
  #   idx <- which(mw_class == "integer")
  #   cols <- mw_names[idx]
  #   dframe[, (cols) := lapply(.SD, as.double), .SDcols = cols]
  # }
  # # one numeric and 2 character
  # col_class <- get_col_class(dframe) # again
  # mw_class <- col_class$col_class
  # if (!identical(sort(mw_class), c("character", "character", "numeric"))) {
  #   stop(paste(
  #     "`dframe` must have one numeric column",
  #     "and two character columns"
  #   ))
  # }

  # any factors to characters
  factor_cols <- names(dframe)[sapply(dframe, is.factor)]
  if (length(factor_cols) > 0) {
    dframe[, (factor_cols) := lapply(.SD, as.character), .SDcols = factor_cols]
  }

  # any integers to double (comes after factors converted)
  integer_cols <- names(dframe)[sapply(dframe, is.integer)]
  if (length(integer_cols) > 0) {
    dframe[, (integer_cols) := lapply(.SD, as.double), .SDcols = integer_cols]
  }

  # check corrected variables correct type
  if (!identical(sort(unname(sapply(dframe, class))),
                 c("character","character", "numeric"))) {
    stop(paste(
      "`dframe` must have exactly one numeric column",
      "and two character columns"
    ))
  }

  # bind names due to NSE notes in R CMD check
  VALUE <- NULL
  CAT1 <- NULL
  CAT2 <- NULL
  MED1 <- NULL
  MED2 <- NULL

  # name of the one quantitative variable name
  value   <- names(dframe)[sapply(dframe, is.numeric)]

  # names of two categorical variables
  cat_var <- names(dframe)[sapply(dframe, is.character)]
  cat1 <- cat_var[1]
  cat2 <- cat_var[2]

  # create names for median value variables
  med1 <- paste0("med_", cat1)
  med2 <- paste0("med_", cat2)

  # convert to factors
  # DT[, (cat_var) := lapply(.SD, as.factor), .SDcols = cat_var]

  # one quantitative variable
  # idx_num <- col_class$col_class == "numeric"
  # value <- col_class$col_name[idx_num]

  # two categorical variables
  # cat_var <- col_class$col_name[!idx_num]
  # cat1 <- cat_var[1]
  # cat2 <- cat_var[2]
  # med1 <- paste0("med_", cat1)
  # med2 <- paste0("med_", cat2)

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

      if(details) {
        dframe <- dframe[, .(CAT1, CAT2, MED1, MED2, VALUE)]
      } else{
        dframe <- dframe[, .(CAT1, CAT2, VALUE)]
      }

    }
  )
  # remove grouping structure, if any
  setkey(dframe, NULL)
  dframe[]
}
