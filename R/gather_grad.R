#' @importFrom dplyr select filter left_join arrange ungroup arrange row_number
#' @importFrom magrittr %>%
#' @importFrom stringr str_c str_detect
NULL

#' Gather program graduates
#'
#' Filters a data frame to return those students earning degrees from the
#' programs being studied.
#'
#' @param program_group A data frame that includes 6-digit CIP codes
#' (\code{cip6}) of the programs being studied.
#'
#' @return A data frame. Each observation is a unique degree per unique
#' student. Returns students earning their first degree (including multiple
#' degrees in the same term), but ignores any degrees earned in subsequent
#' terms.
#'
#' @export
gather_grad <- function(program_group) {
  stopifnot(is.data.frame(program_group))

  # check that necessary variables are present
  stopifnot("cip6" %in% names(program_group))

  # filter the midfielddegrees data set using the search series
  series <- stringr::str_c(program_group$cip6, collapse = "|")
  students <- midfielddata::midfielddegrees %>%
    dplyr::filter(stringr::str_detect(cip6, series))

  # remove NA
  students <- students %>%
    dplyr::filter(!is.na(cip6)) %>%
    dplyr::filter(!is.na(term_degree))

  # extract the earliest single term in which a student earns a degree
  id_first_term_degree <- students %>%
    dplyr::select(id, term_degree) %>%
    dplyr::arrange(id, term_degree) %>%
    dplyr::group_by(id) %>%
    dplyr::filter(dplyr::row_number(id) == 1) %>%
    dplyr::ungroup()

  # and keep multiple degrees earned in that term (if any)
  # using left_join(x, y), all combinations between x and y are returned
  students <- left_join(
    id_first_term_degree,
    students,
    by = c("id", "term_degree")
  )

  # join the group programs
  students <- dplyr::left_join(students, program_group, by = "cip6") %>%
    select(id, institution, cip6, program, degree)
}
"gather_grad"
