#' @importFrom dplyr filter across %>%
#' @importFrom stringr str_c str_detect regex
#' @importFrom wrapr stop_if_dot_args
NULL

#' Filter CIP data
#'
#' Filter a data frame of Classification of Instructional Programs (CIP) codes and return the rows that match conditions.
#'
#' The \code{keep_any} argument is an atomic character vector of search terms  used to filter the CIP data frame. Typical search terms include words and phrases describing academic programs or their CIP codes. The optional \code{drop_any} argument is similar except it drops rows instead of keeping them.
#'
#' Several named series are provided as possible values for \code{keep_any} to facilitate searching for groups of programs such as Biological Sciences, Engineering, Physical Sciences, etc. For the named series help page, run \code{? cip_series}.
#'
#' The function returns a subset of \code{data}. All columns are retained.
#'
#' @param data Data frame or tibble of CIP codes, default \code{midfieldr::cip}.
#'
#' @param keep_any Character vector used to filter \code{data}, keeping all rows in which any matches or partial matches are detected.
#'
#' @param ... Not used for values, forces later optional arguments to bind by name
#'
#' @param drop_any Character vector, optional argument. The output of the \code{keep_any} filter is the input to the \code{drop_any} filter, dropping all rows in which any matches or partial matches are detected.
#'
#' @return Data frame
#'
#' @examples
#' cip_filter(cip, "History")
#' cip_filter(cip, "History", drop_any = c("^04", "^13", "^50"))
#' cip_filter(cip, "History") %>%
#'   cip_filter("American")
#' cip_filter(cip, cip_engr) %>%
#'   cip_filter("Civil")
#' @export
cip_filter <- function(data = NULL, keep_any = NULL, ..., drop_any = NULL) {

  # force optional arguments to be usable only by name
  wrapr::stop_if_dot_args(substitute(list(...)), "cip_filter, optional arguments must be named.")

  # for use with dplyr::across()
  any_row <- function(x) rowSums(x) > 0

  # argument checks
  if (is.null(data)) {
    data <- midfieldr::cip
  }
  if (!(is.data.frame(data) || dplyr::is.tbl(data))) {
    stop("midfieldr::cip_filter, first argument must be a data.frame or tbl.")
  }

  # keep_any: rows to keep. Note that length(NULL) = 0.
  if (length(keep_any) > 0) {
    if (!(is.character(keep_any) || is.atomic(keep_any))) {
      stop("midfieldr::cip_filter, keep_any argument must be a character vector.")
    }
    # filter for keep_any
    search_string <- stringr::str_c(keep_any, collapse = "|")
    data <- dplyr::filter(data, any_row(dplyr::across(names(data), ~ stringr::str_detect(., regex(search_string, ignore_case = TRUE)))))
  }

  # drop_any: rows to delete
  if (length(drop_any) > 0) {
    if (!(is.character(drop_any) || is.atomic(drop_any))) {
      stop("midfieldr::cip_filter, drop_any argument must be a character vector.")
    }
    # filter for drop_any
    search_string <- stringr::str_c(drop_any, collapse = "|")
    data <- dplyr::filter(data, !any_row(dplyr::across(names(data), ~ stringr::str_detect(., regex(search_string, ignore_case = TRUE)))))
  }
  data <- data
}
"cip_filter"
