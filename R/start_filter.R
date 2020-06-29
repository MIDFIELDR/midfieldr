#' @importFrom dplyr select is.tbl
#' @importFrom wrapr stop_if_dot_args let
#' @importFrom stringr str_c str_detect
NULL

#' Filter student data for starting students
#'
#' Filter entering student data to find all students starting in specified
#' programs.
#'
#' The \code{midfielddata} package must be installed to provide the
#'  \code{midfieldstudents} data frame as the default value for the
#'  \code{data} argument. Optionally, a data frame having the same structure
#'  as \code{midfieldstudents} may be used as the value for the \code{data}
#'   argument.
#'
#' The \code{codes} argument is an atomic character vector of 6-digit CIP
#' codes used to filter \code{data} and extract student IDs.
#'
#' The function returns a subset of \code{data} with the student ID and
#' starting major CIP. Only the student ID and program CIP are returned;
#' other variables in \code{data} are quietly dropped.
#'
#' The default values of the optional arguments are the column names
#' \code{"id"} and \code{"cip6"}.
#' If using a data frame with different column names, you can rename
#' your variables to match the defaults or use the optional arguments to
#' pass your variable name(s) to the function.
#'
#' @param data Data frame of student IDs and CIP codes, default
#'  \code{midfieldterms}.
#'
#' @param codes Atomic character vector of 6-digit CIP codes specifying the
#'  programs to filter by.
#'
#' @param ... Not used for values. Forces the subsequent optional arguments
#' to only be usable by name.
#'
#' @param id Column name in quotes of the student ID variable in
#' \code{data}. Default is "id". Optional argument.
#'
#' @param cip6 Column name in quotes of the 6-digit CIP code variable in
#' \code{data}. Default is "cip6". Optional argument.
#'
#' @return Data frame with character variables for student ID and CIP of
#' the starting program.
#' @family data_carpentry
#' @seealso \code{\link[midfieldr]{cip6_select}} for selecting 6-digit CIP
#' codes and naming programs.
#'
#' @examples
#' placeholder <- 2 + 3
#' @export
start_filter <- function(data = NULL, codes = NULL, ..., id = "id",
                         cip6 = "cip6") {

  # force optional arguments to be usable only by name
  wrapr::stop_if_dot_args(substitute(list(...)), "start_filter")

  # argument checks
  if (is.null(data)) {
    data <- midfielddata::midfieldstudents
  }
  if (!(is.data.frame(data) || dplyr::is.tbl(data))) {
    stop("start_filter data argument must be a data frame or tbl")
  }
  if (is.null(codes)) {
    stop("start_filter, codes cannot be NULL")
  }
  if (isFALSE(is.atomic(codes))) {
    stop("start_filter, codes must be an atomic variable")
  }

  # search terms in a single string
  collapse_series <- stringr::str_c(codes, collapse = "|")

  # addresses R CMD check warning "no visible binding"
  ID <- NULL
  CIP6 <- NULL

  # use wrapr::let() to allow alternate column names
  mapping <- c(ID = id, CIP6 = cip6)
  wrapr::let(
    alias = mapping,
    expr = {
      # filter for data for specified programs
      students <- dplyr::select(data, ID, CIP6)
      students <- dplyr::filter(
        students,
        stringr::str_detect(CIP6, collapse_series)
      )
    }
  )
}
"start_filter"
