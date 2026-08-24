# See R/roxygen.R for documentation below that uses inline R code

#' Identify terms after the first completion term
#'
#' For each student's term in a data frame, determine its relationship to the
#' student's first degree term (pre-degree, first-degree, or post-first-degree)
#' and add columns that support the findings. Post-first-baccalaureate terms
#' are typically excluded from the `term, course,` and `degree` data tables.
#'
#' In a typical analysis, one is interested in a student's progress up to
#' and including the term in which they earn their first degree or degrees.
#' Any terms later than the first baccalaureate can usually be excluded from
#' study.
#'
#' @param dframe `r dframe` with required variables `{mcid}` and one of
#'        `{term, term_course, term_degree}.`
#' @param midf_table `r midfield_x("degree")` with required variables
#'        `{mcid, term_degree}.`
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * `r rows_not_modified`
#' * New columns are added or replace existing columns of the same name (if
#'   any). Other columns are not modified. The following variables are added:
#'   - `first_degree_term.` &nbsp;  Character. Term of a student's first
#'      baccalaureate, encoded `YYYYT` or, if no degree recorded, `NA`.
#'      Joined from the `term_degree` variable in `midf_table.`
#'   - `term_cluster.` &nbsp;  Character, indicating that a term belongs
#'      to one of three clusters: terms that are prior to ("pre-degree"),
#'      equal to ("first-degree"), or subsequent to ("post-first-degree")
#'      the student’s first degree term.
#' * `r not_preserved`
#' @example man/examples/exa_post_completion_terms.R
#' @export
#'
post_completion_terms <- function(dframe, midf_table = degree) {
  #
  # class of required data frames, at least one column, missing values OK
  qassert(dframe, "d+")
  qassert(midf_table, "d+")

  # determine name of term variable
  term_var_choices <- c("term", "term_course", "term_degree")
  term_var <- intersect(colnames(dframe), term_var_choices)
  qassert(term_var, "s1")

  # ---------- declarations

  # active column names
  reqd_dframe_vars <- c("mcid", term_var)
  reqd_table_vars <- c("mcid", "term_degree")
  added_vars <- c("first_degree_term", "term_cluster")

  # bind names for R CMD check
  first_degree_term <- NULL
  term_cluster <- NULL
  IDX <- NULL
  TERM_VAR <- NULL

  # ---------- base R checks (all data frame classes)

  # required columns exist
  assert_names(colnames(dframe), must.include = reqd_dframe_vars)
  assert_names(colnames(midf_table), must.include = reqd_table_vars)

  # class of required columns
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
  setnames(midf_table, old = "term_degree", new = "first_degree_term")
  DT <- midf_table[dframe[, .(mcid)], on = "mcid", nomatch = NULL]

  # keep the first-degree term/row
  setorderv(DT, c("mcid", "first_degree_term"))
  DT <- DT[, .SD[1L], by = "mcid"]

  # left-join to dframe, introduces NAs in first_degree_term col
  dframe <- DT[dframe, on = "mcid"]

  # assign term status labels
  dframe[, term_cluster := fcase(
    TERM_VAR == first_degree_term, "first-degree",
    TERM_VAR > first_degree_term, "post-first-degree",
    default = "pre-degree"
  ),
  env = list(TERM_VAR = term_var)
  ]

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
