#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset rows by text
#'
#' Subset a data frame, retaining rows that match or partially match
#' character strings. All columns retained unless specified by
#' \code{select}. The function uses \code{grepl()}, therefore
#' non-character columns that can be coerced to character are also searched
#' for matches.
#'
#' @param dframe data frame to be subset
#' @param pattern character vector of search patterns for retaining rows
#' @param ... not used, force later arguments to be used by name
#' @param drop_text character vector of search patterns for dropping rows
#' @param select character vector of column names, default all columns
#' @param unique_row logical, remove duplicate rows, default TRUE
#' @return Data frame with the following properties:
#' \itemize{
#'     \item Rows matching elements of \code{pattern}
#'     \item All columns or those specified by \code{select}
#'     \item Data frame extensions such as \code{tbl} or \code{data.table}
#'     are preserved
#'     \item Grouping structures are not preserved
#' }
#' @export
#' @examples
#' # subset using keywords
#' subset_text(cip, pattern = "engineering")
#'
#' # drop_text argument, when used, must be named
#' subset_text(cip, "civil engineering", drop_text = "technology")
#'
#' # subset using numerical codes
#' subset_text(cip, pattern = c("050125", "160501"))
#'
#' # subset using regular expressions
#' subset_text(cip, pattern = "^54")
#' subset_text(cip, pattern = c("^1407", "^1408"))
#'
#' # select columns
#' subset_text(cip,
#'             pattern = "^54",
#'             select = c("cip4", "cip4name"))
#'
#' \dontrun{
#' # unsuccessful terms produce a message
#' subset_text(cip, c("050125", "111111", "160501", "Bogus", "^55"))
#' }
subset_text <- function(dframe,
                        pattern = NULL,
                        ...,
                        drop_text = NULL,
                        select = NULL,
                        unique_row = NULL) {
  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named,"
  )
  if (is.null(pattern) & is.null(drop_text)) {
    return(dframe)
  }

  # check before names(dframe) below
  assert_class(dframe, "data.frame")

  # default optional arguments
  select <- select %||% names(dframe)
  unique_row <- unique_row %||% TRUE

  # check arguments
  if (!is.null(pattern)) {
    assert_class(pattern, "character")
  }
  if (!is.null(drop_text)) {
    assert_class(drop_text, "character")
  }
  assert_class(select, "character")
  assert_class(unique_row, "logical")

  # bind names due to nonstandard evaluation notes in R CMD check
  # var <- NULL

  # to preserve data.frame, data.table, or tibble
  df_class <- get_dframe_class(dframe)
  DT <- copy(as.data.table(dframe))

  # subset columns first to reduce search time
  DT <- DT[, select, with = FALSE]

  # do the work
  DT <- filter_char_frame(
    data = DT,
    pattern = pattern,
    drop_text = drop_text
  )

  # stop if all rows have been eliminated
  if (abs(nrow(DT) - 0) < .Machine$double.eps^0.5) {
    revive_class(DT, df_class)
    stop("No CIPs satisfy the search criteria", call. = FALSE)
  }

  # message if a search term was not found
  # data frame with as many columns as there are pattern terms
  # as many rows as there are being searched in data
  df <- data.frame(matrix("", nrow = nrow(DT), ncol = length(pattern)))
  names(df) <- pattern

  for (j in seq_along(pattern)) {
    df[, j] <- apply(DT, 1, function(i) {
      any(grepl(pattern[j], i, ignore.case = TRUE))
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
