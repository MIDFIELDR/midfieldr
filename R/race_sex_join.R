#' @importFrom dplyr select left_join anti_join %>%
#' @importFrom wrapr stop_if_dot_args
NULL

#' Join student demographics
#'
#' Add student race and sex to a data frame.
#'
#' To use this function, the \code{midfielddata} package must be installed to provide \code{midfieldstudents}, the default reference data set.
#'
#' The student IDs in \code{data} are assumed to be a subset of the IDs in  \code{reference} with the same variable name. This name can be changed to match a different reference data set using the optional \code{id} argument.
#'
#' Race and sex data are obtained from the reference data set. These variable names can also be changed to match a different reference data set using the optional \code{race} and \code{sex} arguments.  These variables are joined to \code{data} using ID as the join-by variable.
#'
#' If sex or race variables are already present in the input data frame, they are returned unaltered.
#'
#' @param data data frame to which race and sex are to be joined by student IDs
#'
#' @param ... not used for values, forces later optional arguments to bind by name
#'
#' @param reference a reference data frame from which student race and sex are obtained, default \code{midfieldstudents}
#'
#' @param id character column name of the ID variable in both \code{data} and \code{reference}
#'
#' @param race character column name of the race variable in \code{reference}
#'
#' @param sex character column name of the sex variable in \code{reference}
#'
#' @return The input data frame is returned with two new columns for race and sex
#'
#' @export
race_sex_join <- function(data, ..., reference = NULL, id = "id", race = "race", sex = "sex") {

  # force optional arguments to be usable only by name
  wrapr::stop_if_dot_args(substitute(list(...)), "race_sex_join")

  if (!.pkgglobalenv$has_data) {
    stop(paste(
      "To use this function, you must have",
      "the midfielddata package installed."
    ))
  }

  if (!(is.data.frame(data) || dplyr::is.tbl(data))) {
    stop("midfieldr::race_sex_join() argument must be a data.frame or tbl")
  }
  if (is.null(data)) {
    stop("midfieldr::race_sex_join, data cannot be NULL")
  }

  if (isFALSE(id %in% names(data))) {
    stop("midfieldr::race_sex_join, id missing from data")
  }

  # assign the default reference data set
  if (is.null(reference)) {
    reference <- midfielddata::midfieldstudents
  }

  if (isFALSE(id %in% names(reference) || race %in% names(reference) || sex %in% names(reference))) {
    stop("midfieldr::race_sex_join, id, race, or sex missing from reference data")
  }

  # if race and sex both exist, do not overwrite
  if (isTRUE(sex %in% names(data)) && isTRUE(race %in% names(data))) {
    return(data)
  } else {
    all_id_race_sex <- reference %>%
      seplyr::select_se(., c(id, race, sex))
  }
  if (isTRUE(race %in% names(data))) {
    all_id_race_sex <- all_id_race_sex %>%
      seplyr::select_se(., c(id, sex))
  }
  if (isTRUE(sex %in% names(data))) {
    all_id_race_sex <- all_id_race_sex %>%
      seplyr::select_se(., c(id, race))
  }

  # were all IDs matched? anti_join(): return all rows from x where there are not matching values in y, keeping just columns from x.
  mismatch <- dplyr::anti_join(data, all_id_race_sex, by = id)
  if (isFALSE(identical(nrow(mismatch), 0L))) {
    stop("midfieldr::race_sex_join, id mismatch between data and reference")
  }

  # join race and or sex by id
  data <- left_join(data, all_id_race_sex, by = id)
}
"race_sex_join"
