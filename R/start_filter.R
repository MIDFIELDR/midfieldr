#' @importFrom dplyr select is.tbl
#' @importFrom wrapr stop_if_dot_args let
#' @importFrom stringr str_c str_detect
NULL

#' Filter student data for starting students
#'
#' Filter entering student data to find all students starting in specified
#' programs.
#'
#' The \code{midfielddata} package must be installed to provide the \code{midfieldstudents} data frame as the default value for the \code{data} argument. Optionally, a data frame having the same structure as \code{midfieldstudents} may be used as the value for the \code{data} argument.
#'
#' The \code{codes} argument is an atomic character vector of 6-digit CIP codes used to filter \code{data} and extract student IDs.
#'
#' The function returns a subset of \code{data} with the student ID and starting major CIP. Only the student ID and program CIP are returned; other variables in \code{data} are quietly dropped.
#'
#' Optional arguments. Student ID variables in the midfielddata data sets are named "id". If your data frames use a different name, you can either 1) rename your variables to "id", or 2) use the optional \code{id} argument to pass the alternate variable name to the function. The same is true for the \code{cip6} variable.
#'
#' @param data Data frame of student IDs and CIP codes, default  \code{midfieldterms}.
#'
#' @param codes Atomic character vector of 6-digit CIP codes specifying the programs to filter by.
#'
#' @param ... Not used for values, forces later arguments to bind by name.
#'
#' @param id The column name in quotes of the student ID variable in \code{data}. Default is "id".
#'
#' @param cip6 The column name in quotes of the 6-digit CIP code variable in \code{data}. Default is "cip6".
#'
#' @return Data frame with character variables for student ID and CIP of the starting program.
#'
#' @seealso \code{\link[midfieldr]{cip6_select}} for selecting 6-digit CIP codes and naming programs.
#'
#' @examples
#' placeholder <- 2 + 3
#' @export
start_filter <- function(data = NULL, codes = NULL, ..., id = "id", cip6 = "cip6") {
  if (!.pkgglobalenv$has_data) {
    stop("The midfielddata package must be installed.")
  }

  # force optional arguments to be usable only by name
  wrapr::stop_if_dot_args(substitute(list(...)), "starter_filter")

  # argument checks
  if (is.null(data)) {
    data <- midfielddata::midfieldstudents
  }
  if (!(is.data.frame(data) || dplyr::is.tbl(data))) {
    stop("midfieldr::starter_filter, data must be a data frame or tbl")
  }
  if (is.null(codes)) {
    stop("midfieldr::starter_filter, codes cannot be NULL")
  }
  if (isFALSE(is.atomic(codes))) {
    stop("midfieldr::starter_filter, codes must be an atomic variable")
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
