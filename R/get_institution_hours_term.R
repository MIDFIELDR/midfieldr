#' @importFrom data.table setDT setDF as.data.table
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
#' If the \code{keep_id} argument is NULL, all IDs in \code{data} are used
#' by default.
#'
#' @param data data frame of term attributes
#' @param keep_id character vector of student IDs
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item One row per institution
#'   \item Columns \code{institution} and \code{median_hr_per_term}
#'   \item Grouping structures, if any, are not preserved
#'   \item Data frame extensions \code{tbl} or \code{data.table} are preserved
#' }
#'
#' @examples
#' # placeholder
#'
#' @family data_query
#'
#' @export
#'
get_institution_hours_term <- function(data = NULL, keep_id = NULL) {

  # defaults
  data <- data %||% midfielddata::midfieldterms
  keep_id <- keep_id %||% unique(midfielddata::midfieldterms$id)

  # check arguments
  assert_class(data, "data.frame")
  assert_class(keep_id, "character")
  assert_required_column(data, "id")
  assert_required_column(data, "institution")
  assert_required_column(data, "hours_term")

  # bind names
  institution <- NULL
  hours_term <- NULL
  id <- NULL

  # to preserve data.frame, data.table, or tibble
  dat_class <- get_df_class(data)
  DT <- data.table::as.data.table(data)

  # do the work
  DT <- DT[id %in% keep_id, .(institution, hours_term)]
  hr_per_term <- DT[order(institution),
    .(median_hr_per_term = stats::median(hours_term)),
    by = institution]

  revive_class(hr_per_term, dat_class)
}
