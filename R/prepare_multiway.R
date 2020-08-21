#' @importFrom data.table as.data.table copy
#' @importFrom stats median reorder
#' @importFrom wrapr let
NULL

#' Prepare multiway data
#'
#' Transform a data frame such that two categorical variables are factors
#' with levels ordered by medians of the quantitative variable. Rows and
#' columns of the data frame are otherwise unaffected.
#'
#' In multiway data, there is a single quantitative value (or response)
#' for every combination of levels of two categorical variables.
#' \code{order_multiway()} converts the columns of categorical variables
#' to factors and orders the factor levels by increasing medians of the
#' quantitative response variable.
#'
#' The \code{data} argument, therefore, must have three columns only. One
#' column is a quantitative variable (type numeric) and two columns are
#' categorical variables (type character or factor).
#'
#' @param data data frame of multiway data
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item Rows are not modified
#'   \item Quantitative column is not modified
#'   \item Categorical columns are factors with levels ordered by
#' median quantitative values
#'   \item Grouping structures, if any, are not preserved
#'   \item Data frame extensions \code{tbl} or \code{data.table}
#'   are preserved
#' }
#'
#' @examples
#' catg1 <- rep(c("urban", "rural", "suburb", "village"), each = 2)
#' catg2 <- rep(c("men", "women"), times = 4)
#' value <- c(0.22, 0.14, 0.43, 0.58, 0.81, 0.46, 0.15, 0.20)
#' mw_df <- data.frame(catg1, catg2, value)
#' prepare_multiway(mw_df)
#' @family functions
#'
#' @export
#'
prepare_multiway <- function(data = NULL) {

  # argument checks
  assert_explicit(data)
  assert_class(data, c("data.frame", "data.table"))

  if (isFALSE(ncol(data) == 3)) {
    stop("`data` must have exactly three columns")
  }

  # to preserve data.frame, data.table, or tibble
  df_class <- get_df_class(data)

  # to manage multiway column classes
  col_class <- get_col_class(data)
  mw_names <- col_class$col_name
  mw_class <- col_class$col_class
  # typical result
  #     col_class     col_name
  # 1   character     cat1
  # 2   character     cat2
  # 3   numeric       val

  # do the work in data.table
  DT <- data.table::copy(data.table::as.data.table(data))

  # factors to characters
  if ("factor" %in% mw_class) {
    idx <- which(mw_class == "factor")
    cols <- mw_names[idx]
    DT[, (cols) := lapply(.SD, as.character), .SDcols = cols]
  }
  # integer to double
  if ("integer" %in% mw_class) {
    idx <- which(mw_class == "integer")
    cols <- mw_names[idx]
    DT[, (cols) := lapply(.SD, as.double), .SDcols = cols]
  }
  # one numeric and 2 character
  col_class <- get_col_class(DT) # again
  mw_class <- col_class$col_class
  if (isFALSE(identical(
    sort(mw_class),
    c("character", "character", "numeric")
  ))) {
    stop(paste(
      "`data` must have one numeric column",
      "and two character columns"
    ))
  }

  # bind names
  VALUE <- NULL
  CAT1 <- NULL
  CAT2 <- NULL
  MED1 <- NULL
  MED2 <- NULL

  # one quantitative variable
  idx_num <- col_class$col_class == "numeric"
  value <- col_class$col_name[idx_num]

  # two categorical variables
  cat_var <- col_class$col_name[!idx_num]
  cat1 <- cat_var[1]
  cat2 <- cat_var[2]
  med1 <- paste0("med_", cat1)
  med2 <- paste0("med_", cat2)

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
      DT[, MED1 := stats::median(VALUE, na.rm = TRUE), by = CAT1]
      DT[, MED2 := stats::median(VALUE, na.rm = TRUE), by = CAT2]

      DT[, CAT1 := as.factor(CAT1)]
      DT[, CAT2 := as.factor(CAT2)]

      DT[, CAT1 := reorder(CAT1, MED1)]
      DT[, CAT2 := reorder(CAT2, MED2)]

      DT <- DT[, .(CAT1, CAT2, VALUE)]
    }
  )
  # works by reference
  revive_class(DT, df_class)
}
