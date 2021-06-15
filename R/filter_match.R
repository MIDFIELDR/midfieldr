#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset rows by matching values in shared key columns
#'
#' Subset rows of one data frame by values of a key column that match values
#' of a similar key column in a second data frame. Columns are not subset
#' unless selected in an optional argument.
#'
#' Two data frames are input. The \code{match_to} data frame is subset to
#' retain its key column only.  The result is merged with \code{dframe} in an
#' inner-join, returning the rows of \code{dframe} with values matching the key
#' values in \code{match_to}.
#'
#' Column subsetting occurs after the inner join, so the
#' key column does not have to be included in the vector of column names in
#' \code{select}. The final operation is to subset for unique rows.
#'
#' @param dframe Data frame to be subset and returned. Must contain the key
#'        column named in \code{by_col}.
#' @param match_to Data frame with key column values to be matched to. The
#'        only column used is the required key column named in \code{by_col}.
#' @param by_col Character scalar, name of the key column.
#' @param ... Not used, force later arguments to be used by name.
#' @param select Character vector of \code{dframe} column names to retain,
#'        default all columns.
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'     \item Unique rows with matching values.
#'     \item All columns or those specified by \code{select}.
#'     \item Grouping structures are not preserved.
#' }
#' @family filter_*
#' @export
#' @examples
#' library("midfielddata")
#' data(degree)
#' filter_match(degree,
#'              match_to = study_programs,
#'              by_col   = "cip6",
#'              select   = c("mcid", "institution", "cip6"))
#'
#'
#'
#'
#'
filter_match<- function(dframe,
                        match_to,
                        by_col,
                        ...,
                        select = NULL) {

  # force arguments after dots to be used by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    paste("Arguments after ... must be named.\n",
          "* Did you forget to write `select = `?\n *")

  )

  # explicit arguments
  assert_explicit(dframe)
  assert_explicit(match_to)
  assert_explicit(by_col)

  # check argument class
  # set NULL default once dframe class checked
  assert_class(dframe, "data.frame")
  assert_class(match_to, "data.frame")
  assert_class(by_col, "character")
  select <- select %||% names(dframe)
  assert_class(select, "character")

  # existence of required columns
  assert_common_column(dframe, by_col)
  assert_common_column(match_to, by_col)

  # dframe is not modified by reference
  dframe <- copy(as.data.table(dframe))
  setDT(match_to)

  # key must be in both data frames
  stopifnot("`by_col` must be a column in `dframe`" = by_col %in% names(dframe))
  stopifnot("`by_col` must be a column in `match_to`" = by_col %in% names(match_to))

  # keep one column
  match_to <- match_to[, by_col, with = FALSE]
  match_to <- unique(match_to)

  # set common key
  setkeyv(dframe, by_col)
  setkeyv(match_to, by_col)

  # inner join
  dframe <- match_to[dframe, nomatch = 0]

  # keep selected columns
  dframe <- dframe[, select, with = FALSE]
  dframe <- unique(dframe)

  setkey(dframe, NULL)

  # enable printing (see data.table FAQ 2.23)
  dframe[]
}
