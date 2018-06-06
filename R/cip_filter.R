#' @importFrom dplyr any_vars filter_all arrange group_by filter
#' @importFrom dplyr row_number ungroup
#' @importFrom stringr str_c str_detect
#' @importFrom tibble is_tibble as_tibble
#' @importFrom magrittr %>%
NULL

#' Filter CIP data
#'
#' Filter a data frame of Classification of Instructional Programs (CIP) codes
#' and return the rows that match conditions.
#'
#' \code{cip_filter()} is essentially a search tool to filter the data frame
#' given by the \code{data} argument and return all rows containing the terms
#' specified in the \code{series} argument.
#'
#' Variables are not altered.
#'
#' Typical search terms include words and phrases describing academic programs
#' or all or part of 2-, 4-, or 6-digit CIP codes. midfieldr provides several
#' collections of predefined search terms for groups of programs such as
#' Biological Sciences, Engineering, Physical Sciences, etc.
#'
#' @param data A data frame of character variables (or coercible to one).
#' If NULL, \code{data} is the midfieldr \code{cip} dataset.
#'
#' @param series A character vector (or coercible to one) of search terms. The
#' conditions used to filter the data.
#'
#' @return A subset of \code{data} returned as a data frame (tibble) of
#' character variables.
#'
#' @examples
#' cip_filter()
#' cip_filter(series = "History")
#' cip_filter(series = c("American", "History"))
#' cip_filter(series = "History") %>%
#'   cip_filter(series = "American")
#' cip_filter(series = "^14")
#' cip_filter(series = "^14") %>%
#'   cip_filter(series = "Civil")
#'
#' @export
cip_filter <- function(data = NULL, series = NULL) {

  # default data
  if (is.null(data)) {
    data <- midfieldr::cip
  }

  # tibble required by filter_all()
  if (!tibble::is_tibble(data)) {
    data <- tibble::as_tibble(data)
  }

  # if series not specified, return the data unfiltered,
  # otherwise, filter all columns by search terms
  if (is.null(series)) {
    data <- data
  } else {
    collapse_series <- stringr::str_c(series, collapse = "|")
    data <- data %>%
      dplyr::filter_all(
        dplyr::any_vars(stringr::str_detect(., collapse_series))
      )
  }
}
