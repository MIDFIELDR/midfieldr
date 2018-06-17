#' @importFrom dplyr select left_join anti_join
#' @importFrom magrittr %>%
#' @importFrom stats complete.cases
NULL

#' Join student demographics to a data frame
#'
#' Add variables \code{race} and \code{sex} from the \code{midfieldstudents}
#' dataset to a data frame. `dplyr::left_join()` is the joining function
#' and \code{id} is the join-by variable.
#'
#' If sex and race variables are already present, they are overwritten by race
#' and sex data from \code{midfieldstudents}.
#'
#' @param df A data frame of student attributes that includes the variable
#' \code{id}.
#'
#' @return The incoming data frame plus two new columns \code{race} and
#' \code{sex}, joined by student ID. Other columns are unaffected.
#'
#' @export
race_sex_join <- function(df) {
	stopifnot(is.data.frame(df))

	# check that necessary variable is present
	stopifnot("id" %in% names(df))

	# extract ID, race, and sex from midfieldstudents data
	all_students <- midfielddata::midfieldstudents %>%
		dplyr::select(id, race, sex)

	# if sex OR race already in df, delete before join
	if ("sex"  %in% names(df)) {df <- dplyr::select(df,  -sex)}
	if ("race" %in% names(df)) {df <- dplyr::select(df, -race)}

	# were all IDs matched?
	# anti_join(): return all rows from x where there are not matching values in
	# y, keeping just columns from x.
	check_match <- dplyr::anti_join(df, all_students, by = "id")
	stopifnot(identical(nrow(check_match), 0L))

	# join race and sex to df by id
	# left_join(): return all rows from x, and all columns from x and y.
	# Rows in x with no match in y will have NA values in the new columns.
	# If there are multiple matches between x and y, all combinations of the
	#  matches are returned.
	df <- left_join(df, all_students, by = "id")

}
"race_sex_join"
