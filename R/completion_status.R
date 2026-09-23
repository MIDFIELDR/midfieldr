# See R/roxygen.R for documentation below that uses inline R code

#' Determine completion status
#'
#' `r completion_status_one_line` `r add_cols_support_finding`
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
#' `r redundant_cols("bacc_term")`
#'
#' @param dframe `r dframe` with required variables `{mcid, timely_term}.`
#' @param midf_table `r midfield_x("degree")` with required
#'        variables `{mcid, term_degree}.`
#' @returns Data frame with the following properties:
#' * `r keep_class_rm_groups_rm_keys`
#' * `r keep_row_order_rm_NA_rm_duplic_rows`
#' * `r add_new_cols` The new variables are:
#'   - `bacc_term` &nbsp;  Character. Term of a student's first
#'      baccalaureate, encoded `YYYYT` or, if no degree recorded, `NA.`
#'      Joined from the `term_degree` variable in `midf_table.`
#'   - `completion` &nbsp; Character. Completion status, possible values of
#'      "timely", "late", and "NA".
#' @example man/examples/exa_completion_status.R
#' @export
#'
completion_status <- function(dframe, midf_table = degree) {
  #
  # ---------- initial assertions

  # data frames
  qassert(dframe, "d+")
  qassert(midf_table, "d+")

  # ---------- declarations

  # required column names
  reqd_dframe_vars <- c("mcid", "timely_term")
  reqd_table_vars <- c("mcid", "term_degree")

  # bind names for R CMD check
  BACC_TERM <- NULL
  COMPLETION <- NULL
  IDX <- NULL

  # ---------- variable assertions

  utils_check_reqd_vars(dframe, reqd_dframe_vars)
  utils_check_reqd_vars(midf_table, reqd_table_vars)

  # ---------- preparation

  # for restoring class except grouped tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  midf_table <- copy(midf_table)

  # setDT, reqd_vars as.char, na.omit, unique
  dframe <- utils_prep_DT(dframe, reqd_dframe_vars)
  midf_table <- utils_prep_DT(midf_table, reqd_table_vars)

  # select columns
  midf_table <- midf_table[, .SD, .SDcols = reqd_table_vars]

  # ---------- prevent overwriting

  added_vars <- c("bacc_term", "completion")
  temp_vars <- c("idx")
  proposed <- c(added_vars, temp_vars)

  new_vars <- utils_edit_colnames(dframe, proposed)

  q_bacc_term <- new_vars[1]
  q_completion <- new_vars[2]
  q_idx <- new_vars[3]

  return_vars <- c(names(dframe), q_bacc_term, q_completion)

  # ---------- do the work

  # for restoring row order
  dframe[, IDX := .I, env = list(IDX = q_idx)]

  # edit name before join
  setnames(midf_table, old = "term_degree", new = q_bacc_term)
  dframe <- midf_table[dframe, on = "mcid"]

  # completion is timely, late, or NA
  dframe[, COMPLETION := fifelse(
    BACC_TERM <= timely_term,
    "timely",
    "late",
    na = NA_character_
  ),
  env = list(
    COMPLETION = q_completion,
    BACC_TERM = q_bacc_term
  )
  ]

  # ---------- prepare to return

  # restore row order
  setkeyv(dframe, q_idx)

  # NULL keys, return vars, unique, class
  dframe <- utils_prep_return(dframe, return_vars, prior_class)

  # drop cols or cols.1 duplicates if any
  dframe <- rm_redundant_cols(dframe)

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
  # invoking the old function calls the new function
  completion_status(dframe = dframe, midf_table = midfield_degree)
}
