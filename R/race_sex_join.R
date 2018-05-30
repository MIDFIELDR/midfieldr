#' @importFrom dplyr select filter all_equal left_join mutate
#' @importFrom magrittr %>%
#' @importFrom stringr str_detect str_replace str_c
NULL

#' Join student demographics to a data frame
#'
#' Add variables \code{race} and \code{sex} from the \code{midfieldstudents}
#' dataset to a data frame. `dplyr::left_join()` is the joining function
#' and \code{ID} is the join-by variable.
#'
#' If sex and race variables are already present, the function returns the
#' unchanged data frame and a message.
#'
#' @param df A data frame of student attributes that includes the variable
#' \code{ID}.
#'
#' @return The incoming data frame plus three new columns \code{sex},
#' \code{race}, and the combined string \code{race_sex}, joined by student ID.
#' Other columns are unaffected.
#'
#' @export
race_sex_join <- function(df) {
  stopifnot(is.data.frame(df))

  # return if race AND sex are already variables
  if ("sex" %in% names(df) & "race" %in% names(df)) {
    message("No change to existing variables 'race' and 'sex'.")
    return(df)
  }

  # check that necessary variable is present
  stopifnot("ID" %in% names(df))

  # extract ID, race, and sex from midfieldstudents data
  race_sex <- midfieldstudents::midfieldstudents %>%
    dplyr::select(ID, race, sex)

  # if sex OR race already in df, not joined to df
  if ("sex" %in% names(df)) {
    race_sex <- race_sex %>% dplyr::select(-sex)
    message("'race' successfully joined; 'sex' returned unchanged.")
  }

  if ("race" %in% names(df)) {
    race_sex <- race_sex %>% dplyr::select(-race)
    message("'sex' successfully joined; 'race' returned unchanged.")
  }

  # filter by series of IDs in the input data frame
  series <- stringr::str_c(df$ID, collapse = "|")
  race_sex <- race_sex %>%
    dplyr::filter(stringr::str_detect(ID, series)) %>%
    unique()

  # join demographics if number of unique students identical
  stopifnot(dplyr::all_equal(unique(df$ID), race_sex$ID))

  df <- dplyr::left_join(df, race_sex, by = "ID")
}
"race_sex_join"
