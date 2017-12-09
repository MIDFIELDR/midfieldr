#' @importFrom dplyr filter
#' @importFrom magrittr %>%
#' @importFrom stringr str_length str_c str_detect
#' @importFrom tibble as.tibble
NULL

#' Filter CIP program data
#'
#' Filter CIP program data by type and series. Type is the CIP taxonomy level: 2-digit, 4-digit, or 6-digit. Series is the CIP code.
#'
#' @param type An integer (2, 4, or 6) representing the CIP taxonomy level
#'
#' @param series The first few digits of a CIP code or vector of codes. A character vector, or coercible to one. Can also be one of the predefined vectors of CIP codes for Engineering, Humanities, Mathematics, Sciences, or the Social Sciences (\code{series_engr, series_hum, series_math, series_sci, series_socsci}).
#'
#' @param data CIP data frame. The default is the midfieldr \code{cip} dataset with two variables, \code{CIP} and \code{PROGRAM}.
#'
#' @return A subset of the \code{cip} dataset filtered by type and series
#'
#' @export
#' @examples
#' # Extract all 2-digit CIP data
#' filter_cip()
#'
#' # Extract all 4-digit CIP data
#' filter_cip(type = 4)
#'
#' # Extract all 4-digit CIP data in Engineering
#' filter_cip(type = 4, series = "14")
#'
#' # Use the predefined Engineering series
#' filter_cip(type = 4, series = series_engr)
filter_cip <- function(type = NULL, series = NULL, data = NULL){

	if (is.null(data)) data <- midfieldr::cip

	# ensure a character argument
	ensure_str <- function(y) {
		if (!is.character(y)) {
			y <- as.character(y)
		} else {
			y <- y
		}
	}



	# extract the CIP columns by type (2, 4, or 6-digit)
	if (type == 2 | type == 4 | type == 6) {
		cip <- filter(data, str_length(CIP) == type)
	} else {
		stop("type must be an integer 2, 4, or 6.")
	}

	# filter the CIP by series
	if (!is.null(series)) {

		series <- ensure_str(series)

		# permit multiple series
		series_c <- str_c("^", series)
		series_c <- str_c(series_c, collapse = "|")

		cip <- filter(cip, str_detect(CIP, series_c))
	}

	if (nrow(cip) == 0) {stop("Check that the series exists.")}

	cip <- cip %>%
		unique() %>%
		tibble::as.tibble()

	return(cip)
}
"filter_cip"
