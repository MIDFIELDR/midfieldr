# See R/roxygen.R for documentation below that uses inline R code

#' Identify rows of post-baccalaureate terms
#'
#' Provides a means of excluding post-baccalaureate terms by adding a
#' column of term-status labels identifying pre- and post-baccalaureate
#' terms.
#'
#' In a typical analysis, one is interested in a student's progress up to
#' and including the term in which they earn their first degree or degrees.
#' Any terms later than the first baccalaureate can usually be excluded from
#' study.
#'
#' The input `dframe` must have a term variable with one of three possible
#' names: `term` (from the term data table), `term_course` (from the course
#' data table), or `term_degree` (from the degree data table).
#'
#' `add_term_cluster()` determines a student's first degree term (if any)
#' from `midfield_degree`, adds that column to `dframe`, and adds a second
#' column of term-status labels identifying pre- and post-baccalaureate terms.
#'
#' @param dframe `r dframe_add_term_cluster`
#' @param midfield_degree `r midfield_degree_add_term_cluster`
#'
#' @returns `r return_add_term_cluster`
#' The added columns are:
#' \describe{
#'  \item{`first_degree_term`}{Character. Term of a student's first
#'         baccalaureate, encoded `YYYYT` --- or NA if no degree recorded.}
#'  \item{`term_cluster`}{Character. Possible values are "pre-degree",
#'        "first-degree", and "post-first-degree".}
#' }
#' `r preserve_class`
#'
#' @example man/examples/add_term_cluster_exa.R
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

  # Convert non-data.table input to data.table class. By-ref changes to
  # dframe in global environment remain active for data.tables.
  DT <- prep_non_dt_input(dframe)

  # subset (use base R) avoids change by reference
  degree_subset <- midfield_degree[, c("mcid", "term_degree")]

  # Ensure data.table class
  degree_subset <- prep_non_dt_input(degree_subset)
  degree_subset <- unique(degree_subset, na.rm = TRUE)

  # preserve data.table keys if any
  # prior_keys <- key(DT)

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

# ---------------------------------------------------

# label_term_status <- function(DT, term_var){
#
#     # bind names due to NSE notes in R CMD check
#
#     term_col <- NULL
#     term_status <- NULL
#     first_degree_term <- NULL
#
#     # ---------- do the work
#
#     x <- copy(DT)
#
#     # temporary column to compare to first degree term
#     # term_var: quoted name of term column in term, course, or degree
#     x[, term_col := x[[term_var]]]
#
#     x[, term_status := "pre-bacc"]
#     x[term_col == first_degree_term, term_status := "first-degree"]
#     x[term_col  > first_degree_term, term_status := "post-first-degree"]
#
#     # delete the temporary col
#     x[["term_col"]] <- NULL
#
#     return(x)
# }
