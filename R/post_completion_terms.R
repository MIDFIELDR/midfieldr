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
#'
#' @param midf_table `r midfield_x("degree")` with required variables
#'        `{mcid, term_degree}.`
#'
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
#'
#' @example man/examples/exa_post_completion_terms.R
#' @export
#'
post_completion_terms <- function(dframe, midf_table = degree) {
  #
  # ---------- assign active column names

  # reqd_dframe_vars are mcid and one term_var, obtained later
  reqd_table_vars <- c("mcid", "term_degree")
  added_vars <- c("first_degree_term", "term_cluster")
  term_var_choices <- c("term", "term_course", "term_degree")

  # ---------- base R checks (all data frame classes)

  # assert data frames
  qassert(dframe, "d+")
  qassert(midf_table, "d+")

  # isolate the correct term column name
  dframe_term_var <- intersect(term_var_choices, colnames(dframe))
  assert_choice(dframe_term_var, choices = term_var_choices)
  qassert(dframe_term_var, "s1")

  # required columns
  reqd_dframe_vars <- c("mcid", dframe_term_var)
  assert_names(colnames(dframe), must.include = reqd_dframe_vars)
  assert_names(colnames(midf_table), must.include = reqd_table_vars)

  # class of required columns
  for (var in reqd_dframe_vars) qassert(dframe[[var]], "s+")
  for (var in reqd_table_vars) qassert(midf_table[[var]], "s+")

  # ---------- preparation

  # to restore class except grouped tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  setDT(dframe)
  midf_table <- copy(midf_table)
  setDT(midf_table)

  # avoid overwriting columns that match names of temporary columns
  init_temp_vars <- c("idx")
  temp_vars <- edit_new_col_names(dframe, init_temp_vars)
  idx_chr <- temp_vars[1]

  # bind names due to NSE notes in R CMD check
  first_degree_term <- NULL
  term_cluster <- NULL
  IDX <- NULL
  TERM_VAR <- NULL

  # ---------- do the work

  # added_vars are dropped from dframe
  saved_vars <- setdiff(colnames(dframe), added_vars)
  return_vars <- c(saved_vars, added_vars)

  # saved columns stay with dframe
  dframe <- dframe[, .SD, .SDcols = saved_vars]

  # get name of term variable, assign required vars for dframe
  term_var <- intersect(term_var_choices, colnames(dframe))
  reqd_dframe_vars <- c("mcid", term_var)

  # now can omit NAs in dframe required vars
  dframe <- na.omit(dframe, cols = reqd_dframe_vars)
  dframe <- unique(dframe)

  # keep required vars and omit NAs
  midf_table <- midf_table[, .SD, .SDcols = reqd_table_vars]
  midf_table <- na.omit(midf_table, cols = reqd_table_vars)
  midf_table <- unique(midf_table)

  # add temp col to restore row order
  dframe[, IDX := .I,
    env = list(IDX = idx_chr)
  ]

  # prepare to inner join IDs and subset_degree
  dframe_id <- dframe[, .(mcid)]

  # join degree data
  x <- midf_table[dframe_id, on = "mcid", nomatch = NULL]

  # keep the term of the first degree(s)
  setorderv(x, reqd_table_vars)
  x <- x[, .SD[1L], by = "mcid"]

  # rename the first degree term
  x <- x[, .(mcid, first_degree_term = term_degree)]

  # left-join to dframe, introduces NAs in first_degree_term col
  dframe <- x[dframe, on = "mcid"]

  # ---------- term cluster labels

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
  setkeyv(dframe, idx_chr)

  # drop temporary cols, restore original col order
  dframe <- dframe[, .SD, .SDcols = return_vars]

  # ensure unique rows
  dframe <- unique(dframe)

  # restore class
  setattr(dframe, "class", prior_class)

  # done
  dframe[]
}
