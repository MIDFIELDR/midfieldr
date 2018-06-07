#' @importFrom dplyr select filter left_join
#' @importFrom magrittr %>%
#' @importFrom stringr str_c str_detect
NULL

#' Gather students ever enrolled in a program
#'
#' Filters a data frame to
#' return only those students ever enrolled in the programs being studied.
#' Accounts for students enrolled in more than one program in a term.
#'
#' @param program_group A data frame that includes 6-digit CIP codes
#' (\code{cip6}) of the programs being studied.
#'
#' @return A data frame extracted from the \code{midfieldterms} dataset
#' with variables \code{id}, \code{institution}, \code{cip6}.
#'
#' Each observation in the resulting tidy data frame is a unique program per
#' student. Thus the student identifier (\code{id}) for students who change
#' majors will appear in more than one row, once each per unique program.
#'
#' @export
gather_ever <- function(program_group) {
  stopifnot(is.data.frame(program_group))

  # check that necessary variables are present
  stopifnot("cip6" %in% names(program_group))

  # filter the data set using the search series
  series <- stringr::str_c(program_group$cip6, collapse = "|")
  students <- midfielddata::midfieldterms %>%
    dplyr::select(id, institution, cip6) %>%
    dplyr::filter(stringr::str_detect(cip6, series)) %>%
    unique()

  # join the program labels
  students <- dplyr::left_join(students, program_group, by = "cip6")
}
"gather_ever"
