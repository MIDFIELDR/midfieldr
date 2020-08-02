#' @importFrom data.table as.data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset rows of a data frame by text
#'
#' Retain rows that contain matching or partially matching character strings.
#' Not case-sensitive. Default behavior is to retain all columns.
#' Use \code{keep_col} to subset columns. Use \code{unique_row} to remove
#' duplicate rows after subsetting.
#'
#' The \code{data} argument is typically the midfieldr \code{cip} data set,
#' though any data frame with all character-string columns can be searched
#' and subset.
#'
#' @param data data frame of character columns
#' @param keep_any character vector of search patterns for retaining rows
#' @param ... not used, force later arguments to be used by name
#' @param drop_any character vector of search patterns for dropping rows
#' @param keep_col character vector of column names, default all columns
#' @param unique_row logical, remove duplicate rows, default FALSE
#'
#' @return data frame with the following properties:
#' \itemize{
#'   \item Rows are a subset of the input in the same order
#'   \item All columns if \code{keep_col} NULL, otherwise columns named
#'     in \code{keep_col}
#'   \item Grouping structures are not preserved
#'   \item Data frame extensions such as \code{tbl} or \code{data.table}
#'     are preserved
#' }
#'
#' @examples
#' filter_by_text(cip, keep_any = c("^1407", "^1410"))
#' filter_by_text(cip, keep_any = "civil engineering", drop_any = "technology")
#' filter_by_text(cip, keep_any = "History") %>%
#'   filter_by_text(keep_any = "American")
#'
#' @family data_query
#'
#' @export
#'
filter_by_text <- function(data,
                           keep_any = NULL,
                           ...,
                           drop_any = NULL,
                           keep_col = NULL,
                           unique_row = NULL) {
  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named,"
  )
  if (isTRUE(is.null(keep_any) & is.null(drop_any))) {
    return(data)
  }

  # check before names(data) below
  assert_class(data, "data.frame")

  # default optional arguments
  keep_col <- keep_col %||% names(data)
  unique_row <- unique_row %||% FALSE

  # check arguments
  if (isFALSE(is.null(keep_any))) {assert_class(keep_any, "character")}
  if (isFALSE(is.null(drop_any))) {assert_class(drop_any, "character")}
  assert_class(keep_col, "character")
  assert_class(unique_row, "logical")

  # bind names
  # NA

  # to preserve data.frame, data.table, or tibble
  df_class <- get_df_class(data)
  DT <- data.table::as.data.table(data)

  # do the work
  DT <- filter_char_frame(
    data = DT,
    keep_any = keep_any,
    drop_any = drop_any
  )

  # stop if all rows have been eliminated
  if (abs(nrow(DT) - 0) < .Machine$double.eps^0.5) {
    revive_class(DT, df_class)
    stop("No CIPs satisfy the search criteria", call. = FALSE)
  }

  # message if a search term was not found
  # data frame with as many columns as there are keep_any terms
  # as many rows as there are being searched in data
  df <- data.frame(matrix("", nrow = nrow(DT), ncol = length(keep_any)))
  names(df) <- keep_any

  for (j in seq_along(keep_any)) {
    df[, j] <- apply(DT, 1, function(i) {
      any(grepl(keep_any[j], i, ignore.case = TRUE))
    })
  }

  # the sum is 0 for all FALSE in a column for that search term
  sumTF <- colSums(df)
  not_found <- sumTF[!sapply(sumTF, as.logical)]
  if (length(not_found) > 0) {
    message(paste(
      "Can't find these terms:",
      paste(names(not_found), collapse = ", ")
    ))
  }

  # return
  DT <- DT[, ..keep_col]
  if (unique_row) {DT <- unique_by_keys(DT)}
  revive_class(DT, df_class)
}
