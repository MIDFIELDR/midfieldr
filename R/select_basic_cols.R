# See R/roxygen.R for documentation that uses inline R code

#' Choose columns of student records
#'
#' Subset a MIDFIELD data table to retain the variables required by one or
#' more midfieldr functions. Variables that constitute the key or composite
#' key for a table are retained as well. A convenience function to reduce
#' the number of columns displayed.
#'
#' Functions in midfieldr with a MIDFIELD dataset argument---such as
#' `student, term,` etc.---typically require only a few of the columns
#' available in the table. Depending on which table is input, the following
#' columns are returned if present:
#' * `student: {mcid, race, sex}`
#' * `term: {mcid, term, cip6, institution, level}`
#' * `course: {mcid, term_course, abbrev, number}`
#' * `degree: {mcid, term_degree, cip6}`
#' * Combination of the above if `dframe` contains columns from multiple tables.
#'
#' @param dframe `r dframe` equivalent to or derived from one of the MIDFIELD
#'        data tables: `{student, term, course, degree}.`
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * Rows are not modified.
#' * Columns are a subset of the input, appearing in the same order.
#' @example man/examples/exa_select_basic_cols.R
#' @export
#'
select_basic_cols <- function(dframe) {
  #
  # ---------- declarations

  # variables, by table, required by one or more midfieldr functions
  var_s <- c("mcid", "race", "sex")
  var_t <- c("mcid", "term", "cip6", "institution", "level")
  var_c <- c("mcid", "term_course", "abbrev", "number")
  var_d <- c("mcid", "term_degree", "cip6")
  var_a <- unique(c(var_s, var_t, var_c, var_d))

  # variables, by table, unique to that table
  uniq_s <- c(
    "race", "sex", "transfer", "hours_transfer", "age_desc", "us_citizen",
    "home_zip", "high_school", "sat_math", "sat_verbal", "act_comp"
  )
  uniq_t <- c(
    "term", "level", "standing", "coop", "hours_term", "hours_term_attempt",
    "hours_cumul", "hours_cumul_attempt", "gpa_term", "gpa_cumul"
  )
  uniq_c <- c(
    "term_course", "abbrev", "number", "course", "section", "type",
    "faculty_rank", "hourse_course", "grade", "discipline_midfield"
  )
  uniq_d <- c("term_degree", "degree")

  # bind names for R CMD check
  # NA

  # ---------- base R checks (all data frame classes)

  # data frame assessment
  qassert(dframe, "d+")

  # ---------- preparation

  # to restore class except grouped tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)

  # convert class for analysis
  setDT(dframe)

  # ---------- do the work

  input_cols <- colnames(dframe)

  # number of dframe column names in common with the unique sets
  g <- function(x) {
    length(intersect(x, input_cols))
  }
  N_uniq <- c(
    g(uniq_s),
    g(uniq_t),
    g(uniq_c),
    g(uniq_d)
  )

  # if only one non-zero value in N_uniq, then the source
  # data table (student, term, etc.) is recognized
  reqd_var_set <- if (sum(N_uniq > 0) == 1) {
    switch(which.max(N_uniq),
      var_s, # student required variables
      var_t, # term
      var_c, # course
      var_d
    ) # degree
  } else {
    var_a # return all possible required columns
  }

  # determine the required columns that exist in dframe
  return_vars <- intersect(input_cols, reqd_var_set)

  # select the columns
  dframe <- dframe[, .SD, .SDcols = return_vars]

  # ---------- prepare to return

  # restore class
  setattr(dframe, "class", prior_class)

  # done
  dframe[]
}


# ---------- deprecated version

#' Select record columns
#' @param midfield_x Deprecated `select_required()`. Data frame from which
#'        columns are selected.
#' @param select_add Defunct `select_required()`. Character vector of
#'        patterns to search `dframe` column names.
#' @rdname midfieldr-deprecated
#' @export
select_required <- function(midfield_x, select_add = NULL) {
  .Deprecated(
    new = "select_basic_cols",
    package = "midfieldr",
    msg = "This function was deprecated for consistency with midfieldr
    naming conventions. Please use `select_basic_cols()` instead."
  )

  # old function still works, wraps the new function
  select_basic_cols(dframe = midfield_x)
}
