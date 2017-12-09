#' @importFrom dplyr select left_join
#' @importFrom magrittr %>%
NULL

#' Join student demographics to term, course, or degree data
#'
#' Gather student demographic information from the \code{student} dataset and use `dplyr::left_join()` to join to a data frame.
#'
#' @param x A data frame of student attributes for term, course, or degree.
#'
#' @return The input data frame with added demographic variables joined by MID and Institution.
#'
#' @export
join_demographics <- function(x){

	stopifnot(is.data.frame(x))
	stopifnot("MID" %in% names(x))

	# filter the demographic data for just the variables we need
	student <- student %>%
		select(MID, ETHNIC, SEX)

	# join to grad data frame
	x <- left_join(x, student, by = "MID")

	return(x)
}
"join_demographics"
