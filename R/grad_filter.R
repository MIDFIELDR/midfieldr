#' @importFrom dplyr filter ungroup is.tbl
#' @importFrom stringr str_c str_detect
#' @importFrom tidyr drop_na
#' @importFrom wrapr stop_if_dot_args let
NULL

#' Filter degree data for graduating students
#'
#' Filter academic degree data to find all students graduating from specified programs.
#'
#' The \code{midfielddata} package must be installed to provide the \code{midfielddegrees} data frame as the default value for the \code{data} argument. Optionally, a data frame having the same structure as \code{midfielddegrees} may be used as the value for the \code{data} argument.
#'
#' The \code{codes} argument is an atomic character vector of 6-digit CIP codes used to filter \code{data} and extract student IDs and terms.
#'
#' The function returns a subset of \code{data} with every unique combination of student ID and CIP of the program(s) in which they earned their first degree(s). Only the student ID and program CIP are returned; other variables in \code{data} are quietly dropped.
#'
#' Optional arguments. Student ID variables in the midfielddata data sets are named "id". If your data frames use a different name, you can either 1) rename your variables to "id", or 2) use the optional \code{id} argument to pass the alternate variable name to the function. The same is true for the \code{cip6} and \code{term} variables.
#'
#' @param data Data frame of student IDs, academic terms, and CIP codes, default \code{midfielddegrees}.
#'
#' @param codes Atomic character vector of 6-digit CIP codes specifying the programs to filter by.
#'
#' @param ... Not used for values, forces later arguments to bind by name
#'
#' @param id The column name in quotes of the student ID variable in \code{data}. Default is "id".
#'
#' @param cip6 The column name in quotes of the 6-digit CIP code variable in \code{data}. Default is "cip6".
#'
#' @param term The column name in quotes of the term variable in \code{data}. Default is "term".
#'
#' @return Data frame with character variables for student ID and program CIP
#'
#' @seealso \code{\link[midfieldr]{cip6_select}} for selecting 6-digit CIP codes and naming programs.
#'
#' @examples
#' library("midfielddata")
#' (grad_filter(codes = "540104"))
#' @export
grad_filter <- function(data = NULL, codes = NULL, ..., id = "id", cip6 = "cip6", term = "term_degree") {
  if (!.pkgglobalenv$has_data) {
    stop(paste(
      "To use this function, you must have",
      "the midfielddata package installed."
    ))
  }

  # force optional arguments to be usable only by name
  wrapr::stop_if_dot_args(substitute(list(...)), "grad_filter")

  # argument checks
  if (is.null(data)) {
    data <- midfielddata::midfielddegrees
  }
  if (!(is.data.frame(data) || dplyr::is.tbl(data))) {
    stop("midfieldr::grad_filter, data must be a data frame or tbl")
  }
  if (is.null(codes)) {
    stop("midfieldr::grad_filter, codes cannot be NULL")
  }
  if (isFALSE(is.atomic(codes))) {
    stop("midfieldr::grad_filter, codes must be an atomic variable")
  }


  # search terms in a single string
  collapse_series <- stringr::str_c(codes, collapse = "|")

  # addresses R CMD check warning "no visible binding"
  ID <- NULL
  CIP6 <- NULL
  TERM <- NULL

  # use wrapr::let() to allow alternate column names
  mapping <- c(ID = id, CIP6 = cip6, TERM = term)
  wrapr::let(
    alias = mapping,
    expr = {
      # filter for data for specified programs
      students <- dplyr::select(data, ID, CIP6, TERM)
      students <- dplyr::filter(
        students,
        stringr::str_detect(CIP6, collapse_series)
      )

      # keep the first term of unique combinations of id and cip6
      students <- dplyr::arrange(students, ID, TERM)
      students <- dplyr::group_by(students, ID, CIP6)
      students <- dplyr::filter(students, dplyr::row_number() == 1)
      students <- dplyr::ungroup(students)

      # clean up before return
      students <- dplyr::select(students, ID, CIP6)
      students <- tidyr::drop_na(students)
      students <- unique(students)
    }
  )
}
"grad_filter"
