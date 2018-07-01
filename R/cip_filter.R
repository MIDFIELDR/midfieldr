#' @importFrom dplyr any_vars filter_all arrange group_by filter
#' @importFrom dplyr row_number ungroup %>%
#' @importFrom stringr str_c str_detect
#' @importFrom tibble is_tibble as_tibble
NULL

#' Filter by CIP data
#'
#' Filter a data frame of Classification of Instructional Programs (CIP) codes and return the rows that match conditions.
#'
#' The \code{series} argument is an atomic character vector of search terms  used to filter the reference CIP data set. Typical search terms include words and phrases describing academic programs or their CIP codes.
#'
#' Several collections of named series are provided to facilitate searching for groups of programs such as Biological Sciences, Engineering, Physical Sciences, etc. For the named series help page, run \code{?cip_series}.
#'
#' The function returns a subset of \code{reference} with all rows containing any of the search terms. Variables are not altered.
#'
#' @param series atomic character vector of search terms to filter by
#'
#' @param ... not used for values, forces later arguments to bind by name
#'
#' @param reference a reference data frame from which 2-digit, 4-digit, and 6-digit CIP codes and program names are obtained, default \code{cip}
#'
#' @return data frame, subset of \code{reference}
#'
#' @examples
#' cip_filter()
#' cip_filter(series = "History")
#' cip_filter(series = c("American", "History"))
#' cip_filter(series = "History") %>%
#'   cip_filter(series = "American", reference = .)
#' cip_filter(series = "^14")
#' cip_filter(series = "^14") %>%
#'   cip_filter(series = "Civil", reference = .)
#'
#' @export
cip_filter <- function(series = NULL, ..., reference = NULL) {

  # default data
  if (is.null(reference)) {
    reference <- midfieldr::cip
  }

  # tibble required by filter_all()
  if (!tibble::is_tibble(reference)) {
    reference <- tibble::as_tibble(reference)
  }

  # if series not specified, return the data unfiltered,
  # otherwise, filter all columns by search terms
  if (is.null(series)) {
    reference <- reference
  } else {
    collapse_series <- stringr::str_c(series, collapse = "|")
    reference <- reference %>%
      dplyr::filter_all(
        dplyr::any_vars(stringr::str_detect(., collapse_series))
      )
  }
}
