#' @importFrom dplyr select filter left_join
#' @importFrom magrittr %>%
#' @importFrom stringr str_c str_detect
NULL

#' Gather students ever enrolled in a program
#'
#' Filters a data frame to
#' return only those students ever enrolled in the programs being studied.
#' Accounts for students enrolled in more than one program in a term.
#'
#' @param data A data frame of term data from \pkg{midfieldterms}.
#'
#' @param group A data frame with 6-digit CIP codes (\code{CIP6}) for the programs being studied.
#'
#' @return A data frame with variables  \code{ID}, \code{institution}, \code{CIP6} from the original \code{midfieldterms} data.
#'
#' Each observation in the resulting tidy data frame is a unique program per
#' student. Thus the student identifier (\code{MID}) for students who change
#' majors will appear in more than one row, once each per unique program. If
#' extant, values \code{TCIP2} and \code{TCIP3} indicate that a student is
#' enrolled in more than one program in that term.
#'
#' @export
gather_ever <- function(data, group) {

	# check that necessary variables are present
	stopifnot(c("ID", "CIP6", "institution") %in% names(data))
	stopifnot("CIP6" %in% names(group))

	# filter the data set using the search series
	series   <- stringr::str_c(group$CIP6, collapse = "|")
	students <- data %>%
		dplyr::select(ID, institution, CIP6) %>%
		dplyr::filter(stringr::str_detect(CIP6, series)) %>%
		unique()

  # join the group programs
	students <- dplyr::left_join(students, group, by = "CIP6")
}
"gather_ever"
