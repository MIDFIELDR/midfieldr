# See R/roxygen.R for documentation that uses inline R code

# ---------- deprecated version

#' Select record columns
#' @param midfield_x Deprecated `select_required()`. Data frame from which
#'        columns are selected.
#' @param select_add Deprecated `select_required()`. Character vector of
#'        col_patterns to search `dframe` column names.
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
  select_basic_cols(dframe = midfield_x, col_pattern = select_add)
}
NULL

# ---------- new version

#' Choose columns of student records
#'
#' Subset one of the four MIDFIELD data tables `{student, term, course, degree}`
#' by selecting the columns required by other midfieldr
#' functions.
#'
#' A convenience function to reduce the dimensions of a MIDFIELD
#' data table by selecting only those columns required by other midfieldr
#' functions or that are required to form a composite key. Particularly
#' useful in interactive sessions when viewing the data tables at various
#' stages of an analysis.
#'
#' Several midfieldr functions require input data frames containing
#' specific variables (column names) such as `mcid` or `cip6`. In addition,
#' the MIDFIELD data tables have specific variables that act as keys
#' or composite keys to the information in that table. If the `type` argument
#' is NULL (default), one of the following codes is assigned to return the
#' column names indicated (if present):
#' * `type = "s"` (student) looks for `{mcid, race, sex}`
#' * `type = "t"` (term) looks for `{mcid, term, cip6, institution, level}`
#' * `type = "c"` (course) looks for  `{mcid, term_course, abbrev, number}`
#' * `type = "d"` (degree) looks for  `{mcid, term_degree, cip6}`
#' * `type = "a"` looks for all the above columns
#'
#' Specifying the type `{s, t, c, d, a}` manually in the argument overrides
#' the automatic selection. Additional column names can be included by using
#' the `col_pattern` argument. In all cases, unmatched search strings are
#' silently ignored.
#'
#' @param dframe `r dframe` equivalent to or derived from one of the MIDFIELD
#'        data tables: `{student, term, course, degree}.`
#'
#' @param col_pattern Character vector containing strings or regular
#'        expressions to be matched or partially matched to the column
#'        names of `dframe.`.
#'
#' @param ... `r param_dots`
#'
#' @param type Character identifying the table type. Possible values are "s",
#'        "t", "c", "d", "a", or NULL (default). See Details.
#'
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * `r rows_not_modified`
#' * Columns are a subset of the input, appearing in the same order.
#' * `r not_preserved`
#'
#' @example man/examples/exa_select_basic_cols.R
#' @export
#'
select_basic_cols <- function(dframe, col_pattern = NULL, ..., type = NULL) {
  #
  # ---------- base R checks (all data frame classes)
  
  # arguments after ... must be named
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    "Arguments after ... must be named, as in arg = val."
  )

  # data frame assessment
  qassert(dframe, "d+")

  # optional arguments
  if (!is.null(col_pattern)) {
    qassert(col_pattern, "s+")
  }
  if (!is.null(type)) {
    qassert(type, "S1")
    assert_subset(
      type,
      choices = c("s", "t", "c", "d", "a"),
      empty.ok = FALSE,
      .var.name = "type"
    )
  }

  # ---------- preparation

  # to restore class except for groups in tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  setDT(dframe)

  if (is.null(type)) {
    uniq_s_cols <- c(
      "race", "sex", "transfer", "hours_transfer",
      "age_desc", "us_citizen", "home_zip", "high_school",
      "sat_math", "sat_verbal", "act_comp"
    )
    uniq_t_cols <- c(
      "term", "level", "standing", "coop", "hours_term",
      "hours_term_attempt", "hours_cumul", "hours_cumul_attempt",
      "gpa_term", "gpa_cumul"
    )
    uniq_c_cols <- c(
      "term_course", "abbrev", "number", "course", "section",
      "type", "faculty_rank", "hourse_course", "grade",
      "discipline_midfield"
    )
    uniq_d_cols <- c("term_degree", "degree")

    if (length(intersect(colnames(dframe), uniq_s_cols)) > 0) {
      type <- "s"
    } else if (length(intersect(colnames(dframe), uniq_t_cols)) > 0) {
      type <- "t"
    } else if (length(intersect(colnames(dframe), uniq_c_cols)) > 0) {
      type <- "c"
    } else if (length(intersect(colnames(dframe), uniq_d_cols)) > 0) {
      type <- "d"
    } else {
      type <- "a"
    }
  }

  # bind names due to NSE notes in R CMD check
  # NA

  # ---------- do the work

  # column names, minimum required plus keys
  record_vars <- if (type == "s") {
    c("mcid", "race", "sex")
  } else if (type == "t") {
    c("mcid", "term", "cip6", "institution", "level")
  } else if (type == "c") {
    c("mcid", "term_course", "abbrev", "number")
  } else if (type == "d") {
    c("mcid", "term_degree", "cip6")
  } else {
    c(
      "mcid", "institution", "race", "sex", "cip6", "level", "abbrev",
      "number", "term", "term_course", "term_degree"
    )
  }

  # separate canonical from non-canonical names
  cols_to_search <- setdiff(colnames(dframe), record_vars)
  cols_to_keep <- intersect(colnames(dframe), record_vars)

  # use search to update columns to keep
  search_col_pattern <- paste(col_pattern, collapse = "|")
  if (nchar(search_col_pattern) > 0) {
    cols_to_add <- grep(search_col_pattern,
      cols_to_search,
      ignore.case = TRUE,
      value = TRUE
    )
    return_vars <- c(cols_to_keep, cols_to_add)
  } else {
    return_vars <- cols_to_keep
  }

  # ---------- prepare to return

  dframe <- dframe[, .SD, .SDcols = return_vars]
  setkey(dframe, NULL)
  dframe <- unique(dframe)
  setattr(dframe, "class", prior_class)
  dframe[]
}
