#' @importFrom dplyr group_by summarize
#' @importFrom wrapr stop_if_dot_args let
NULL

#' Determine range of terms
#'
#' Determine first and last academic terms for each institution in a data frame.
#'
#' The default values of the optional arguments are the column names
#' \code{"institution"} and \code{"term"}.
#' If using a data frame with different column names, you can rename
#' your variables to match the defaults or use the optional arguments to
#' pass your variable name(s) to the function.
#'
#' \code{term_summarise()} is synonymous with \code{term_summarize()}.
#'
#' @param data Data frame. Default is \code{midfieldterms}.
#'
#' @param ... Not used for values. Forces the subsequent optional arguments
#' to only be usable by name.
#'
#' @param institution Column name in quotes of the institution variable in
#' \code{data}. Default is "institution". Optional argument.
#'
#' @param term Column name in quotes of the term variable in
#' \code{data}. Default is "term". Optional argument.
#'
#' @return Data frame with minimum and maximum range of terms by institution.
#'
#' @family data_carpentry
#'
#' @examples
#' library(midfielddata)
#' term_summarize(midfieldterms)
#' @export
term_summarize <- function(data = NULL, ..., institution = "institution",
                           term = "term") {
  if (is.null(data)) {
    data <- midfieldterms
  }

  # argument checks
  if (!(is.data.frame(data) || dplyr::is.tbl(data))) {
    stop("term_summarize data argument must be a data frame or tbl")
  }
  if (!institution %in% names(data)) {
    stop("term_summarize expects an institution variable.")
  }
  if (!term %in% names(data)) {
    stop("term_summarize expects a term variable.")
  }
  wrapr::stop_if_dot_args(substitute(list(...)), "term_summarize")

  # fixes "no visible binding" in R CMD check
  INSTITUTION <- NULL
  TERM <- NULL

  # use wrapr::let() to allow alternate column names
  mapping <- c(
    INSTITUTION = institution,
    TERM = term
  )
  wrapr::let(
    alias = mapping,
    expr = {
      # range_min and range_max are created by the function
      data_range <- data %>%
        group_by(INSTITUTION) %>%
        summarize(range_min = min(TERM), range_max = max(TERM))
    }
  )
}

#' @rdname term_summarize
#' @export
term_summarise <- term_summarize
