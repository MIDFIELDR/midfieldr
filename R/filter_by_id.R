#' @importFrom data.table setDT '%chin%' as.data.table
NULL

#' Subset rows of a data frame by student ID
#'
#' Retain rows that match student IDs. Default behavior is to retain all
#' columns. Use \code{keep_col} to subset columns. Use \code{unique_row} to
#' remove duplicate rows after subsetting.
#'
#' The \code{data} argument---a midfielddata data set or equivalent---must
#' include an \code{id} column.
#'
#' If applied to \code{midfielddegrees}, setting \code{first_degree} to TRUE
#' retains the first degree term only (by \code{id}), dropping rows with
#' degrees earned in subsequent terms. However, multiple degrees in the
#' first degree term are always retained.
#'
#' @param data data frame
#' @param keep_id character vector of student IDs
#' @param ... not used, force later arguments to be used by name
#' @param keep_col character vector of column names, default all columns
#' @param unique_row logical, remove duplicate rows, default FALSE
#' @param first_degree logical, retain first degree term only, default FALSE
#'
#' @return data frame with the following properties:
#' \itemize{
#'     \item Rows with an ID matching an element of \code{keep_id}
#'     \item All columns if \code{keep_col} NULL, otherwise columns named
#'     in \code{keep_col}
#'     \item Grouping structures are not preserved
#'     \item Data frame extensions such as \code{tbl} or \code{data.table}
#'     are preserved
#' }
#'
#' @examples
#' # placeholder
#' @family data_query
#'
#' @export
#'
filter_by_id <- function(data,
                         keep_id,
                         ...,
                         keep_col = NULL,
                         unique_row = NULL,
                         first_degree = NULL) {
  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named,"
  )

  # default optional arguments
  unique_row <- unique_row %||% FALSE
  first_degree <- first_degree %||% FALSE

  # check arguments
  assert_explicit(data)
  assert_class(data, "data.frame")
  keep_col <- keep_col %||% names(data) # depends on `data`


  assert_explicit(keep_id)

  assert_class(keep_id, "character")
  assert_class(keep_col, "character")
  assert_class(unique_row, "logical")
  assert_class(first_degree, "logical")
  assert_required_column(data, "id")

  # bind names
  id <- NULL
  term_degree <- NULL

  # preserve data.frame, data.table, or tibble
  df_class <- get_df_class(data)
  DT <- data.table::as.data.table(data)

  # filter and unique
  DT <- DT[id %chin% keep_id]

  # stop if all rows have been eliminated
  if (abs(nrow(DT) - 0) < .Machine$double.eps^0.5) {
    revive_class(DT, df_class)
    stop("No IDs satisfy the search criteria", call. = FALSE)
  }

  # return the first degree term only
  if (first_degree & "term_degree" %in% names(data)) {
    DT <- DT[, term_degree := min(term_degree), by = id]
  }

  # return
  DT <- DT[, ..keep_col]
  if (unique_row) {
    DT <- unique_by_keys(DT)
  }
  revive_class(DT, df_class)
}
