# See R/roxygen.R for documentation below that uses inline R code

#' Choose rows of undergraduate terms only
#'
#' Distinguish post-baccalaureate terms from undergraduate terms for each
#' student in a data frame and retain the undergraduate terms. Applied
#' to a data table having an academic term variable, e.g., the `term, course,`
#' and `degree` tables.
#'
#' `r redundant_cols("bacc_term")`
#'
#' @param dframe `r dframe` with required variables `{mcid}` and one of the
#'        following: `{term, term_course, term_degree}.`
#' @param midf_table `r midfield_x("degree")` with required variables
#'        `{mcid, term_degree}.`
#' @param ... `r param_dots`
#' @param add_bacc_term Logical, default false. If true, a column for the first
#'        degree term is added and post-baccalaureate rows are not removed.
#' @returns Data frame with the following properties:
#' * `r keep_class_rm_groups_rm_keys`
#' * Post-baccalaureate rows are removed (default) unless `add_bacc_term` is true.
#'   In all cases, duplicated rows are removed.
#' * Columns are not modified (default). When `add_bacc_term` true, one new
#'   column is added unless it is redundant (see Details). The new variable is:
#'   - `bacc_term` &nbsp;  Character. Term of a student's first
#'      baccalaureate, encoded `YYYYT` or, if no degree recorded, `NA.`
#'      Joined from the `term_degree` variable in `midf_table.`
#'
#' @example man/examples/exa_filter_undergrad.R
#' @export
#'
filter_undergrad <- function(dframe, midf_table = degree, ..., add_bacc_term = NULL) {
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

  add_bacc_term <- add_bacc_term %?% FALSE

  # bind names for R CMD check
  BACC_TERM <- NULL
  IDX <- NULL
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

  temp_vars <- c("bacc_term", "idx")
  new_vars <- utils_edit_colnames(dframe, temp_vars)

  q_bacc_term <- new_vars[1]
  q_idx <- new_vars[2]

  return_vars <- copy(colnames(dframe))
  if (add_bacc_term) return_vars <- c(return_vars, q_bacc_term)

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

  # filter to retain undergrad terms (default)
  if (!isTRUE(add_bacc_term)) {
    dframe <- dframe[is.na(BACC_TERM) | BACC_TERM >= TERM_VAR,
      env = list(
        TERM_VAR = term_var,
        BACC_TERM = q_bacc_term
      )
    ]
  }

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
