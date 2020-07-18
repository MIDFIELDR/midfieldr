#' @importFrom data.table setDT setDF
NULL

#' Get limits on feasible completion by institution
#'
#' Determine the data limit and matriculation limit for program completion
#' feasibility by institution. The data are term attributes keyed by
#' institution and term (\code{\link[midfielddata]{midfieldterms}}
#' or equivalent). Rows are subset by the latest term in the data set
#' (the data limit) by institution. Results are the institutions,
#' matriculation limits, and data limits.
#'
#' The default \code{data} argument is \code{midfieldterms}, accessed by
#' name or by leaving the \code{data} argument vacant. Any other
#' \code{data} argument should be a subset of \code{midfieldterms}
#' or equivalent. Character columns \code{institution} and \code{term} are
#' required by name.
#'
#' @param data data frame of term attributes
#'
#' @param span number of years for feasible completion
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item One row per institution
#'   \item Columns \code{institution}, \code{matric_limit},
#'   and \code{data_limit}
#'   \item Grouping structures, if any, are not preserved
#'   \item Data frame extension attributes, e.g., tibble, are not preserved
#' }
#'
#' @family data_query
#'
#' @examples
#' # placeholder
#' @export
get_institution_limits <- function(data = NULL, span = NULL){

  # defaults
  data <- data %||% midfielddata::midfieldterms
  span <- span %||% 6

  # check arguments
  assert_class(data, "data.frame")
  assert_class(span, "numeric")
  assert_required_column(data, "institution")
  assert_required_column(data, "term")

  # bind names
  institution  <- NULL
  term         <- NULL
  data_limit   <- NULL
  iterm        <- NULL
  enter_y      <- NULL
  enter_t      <- NULL
  matric_limit <- NULL
  year         <- NULL

  # do the work
  DT <- data.table::as.data.table(data)

  # find data_limit for each institution
  DT <- DT[, .(institution, term)]
  DT[, data_limit := max(term), by = institution]

  # select
  DT <- unique(DT[, .(institution, data_limit)])
  inst_data_limit <- DT # save for later merge

  # split term to create year and iterm
  DT[, year  := as.double(substr(data_limit, 1, 4))]
  DT[, iterm := as.double(substr(data_limit, 5, 5))]

  # select
  DT <- unique(DT[, .(data_limit, year, iterm)])

  # round summer and second quarter
  DT[, iterm := ifelse(iterm >= 3, 3, 1)]

  # determine matric_limit
  DT[, enter_y := ifelse(iterm > 2,
                           year - span + 1,
                           year - span)
  ][
    , enter_t := ifelse(iterm > 2, 1, 3)
  ][
    , matric_limit := 10 * enter_y + enter_t
  ]

  # select
  inst_matric_limit <- unique(DT[, .(matric_limit, data_limit)])

  # join
  inst_limits <- merge(inst_data_limit,
                       inst_matric_limit,
                       all.x = TRUE,
                       by = "data_limit")
  # select
  inst_limits <- inst_limits[order(institution),
                             .(institution, matric_limit, data_limit)]
  data.table::setDF(inst_limits)
}
