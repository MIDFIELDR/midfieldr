# See R/roxygen.R for documentation below that uses inline R code
#
# ---------- deprecated version
#
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
  completion_status(dframe = dframe, midfield_table = midfield_degree)
}
NULL
#
# ---------- current version
#
#' Determine completion status
#'
#' For each student in a data frame, determine their *completion status*
#' (timely, late, or NA) and add columns that support the findings.
#'
#' By *completing a program* we mean an undergraduate earning their first
#' baccalaureate degree or degrees. *Timely* completion is typically 4, 6, or
#' 8 years after admission depending on the definition adopted in a particular
#' study. The term at the upper limit of that span is the
#' *timely completion term.*
#'
#' Our heuristic obtains a student's first degree term (if any) from
#' `midfield_table`. Completion status is "timely" for students completing
#' a degree no later than their timely completion terms; "late" for
#' students completing their program after their timely completion term;
#' and "NA" for non-completers. These results are documented in the output.
#'
#' @param dframe `r dframe` with required variables `{mcid, timely_term}.`
#'        The latter variable is provided by `timely_term().`
#'
#' @param midfield_table `r midfield_x("degree")` with required
#'        variables `{mcid, term_degree}.`
#'
#' @returns Data frame with the following properties:
#' * `r class_presrv`
#' * `r rows_not_mod`
#' * Columns `{mcid, timely_term}` are retained. All other columns (if any)
#'   are dropped and the following variables are added:
#'   - `term_degree.` &nbsp; Character. Term in which the first degree(s) are
#'      completed, encoded `YYYYT`. Joined from `midfield_table.`
#'   - `completion_status.` &nbsp; Character. Possible values are "timely",
#'      "late" and "NA".
#' * `r groups_not`
#'
#' @example man/examples/exa_completion_status.R
#' @export
#'
completion_status <- function(dframe, midfield_table = degree) {
  #
  # ---------- assign active column names
  
  reqd_dframe_vars <- c("mcid", "timely_term")
  reqd_table_vars <- c("mcid", "term_degree")
  added_vars <- c("term_degree", "completion_status")
  
  # ---------- base R checks (all data frame classes)
  
  # data frame assessment
  qassert(dframe, "d+")
  qassert(midfield_table, "d+")

  # required columns
  assert_names(colnames(dframe), must.include = reqd_dframe_vars)
  assert_names(colnames(midfield_table), must.include = reqd_table_vars)

  # class of required columns
  for (i in seq_along(reqd_dframe_vars)) {
    qassert(dframe[[reqd_dframe_vars[i]]], "s+")
  }
  for (i in seq_along(reqd_table_vars)) {
    qassert(midfield_table[[reqd_table_vars[i]]], "s+")
  }
  
  # ---------- preparation
  
  # to restore class, but not grouped_DF (tibbles)
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  setDT(dframe)
  midf_table <- copy(midfield_table)
  setDT(midf_table)

  # bind names due to NSE notes in R CMD check
  completion_status <- NULL
  idx <- NULL
  timely_term <- NULL
  
  # ---------- do the work
  
  # subset required variables
  dframe <- dframe[, .SD, .SDcols = reqd_dframe_vars]
  dframe <- unique(dframe, na.rm = TRUE)
  midf_table <- midf_table[, .SD, .SDcols = reqd_table_vars]
  midf_table <- unique(midf_table, na.rm = TRUE)

  # add temp col to restore row order
  dframe[, idx := .I]

  # join degree records
  dframe <- midf_table[dframe, on = "mcid"]
  
  # ---------- timely completion labels
  
  # completion is timely, late, or NA
  dframe[, completion_status := fifelse(
    term_degree <= timely_term,
    "timely",
    "late",
    na = NA_character_
  )]
  
  # ---------- prepare to return
  
  # restore row order
  setkey(dframe, idx)

  # drop temp cols, restore col order, ensure unique rows
  dframe <- dframe[, .SD, .SDcols = c(reqd_dframe_vars, added_vars)]
  dframe <- unique(dframe)

  # restore class
  setkey(dframe, NULL)
  setattr(dframe, "class", prior_class)

  # done
  dframe[]
}
