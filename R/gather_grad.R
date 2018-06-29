#' @importFrom dplyr %>% select filter arrange group_by ungroup is.tbl
#' @importFrom stringr str_c str_detect
#' @importFrom tidyr drop_na
NULL

#' Gather graduates
#'
#' Filter academic degree data for students graduating from a set of programs.
#'
#' To use this function, the \code{midfielddata} package must be installed to provide the default \code{.data} argument, \code{midfielddegrees}.
#'
#' The input data frame must include the three character variables: \code{id}, \code{cip6}, and \code{term_degree}. The default data include every degree a student earned, but only the student's first degree (or multiple degrees if earned in the same term) are retained.
#'
#' The \code{series} argument is an atomic character vector of 6-digit CIP codes used to filter the academic degree data frame.
#'
#' The function returns a subset of the input data frame with every unique combination of student ID and CIP of the program(s) in which they earned their first degree(s). Only \code{id} and \code{cip6} are returned; other variables in the input data frame are dropped.
#'
#' @param .data Data frame of academic degree data with character variables \code{id}, \code{cip6}, and \code{term_degree}
#'
#' @param series Atomic character vector of 6-digit CIP codes used to filter the data
#'
#' @return Data frame with character variables \code{id} and \code{cip6}
#'
#' @seealso \code{\link[midfieldr]{cip_filter}} for obtaining 6-digit CIP codes
#'
#' @examples
#' grad <- gather_grad(series = "540104")
#' head(grad)
#'
#' @export
gather_grad <- function(.data = NULL, series = NULL) {

	if (is.null(series)) {
		stop("midfieldr::gather_grad, series missing or incorrectly specified")
	}

	if (isFALSE(is.atomic(series))) {
		stop("midfieldr::gather_grad, series must be an atomic variable")
	}

	if(!.pkgglobalenv$has_data){
		stop(paste(
			"To use this function, you must have the",
			"`midfielddata` package installed."))
	}

	# assign the default terms dataset
	if (is.null(.data)) {.data <- midfielddata::midfielddegrees}

	if (!(is.data.frame(.data) || dplyr::is.tbl(.data))) {
		stop("midfieldr::gather_grad, .data must be a data frame or tbl")
	}

	# search terms in a single string
	collapse_series <- stringr::str_c(series, collapse = "|")

	# filter for desired programs in series
	students <- .data %>%
		dplyr::select(id, cip6, term_degree) %>%
		dplyr::filter(stringr::str_detect(cip6, collapse_series))

	# keep the first term of unique combinations of id and cip6
	students <- students %>%
		dplyr::arrange(id, cip6, term_degree) %>%
		dplyr::group_by(id, cip6) %>%
		dplyr::filter(dplyr::row_number() == 1) %>%
		dplyr::ungroup()

	# clean up before return
	students <- students %>%
		dplyr::select(-term_degree) %>%
		tidyr::drop_na() %>%
		unique()
}
"gather_grad"
