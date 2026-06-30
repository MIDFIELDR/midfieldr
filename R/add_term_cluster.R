# See R/roxygen.R for documentation below that uses inline R code

#' Identify rows of post-baccalaureate terms
#'
#' Add columns to a student-records data frame indicating an observation
#' should be included (or excluded) because the term is clustered with
#' pre-degree (or post-first-degree) terms.
#'
#' In a typical analysis, one is interested in a student's progress up to
#' and including the term in which they earn their first degree or degrees.
#' Any terms later than the first baccalaureate can usually be excluded from
#' study.
#'
#' @param dframe Student-records data frame to which term-cluster columns
#'        are to be added. Required variables are `mcid` and a single term
#'        variable: `term` (when working with the term table),
#'        `term_course` (course table), or `term_degree` (degree table).
#'
#' @param midfield_rec MIDFIELD `degree` data table or equivalent with
#'        required variables `mcid` and `term_degree`.
#'
#' @returns Data frame `dframe` with added columns. Output has the
#'          following properties:
#' * Rows are not modified.
#' * Columns added or updated/overwritten:
#'   - `first_degree_term.` &nbsp;  Character. Term of a student's first
#'      baccalaureate, encoded `YYYYT` or, if no degree recorded, `NA`.
#'      Joined from `midfield_rec$term_degree`.
#'   - `term_cluster.` &nbsp;  Character, indicating that a term belongs
#'      to one of three clusters: terms that are prior to ("pre-degree"),
#'      equal to ("first-degree"), or subsequent to ("post-first-degree")
#'      the student’s first degree term.
#' * Columns not listed above are not modified.
#' * Data frame attributes (except groups) are preserved.
#'
#' @example man/examples/exa_add_term_cluster.R
#' @family add_*
#' @export
#'
add_term_cluster <- function(dframe, midfield_rec = degree) {
  # ---------- base R checks (all data frame classes)

  # define required columns in midfield_x argument
  reqd_record_vars <- c("mcid", "term_degree")

  # assert data frames
  checkmate::qassert(dframe, "d+")
  checkmate::qassert(midfield_rec, "d+")

  # assert class of required variables
  checkmate::qassert(dframe[["mcid"]], "s+")

  # dframe term variable, exact match, string, length 1
  term_var_choices <- c("term", "term_course", "term_degree")
  var <- intersect(term_var_choices, colnames(dframe))
  checkmate::assert_choice(var, choices = term_var_choices)
  checkmate::qassert(var, "s1")

  # then assert
  assert_names(colnames(midfield_rec),
    must.include = reqd_record_vars
  )
  for (i in seq_along(reqd_record_vars)) {
    qassert(midfield_rec[[reqd_record_vars[i]]], "s+")
  }

  # ---------- preparation

  # to restore class before return
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  setDT(dframe)
  reqd_record <- copy(midfield_rec)
  setDT(reqd_record)

  # subset of required variables
  reqd_record <- reqd_record[, .SD, .SDcols = reqd_record_vars]
  reqd_record <- unique(reqd_record, na.rm = TRUE)

  # bind names due to NSE notes in R CMD check
  term_var <- NULL
  term_cluster <- NULL
  first_degree_term <- NULL

  # ---------- do the work

  # variable names to add/overwrite
  active_cols <- c("first_degree_term", "term_cluster")

  # name of term variable
  dframe_term_var <- intersect(term_var_choices, colnames(dframe))

  # ordered column names for the return
  return_cols <- setup_return_cols(dframe, active_cols)

  # prepare to inner join IDs and subset_degree, na.rm in case
  dframe_id <- dframe[, .(mcid)]
  dframe_id <- unique(dframe_id, na.rm = TRUE)

  # inner-join input-ID and midfield-degree data
  x <- reqd_record[dframe_id, on = "mcid", nomatch = NULL]

  # keep the term of the first degree(s)
  setorderv(x, reqd_record_vars, order = 1)
  x <- x[, .SD[1], by = "mcid"]

  # rename the first degree term
  x <- x[, .(mcid, first_degree_term = term_degree)]

  # left-join two columns to dframe, introduce NAs in first_degree_term col
  dframe <- x[dframe, on = "mcid"]

  # ---------- term cluster labels

  # assign term status labels
  dframe[, term_cluster := "pre-degree"]

  # using string (dframe_term_var) on the LHS of i with env
  dframe[term_var == first_degree_term,
    term_cluster := "first-degree",
    env = list(term_var = dframe_term_var)
  ]

  dframe[term_var > first_degree_term,
    term_cluster := "post-first-degree",
    env = list(term_var = dframe_term_var)
  ]

  # select cols for return
  dframe <- dframe[, .SD, .SDcols = return_cols]

  # ---------- restore class, remove keys

  setattr(dframe, "class", prior_class)
  setkey(dframe, NULL)
  dframe[]
}
