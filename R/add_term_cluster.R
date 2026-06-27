# See R/roxygen.R for documentation below that uses inline R code

#' Identify rows of post-baccalaureate terms
#'
#' Provides a means of excluding post-baccalaureate terms by adding a
#' column of term-cluster labels identifying pre- and post-baccalaureate
#' terms. In a typical analysis, one is interested in a student's progress up to
#' and including the term in which they earn their first degree or degrees.
#' Any terms later than the first baccalaureate can usually be excluded from
#' study.
#'
#' The new columns are :
#'
#' * `first_degree_term` Character. Term of a student's first baccalaureate,
#'    encoded `YYYYT` or, if no degree recorded, `NA`. Joined from
#'    `midfield_degree$term_degree`.
#'
#' * `term_cluster` Character, indicating that a term belongs
#'    to one of three clusters: terms that are prior to ("pre-degree"), equal
#'    to ("first-degree"), or subsequent to ("post-first-degree") the student’s
#'    first degree term.
#'
#' @param dframe Working data frame of student-level records to which a
#'        term-cluster column is to be added. Required variables are `mcid` and
#'        a single term variable: `term` (when working with the term table),
#'        `term_course` (course table), or `term_degree` (degree table).
#'
#' @param midfield_degree MIDFIELD `degree` data table or equivalent with
#'        required variables `mcid` and `term_degree`.
#'
#' @returns A data frame of the same type as `dframe`. The output has the
#' following properties:
#'
#' * Rows are not modified.
#' * Columns are added, overwriting existing columns (if any) of the same name.
#'   Other columns are not modified.
#' * Groups are not preserved.
#' * Data frame attributes are preserved for classes `data.frame`, `data.table`,
#'   or `tbl_df`.
#'
#' @example man/examples/exa_add_term_cluster.R
#' @export
add_term_cluster <- function(dframe, midfield_degree = degree) {
  # ---------- checks, use base R syntax

  # assert data frames
  checkmate::qassert(dframe, "d+")
  checkmate::qassert(midfield_degree, "d+")

  # assert class of required variables
  checkmate::qassert(dframe[["mcid"]], "s+")
  checkmate::qassert(midfield_degree[["mcid"]], "s+")

  # exact match, string, length 1
  term_var_choices <- c("term", "term_course", "term_degree")

  term_variable <- intersect(term_var_choices, colnames(dframe))
  checkmate::assert_choice(term_variable, choices = term_var_choices)
  checkmate::qassert(term_variable, "s1")

  term_variable <- intersect(term_var_choices, colnames(midfield_degree))
  checkmate::assert_choice(term_variable, choices = term_var_choices)
  checkmate::qassert(term_variable, "s1")

  # ---------- preparation

  # to restore class (tibble, data.frame, etc.) before return
  prior_class <- class(dframe)

  # Copy and setDT() non-DT input. Prevents by-ref changes.
  # No change to DT class input. By-ref changes remain active.
  DT <- copy_setDT_non_DT(dframe)
  midfield_degree <- copy_setDT_non_DT(midfield_degree)

  # subset avoids change by reference
  degree_subset <- midfield_degree[, .(mcid, term_degree)]
  degree_subset <- unique(degree_subset, na.rm = TRUE)

  # bind names due to NSE notes in R CMD check
  term_col <- NULL
  term_cluster <- NULL
  first_degree_term <- NULL

  # ---------- do the work

  # variable names to add/overwrite
  term_var <- intersect(colnames(DT), term_var_choices)
  active_cols <- c("first_degree_term", "term_cluster")
  inactive_cols <- setdiff(colnames(DT), active_cols)

  # add baccalaureate term
  DT <- add_bacc_term(DT, degree_subset)

  # add temporary term col for comparison to degree term
  DT[, term_col := DT[[term_var]]]

  # assign term status labels
  DT[, term_cluster := "pre-degree"]
  DT[term_col == first_degree_term, term_cluster := "first-degree"]
  DT[term_col > first_degree_term, term_cluster := "post-first-degree"]

  # delete the temporary col
  DT[, term_col := NULL]

  # reset column order
  DT <- DT[, .SD, .SDcols = c(inactive_cols, active_cols)]

  # ---------- restore state

  # restore prior keys
  # setkeyv(DT, prior_keys)

  # Except for grouped tibbles, restores non-data.table data frames
  # to same class as input.
  DT <- restore_non_dt_class(DT, prior_class)

  DT[]
}

# ------------------------------------------------------------------
# Internal functions
# ---------------------------------------------------

add_bacc_term <- function(DT, degree_subset) {
  # ---------- do the work

  # prepare to inner join IDs and term degree, na.rm in case
  DT_id <- DT[, .(mcid)]
  DT_id <- unique(DT_id, na.rm = TRUE)

  # inner-join input-ID and midfield-degree data
  first_degree <- degree_subset[DT_id, on = .(mcid), nomatch = NULL]

  # keep the first degree term
  setorderv(first_degree, c("mcid", "term_degree"), order = 1)
  first_degree <- first_degree[, .SD[1], by = "mcid"]

  # rename the first degree term
  first_degree <- first_degree[, .(mcid, first_degree_term = term_degree)]

  # left-outer join first_degree to DT, introduces NAs in first degree term column
  DT <- first_degree[DT, on = "mcid"]

  return(DT)
}
