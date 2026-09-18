# See R/roxygen.R for documentation below that uses inline R code

#' Categorize the qualification focus of a term
#'
#' Determine the qualification focus (undergraduate or post-baccalaureate) of every term for each student in a data frame and add columns to the data frame to support the finding.
#'
#' Every term in a student's record can be categorized as "undergraduate" if
#' the term predates their first degree and "post-baccalaureate" if it postdates
#' the degree. Post-baccalaureate terms are
#' typically excluded from the `term, course,` and `degree` data tables.
#'
#' `r redundant_cols("bacc_term")`
#'
#' @param dframe `r dframe` with required variables `{mcid}` and one of
#'        `{term, term_course, term_degree}.`
#' @param midf_table `r midfield_x("degree")` with required variables
#'        `{mcid, term_degree}.`
#' @returns Data frame with the following properties:
#' * `r preserv_class_not_grp_keys`
#' * `r omit_NA_dup_rows`
#' * `r add_new_cols` The new variables are:
#'   - `bacc_term` &nbsp;  Character. Term of a student's first
#'      baccalaureate, encoded `YYYYT` or, if no degree recorded, `NA`.
#'      Joined from the `term_degree` variable in `midf_table.`
#'   - `term_focus` &nbsp;  Character. Indicating a term contributes to study
#'      before or after a student's first baccalaureate.
#'      Possible values are "undergrad" and "post-bacc."
#' @example man/examples/exa_term_qual_focus.R
#' @export
#'
term_qual_focus <- function(dframe, midf_table = degree) {
  #
  # ---------- initial assertions

  # data frames
  qassert(dframe, "d+")
  qassert(midf_table, "d+")

  # ---------- declarations

  # determine name of term variable
  term_var_choices <- c("term", "term_course", "term_degree")
  term_var <- intersect(colnames(dframe), term_var_choices)

  # active column names
  reqd_dframe_vars <- c("mcid", term_var)
  reqd_table_vars <- c("mcid", "term_degree")

  # bind names for R CMD check
  BACC_TERM <- NULL
  IDX <- NULL
  TERM_FOCUS <- NULL
  TERM_VAR <- NULL

  # ---------- variable assertions

  utils_check_reqd_vars(dframe, reqd_dframe_vars)
  utils_check_reqd_vars(midf_table, reqd_table_vars)
  qassert(term_var, "s1")

  # ---------- preparation

  # for restoring class except grouped tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  midf_table <- copy(midf_table)

  # setDT then reqd_vars as.char, na.omit, unique
  dframe <- utils_prep_DT(dframe, reqd_dframe_vars)
  midf_table <- utils_prep_DT(midf_table, reqd_table_vars)

  # select columns
  midf_table <- midf_table[, .SD, .SDcols = reqd_table_vars]

  # ---------- prevent overwriting

  added_vars <- c("bacc_term", "term_focus")
  temp_vars <- c("idx")
  proposed <- c(added_vars, temp_vars)

  new_vars <- utils_edit_colnames(dframe, proposed)

  q_bacc_term <- new_vars[1]
  q_term_focus <- new_vars[2]
  q_idx <- new_vars[3]

  return_vars <- c(names(dframe), new_vars[1:2])

  # ---------- do the work

  # for restoring row order
  dframe[, IDX := as.double(.I), env = list(IDX = q_idx)]

  # edit name before join
  setnames(midf_table, old = "term_degree", new = q_bacc_term)
  DT <- midf_table[dframe[, .(mcid)], on = "mcid", nomatch = NULL]

  # keep the first-degree term/row
  setorderv(DT, c("mcid", q_bacc_term))
  DT <- DT[, .SD[1L], by = "mcid"]

  # left-join to dframe, introduces NAs in bacc_term col
  dframe <- DT[dframe, on = "mcid"]

  # assign term status labels
  dframe[, TERM_FOCUS := fifelse(
    TERM_VAR > BACC_TERM,
    "post-bacc",
    "undergrad",
    na = "undergrad"
  ),
  env = list(
    TERM_VAR = term_var,
    TERM_FOCUS = q_term_focus,
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
