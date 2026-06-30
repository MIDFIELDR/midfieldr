# See R/roxygen.R for documentation that uses inline R code

# ---------- deprecated version

#' Select basic columns of student-level records
#' @param midfield_x Deprecated `select_required()`. Data frame from which
#'        columns are selected.
#' @param select_add Deprecated `select_required()`. Character vector of
#'        col_patterns to search `dframe` column names.
#' @rdname midfieldr-deprecated
#' @export
select_required <- function(midfield_x, select_add = NULL) {
  .Deprecated(
    new = "select_record_cols",
    package = "midfieldr",
    msg = "This function was deprecated for consistency with midfieldr
    naming conventions. Please use `select_record_cols()` instead."
  )

  # old function still works, wraps the new function
  select_record_cols(dframe = midfield_x, col_pattern = select_add)
}
NULL

# ---------- new version

#' Select basic columns of student-level records
#'
#' Subset a data frame, selecting columns by matching a vector of character
#' strings. A convenience function to reduce the dimensions of a MIDFIELD
#' data table by selecting only those columns required by other midfieldr
#' functions or that are required to form a composite key. Particularly
#' useful in interactive sessions when viewing the data tables at various
#' stages of an analysis.
#'
#' Several midfieldr functions require input data frames containing
#' specific variables (column names) such as `mcid` or `cip6`. In addition,
#' the MIDFIELD data tables have specific variables that act as keys
#' or composite keys to the information in that table. The `type` argument
#' determines which columns are returned, if those columns exist in `dframe`:
#'
#' * `type = "s"` (student table) returns columns `mcid, race, sex`
#' * `type = "t"` (term table) returns columns `mcid, term, cip6, institution, level`
#' * `type = "c"` (course table) returns columns `mcid, term_course, abbrev, number`
#' * `type = "d"` (degree table) returns columns `mcid, term_degree, cip6`
#' * `type = "a"` (default) returns all the above
#'
#' Additional column names can be included by using the `col_pattern`
#' argument. In all cases, unmatched search strings are silently ignored.
#'
#' @param dframe Data frame of student records from which columns are selected.
#'        Expected choices are `student`, `term`, `course`, `degree` or their
#'        equivalent.
#' @param type Character identifying the record type. Possible values are "s",
#'        "t", "c", "d", or "a". See Details.
#' @param ... `r param_dots`
#' @param col_pattern Character vector containing strings or regular
#'        expressions to be matched or partially matched to the column
#'        names of `dframe`.
#'
#' @returns A data frame of the same type as `dframe`. The output has the
#' following properties:
#'
#' * Rows are not modified.
#' * Columns are a subset of the input, but appear in the same order.
#' * Groups are not necessarily preserved.
#' * Data frame attributes are preserved with the exception of grouped tibbles.
#'
#' @example man/examples/exa_select_record_cols.R
#' @export
select_record_cols <- function(dframe, type = NULL, ..., col_pattern = NULL) {
  # ---------- base R checks (all data frame classes)
  #
  # arguments after ... must be named
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    "Arguments after ... must be named, as in arg = val."
  )

  # data frame assessment
  checkmate::qassert(dframe, "d+")

  # optional arguments
  if (!is.null(col_pattern)) {
    checkmate::qassert(col_pattern, "s+")
  }
  type <- type %?% "a"
  qassert(type, "S1")
  assert_subset(
    type,
    choices = c("s", "t", "c", "d", "a"),
    empty.ok = FALSE,
    .var.name = "type"
  )

  # ---------- preparation

  # to restore class except for groups in tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  setDT(dframe)

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
  setattr(dframe, "class", prior_class)
  dframe[]
}
