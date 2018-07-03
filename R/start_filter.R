#' @importFrom dplyr select is.tbl
#' @importFrom wrapr stop_if_dot_args let
#' @importFrom stringr str_c
NULL

#' Filter student data for starting students
#'
#' Filter entering student data to find all students starting in specified
#' programs.
#'
#' To use this function, the \code{midfielddata} package must be installed
#' to provide \code{midfieldstudents}, the default reference data set.
#'
#' The \code{series} argument is an atomic character vector of 6-digit CIP
#' codes used to filter the reference data set and extract student IDs.
#'
#' The function returns a subset of \code{reference} with the student ID and
#' starting major CIP. Other variables in \code{reference} are quietly dropped.
#'
#' Optional arguments. An alternate reference data set can be assigned via
#' the \code{reference} argument. The alternate must have variables for student
#' ID and starting CIP.
#'
#' @param series atomic character vector of 6-digit CIP codes specifying the
#' programs to filter by
#'
#' @param ... not used for values, forces later arguments to bind by name
#'
#' @param reference a reference data frame from which student IDs, academic
#' terms, and CIP codes are obtained, default \code{midfieldterms}
#'
#' @param id character column name of the ID variable in \code{reference}
#'
#' @param cip6 character column name of the CIP code variable in
#' \code{reference}
#'
#' @return Data frame with character variables for student ID and CIP of the
#' starting program
#'
#' @seealso \code{\link[midfieldr]{cip_filter}} for obtaining 6-digit CIP codes
#'
#' @examples
#' placeholder <- 2 + 3
#'
#' @export
start_filter <- function(series, ..., reference = NULL, id = "id", cip6 = "cip6") {
	if (!.pkgglobalenv$has_data) {
		stop(paste(
			"To use this function, you must have",
			"the midfielddata package installed."
		))
	}

  # force optional arguments to be usable only by name
  wrapr::stop_if_dot_args(substitute(list(...)), "gather_ever")

  if (is.null(series)) {
    stop("midfieldr::start_filter, series cannot be NULL")
  }

  if (isFALSE(is.atomic(series))) {
    stop("midfieldr::start_filter, series must be an atomic variable")
  }

  # assign the default terms dataset
  if (is.null(reference)) {
    reference <- midfielddata::midfieldstudents
  }

  if (!(is.data.frame(reference) || dplyr::is.tbl(reference))) {
    stop("midfieldr::start_filter, reference must be a data frame or tbl")
  }

  # ensure that the id and cip6 match the names of reference
  if (!id %in% names(reference)) {
  	stop("midfieldr::start_filter, use the id argument for non-default name")
  	}
  if (!cip6 %in% names(reference)) {
  	stop("midfieldr::start_filter, use the cip6 argument for non-default name")
  }

  # search terms in a single string
  collapse_series <- stringr::str_c(series, collapse = "|")

  # addresses R CMD check warning "no visible binding"
  ID   <- NULL
  CIP6 <- NULL

  # use wrapr::let() to allow alternate column names
  wrapr::let(
  	alias = c(ID = id, CIP6 = cip6),
  	expr = {

  		# filter for data for specified programs
  		students <- dplyr::select(reference, ID, CIP6)
  		students <- dplyr::filter(students,
  															stringr::str_detect(CIP6, collapse_series))

  		})
  students
}
"start_filter"
