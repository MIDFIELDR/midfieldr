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
#' (\code{CIP6}) of the programs being studied.
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
  stopifnot("CIP6" %in% names(program_group))

  # filter the midfielddegrees data set using the search series
  series <- stringr::str_c(program_group$CIP6, collapse = "|")
  students <- midfielddegrees::midfielddegrees %>%
    dplyr::filter(stringr::str_detect(CIP6, series))

  # remove NA
  students <- students %>%
    dplyr::filter(!is.na(CIP6)) %>%
    dplyr::filter(!is.na(term_degree))

  # extract the earliest single term in which a student earns a degree
  ID_first_term_degree <- students %>%
    dplyr::select(ID, term_degree) %>%
    dplyr::arrange(ID, term_degree) %>%
    dplyr::group_by(ID) %>%
    dplyr::filter(dplyr::row_number(ID) == 1) %>%
    dplyr::ungroup()

  # and keep multiple degrees earned in that term (if any)
  # using left_join(x, y), all combinations between x and y are returned
  students <- left_join(
    ID_first_term_degree,
    students,
    by = c("ID", "term_degree")
  )

  # join the group programs
  students <- dplyr::left_join(students, program_group, by = "CIP6") %>%
    select(ID, institution, CIP6, program, degree)
}
"gather_grad"
