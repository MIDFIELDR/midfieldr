#' @importFrom data.table setDT setDF '%chin%' as.data.table
NULL

#' Get transfer status of students by ID
#'
#' Subset the rows of a data frame by student ID. The data are student
#' matriculation attributes keyed by student ID
#' (\code{\link[midfielddata]{midfieldstudents}} or equivalent). Results are
#' student ID, entering term, transfer status, and transfer credit hours.
#'
#' The default \code{data} argument is \code{midfieldstudents}, accessed by
#' name or by leaving the \code{data} argument vacant. Any other
#' \code{data} argument should be a subset of \code{midfieldstudents}
#' or equivalent. Character column \code{id} and
#' numerical columns \code{term_enter} and code{hours_transfer} are required
#' by name.
#'
#' @param data data frame of student attributes
#' @param keep_id character vector of student IDs
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item Rows for which student ID is in \code{keep_id}
#'   \item Columns \code{id}, \code{term_enter}, and \code{hours_transfer}
#'   \item Grouping structures, if any, are not preserved
#'   \item Data frame extensions \code{tbl} or \code{data.table} are preserved
#' }
#'
#' @examples
#' music_codes <- c("500901", "500903", "500913")
#' music_enrollees <- get_enrollees(codes = music_codes)
#' enrollees_id <- music_enrollees$id
#' enrollees <- get_status_transfers(keep_id = enrollees_id)
#' str(enrollees)
#'
#' @family data_query
#'
#' @export
#'
get_status_transfers <- function(data = NULL, keep_id = NULL) {

  # default data if NULL
  data <- data %||% midfielddata::midfieldstudents

  # check arguments
  assert_explicit(keep_id)
  assert_class(data, "data.frame")
  assert_class(keep_id, "character")
  assert_required_column(data, "id")
  assert_required_column(data, "term_enter")
  assert_required_column(data, "hours_transfer")

  # bind names
  hours_transfer <- NULL
  term_enter <- NULL
  id <- NULL

  # to preserve data.frame, data.table, or tibble
  dat_class <- get_df_class(data)
  DT <- data.table::as.data.table(data)

  # do the work
  columns <- c("id", "term_enter", "hours_transfer")
  DT <- DT[, ..columns][
    id %chin% keep_id
  ]
  DT <- dt_unique_rows(DT, columns)

  revive_class(DT, dat_class)
}
