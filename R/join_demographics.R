#' @importFrom dplyr select filter all_equal left_join mutate
#' @importFrom magrittr %>%
#' @importFrom stringr str_detect str_replace
NULL

#' Join student demographics to a data frame
#'
#' Add variables \code{race} and \code{sex} from the \code{midfieldstudents} dataset to a data frame. `dplyr::left_join()` is the joining function and \code{ID} is the join-by variable.
#'
#' @param df A data frame of student attributes that includes the variable \code{ID}.
#'
#' @return The incoming data frame plus two new columns \code{sex} and \code{race}. Other columns are unaffected.
#'
#' @export
join_demographics <- function(df) {

	stopifnot(is.data.frame(df))
	# check that necessary variables are present
	stopifnot("ID" %in% names(df))

	# filter midfieldstudents by IDs in input df
	series <- stringr::str_c(df$ID, collapse = "|")
	demographics <- midfieldstudents %>%
		dplyr::select(ID, race, sex) %>%
		dplyr::filter(stringr::str_detect(ID, series)) %>%
		unique()

	# join demographics if number of unique students identical
	if (dplyr::all_equal(unique(df$ID), demographics$ID)) {
		df <- dplyr::left_join(df, demographics, by = "ID") %>%
			dplyr::mutate(sex = stringr::str_replace(sex, "M", "Male")) %>%
			dplyr::mutate(sex = stringr::str_replace(sex, "F", "Female"))
	} else {
		warning("Mismatch between input ID and midfieldstudents data ID")
	}
	return(df)
}
"join_demographics"
