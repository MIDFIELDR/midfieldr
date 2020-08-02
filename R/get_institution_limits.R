#' @importFrom data.table setDT setDF as.data.table
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
#' @param span number of years for feasible completion
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item One row per institution
#'   \item Columns \code{institution}, \code{matric_limit},
#'   and \code{data_limit}
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
get_institution_limits <- function(data = NULL, span = NULL) {

  # defaults
  data <- data %||% midfielddata::midfieldterms
  span <- span %||% 6

  # check arguments
  assert_class(data, "data.frame")
  assert_class(span, "numeric")
  assert_required_column(data, "institution")
  assert_required_column(data, "term")

  # bind names
  matric_limit <- NULL
  institution <- NULL
  data_limit <- NULL
  enter_y <- NULL
  enter_t <- NULL
  iterm <- NULL
  year <- NULL
  term <- NULL

  # to preserve data.frame, data.table, or tibble
  dat_class <- get_df_class(data)
  DT <- data.table::as.data.table(data)

  # find data_limit for each institution
  columns <- c("institution", "term")
  DT <- DT[, ..columns]
  DT <- unique_by_keys(DT, columns)
  DT[, data_limit := max(term), by = institution]

  # select
  columns <- c("institution", "data_limit")
  DT <- DT[, ..columns]
  DT <- unique_by_keys(DT, columns)
  inst_data_limit <- DT # save for later merge

  # split term to create year and iterm
  DT[, year := as.double(substr(data_limit, 1, 4))]
  DT[, iterm := as.double(substr(data_limit, 5, 5))]

  # select
  columns <- c("data_limit", "year", "iterm")
  DT <- DT[, ..columns]
  DT <- unique_by_keys(DT, columns)

  # round summer and second quarter
  DT[, iterm := ifelse(iterm >= 3, 3, 1)]

  # determine matric_limit
  DT[, enter_y := ifelse(iterm > 2,
    year - span + 1,
    year - span
  )][
    , enter_t := ifelse(iterm > 2, 1, 3)
  ][
    , matric_limit := 10 * enter_y + enter_t
  ]

  # select
  columns <- c("matric_limit", "data_limit")
  inst_matric_limit <- DT[, ..columns]
  inst_matric_limit <- unique_by_keys(inst_matric_limit, columns)

  # join
  inst_limits <- merge(inst_data_limit,
    inst_matric_limit,
    by = "data_limit",
    all.x = TRUE
  )
  # select
  inst_limits <- inst_limits[
    order(institution),
    .(institution, matric_limit, data_limit)
  ]

  revive_class(inst_limits, dat_class)
}
