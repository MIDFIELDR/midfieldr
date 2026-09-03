# See R/roxygen.R for documentation below that uses inline R code

#' Categorize qualification level by term
#' 
#' Categorize the qualification level towards which a student is working in 
#' each term. Two levels are used: “undergrad” for terms before a student's 
#' first degree and “post-bacc” (post-baccalaureate) for terms after the first 
#' degree. Added columns support the findings. Post-baccalaureate terms are 
#' typically excluded from the `term, course,` and `degree` data tables.
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
#'   - `bacc` &nbsp;  Character. Term of a student's first
#'      baccalaureate, encoded `YYYYT` or, if no degree recorded, `NA`.
#'      Joined from the `term_degree` variable in `midf_table.`
#'   - `qual_level` &nbsp;  Character, indicating that a term belongs
#'      to one of two groups: "undergrad" terms are those leading up to
#'      and including the term in which a student completes their first
#'      degree; and "post-bacc" (post-baccalaureate) for all terms after the
#'      first degree.
#' * `r not_preserved`
#' @example man/examples/exa_qualification_level.R
#' @export
#'
qualification_level <- function(dframe, midf_table = degree) {
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
  added_vars <- c("bacc", "qual_level")

  # bind names for R CMD check
  bacc <- NULL
  qual_level <- NULL
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

  # dframe columns to protect and return
  protected_vars <- setdiff(colnames(dframe), added_vars)
  subset_protected_vars <- setdiff(protected_vars, term_var)
  protected_vars <- c(subset_protected_vars, term_var)
  returned_vars <- c(protected_vars, added_vars)

  # select columns
  dframe <- dframe[, .SD, .SDcols = protected_vars]
  midf_table <- midf_table[, .SD, .SDcols = reqd_table_vars]

  # prevent overwriting by temporary columns
  temp_vars <- c("idx")
  temp_vars <- utils_edit_colnames(dframe, temp_vars)
  idx <- temp_vars[1]

  # for restoring row order
  dframe[, IDX := .I, env = list(IDX = idx)]

  # ---------- do the work

  # edit name before join
  setnames(midf_table, old = "term_degree", new = "bacc")
  DT <- midf_table[dframe[, .(mcid)], on = "mcid", nomatch = NULL]

  # keep the first-degree term/row
  setorderv(DT, c("mcid", "bacc"))
  DT <- DT[, .SD[1L], by = "mcid"]

  # left-join to dframe, introduces NAs in bacc col
  dframe <- DT[dframe, on = "mcid"]

  # assign term status labels
  dframe[, qual_level := fifelse(
    TERM_VAR > bacc,
    "post-bacc",
    "undergrad",
    na = "undergrad"
  ),
  env = list(TERM_VAR = term_var)
  ]

  # ---------- prepare to return
  # restore row and column order, select return columns, restore class
  dframe <- utils_prepare_return(dframe, idx, returned_vars, prior_class)

  # done
  dframe[]
}
