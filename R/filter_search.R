

#' @import data.table
#' @importFrom wrapr stop_if_dot_args
#' @importFrom checkmate qassert
NULL


#' Subset rows that include matches to search strings
#'
#' Subset a data frame, retaining rows that match or partially match
#' a vector of character strings. Columns are not subset unless selected in
#' an optional argument. Most commonly used for searching the CIP data set.
#'
#' Search terms can include regular expressions. Uses \code{grepl()},
#' therefore non-character columns (if any) that can be coerced to
#' character are also searched for matches. Columns are subset by
#' the values in \code{select} after the search concludes.
#'
#' If none of the optional arguments are specified, the function returns
#' the original data frame.
#'
#' @param dframe Data frame to be searched.
#' @param keep_text Optional character vector of search text for retaining
#'        rows.
#' @param ... Not used, force later arguments to be used by name.
#' @param drop_text Optional character vector of search text for dropping rows.
#' @param select Optional character vector of column names to return,
#'        default all columns.
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'     \item Rows matching elements of \code{keep_text} but excluding rows
#'           matching elements of \code{drop_text}.
#'     \item All columns or those specified by \code{select}.
#'     \item Grouping structures are not preserved.
#' }
#'
#'
#' @family filter_*
#'
#'
#' @examples
#' # subset using keywords
#' filter_search(cip, keep_text = "engineering")
#'
#'
#' # drop_text argument, when used, must be named
#' filter_search(cip, "civil engineering", drop_text = "technology")
#'
#'
#' # subset using numerical codes
#' filter_search(cip, keep_text = c("050125", "160501"))
#'
#'
#' # subset using regular expressions
#' filter_search(cip, keep_text = "^54")
#' filter_search(cip, keep_text = c("^1407", "^1408"))
#'
#'
#' # select columns
#' filter_search(cip,
#'   keep_text = "^54",
#'   select = c("cip6", "cip4name")
#' )
#'
#'
#' # multiple passes to narrow the results
#' first_pass <- filter_search(cip, "civil")
#' second_pass <- filter_search(first_pass, "engineering")
#' filter_search(second_pass, drop_text = "technology")
#'
#'
#' \dontrun{
#' # unsuccessful terms produce a message
#' filter_search(cip, c("050125", "111111", "160501", "Bogus", "^55"))
#' }
#'
#'
#' @export
#'
#'
filter_search <- function(dframe,
                          keep_text,
                          ...,
                          drop_text,
                          select = NULL) {

  # remove all keys
  on.exit(setkey(dframe, NULL))

  # assert arguments after dots used by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    paste(
      "Arguments after ... must be named.\n",
      "* Did you forget to write `drop_text = ` or `select = `?\n *"
    )
  )

  # required argument
  qassert(dframe, "d+")

  # optional arguments
  select <- select %||% names(dframe)
  if (missing(keep_text)){keep_text = NULL}
  if (missing(drop_text)){drop_text = NULL}
  qassert(select, "s+")
  if (!is.null(keep_text)) qassert(keep_text, "s+")
  if (!is.null(drop_text)) qassert(drop_text, "s+")

  # return if no work is being done
  if (is.null(keep_text) & is.null(drop_text) & is.null(select)) {
    return(dframe)
  }

  # input modified (or not) by reference
  setDT(dframe)

  # required columns
  # NA
  # class of required columns
  # NA
  # bind names due to NSE notes in R CMD check
  # NA

  # do the work
  dframe <- filter_char_frame(
    data = dframe,
    keep_text = keep_text,
    drop_text = drop_text
  )

  # stop if all rows have been eliminated
  if (abs(nrow(dframe) - 0) < .Machine$double.eps^0.5) {
    stop(
      paste(
        "The search result is empty. Possible causes are:\n",
        "* 'dframe' contained no matches to terms in 'keep_text'.\n",
        "* 'drop_text' eliminated all remaining rows."
      ),
      call. = FALSE
    )
  }

  # message if a search term was not found
  # data frame with as many columns as there are keep_text terms
  # as many rows as there are being searched in data
  df <- data.frame(matrix("", nrow = nrow(dframe), ncol = length(keep_text)))
  names(df) <- keep_text

  for (j in seq_along(keep_text)) {
    df[, j] <- apply(dframe, 1, function(i) {
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

  # subset columns
  dframe <- dframe[, select, with = FALSE]

  # enable printing (see data.table FAQ 2.23)
  dframe[]
}
