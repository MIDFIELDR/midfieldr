# See R/roxygen.R for documentation below that uses inline R code



# ---------- deprecated version ----------

#' midfieldr deprecated functions
#' @param dframe `r dframe`
#' @param midfield_degree `r midfield_x("*degree*")`
#' @rdname midfieldr-deprecated
#' @export
add_completion_status <- function(dframe, midfield_degree = degree) {
  .Deprecated(
    new = "completion_status",
    package = "midfieldr",
    msg = "This function was deprecated as part of an update to all 
    midfieldr functions. Please use `completion_status()` instead."
  )
  
  # original function calls the new function
  completion_status(dframe = dframe, midfield_rec = midfield_degree)
}
NULL



# ---------- current version ----------

#' Determine completion status
#'
#' To a data frame keyed by student ID, add a column indicating if a
#' student completed their program, and if so, whether their completion
#' was timely or late. Columns of supporting information are
#' also added.
#'
#' In many studies, students must complete their programs in a specified time
#' span to be considered "timely", for example 4, 6, or 8 years after
#' admission. By "completion" we mean an
#' undergraduate earning their first baccalaureate degree (or degrees, for
#' students earning more than one degree in the same term).
#'
#' The goal of determining timely completion is to refine a population, that
#' is, obtain a data frame of IDs that satisfy our constraints. Thus
#' `completion_status()` yields a column of completion status values and
#' columns of supporting information keyed by ID. All other columns in
#' `dframe` (if any) are dropped.
#'
#' The supporting information in the output is provided so that the user
#' can review the findings. After review, we usually delete all columns
#' except the IDs, yielding the refined population that was our goal.
#'
#' @param dframe `r dframe` Required variables: `{mcid, timely_term}`.
#'
#' @param midfield_rec `r midfield_x("*degree*")` Required variables:
#'        `{mcid, term_degree}`.
#'
#' @returns Data frame with the following properties:
#' * Data frame class is preserved. Groups and keys are not preserved.
#' * Rows are filtered for unique `mcid` values.
#' * Columns `{mcid, timely_term}` are retained (all other columns
#'   are dropped). New columns added:
#'   - `term_degree.` &nbsp; Character. Term in which the first degree(s) are
#'      completed, encoded `YYYYT`. Joined from `midfield_rec.`
#'   - `completion_status.` &nbsp; Character. Possible values are "timely"
#'      for students completing a degree no later than their timely
#'      completion terms; "late" for students completing their program
#'      after their timely completion term; and "NA" for non-completers.
#'
#' @example man/examples/exa_completion_status.R
#' @family add_*
#' @export
#'
completion_status <- function(dframe, midfield_rec = degree) {
  # define required columns and variables to be added
  dframe_vars <- c("mcid", "timely_term")
  record_vars <- c("mcid", "term_degree")
  added_vars <- c("term_degree", "completion_status")
  return_vars <- c(dframe_vars, added_vars)

  # ---------- base R checks (all data frame classes)

  # data frame assessment
  qassert(dframe, "d+")
  qassert(midfield_rec, "d+")

  # required columns
  assert_names(colnames(dframe), must.include = dframe_vars)
  assert_names(colnames(midfield_rec), must.include = record_vars)

  # class of required columns
  for (i in seq_along(dframe_vars)) {
    qassert(dframe[[dframe_vars[i]]], "s+")
  }
  for (i in seq_along(record_vars)) {
    qassert(midfield_rec[[record_vars[i]]], "s+")
  }

  # ---------- preparation

  # to restore class except for groups in tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  setDT(dframe)
  reqd_record <- copy(midfield_rec)
  setDT(reqd_record)

  # bind names due to NSE notes in R CMD check
  completion_status <- NULL
  timely_term <- NULL

  # ---------- do the work

  # subset required variables
  dframe <- dframe[, .SD, .SDcols = dframe_vars]
  dframe <- unique(dframe, na.rm = TRUE)
  reqd_record <- reqd_record[, .SD, .SDcols = record_vars]
  reqd_record <- unique(reqd_record, na.rm = TRUE)

  # join degree records
  dframe <- reqd_record[dframe, on = "mcid"]

  # ---------- timely completion labels

  # completion is timely, late, or NA
  dframe[, completion_status := fifelse(term_degree <= timely_term,
    "timely",
    "late",
    na = NA_character_
  )]

  # ---------- prepare to return

  dframe <- dframe[, .SD, .SDcols = return_vars]
  setkey(dframe, NULL)
  setattr(dframe, "class", prior_class)
  dframe[]
}
