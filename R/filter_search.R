#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset rows that include matches to search strings
#'
#' Subset a data frame, retaining unique rows that match or partially match
#' a vector of character strings. Columns are not subset unless selected in
#' an optional argument. Most commonly used for searching the CIP data set.
#'
#' Search terms can include regular expressions. To improve the speed of
#' the search, columns are subset by the values in the \code{select} argument
#' before the text search starts. Uses \code{grepl()}, therefore non-character
#' columns (if any) that can be coerced to character are also searched for
#' matches.
#'
#' @param dframe Data frame to be searched.
#' @param keep_text Character vector of search text for retaining rows.
#' @param ... Not used, force later arguments to be used by name.
#' @param drop_text Character vector of search text for dropping rows.
#' @param select Character vector of column names to search and return,
#'        default all columns.
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'     \item Unique rows matching elements of \code{keep_text}.
#'     \item All columns or those specified by \code{select}.
#'     \item Grouping structures are not preserved.
#' }
#' @family filter_*
#' @export
#' @examples
#' # subset using keywords
#' filter_search(cip, keep_text = "engineering")
#'
#' # drop_text argument, when used, must be named
#' filter_search(cip, "civil engineering", drop_text = "technology")
#'
#' # subset using numerical codes
#' filter_search(cip, keep_text = c("050125", "160501"))
#'
#' # subset using regular expressions
#' filter_search(cip, keep_text = "^54")
#' filter_search(cip, keep_text = c("^1407", "^1408"))
#'
#' # select columns
#' filter_search(cip,
#'   keep_text = "^54",
#'   select = c("cip6", "cip4name")
#' )
#'
#' # multiple passes to narrow the results
#' first_pass <- filter_search(cip, "civil")
#' second_pass <- filter_search(first_pass, "engineering")
#' filter_search(second_pass, drop_text = "technology")
#' \dontrun{
#' # unsuccessful terms produce a message
#' filter_search(cip, c("050125", "111111", "160501", "Bogus", "^55"))
#' }
filter_search <- function(dframe,
                          keep_text = NULL,
                          ...,
                          drop_text = NULL,
                          select = NULL) {

  # force arguments after dots to be used by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    paste(
      "Arguments after ... must be named.\n",
      "* Did you forget to write `drop_text = ` or `select = `?\n *"
    )
  )

  # explicit arguments and NULL defaults
  assert_explicit(dframe)
  assert_class(dframe, "data.frame")

  # return if no work is being done
  if ((missing(keep_text) | is.null(keep_text)) &
    is.null(drop_text) &
    is.null(select)) {
    return(dframe)
  }

  # NULL default
  select <- select %||% names(dframe)
  assert_class(select, "character")

  # check argument class of optional arguments
  if (!is.null(keep_text)) assert_class(keep_text, "character")
  if (!is.null(drop_text)) assert_class(drop_text, "character")

  # dframe is NOT modified by reference
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
    stop(
      paste(
        "The search result is empty. Either 'keep_text' terms were not",
        "found or 'drop_text' eliminated every row."
      ),
      call. = FALSE
    )
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
