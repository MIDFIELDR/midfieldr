#' @importFrom dplyr select left_join anti_join
#' @importFrom wrapr stop_if_dot_args let
NULL

#' Join student demographics
#'
#' Add student race/ethnicity and sex variables to a data frame.
#'
#' The \code{data} argument is a data frame to which student race/ethnicity and sex data are to be joined and returned.
#'
#' Student race/ethnicity and sex information are obtained from the \code{demographics} data frame with a default value of  \code{midfieldstudents} from the midfielddata package. Optionally, any data frame having the same structure as \code{midfieldstudents} can be used.
#'
#' The student ID variables in \code{data} and \code{demographics} must have the same column name. The values of the ID variable in \code{data} are assumed to be a subset of the values in \code{demographics}.
#'
#' If  \code{data} already contains \code{race} and \code{sex} variables, a join does not take place and \code{data} is returned unaltered.
#'
#' Optional arguments. Student ID variables in the midfielddata data sets are named "id". If your data frames use a different name, you can either 1) rename your variables to "id", or 2) use the optional \code{id} argument to pass the alternate variable name to the function. The same is true for the \code{race} and \code{sex} variables.
#'
#' @param data Data frame to which race and sex are to be joined by student IDs
#'
#' @param demographics A data frame from which student race and sex are obtained, default \code{midfieldstudents}
#'
#'
#' @param ... Not used for values, forces later optional arguments to bind by name.
#'
#' @param id Optional character column name of the ID variable in both \code{data} and \code{demographics}.
#'
#' @param race Optional character column name of the race variable in \code{demographics}.
#'
#' @param sex Optional character column name of the sex variable in \code{demographics}.
#'
#' @return The input data frame is returned with two new columns for race and sex.
#'
#' @export
race_sex_join <- function(data = NULL, demographics = NULL, ..., id = "id", race = "race", sex = "sex") {

  # force optional arguments to be usable only by name
  wrapr::stop_if_dot_args(substitute(list(...)), "race_sex_join")

  if (!.pkgglobalenv$has_data) {
    stop(paste(
      "To use this function, you must have",
      "the midfielddata package installed."
    ))
  }

  # argument checks
  if (is.null(demographics)) {
    demographics <- midfielddata::midfieldstudents
  }
  if (!(is.data.frame(data) || dplyr::is.tbl(data))) {
    stop("midfieldr::race_sex_join() data argument must be a data.frame or tbl")
  }
  if (is.null(data)) {
    stop("midfieldr::race_sex_join, data cannot be NULL")
  }

  # addresses R CMD check warning "no visible binding"
  ID <- NULL
  RACE <- NULL
  SEX <- NULL

  # use wrapr::let() to allow alternate column names

  wrapr::let(
    alias = c(ID = id, RACE = race, SEX = sex),
    expr = {
      if (isFALSE(ID %in% names(data))) {
        stop("midfieldr::race_sex_join, id missing from data")
      }

      if (isFALSE(ID %in% names(demographics) ||
        RACE %in% names(demographics) ||
        SEX %in% names(demographics))) {
        stop(paste(
          "midfieldr::race_sex_join, id, race, or sex",
          "missing from demographics"
        ))
      }

      # if race and sex both exist, do not overwrite
      if (isTRUE(SEX %in% names(data)) && isTRUE(RACE %in% names(data))) {
        return(data)
      } else {
        all_id_race_sex <- dplyr::select(demographics, ID, RACE, SEX)
      }
      if (isTRUE(race %in% names(data))) {
        all_id_race_sex <- dplyr::select(all_id_race_sex, ID, SEX)
      }
      if (isTRUE(sex %in% names(data))) {
        all_id_race_sex <- dplyr::select(all_id_race_sex, ID, RACE)
      }

      # were all IDs matched? anti_join(): return all rows from x where there
      # are not matching values in y, keeping just columns from x.
      mismatch <- dplyr::anti_join(data, all_id_race_sex, by = ID)
      if (isFALSE(identical(nrow(mismatch), 0L))) {
        stop("midfieldr::race_sex_join, id mismatch between data and demographics")
      }

      # join race and or sex by id
      data <- dplyr::left_join(data, all_id_race_sex, by = ID)
    }
  )
}
"race_sex_join"
