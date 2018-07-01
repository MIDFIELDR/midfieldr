#' @importFrom dplyr %>%  filter ungroup is.tbl
#' @importFrom stringr str_c str_detect
#' @importFrom tidyr drop_na
#' @importFrom seplyr select_se arrange_se group_by_se
#' @importFrom wrapr stop_if_dot_args
NULL

#' Gather ever-enrolled students
#'
#' Filter academic term data to find all students ever enrolled in specified programs.
#'
#' To use this function, the \code{midfielddata} package must be installed to provide \code{midfieldterms}, the default reference data set.
#'
#' The \code{series} argument is an atomic character vector of 6-digit CIP codes used to filter the reference data set and extract student IDs and terms.
#'
#' The function returns a subset of \code{reference} with every unique combination of student ID and program CIP, representing every student ever enrolled in the specified programs. Only the student ID and program CIP are returned; other variables in \code{reference} are quietly dropped.
#'
#' Optional arguments. An alternate reference data set can be assigned via the \code{reference} argument. The alternate must have variables for student ID, 6-digit CIP, and terms with the same structure as in \code{midfieldterms}. Use the  \code{id}, \code{cip6}, and \code{term} arguments to reassign the variables names, if necessary, to match the variable names in the alternate.
#'
#' @param series atomic character vector of 6-digit CIP codes specifying the programs to filter by
#'
#' @param ... not used for values, forces later arguments to bind by name
#'
#' @param reference a reference data frame from which student IDs, academic terms, and CIP codes are obtained, default \code{midfieldterms}
#'
#' @param id character column name of the ID variable in \code{reference}
#'
#' @param cip6 character column name of the CIP code variable in \code{reference}
#'
#' @param term character column name of term variable in \code{reference}
#'
#' @return Data frame with character variables for student ID and program CIP
#'
#' @seealso \code{\link[midfieldr]{cip_filter}} for obtaining 6-digit CIP codes
#'
#' @examples
#' ever <- gather_ever("540104")
#' ever
#'
#' @export
gather_ever <- function(series, ..., reference = NULL, id = "id", cip6 = "cip6", term = "term") {
  if (!.pkgglobalenv$has_data) {
    stop(paste(
      "To use this function, you must have",
      "the midfielddata package installed."
    ))
  }

  # force optional arguments to be usable only by name
  wrapr::stop_if_dot_args(substitute(list(...)), "gather_ever")

  if (is.null(series)) {
    stop("midfieldr::gather_ever, series cannot be NULL")
  }

  if (isFALSE(is.atomic(series))) {
    stop("midfieldr::gather_ever, series must be an atomic variable")
  }

  # assign the default terms dataset
  if (is.null(reference)) {
    reference <- midfielddata::midfieldterms
  }

  if (!(is.data.frame(reference) || dplyr::is.tbl(reference))) {
    stop("midfieldr::gather_ever, reference must be a data frame or tbl")
  }

  # search terms in a single string
  collapse_series <- stringr::str_c(series, collapse = "|")

  # filter for data for specified programs
  students <- reference %>%
    seplyr::select_se(., c(id, cip6, term)) %>%
    dplyr::filter(., stringr::str_detect(cip6, collapse_series))

  # keep the first term of unique combinations of id and cip6
  students <- students %>%
    seplyr::arrange_se(., c(id, term)) %>%
    seplyr::group_by_se(., c(id, cip6)) %>%
    dplyr::filter(dplyr::row_number() == 1) %>%
    dplyr::ungroup()

  # clean up before return
  students <- students %>%
    seplyr::select_se(., c(id, cip6)) %>%
    tidyr::drop_na() %>%
    unique()
}
"gather_ever"
