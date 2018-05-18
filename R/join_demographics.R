#' @importFrom dplyr select left_join semi_join
#' @importFrom magrittr %>%
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
join_demographics <- function(df){

	stopifnot(is.data.frame(df))
	stopifnot("ID" %in% names(df))

	# select the three variables we need from the student dataset
	studentID_sex_race <- midfieldstudents %>%
		select(ID, sex, race) %>%
		unique()

	# use semi_join to return all rows from the students data frame
	# with matching IDs in the ever data farme
	studentID_sex_race <- semi_join(studentID_sex_race, df, by = "ID") %>%
		unique()

	# join to the data frame
	df <- left_join(df, studentID_sex_race, by = "ID")

	return(df)
}
"join_demographics"
