#' @importFrom dplyr select filter left_join arrange ungroup arrange row_number
#' @importFrom magrittr %>%
#' @importFrom stringr str_c str_detect
NULL

#' Gather students graduating from a set of programs
#'
#' Filters the \code{midfielddata::midfielddegrees} dataset for all students graduating from a set of programs denoted by their 6-digit CIP codes.
#'
#' \code{gather_grad()} uses the codes in the \code{cip6} variable to filter the \code{midfielddegrees} dataset, keeping all students who graduate from any of those programs.
#'
#' The data can include students earning degrees in multiple programs in the same term. The function returns a data frame with one observation for each unique pairing between students and programs in the term in which their first degree or degrees are awarded. Degrees earned in later terms are ignored.
#'
#' All variables in \code{.data} other than the required \code{cip6} and \code{program} are quietly dropped.
#'
#' @param .data A data frame with two required character variables:  \code{cip6} (6-digit CIP codes) and \code{program} (program labels).
#'
#' @return A data frame with variables \code{id} (unique MIDFIELD student ID), \code{cip6} (6-digit CIP code), and \code{program} (a program label).
#'
#' @seealso \code{\link[midfieldr]{cip_filter}} for obtaining 6-digit CIP codes, \code{\link[midfieldr]{cip_label}} for adding a column of program labels
#'
#' @examples
#' d <- cip_filter(cip, series = "540104")
#' d <- cip_label(d, program = "cip6name")
#' grad <- gather_grad(d)
#' head(grad)
#'
#' @export
gather_grad <- function(.data) {
  if (!(is.data.frame(.data) || dplyr::is.tbl(.data))) {
    stop("midfieldr::gather_grad() argument must be a data frame or tbl")
  }
  if (isFALSE("cip6" %in% names(.data))) {
    stop("midfieldr::gather_grad() data frame must include a `cip6` variable")
  }
  if (isFALSE("program" %in% names(.data))) {
    stop("midfieldr::gather_grad() data frame must include a `program` variable")
  }

  # from incoming data, use only cip6 and program labels
  .data <- .data %>%
    select(cip6, program)

  # obtain data from midfieldterms
  series <- stringr::str_c(.data$cip6, collapse = "|")
  students <- midfielddata::midfielddegrees %>%
    dplyr::filter(stringr::str_detect(cip6, series))

  # remove unnecessary columns and incomplete rows
  students <- students %>%
    select(id, cip6, term_degree) %>%
    arrange(id, cip6, term_degree) %>%
    drop_na()

  # keep the first term in which a student id is paired with a program
  students <- students %>%
    group_by(id, cip6) %>%
    filter(dplyr::row_number() == 1) %>%
    ungroup() %>%
    select(-term_degree)

  # join program names by cip6
  students <- dplyr::left_join(students, .data, by = "cip6") %>%
    select(id, cip6, program) %>%
    arrange(program, cip6, id)
}
"gather_grad"
