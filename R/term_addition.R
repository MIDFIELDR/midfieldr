#' @importFrom data.table setDT setDF as.data.table
NULL

#' Add semesters to an encoded academic term
#'
#' Add a whole number of semesters to an academic term encoded \code{YYYYT}
#'
#' @param data data frame
#' @param term_col character name of a numeric column of terms
#' encoded YYYYT
#' @param add_col character name of a numeric column of the whole number
#' of semesters to add to YYYYT
#'
#' @return \code{data.frame} with \code{tbl} or \code{data.table}
#' extensions preserved
#'
#' @examples
#' # placeholder
#'
#' @family data_carpentry
#'
#' @export
#'
term_addition <- function(data = NULL, term_col = NULL, add_col = NULL) {

  # check arguments
  assert_class(data, "data.frame")
  assert_class(term_col, "character")
  assert_class(add_col, "character")

  # to preserve data.frame, data.table, or tibble
  dat_class <- get_df_class(data)

  # bind names
  iterm <- NULL
  jterm <- NULL
  jyear <- NULL
  year  <- NULL

  # do the work
  DT <- data.table::as.data.table(data)

  # split the YYYYT to prep for term addition
  split_matric <- split_term(DT, term_col)

  # left join split_matric to DT
  DT <- split_matric[DT, on = "matric_limit"]

  # advance a Fall term, n %% 2 = 0 for n even
  fc_data_1 <- DT[iterm < 2]
  fc_data_1[, jterm := ifelse(get(add_col) %% 2 == 0, 1, 3)]
  fc_data_1[, jyear := year + get(add_col) %/% 2]

  # advance a Spring term
  fc_data_3 <- DT[iterm > 2]
  fc_data_3[, jterm := ifelse(get(add_col) %% 2 == 0, 3, 1)]
  fc_data_3[, jyear := year + (get(add_col) + 1) %/% 2]

  # bind
  DT <- rbind(fc_data_1, fc_data_3)
  DT[, (term_col) := 10 * jyear + jterm]
  DT$year  <- NULL
  DT$iterm <- NULL
  DT$jterm <- NULL
  DT$jyear <- NULL

  # by reference,
  revive_class(DT, dat_class)
}
