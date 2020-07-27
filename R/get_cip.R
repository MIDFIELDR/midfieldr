#' @importFrom data.table as.data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset CIP data frame
#'
#' Subset the rows of a data frame by matching character patterns. The data
#' are CIP attributes with 2-, 4-, and 6-digit codes and names in character
#' columns (\code{\link[midfieldr]{cip}} or equivalent). Rows are subset by
#' matching or partially matching patterns. The search is not case-sensitive.
#'
#' The default \code{data} argument is \code{cip}, accessed by name or
#' by leaving the \code{data} argument vacant. Any other \code{data}
#' argument should be a subset of \code{cip} or equivalent.
#'
#' @param data data frame of CIP codes and names
#' @param keep_any character vector of search patterns for retaining rows
#' @param ... not used for values. Forces optional arguments to be usable
#' by name only.
#' @param drop_any (optional) character vector of search patterns for
#' dropping rows
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item Rows are a subset of the input in the same order
#'   \item Columns are not modified
#'   \item Grouping structures, if any, are not preserved
#'   \item Data frame extensions \code{tbl} or \code{data.table} are preserved
#' }
#'
#' @examples
#' get_cip(cip, keep_any = c("^1407", "^1410"))
#' get_cip(cip, keep_any = "civil engineering", drop_any = "technology")
#' get_cip(cip, keep_any = "History") %>%
#'   get_cip(keep_any = "American")
#'
#' @family data_query
#'
#' @export
#'
get_cip <- function(data = NULL, keep_any = NULL, ..., drop_any = NULL) {
  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named,"
  )

  # default data
  data <- data %||% midfieldr::cip

  # check arguments
  assert_class(data, "data.frame")
  assert_class(keep_any, "character")
  assert_class(drop_any, "character")

  if (isTRUE(is.null(keep_any) && is.null(drop_any))) {
    return(data)
  }

  # bind names
  # NA

  # to preserve data.frame, data.table, or tibble
  dat_class <- get_df_class(data)
  DT <- data.table::as.data.table(data)

  # do the work
  DT <- filter_char_frame(
    data = DT,
    keep_any = keep_any,
    drop_any = drop_any
  )

  # stop if all rows have been eliminated
  if (abs(nrow(DT) - 0) < .Machine$double.eps^0.5) {
    revive_class(DT, dat_class)
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

  revive_class(DT, dat_class)
}
