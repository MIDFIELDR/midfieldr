#' @importFrom dplyr %>% select filter arrange group_by ungroup is.tbl
#' @importFrom stringr str_c str_detect
#' @importFrom tidyr drop_na
NULL

#' Gather ever-enrolled students
#'
#' Filter academic term data for students ever enrolled in a set of programs.
#'
#' To use this function, the \code{midfielddata} package must be installed to provide the default \code{.data} argument, \code{midfieldterms}.
#'
#' The input data frame must include the three character variables: \code{id}, \code{cip6}, and \code{term}. The default data include every term for every student, so an ID will be associated with the same program in multiple terms. Students who change majors will have their ID associated with different programs in different terms. Students enrolled in more than one major will have their ID associated with multiple programs in the same term. All unique combinations of ID and program are retained.
#'
#' The \code{series} argument is an atomic character vector of 6-digit CIP codes used to filter the academic term data frame.
#'
#' The function returns a subset of the input data frame with every unique combination of student ID and program CIP, representing every student ever enrolled in the set of programs being studied. Only \code{id} and \code{cip6} are returned; other variables in the input data frame are dropped.
#'
#' @param .data Data frame of academic term data with character variables \code{id}, \code{cip6}, and \code{term}
#'
#' @param series Atomic character vector of 6-digit CIP codes used to filter the data
#'
#' @return Data frame with character variables \code{id} and \code{cip6}
#'
#' @seealso \code{\link[midfieldr]{cip_filter}} for obtaining 6-digit CIP codes
#'
#' @examples
#' ever <- gather_ever(series = "540104")
#' head(ever)
#'
#' @export
gather_ever <- function(.data = NULL, series = NULL) {

	if (is.null(series)) {
		stop("midfieldr::gather_ever, series missing or incorrectly specified")
		}

	if (isFALSE(is.atomic(series))) {
		stop("midfieldr::gather_ever, series must be an atomic variable")
		}

	if(!.pkgglobalenv$has_data){
		stop(paste(
			"To use this function, you must have the",
			"`midfielddata` package installed."))
	}

	# assign the default terms dataset
	if (is.null(.data)) {.data <- midfielddata::midfieldterms}

	if (!(is.data.frame(.data) || dplyr::is.tbl(.data))) {
		stop("midfieldr::gather_ever, .data must be a data frame or tbl")
	}

	# search terms in a single string
	collapse_series <- stringr::str_c(series, collapse = "|")

	# filter for desired programs in series
	students <- .data %>%
		dplyr::select(id, cip6, term) %>%
		dplyr::filter(stringr::str_detect(cip6, collapse_series))

	# keep the first term of unique combinations of id and cip6
	students <- students %>%
		dplyr::arrange(id, term) %>%
		dplyr::group_by(id, cip6) %>%
		dplyr::filter(dplyr::row_number() == 1) %>%
		dplyr::ungroup()

	# clean up before return
	students <- students %>%
		dplyr::select(-term) %>%
		tidyr::drop_na() %>%
		unique()

}
"gather_ever"
