#' @importFrom data.table as.data.table copy
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset rows by text
#'
#' Subset a data frame, retaining rows that match or partially match
#' character strings. All columns retained unless specified by
#' \code{keep_col}. The function uses \code{grepl()}, therefore
#' non-character columns that can be coerced to character are also searched
#' for matches.
#'
#' @param data data frame to be subset
#' @param keep_text character vector of search patterns for retaining rows
#' @param ... not used, force later arguments to be used by name
#' @param drop_text character vector of search patterns for dropping rows
#' @param keep_col character vector of column names, default all columns
#' @param unique_row logical, remove duplicate rows, default TRUE
#' @return Data frame with the following properties:
#' \itemize{
#'     \item Rows matching elements of \code{keep_text}
#'     \item Columns specified by \code{keep_col}
#'     \item Data frame extensions such as \code{tbl} or \code{data.table}
#'     are preserved
#'     \item Grouping structures are not preserved
#' }
#' @examples
#' filter_text(cip, keep_text = c("^1407", "^1410"))
#' filter_text(cip,
#'                keep_text = "civil engineering",
#'                drop_text = "technology")
#' filter_text(cip, keep_text = "History") %>%
#'   filter_text(keep_text = "American")
#' @family functions
#' @export
filter_text <- function(data,
                           keep_text = NULL,
                           ...,
                           drop_text = NULL,
                           keep_col = NULL,
                           unique_row = NULL) {
  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named,"
  )
  if (isTRUE(is.null(keep_text) & is.null(drop_text))) {
    return(data)
  }

  # check before names(data) below
  assert_class(data, "data.frame")

  # default optional arguments
  keep_col <- keep_col %||% names(data)
  unique_row <- unique_row %||% TRUE

  # check arguments
  if (isFALSE(is.null(keep_text))) {
    assert_class(keep_text, "character")
  }
  if (isFALSE(is.null(drop_text))) {
    assert_class(drop_text, "character")
  }
  assert_class(keep_col, "character")
  assert_class(unique_row, "logical")

  # bind names
  # NA

  # to preserve data.frame, data.table, or tibble
  df_class <- get_df_class(data)
  DT <- data.table::copy(data.table::as.data.table(data))

  # subset columns first to reduce search time
  DT <- DT[, ..keep_col]

  # do the work
  DT <- filter_char_frame(
    data = DT,
    keep_text = keep_text,
    drop_text = drop_text
  )

  # stop if all rows have been eliminated
  if (abs(nrow(DT) - 0) < .Machine$double.eps^0.5) {
    revive_class(DT, df_class)
    stop("No CIPs satisfy the search criteria", call. = FALSE)
  }

  # message if a search term was not found
  # data frame with as many columns as there are keep_text terms
  # as many rows as there are being searched in data
  df <- data.frame(matrix("", nrow = nrow(DT), ncol = length(keep_text)))
  names(df) <- keep_text

  for (j in seq_along(keep_text)) {
    df[, j] <- apply(DT, 1, function(i) {
      any(grepl(keep_text[j], i, ignore.case = TRUE))
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
  if (unique_row) {
    DT <- unique_by_keys(DT)
  }
  revive_class(DT, df_class)
}
