#' @importFrom data.table setDT setDF
#' @importFrom stats median
NULL

#' Get median credit hours per term by institution
#'
#' Determine the median number of credit hours per term by institution
#' for a given group of students. The data are term attributes keyed by
#' ID, institution, and term   (\code{\link[midfielddata]{midfieldterms}}
#' or equivalent). Results are the institutions and median hours per term.
#'
#' The default \code{data} argument is \code{midfieldterms}, accessed by
#' name or by leaving the \code{data} argument vacant. Any other
#' \code{data} argument should be a subset of \code{midfieldterms}
#' or equivalent. Character columns \code{id}, \code{institution} and
#' \code{hours_term} are required by name.
#'
#' The default `keep_id` argument is the set of IDs in `data`.
#'
#' @param data data frame of term attributes
#'
#' @param keep_id character vector of student IDs
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item One row per institution
#'   \item Columns \code{institution} and \code{median_hr_per_term}
#'   \item Grouping structures, if any, are not preserved
#'   \item Data frame extension attributes, e.g., tibble, are not preserved
#' }
#'
#' @family data_query
#'
#' @examples
#' # placeholder
#' @export
get_institution_hours_term <- function(data = NULL, keep_id = NULL){

  # defaults
  data <- data %||% midfielddata::midfieldterms

  # check arguments
  assert_explicit(keep_id)
  assert_class(data, "data.frame")
  assert_class(keep_id, "character")
  assert_required_column(data, "id")
  assert_required_column(data, "institution")
  assert_required_column(data, "hours_term")

  # bind names
  id            <- NULL
  institution   <- NULL
  hours_term    <- NULL
  term          <- NULL
  data_limit    <- NULL
  year          <- NULL
  iterm         <- NULL
  enter_y       <- NULL
  enter_t       <- NULL
  matric_limit  <- NULL

  # do the work
  data.table::setDT(data)
  data <- data[id %in% keep_id, .(institution, hours_term)]
  hr_per_term <- data[order(institution),
                       .(median_hr_per_term = stats::median(hours_term)),
                       by = institution]
  data.table::setDF(hr_per_term)
}
