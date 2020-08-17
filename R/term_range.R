#' @importFrom data.table as.data.table copy
NULL

#' Range of terms by institution
#'
#' Determine the range of terms in a data frame by institution. Returns the
#' minimum and maximum terms.
#'
#' \code{data} is one of the midfielddata data sets or equivalent, with one
#' column name starting with "term" and one named "institution."  The function
#' identifies the term column and returns the minimum and maximum values by
#' institution, ignoring NA values.
#'
#' Each midfielddata data set has one column that starts with "term":
#'
#' \tabular{lll}{
#' \tab\code{term} \tab in \code{midfieldterms}\cr
#' \tab\code{term_enter} \tab in \code{midfieldstudents}\cr
#' \tab\code{term_course  } \tab in \code{midfieldcourses}\cr
#' \tab\code{term_degree  } \tab in \code{midfielddegrees}\cr
#' }
#'
#' @param data data frame
#' @return data frame with the following properties:
#' \itemize{
#'     \item One row per institution
#'     \item Columns \code{institution}, \code{min_term}, \code{max_term}
#' }
#'
#' @noRd
#'
term_range <- function(data) {

  # check arguments
  assert_explicit(data)
  assert_class(data, "data.frame")
  assert_required_column(data, "institution")

  # identify single column that starts with term
  term_col <- names(data)[grepl("^term", names(data))]
  if (seq_along(term_col) > 1) {
    stop("Only one column name may start with `term`")
  }
  if (seq_along(term_col) < 1) {
    stop("One column name must start with `term`")
  }

  # bind names
  min_term <- NULL
  max_term <- NULL

  # preserve data.frame, data.table, or tibble
  df_class <- get_df_class(data)
  DT <- data.table::copy(data.table::as.data.table(data))

  columns_we_want <- c("institution", term_col)
  DT <- DT[, ..columns_we_want]
  DT[,
    min_term := min(.SD, na.rm = TRUE),
    by = "institution",
    .SDcols = term_col
  ]
  DT[,
    max_term := max(.SD, na.rm = TRUE),
    by = "institution",
    .SDcols = term_col
  ]

  # return
  keep_col <- c("institution", "min_term", "max_term")
  DT <- DT[order(institution), ..keep_col]
  DT <- unique_by_keys(DT)
  revive_class(DT, df_class)
}
