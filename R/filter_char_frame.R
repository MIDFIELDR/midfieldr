#' @importFrom data.table setDT setDF
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset rows of character data frame
#'
#' Subset the rows of a data frame by matching character patterns. Rows are
#' subset by matching or partially matching the patterns. Used primarily
#' for subsetting operations by midfieldr functions such as \code{get_cip()}.
#'
#' The \code{data} argument is any data frame comprised of character columns.
#' Rows are retained if they contain terms that match or partially match
#' patterns in \code{keep_any}; dropped if they match or partially match
#' patterns in \code{drop_any}.
#'
#' Search patterns are not case-sensitive,  must
#' be supported by \code{\link[base:grep]{grepl}}, and can include
#' \code{\link[base:regex]{regular expressions}}.
#'
#' @param data data frame of character variables
#'
#' @param keep_any character vector of search patterns for retaining rows
#'
#' @param ... not used for values. Forces optional arguments to be usable
#' by name only.
#'
#' @param drop_any (optional) character vector of search patterns for
#' dropping rows.
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item Rows are a subset of the input in the same order
#'   \item Columns are not modified
#'   \item Grouping structures, if any, are not preserved
#'   \item Data frame extension attributes, e.g., tibble, are not preserved
#' }
#'
#' @family data_carpentry
#'
#' @examples
#' filter_char_frame(cip, keep_any = c("^1407", "^1410"))
#' filter_char_frame(cip,
#'         keep_any = "civil engineering",
#'         drop_any = "technology")
#' filter_char_frame(cip, keep_any = "History") %>%
#'   filter_char_frame(keep_any = "American")
#'
#' @export
filter_char_frame <- function(data, keep_any = NULL, ..., drop_any = NULL) {

  # check arguments
  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named"
  )
  if(is.null(data)) {
    stop("`data` can't be NULL",
         call. = FALSE)
  }
  # check arguments
  assert_class(data, "data.frame")

  # bind names
  # NA

  # do the work
  data.table::setDT(data)

  # filter to keep rows
  if(length(keep_any) > 0){

    keep_any <- paste0(keep_any, collapse = "|")

    data <- data[apply(data, 1, function(i)
      any(grepl(keep_any, i, ignore.case = TRUE))), ]
  }

  # filter to drop rows
  if(length(drop_any) > 0){

    drop_any <- paste0(drop_any, collapse = "|")

    data <- data[apply(data, 1, function(j)
      !any(grepl(drop_any, j, ignore.case = TRUE))), ]
  }

  data.table::setDF(data)
}
