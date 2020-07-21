#' @importFrom data.table setDT setDF '%chin%'
NULL

#' Get degree status of students by ID
#'
#' Subset the rows of a data frame by student ID. The data are student
#' degree attributes keyed by student ID
#' (\code{\link[midfielddata]{midfielddegrees}} or equivalent). Results are
#' student ID, institution, and degree.
#'
#' The default \code{data} argument is \code{midfielddegrees}, accessed by
#' name or by leaving the \code{data} argument vacant. Any other
#' \code{data} argument should be a subset of \code{midfielddegrees}
#' or equivalent. Character columns \code{id}, \code{institution}, and
#' \code{degree} are required by name.
#'
#' @param data data frame of degree attributes
#' @param keep_id character vector of student IDs
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item Rows for which student ID is in \code{keep_id}
#'   \item Columns \code{id}, \code{institution}, and \code{degree}
#'   \item Grouping structures, if any, are not preserved
#'   \item Data frame extension attributes, e.g., tibble, are not preserved
#' }
#'
#' @examples
#' music_codes <- c("500901", "500903", "500913")
#' students <- get_enrollees(codes = music_codes)
#' students <- get_status_degrees(keep_id = students$id)
#' str(students)
#'
#' @family data_query
#'
#' @export
#'
get_status_degrees <- function(data = NULL, keep_id = NULL) {

  # default data if NULL
  data <- data %||% midfielddata::midfielddegrees

  # check arguments
  assert_explicit(keep_id)
  assert_class(data, "data.frame")
  assert_class(keep_id, "character")
  assert_required_column(data, "id")
  assert_required_column(data, "institution")
  assert_required_column(data, "degree")

  # bind names
  id <- NULL
  term_degree <- NULL
  degree <- NULL
  institution <- NULL

  # do the work
  data.table::setDT(data)
  DT <- data[id %chin% keep_id][
    , .(institution, degree, term_degree = min(term_degree)),
    by = id
  ][
    , .(id, institution, degree)
  ]
  data.table::setDF(DT)
}
