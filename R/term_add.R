#' @import data.table
NULL

#' Add or subtract semesters to an encoded academic term
#'
#' Add a positive or negative number of semesters to an academic term
#' encoded \code{YYYYT}.
#'
#' The number of terms in \code{n_col} are semester equivalents, that is,
#' two semesters in an academic year. Values may be positive or negative
#' whole numbers.
#'
#' Winter and Summer terms in \code{term_col} are "rounded" down to the
#' nearest Fall or Spring before adding \code{n_col} semesters. Thus for
#' institutions on a quarter system, Winter terms (\code{T = 2}) are rounded
#' to Fall (\code{T = 1}). For all institutions, Summer terms
#' (\code{T = 4, 5, 6}) are rounded to Spring  (\code{T = 3}). The result of
#' the addition is therefore a Fall or Spring term.
#'
#' @param data data frame
#' @param term_col column name of YYYYT term
#' @param n_col column name of addend, whole number of terms
#'
#' @return \code{data.frame} with \code{tbl} or \code{data.table}
#' extensions preserved
#'
#' @noRd
#'
term_add <- function(data, term_col, n_col) {

  # check arguments
  assert_class(data, "data.frame")
  assert_class(term_col, "character")
  assert_class(n_col, "character")

  # to preserve data.frame, data.table, or tibble
  df_class <- get_dframe_class(data)

  # bind names due to nonstandard evaluation notes in R CMD check
  get_n_col <- NULL
  term_sum <- NULL
  iterm <- NULL
  jterm <- NULL
  jyear <- NULL
  year <- NULL


  # do the work
  DT <- data.table::copy(data.table::as.data.table(data))

  # separate YYYY and T
  DT[, year := floor(get(term_col) / 10)]
  DT[, t := get(term_col) - year * 10]

  # round summer to spring, winter to fall
  DT[, t := ifelse(t < 3, 1, 3)]

  # N terms if negative, add 1
  DT[, get_n_col := get(n_col)]
  DT[get_n_col < 0, get_n_col := get_n_col + 1]

  # Fall term addition, n %% 2 = 0 for n even
  DT[t == 1, jterm := ifelse(get_n_col %% 2 == 0, t, 3)]
  DT[t == 1, jyear := year + get_n_col %/% 2]
  # Spring term addition
  DT[t == 3, jyear := year + (get_n_col + 1) %/% 2]
  DT[t == 3, jterm := ifelse(get_n_col %% 2 == 0, t, 1)]

  DT[, term_sum := 10 * jyear + jterm]
  DT$year <- NULL
  DT$t <- NULL
  DT$jterm <- NULL
  DT$jyear <- NULL
  DT$get_n_col <- NULL

  # by reference,
  revive_class(DT, df_class)
}
