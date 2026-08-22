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
#' @param midf_table `r midfield_x("degree")` with required
#'        variables `{mcid, term_degree}.`
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * `r rows_not_modified`
#' * `r new_cols_added`
#'   - `completion_term` &nbsp; Equal to `term_degree` from `midf_table.`
#'   - `completion_status` &nbsp; Character. Possible values of "timely",
#'      "late" and "NA".
#' @example man/examples/exa_completion_status.R
#' @export
#'
completion_status <- function(dframe, midf_table = degree) {
  #
  # class of required data frames, at least one column, missing values OK
  qassert(dframe, "d+")
  qassert(midf_table, "d+")
  
  # ---------- declarations
  
  # active column names
  reqd_dframe_vars <- c("mcid", "timely_term")
  reqd_table_vars <- c("mcid", "term_degree")
  added_vars <- c("completion_term", "completion_status")
  
  # bind names for R CMD check
  completion_term <- NULL
  IDX <- NULL
  
  # ---------- base R checks (all data frame classes)
  
  # required columns exist
  assert_names(colnames(dframe), must.include = reqd_dframe_vars)
  assert_names(colnames(midf_table), must.include = reqd_table_vars)
  
  # class of required columns, string or factor OK
  for (var in reqd_dframe_vars) qassert(dframe[[var]], c("s+", "f+"))
  for (var in reqd_table_vars) qassert(midf_table[[var]], c("s+", "f+"))
  
  # ---------- preparation
  
  # to restore class except grouped tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")
  
  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  midf_table <- copy(midf_table)
  
  # convert class for analysis
  setDT(dframe)
  setDT(midf_table)
  
  # ensure character vars
  psi <- function(x, sel_cols) {
    x[, names(.SD) := lapply(.SD, as.character), .SDcols = sel_cols]
  }
  dframe <- psi(dframe, reqd_dframe_vars)
  midf_table <- psi(midf_table, reqd_table_vars)
  
  # ---------- do the work
  
  # dframe columns to retain and return
  keep_dframe_vars <- setdiff(colnames(dframe), added_vars)
  return_vars <- c(keep_dframe_vars, added_vars)
  
  # select columns
  dframe <- dframe[, .SD, .SDcols = keep_dframe_vars]
  midf_table <- midf_table[, .SD, .SDcols = reqd_table_vars]
  
  # filter NAs in reqd vars
  phi <- function(x, reqd_vars) {
    x <- na.omit(x, cols = reqd_vars)
    x <- unique(x)
  }
  dframe <- phi(dframe, reqd_dframe_vars)
  midf_table <- phi(midf_table, reqd_table_vars)
  
  # prevent overwriting by temporary columns
  temp_vars <- c("idx")
  temp_vars <- edit_new_col_names(dframe, temp_vars)
  idx <- temp_vars[1]
  
  # add temporary column to restore row order
  dframe[, IDX := .I, env = list(IDX = idx)]
  
  # edit name before join
  setnames(midf_table, old = "term_degree", new = "completion_term")
  dframe <- midf_table[dframe, on = "mcid"]
  
  # completion is timely, late, or NA
  dframe[, completion_status := fifelse(
    completion_term <= timely_term,
    "timely",
    "late",
    na = NA_character_
  )]
  
  # ---------- prepare to return
  
  # restore row order
  setkeyv(dframe, idx)
  
  # drop temporary cols, restore original col order
  dframe <- dframe[, .SD, .SDcols = return_vars]
  
  # ensure unique rows
  dframe <- unique(dframe)
  
  # restore class
  setattr(dframe, "class", prior_class)
  
  # done
  dframe[]
}


# ========== deprecated version ==========
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
  completion_status(dframe = dframe, midf_table = midfield_degree)
}
