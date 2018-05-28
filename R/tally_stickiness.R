#' @importFrom dplyr left_join mutate arrange na_if
#' @importFrom magrittr %>%
NULL

#' Computes stickiness
#'
#' Given the numbers of students graduating from a program and the number of students ever enrolled in a program, the ratio of the two numbers is stickiness.
#'
#' @param ever A data frame
#'
#' @param grad A data frame
#'
#' @return A data frame
#'
#' The two input data frames are joined by the set of variables they have in common.
#'
#' @export
tally_stickiness <- function(ever, grad) {
	stopifnot(is.data.frame(ever))
	stopifnot(is.data.frame(grad))

	stickiness <- dplyr::left_join(ever, grad) %>%
		dplyr::mutate(stick = round(grad / dplyr::na_if(ever, 0), 3))
}
"tally_stickiness"
