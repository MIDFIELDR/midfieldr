#' @importFrom data.table setDT setDF '%chin%'
NULL

#' Get race/ethnicity and sex of students by ID
#'
#' Subset the rows of a data frame by student ID. The data are student
#' matriculation attributes keyed by student ID
#' (\code{\link[midfielddata]{midfieldstudents}} or equivalent). Results are
#' student ID, sex, and race/ethnicity.
#'
#' The default \code{data} argument is \code{midfieldstudents}, accessed by
#' name or by leaving the \code{data} argument vacant. Any other
#' \code{data} argument should be a subset of \code{midfieldstudents}
#' or equivalent. Character columns \code{id}, \code{race}, and \code{sex}
#' are required by name.
#'
#' @param data data frame of student attributes
#'
#' @param keep_id character vector of student IDs
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item Rows for which student ID is in \code{keep_id}
#'   \item Columns \code{id}, \code{race}, and \code{sex}
#'   \item Grouping structures, if any, are not preserved
#'   \item Data frame extension attributes, e.g., tibble, are not preserved
#' }
#'
#' @family data_carpentry
#'
#' @examples
#' music_codes <- c("500901", "500903", "500913")
#' music_grads <- get_graduates(codes = music_codes)
#' grads_id    <- music_grads$id
#' grads       <- get_race_sex(keep_id = grads_id)
#' str(grads)
#'
#' @export
get_race_sex <- function(data = NULL, keep_id = NULL) {

  # default data if NULL
  data <- data %||% midfielddata::midfieldstudents

  # check arguments
  assert_class(data, "data.frame")
  assert_class(keep_id, "character")
  if(isFALSE(length(keep_id) > 0)) {
    stop("Can't find a `keep_id` argument",
         call. = FALSE)
  }

  # bind names
  id   <- NULL
  race <- NULL
  sex  <- NULL

  # do the work
  data.table::setDT(data)
  DT <- data[, .(id, race, sex)]
  DT <- DT[id %chin% keep_id, ]
  unique(DT)
  data.table::setDF(DT)
}
