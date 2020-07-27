#' @importFrom data.table setDT setDF  '%chin%' as.data.table
#' @importFrom stats na.omit
NULL

#' Get IDs of students ever enrolled in programs
#'
#' Subset the rows of a data frame by CIP codes. The data are term attributes
#' keyed by student ID and term  (\code{\link[midfielddata]{midfieldterms}}
#' or equivalent). Rows are subset by 6-digit CIP codes and unique pairings of
#' CIP code and student ID. Results are the ID and CIP columns for
#' students ever enrolled in the programs.
#'
#' The default \code{data} argument is \code{midfieldterms}, accessed by
#' name or by leaving the \code{data} argument vacant. Any other
#' \code{data} argument should be a subset of \code{midfieldterms}
#' or equivalent. Character columns \code{id} and \code{cip6} are required
#' by name.
#'
#' @param data data frame of term attributes
#' @param codes character vector of 6-digit CIP codes
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item Rows for which CIP is in \code{codes} and student-program
#'   pairings are unique
#'   \item Columns \code{id} and \code{cip6}
#'   \item Grouping structures, if any, are not preserved
#'   \item Data frame extensions \code{tbl} or \code{data.table} are preserved
#' }
#'
#' @examples
#' music_programs <- get_cip(cip, "^5009")
#' music_codes <- music_programs$cip6
#' x <- get_enrollees(codes = music_codes)
#' str(x)
#'
#' music_codes <- c("500903", "500913")
#' x <- get_enrollees(codes = music_codes)
#' str(x)
#'
#' @family data_query
#'
#' @export
#'
get_enrollees <- function(data = NULL, codes = NULL) {

  # default data
  data <- data %||% midfielddata::midfieldterms

  # check arguments
  assert_explicit(codes)
  assert_class(data, "data.frame")
  assert_class(codes, "character")
  assert_required_column(data, "id")
  assert_required_column(data, "cip6")

  # bind names
  cip6 <- NULL
  id <- NULL

  # to preserve data.frame, data.table, or tibble
  dat_class <- get_df_class(data)
  DT <- data.table::as.data.table(data)

  # do the work
  DT <- DT[, .(id, cip6)]
  DT <- stats::na.omit(DT)
  DT <- DT[cip6 %chin% codes]
  DT <- dt_unique_rows(DT, c("id", "cip6"))
  revive_class(DT, dat_class)
}
