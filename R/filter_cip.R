#' @importFrom dplyr filter arrange bind_rows
#' @importFrom magrittr %>%
#' @importFrom stringr str_length str_c str_detect
#' @importFrom tibble as.tibble
#' @importFrom dplyr enquo select
NULL

#' Filter CIP data
#'
#' Filter a data frame of Classification of Instructional Programs (CIP) codes to return the rows that match conditions.
#'
#' In the midfieldr datasets (\code{student}, \code{course}, \code{term},   \code{degree}) a 6-digit CIP code identifies the program in which a student is enrolled at matriculation, in a term, and at graduation. The purpose of \code{filter_cip()} is to obtain the 6-digit codes of the programs one wishes to study.
#'
#' @param series The conditions used to filter the data. A character vector (or coercible to one) of 2, 4, or 6-digit CIP codes.
#'
#' @param data A data frame of CIP codes and program names at the 2, 4, and 6-digit levels: \code{CIP2}, \code{PRGM2}, \code{CIP4}, \code{PRGM4}, \code{CIP6}, and \code{PRGM6}. The default is the midfieldr \code{cip} dataset. All variables are characters.
#'
#' @return A data frame: \code{data} filtered by the conditions in \code{series}.
#'
#' @examples
#' filter_cip(series = c("490101", "490205"))
#' filter_cip(series = c("4901", "4902"))
#' filter_cip(series = c("49", "99"))
#' filter_cip(series = c("54", "4901", "490205"))
#' filter_cip(series = seq(540102, 540108))
#'
#' @export
filter_cip <- function(series = NULL, data = NULL){

	# default cip data set
	if (is.null(data)) {

		data <- midfieldr::cip

	} else {

		# check that data frame has correct structure
    stopifnot(names(data) == names(cip))
    stopifnot(is.data.frame(data))
	}

	if (is.null(series)) {

		# default series is all codes in midfieldr::cip
		cip <- data

	} else {

		# coerce series to character
		series <- as.character(series)

		collapse_series <- str_c("^", series, collapse = "|")
		cip2 <- filter(data, str_detect(CIP2, collapse_series))
		cip4 <- filter(data, str_detect(CIP4, collapse_series))
		cip6 <- filter(data, str_detect(CIP6, collapse_series))
		cip  <- bind_rows(cip2, cip4, cip6)
	}

	# omit duplicates (if any) and arrange in order of CIP
	cip <- unique(cip) %>%
		arrange(CIP2, CIP4, CIP6)

	return(cip)
}
