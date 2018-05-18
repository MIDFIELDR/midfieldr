#' @importFrom dplyr select filter arrange left_join
#' @importFrom tidyr gather
#' @importFrom magrittr %>%
#' @importFrom stringr str_c str_detect
NULL

#' Gather students ever enrolled in a program
#'
#' Filters the \code{term} data frame from the \pkg{midfieldterm} package to
#' return only those students ever enrolled in the programs being studied.
#' Accounts for students enrolled in more than one program in a term. Adds
#' student demographics from \pkg{midfieldstudent}.
#'
#' @param term A data frame of term data from \pkg{midfieldterm}.
#'
#' @param programs A data frame with the 6-digit CIP codes (\code{CIP6}) and
#' custom label (\code{PGRM}) for the programs being studied.
#'
#' @return A data frame with variables  MID, BEGINYEAR, TYEAR, TTERM, and
#' INSTITUTION from the original \code{term} data frame plus new variables:
#'
#' \tabular{ll}{
#' \code{TCIPN} \tab The "key" variable for gathering the variable names
#' \code{TCIP}, \code{TCIP2}, and \code{TCIP3}.\cr
#' \code{CIP6} \tab The 6-digit code of the program in which the student is
#' enrolled.\cr
#' \code{ETHNIC} \tab Student race/ethnicty as defined in
#' \pkg{midfieldstudent}\cr
#' \code{SEX} \tab Student sex as defined in \pkg{midfieldstudent}\cr
#' }
#'
#' Each observation in the resulting tidy data frame is a unique program per
#' student. Thus the student identifier (\code{MID}) for students who change
#' majors will appear in more than one row, once each per unique program. If
#' extant, values \code{TCIP2} and \code{TCIP3} indicate that a student is
#' enrolled in more than one program in that term.
#'
#' @export
gather_ever <- function(term, programs) {
	# select only those variables likely to be used for grouping
	# ever <- term %>%
	# 	dplyr::select(ID, pro, TYEAR, TTERM, INSTITUTION, TCIP, TCIP2, TCIP3)

	# gather all 6-digit codes (TCIP, TCIP2, TCIP3) in one column.
	# ever <- ever %>%
	# 	tidyr::gather(TCIPN, CIP6, TCIP:TCIP3) %>%
	# 	unique()

	# collapse the programs CIP6 vector to a search string
	# then filter `ever` for the desired programs
	series <- stringr::str_c(programs$CIP6, collapse = "|")
	ever <- term %>%
		dplyr::filter(str_detect(CIP6, series)) %>%
		unique()

	# Join the program labels to ever
	ever <- left_join(ever, programs, by = "CIP6") %>%
		dplyr::arrange(CIP6)

	# Join the sex and ethnicity/race demographics from the `student` dataset
	# to the `ever` data frame.
	ever <- join_demographics(ever)

	return(ever)
}
"gather_ever"
