#' @importFrom data.table setDT setDF  '%chin%'
#' @importFrom stats na.omit
NULL

#' Get IDs of students graduating from programs
#'
#' Subset the rows of a data frame by CIP codes. The data are degree
#' attributes keyed by student ID (\code{\link[midfielddata]{midfielddegrees}}
#' or equivalent). Rows are subset by program CIP codes and the first term
#' in which a student earns a degree. Results are the ID and CIP columns for
#' students graduating in the programs.
#'
#' The default \code{data} argument is \code{midfielddegrees}, accessed by
#' name or by leaving the \code{data} argument vacant. Any other \code{data}
#' argument should be a subset of \code{midfielddegrees} or equivalent.
#' Character columns \code{id} and \code{cip6} and numerical column
#' \code{term_degree} are required by name.
#'
#' Degrees earned after the first degree term are dropped. Multiple degrees,
#' if earned in the first degree term, are retained.
#'
#' @param data data frame of degree attributes
#'
#' @param codes character vector of 6-digit CIP codes
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item Rows for which CIP is in \code{codes} and graduation is
#'   observed, i.e., the value of \code{term_degree} is not NA
#'   \item Columns \code{id} and \code{cip6}
#'   \item Grouping structures, if any, are not preserved
#'   \item Data frame extension attributes, e.g., tibble, are not preserved
#' }
#'
#' @family data_carpentry
#'
#' @examples
#' music_programs <- get_cip(cip, "^5009")
#' music_codes <- music_programs$cip6
#' x <- get_graduates(codes = music_codes)
#' str(x)
#'
#' music_codes <- c("500901", "500903", "500913")
#' x <- get_graduates(codes = music_codes)
#' str(x)
#'
#' @export
get_graduates <- function(data = NULL, codes = NULL) {

  # default data
  data <- data %||% midfielddata::midfielddegrees

  # check arguments
  assert_class(data, "data.frame")
  assert_class(codes, "character")

  # bind names
  id <- NULL
  cip6 <- NULL
  term_degree <- NULL

  # do the work
  data.table::setDT(data)
  DT <- data[, .(id, cip6, term_degree)]
  stats::na.omit(DT)
  DT <- DT[cip6 %chin% codes][
    , .(cip6, term_degree = min(term_degree)), by = id][
      , .(id, cip6)]
  data.table::setDF(DT)
}
