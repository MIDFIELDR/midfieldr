# See R/roxygen.R for documentation below that uses inline R code

#' Identify post-baccalaureate terms
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
#' @param midfield_table `r midfield_x("degree")` with required variables
#'        `{mcid, term_degree}.`
#'
#' @returns Data frame with the following properties:
#' * `r class_presrv`
#' * `r rows_not_mod`
#' * New columns are added or replace existing columns of the same name (if
#'   any). Other columns are not modified. The following variables are added:
#'   - `first_degree_term.` &nbsp;  Character. Term of a student's first
#'      baccalaureate, encoded `YYYYT` or, if no degree recorded, `NA`.
#'      Joined from the `term_degree` variable in `midfield_table.`
#'   - `term_cluster.` &nbsp;  Character, indicating that a term belongs
#'      to one of three clusters: terms that are prior to ("pre-degree"),
#'      equal to ("first-degree"), or subsequent to ("post-first-degree")
#'      the student’s first degree term.
#' * `r groups_not`
#'
#' @example man/examples/exa_post_bacc_terms.R
#' @export
#'
post_bacc_terms <- function(dframe, midfield_table = degree) {
  #
  # ---------- assign active column names
  
  reqd_table_vars <- c("mcid", "term_degree")
  added_vars <- c("first_degree_term", "term_cluster")
  term_var_choices <- c("term", "term_course", "term_degree")

  # ---------- base R checks (all data frame classes)

  # assert data frames
  qassert(dframe, "d+")
  qassert(midfield_table, "d+")

  # assert class of required variables
  qassert(dframe[["mcid"]], "s+")

  # dframe term variable, exact match, string, length 1
  var <- intersect(term_var_choices, colnames(dframe))
  assert_choice(var, choices = term_var_choices)
  qassert(var, "s1")

  # then assert
  assert_names(colnames(midfield_table),
    must.include = reqd_table_vars
  )
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
  idx <- NULL
  term_var <- NULL
  TERM_VAR <- NULL
  term_cluster <- NULL
  first_degree_term <- NULL
  
  # ---------- do the work
  
  # subset of required variables
  reqd_dframe_vars <- setdiff(colnames(dframe), added_vars)
  dframe <- dframe[, .SD, .SDcols = reqd_dframe_vars]
  dframe <- unique(dframe)
  midf_table <- midf_table[, .SD, .SDcols = reqd_table_vars]
  midf_table <- unique(midf_table)

  # name of term variable
  term_var <- intersect(term_var_choices, colnames(dframe))

  # add temp col to restore row order
  dframe[, idx := .I]

  # prepare to inner join IDs and subset_degree, na.rm in case
  dframe_id <- dframe[, .(mcid)]
  dframe_id <- unique(dframe_id, na.rm = TRUE)

  # join degree data
  x <- midf_table[dframe_id, on = "mcid", nomatch = NULL]

  # keep the term of the first degree(s)
  setorderv(x, reqd_table_vars)
  x <- x[, .SD[1], by = "mcid"]

  # rename the first degree term
  x <- x[, .(mcid, first_degree_term = term_degree)]

  # left-join two columns to dframe, introduce NAs in first_degree_term col
  dframe <- x[dframe, on = "mcid"]
  
  # ---------- term cluster labels
  
  # assign term status labels
  dframe[, term_cluster := fcase(TERM_VAR == first_degree_term, "first-degree",
    TERM_VAR > first_degree_term, "post-first-degree",
    default = "pre-degree"
  ),
  env = list(TERM_VAR = term_var)
  ]
  
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
