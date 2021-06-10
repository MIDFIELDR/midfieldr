#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset rows by text
#'
#' Subset a data frame, retain unique rows that match or partially match
#' character strings. All columns retained unless specified by
#' \code{select}. Uses \code{grepl()}, therefore non-character columns
#' that can be coerced to character are also searched for matches.
#'
#' To improve the speed of the search, columns are subset by the values in
#' the\code{select} argument before the text search starts.
#'
#' @param dframe data frame to be searched
#' @param keep_text character vector of search text for retaining rows
#' @param ... not used, force later arguments to be used by name
#' @param drop_text character vector of search text for dropping rows
#' @param select character vector of column names to search and return,
#'        default all columns
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'     \item Unique rows matching elements of \code{keep_text}
#'     \item All columns or those specified by \code{select}
#'     \item Grouping structures are not preserved
#' }
#' @family functions
#' @export
#' @examples
#' # subset using keywords
#' filter_text(cip, keep_text = "engineering")
#'
#' # drop_text argument, when used, must be named
#' filter_text(cip, "civil engineering", drop_text = "technology")
#'
#' # subset using numerical codes
#' filter_text(cip, keep_text = c("050125", "160501"))
#'
#' # subset using regular expressions
#' filter_text(cip, keep_text = "^54")
#' filter_text(cip, keep_text = c("^1407", "^1408"))
#'
#' # select columns
#' filter_text(cip,
#'             keep_text = "^54",
#'             select = c("cip6", "cip4name"))
#'
#' \dontrun{
#' # unsuccessful terms produce a message
#' filter_text(cip, c("050125", "111111", "160501", "Bogus", "^55"))
#' }
filter_text <- function(dframe,
                        keep_text = NULL,
                        ...,
                        drop_text = NULL,
                        select = NULL) {
  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named,"
  )
  if (is.null(keep_text) & is.null(drop_text) & is.null(select)) {
    return(dframe)
  }

  # check before names(dframe) below
  assert_class(dframe, "data.frame")

  # default optional arguments
  select <- select %||% names(dframe)

  # check arguments
  if (!is.null(keep_text)) {
    assert_class(keep_text, "character")
  }
  if (!is.null(drop_text)) {
    assert_class(drop_text, "character")
  }
  assert_class(select, "character")

  # bind names due to nonstandard evaluation notes in R CMD check
  # var <- NULL

  # The dframe argument is copied and therefore not modified "by reference."
  # Thus changing its value inside the function does not change its value
  # in the calling frame.

  # start
  DT <- copy(as.data.table(dframe))

  # subset columns
  DT <- DT[, select, with = FALSE]

  # do the work
  DT <- filter_char_frame(
    data = DT,
    keep_text = keep_text,
    drop_text = drop_text
  )

  # stop if all rows have been eliminated
  if (abs(nrow(DT) - 0) < .Machine$double.eps^0.5) {
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
  setkey(DT, NULL)
  DT <- unique(DT)

  # enable printing (see data.table FAQ 2.23)
  DT[]
}
