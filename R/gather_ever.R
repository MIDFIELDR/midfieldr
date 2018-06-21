#' @importFrom dplyr select filter left_join
#' @importFrom magrittr %>%
#' @importFrom stringr str_c str_detect
#' @importFrom stats complete.cases
#' @importFrom tidyr drop_na
NULL

#' Gather students ever enrolled in a set of programs
#'
#' Filters the \code{midfielddata::midfieldterms} dataset for all students ever enrolled in a set of programs denoted by their 6-digit CIP codes.
#'
#' \code{gather_ever()} uses the codes in the \code{cip6} variable to filter the \code{midfieldterms} dataset, keeping all students who in any term were enrolled in any of those programs.
#'
#' The data can include students who change programs, who enroll in more than one program in a term, and of course a majority who enroll in the same program over multiple terms. The function returns a data frame with one observation for each unique pairing between student and program.
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
#' ever <- gather_ever(d)
#' head(ever)
#'
#' @export
gather_ever <- function(.data) {

	if(!.pkgglobalenv$has_data){
		stop(paste("To use this function, you must have the",
							 "`midfielddata` package installed. See the",
							 "`midfielddata` package vignette for more details."))
	}

  if (!(is.data.frame(.data) || dplyr::is.tbl(.data))) {
    stop("midfieldr::gather_ever() argument must be a data frame or tbl")
  }
  if (isFALSE("cip6" %in% names(.data))) {
    stop("midfieldr::gather_ever() data frame must include a `cip6` variable")
  }
  if (isFALSE("program" %in% names(.data))) {
    stop("midfieldr::gather_ever() data frame must include a `program` variable")
  }

  # from incoming data, use only cip6 and program labels
  .data <- .data %>%
    select(cip6, program)

  # obtain data from midfieldterms
  series <- stringr::str_c(.data$cip6, collapse = "|")
  students <- midfielddata::midfieldterms %>%
    dplyr::filter(stringr::str_detect(cip6, series))

  # remove unnecessary columns and incomplete rows
  students <- students %>%
    select(id, cip6, term) %>%
    arrange(id, cip6, term) %>%
    drop_na()

  # keep the first term in which a student id is paired with a program
  students <- students %>%
    group_by(id, cip6) %>%
    filter(dplyr::row_number() == 1) %>%
    ungroup() %>%
    select(-term)

  # join program names by cip6
  students <- dplyr::left_join(students, .data, by = "cip6") %>%
    select(id, cip6, program) %>%
    arrange(program, cip6, id)
}
"gather_ever"
