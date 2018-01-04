#' @importFrom dplyr select left_join
#' @importFrom magrittr %>%
NULL

#' Join student demographics to a data frame
#'
#' Add variables \code{ETHNIC} and \code{SEX} from the \code{student} dataset to a data frame. `dplyr::left_join()` is the joining function and \code{MID} is the join-by variable.
#'
#' @param df A data frame of student attributes that includes the variable \code{MID}.
#'
#' @return The incoming data frame plus two new columns \code{ETHNIC} and \code{SEX}. Other columns are unaffected.
#'
#' @export
join_demographics <- function(df){

	stopifnot(is.data.frame(df))
	stopifnot("MID" %in% names(df))

	# select the three variables we need from the student dataset
	mid_eth_sex <- student %>%
		select(MID, ETHNIC, SEX)

	# join to the data frame
	df <- left_join(df, mid_eth_sex, by = "MID")

	return(df)
}
"join_demographics"
