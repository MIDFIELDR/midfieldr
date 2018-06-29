#' @importFrom dplyr select left_join anti_join %>%
NULL

#' Join student demographics to a data frame
#'
#' Add variables \code{race} and \code{sex} from the \code{midfieldstudents}
#' dataset to a data frame, using \code{id} as the join-by variable.
#'
#' If sex or race variables are already present, they are returned as-is (not overwritten).
#'
#' @param .data A data frame of student attributes that includes the variable
#' \code{id}
#'
#' @return The incoming data frame plus two new columns \code{race} and
#' \code{sex}, joined by student ID
#'
#' @export
race_sex_join <- function(.data) {

	if(!.pkgglobalenv$has_data){
		stop(paste("To use this function, you must have the",
							 "`midfielddata` package installed. See the",
							 "`midfielddata` package vignette for more details."))
	}

	if (!(is.data.frame(.data) || dplyr::is.tbl(.data))) {
		stop("midfieldr::race_sex_join() argument must be a data.frame or tbl")
	}

	# check that necessary variable is present
	if (isFALSE("id" %in% names(.data))) {
		stop("midfieldr::race_sex_join() expects id variable in .data")
	}

	# if race and sex both exist, do not overwrite
	if (isTRUE("sex" %in% names(.data)) && isTRUE("race" %in% names(.data))) {
		return(.data)
	} else {
		all_students_race_sex <- midfielddata::midfieldstudents %>%
			dplyr::select(id, race, sex)
	}
	if (isTRUE("race" %in% names(.data))) {
		all_students_race_sex <- all_students_race_sex %>%
			select(-race)
	}
	if (isTRUE("sex" %in% names(.data))) {
		all_students_race_sex <- all_students_race_sex %>%
			select(-sex)
	}

  # were all IDs matched? anti_join(): return all rows from x where there are not matching values in y, keeping just columns from x.
  check_match <- dplyr::anti_join(.data, all_students_race_sex, by = "id")
  stopifnot(identical(nrow(check_match), 0L))

  # join race and or sex by id
  .data <- left_join(.data, all_students_race_sex, by = "id")
}
"race_sex_join"
