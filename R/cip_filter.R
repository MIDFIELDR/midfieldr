#' @importFrom dplyr filter across %>%
#' @importFrom stringr str_c str_detect regex
#' @importFrom wrapr stop_if_dot_args
NULL

#' Filter by CIP data
#'
#' Filter a data frame of Classification of Instructional Programs (CIP) codes and return the rows that match conditions.
#'
#' The \code{series} argument is an atomic character vector of search terms  used to filter the CIP data frame. Typical search terms include words and phrases describing academic programs or their CIP codes.
#'
#' Several collections of named series are provided to facilitate searching for groups of programs such as Biological Sciences, Engineering, Physical Sciences, etc. For the named series help page, run \code{?cip_series}.
#'
#' The function returns a subset of \code{data} with all rows containing any of the search terms. Variables are not altered.
#'
#' @param data a data frame or tibble of CIP codes
#'
#' @param series character vector used to filter \code{data}, retaining all rows containing any of these terms.
#'
#' @param ... not used for values, forces later optional arguments to bind by name
#'
#' @param except character vector used to filter \code{data}, deleting all rows containing any of these terms.
#'
#' @return data frame
#'
#' @examples
#' cip_filter(cip, "History")
#' cip_filter(cip, c("American", "History"))
#' cip_filter(cip, "History") %>%
#'   cip_filter(., American")
#' cip_filter(cip, ^14") %>%
#'   cip_filter(., series = "Civil")
#' @export
cip_filter <- function(data, series = NULL, ..., except = NULL) {

  # force optional arguments to be usable only by name
  wrapr::stop_if_dot_args(substitute(list(...)), "cip_filter, optional arguments must be named.")

  # for use with dplyr::across()
  any_row <- function(x) rowSums(x) > 0

  if(!(is.data.frame(data) || dplyr::is.tbl(data))) {
    stop("midfieldr::cip_filter, first argument must be a data.frame or tbl.")
  }
  if (is.null(data)) {
    stop("midfieldr::cip_filter, data cannot be NULL")
  }

  # series: rows to keep. Note that length(NULL) = 0.
  if (length(series) > 0) {

    if(!(is.character(series) || is.atomic(series))) {
      stop("midfieldr::cip_filter, series argument must be a character vector.")
    }

    search_string <- stringr::str_c(series, collapse = "|")

    data <- dplyr::filter(data, any_row(dplyr::across(where(is.character), ~ stringr::str_detect(., regex(search_string, ignore_case = TRUE)))))
  }

  # except: rows to delete
  if (length(except) > 0) {

    if(!(is.character(except) || is.atomic(except))) {
      stop("midfieldr::cip_filter, except argument must be a character vector.")
    }

    search_string <- stringr::str_c(except, collapse = "|")

    data <- dplyr::filter(data, !any_row(dplyr::across(where(is.character), ~ stringr::str_detect(., regex(search_string, ignore_case = TRUE)))))
  }

  data <- data
}
