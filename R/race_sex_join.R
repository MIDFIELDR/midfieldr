#' @importFrom dplyr select left_join anti_join
#' @importFrom magrittr %>%
#' @importFrom stats complete.cases
NULL

#' Join student demographics to a data frame
#'
#' Add variables \code{race} and \code{sex} from the \code{midfieldstudents}
#' dataset to a data frame, using \code{id} is the join-by variable.
#'
#' If sex or race variables are already present, they are overwritten.
#'
#' @param .data A data frame of student attributes that includes the variable
#' \code{id}
#'
#' @return The incoming data frame plus two new columns \code{race} and
#' \code{sex}, joined by student ID
#'
#' @export
race_sex_join <- function(.data) {
  if (!(is.data.frame(.data) || dplyr::is.tbl(.data))) {
    stop("midfieldr::race_sex_join() argument must be a data.frame or tbl")
  }

  # check that necessary variable is present
  if (isFALSE("id" %in% names(.data))) {
    stop("midfieldr::race_sex_join() data frame must include an `id` variable")
  }

  # if sex OR race already in .data, delete before join
  if ("sex" %in% names(.data)) {
    .data <- dplyr::select(.data, -sex)
  }
  if ("race" %in% names(.data)) {
    .data <- dplyr::select(.data, -race)
  }

  # extract ID, race, and sex from midfieldstudents data
  all_students_race_sex <- midfielddata::midfieldstudents %>%
    dplyr::select(id, race, sex)

  # were all IDs matched? anti_join(): return all rows from x where there are not matching values in y, keeping just columns from x.
  check_match <- dplyr::anti_join(.data, all_students_race_sex, by = "id")
  stopifnot(identical(nrow(check_match), 0L))

  # join race and sex to df by id
  # left_join(): return all rows from x, and all columns from x and y.
  # Rows in x with no match in y will have NA values in the new columns.
  # If there are multiple matches between x and y, all combinations of the
  #  matches are returned.
  .data <- left_join(.data, all_students_race_sex, by = "id")
}
"race_sex_join"
