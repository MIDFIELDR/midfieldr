# See R/roxygen.R for documentation below that uses inline R code

#' Determine completion status
#'
#' Determine the *completion status* for each student in a data frame and
#' add columns that support the findings.
#'
#' If a population has been filtered for data sufficiency, then determining
#' every student's *completion status* is feasible. Completing an academic
#' program in a timely manner means that a student completes the requirements
#' for a degree within a set time span, typically 4, 6, or 8 years after
#' admission depending on the definition adopted in a particular study. The
#' term at the end of that span is the *timely completion term.*
#'
#' If the student's degree term is no later than their timely completion term,
#' then their completion status is "timely"; if later, their status is "late".
#' For students with no degree, completion status is NA.
#'
#' @param dframe `r dframe` with required variables `{mcid, timely_term}.`
#'
#' @param midfield_table `r midfield_x("degree")` with required
#'        variables `{mcid, term_degree}.`
#'
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * `r rows_not_modified`
#' * `r new_cols_added`
#'   - `term_degree` &nbsp; Joined from `midfield_table.`
#'   - `completion_status` &nbsp; Character. Possible values of "timely",
#'      "late" and "NA".
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

  # save columns except those being added
  saved_vars <- setdiff(colnames(dframe), added_vars)
  return_vars <- c(saved_vars, added_vars)

  # drop added vars, omit NA in required vars
  dframe <- dframe[, .SD, .SDcols = saved_vars]
  dframe <- na.omit(dframe, cols = reqd_dframe_vars)
  dframe <- unique(dframe)

  # keep required vars and omit NAs
  midf_table <- midf_table[, .SD, .SDcols = reqd_table_vars]
  midf_table <- na.omit(midf_table, cols = reqd_table_vars)
  midf_table <- unique(midf_table)

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

  # drop temporary cols, restore original col order
  dframe <- dframe[, .SD, .SDcols = return_vars]

  # ensure unique rows
  dframe <- unique(dframe)

  # restore class
  setattr(dframe, "class", prior_class)

  # done
  dframe[]
}


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
