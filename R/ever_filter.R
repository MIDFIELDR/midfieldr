#' @importFrom dplyr filter ungroup is.tbl
#' @importFrom stringr str_c str_detect
#' @importFrom tidyr drop_na
#' @importFrom wrapr stop_if_dot_args let
NULL

#' Filter term data for enrolled students
#'
#' Filter academic term data to find all students ever enrolled in specified
#' programs.
#'
#' To use this function, the \code{midfielddata} package must be installed to
#' provide the \code{midfieldterms} data frame as the default value for the
#' \code{data} argument.
#'
#' A substitute for \code{midfieldterms} may be used if it has the same structure
#' as \code{midfieldterms}.
#'
#' The \code{filter_by} argument is an atomic character vector of 6-digit CIP
#' codes used to filter \code{data} and extract student IDs and terms.
#'
#' The function returns a subset of \code{data} with every unique
#' combination of student ID and program CIP, representing every student
#' ever enrolled in the specified programs. Only the student ID and program
#' CIP are returned; other variables in \code{data} are quietly dropped.
#'
#' Optional arguments. Use the  \code{id}, \code{cip6}, and \code{term}
#' arguments to reassign the variables names, if necessary, to match the
#' variable names in the alternate.
#'
#' @param data Data frame of student IDs, academic terms, and CIP codes,
#' default \code{midfieldterms}.
#'
#' @param filter_by Atomic character vector of 6-digit CIP codes specifying the
#' programs to filter by.
#'
#' @param ... Not used for values, forces later arguments to bind by name
#'
#' @param id Optional argument, the quoted column name of the student ID
#' variable in \code{data}. Default is "id".
#'
#' @param cip6 Optional argument, the quoted column name of the 6-digit CIP
#' code variable in \code{data}. Default is "cip6".
#'
#' @param term Optional argument, the quoted column name of the term
#' variable in \code{data}. Default is "term".
#'
#' @return Data frame with character variables for student ID and program CIP
#'
#' @seealso \code{\link[midfieldr]{cip6_select}} for selecting 6-digit CIP codes
#' and naming programs.
#'
#' @examples
#' library("midfielddata")
#' (ever_filter(filter_by = "540104"))
#'
#' @export
ever_filter <- function(data = NULL, filter_by = NULL, ...,
                        id = "id",
                        cip6 = "cip6",
                        term = "term") {
  if (!.pkgglobalenv$has_data) {
    stop(paste(
      "To use this function, you must have",
      "the midfielddata package installed."
    ))
  }

  # force optional arguments to be usable only by name
  wrapr::stop_if_dot_args(substitute(list(...)), "ever_filter")

  if (is.null(data)) {
    data <- midfielddata::midfieldterms
  }
  if (!(is.data.frame(data) || dplyr::is.tbl(data))) {
    stop("midfieldr::ever_filter, data must be a data frame or tbl")
  }
  if (is.null(filter_by)) {
    stop("midfieldr::ever_filter, filter_by cannot be NULL")
  }
  if (isFALSE(is.atomic(filter_by))) {
    stop("midfieldr::ever_filter, filter_by must be an atomic variable")
  }

  # search terms in a single string
  collapse_series <- stringr::str_c(filter_by, collapse = "|")

  # addresses R CMD check warning "no visible binding"
  ID   <- NULL
  CIP6 <- NULL
  TERM <- NULL

  # use wrapr::let() to allow alternate column names
  mapping <- c(ID = id, CIP6 = cip6, TERM = term)
  wrapr::let(
    alias = mapping,
    expr = {
      # filter for specified programs
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

      # clean up before return (drop_na and unique just in case)
      students <- dplyr::select(students, ID, CIP6)
      students <- tidyr::drop_na(students)
      students <- unique(students)
    }
  )
}
"ever_filter"
