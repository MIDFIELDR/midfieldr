#' @importFrom data.table setDT setDF
NULL

#' Add terms
#'
#' Term arithmetic
#'
#' @param data data frame
#' @param ... not used for values. Forces optional arguments to be usable
#' by name only.
#' @param term_col character scalar, name of a term column, numeric format YYYYT
#' @param add_col character scalar, name of a column of terms to add, numeric
#' format T
#'
#' @return \code{data.frame}
#' @family data_carpentry
#' @examples
#' # placeholder
#'
#' @export
term_addition <- function(data = NULL, ..., term_col = NULL, add_col = NULL) {

  DT <- data.table::as.data.table(data)

  # bind names
  iterm <- NULL
  jterm <- NULL
  jyear <- NULL
  year  <- NULL

  # advance matriculation limit by transfer terms
  split_matric <- data.table::as.data.table(split_term(DT, term_col))
  DT <- merge(DT, split_matric, all.x = TRUE, by = term_col)

  # advance a Fall term, n %% 2 = 0 for n even
  fc_data_1 <- DT[iterm < 2]
  fc_data_1[, jterm := ifelse(get(add_col) %% 2 == 0, 1, 3)]
  fc_data_1[, jyear := year + get(add_col) %/% 2]

  # advance a Spring term
  fc_data_3 <- DT[iterm > 2]
  fc_data_3[, jterm := ifelse(get(add_col) %% 2 == 0, 3, 1)]
  fc_data_3[, jyear := year + (get(add_col) + 1) %/% 2]

  # rbind is insensitive to empty data frames
  DT <- rbind(fc_data_1, fc_data_3)
  DT <- DT[, (term_col) := 10 * jyear + jterm]
  DT$year <- NULL
  DT$iterm <- NULL
  DT$jterm <- NULL
  DT$jyear <- NULL
  df <- data.table::setDF(DT)
}
