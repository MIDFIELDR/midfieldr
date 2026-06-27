# See R/roxygen.R for documentation that uses inline R code

# ---------- deprecated version

#' midfieldr deprecated functions
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
#' determines the set of columns searched for in `dframe`. Unmatched search
#' strings are silently ignored.
#'
#' * `type = "s"` (student table) searches for columns `mcid, race, sex`
#' * `type = "t"` (term table) searches for columns `mcid, term, cip6, institution, level`
#' * `type = "c"` (course table) searches for columns `mcid, term_course, abbrev, number`
#' * `type = "d"` (degree table) searches for columns `mcid, term_degree, cip6`
#' * `type = "a"` (default) searches for all of the columns listed above
#'
#' Additional column names can be included in the search by using the
#' `col_pattern` argument.
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
#' * Groups are not preserved.
#' * Data frame attributes are preserved for classes `data.frame`, `data.table`,
#'   or `tbl_df`.
#'
#' @example man/examples/exa_select_record_cols.R
#' @export
select_record_cols <- function(dframe, type = NULL, ..., col_pattern = NULL) {
  # ---------- checks, use base R syntax

  # arguments after ... must be named
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    "Arguments after ... must be named, as in arg = val."
  )

  # required arguments
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

  # to restore class (tibble, data.frame, etc.) before return
  prior_class <- class(dframe)

  # convert non-data.table input to data.table class. By-ref changes to
  # dframe in global environment remain active for data.tables.
  DT <- copy_setDT_non_DT(dframe)

  # bind names due to NSE notes in R CMD check
  # x <- NULL

  # ---------- do the work

  # column names, minimum required plus keys
  active_cols <- if (type == "s") {
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
  cols_to_search <- setdiff(colnames(DT), active_cols)
  cols_to_keep <- intersect(colnames(DT), active_cols)

  # use search to update columns to keep
  search_col_pattern <- paste(col_pattern, collapse = "|")
  if (nchar(search_col_pattern) > 0) {
    cols_to_add <- grep(search_col_pattern,
      cols_to_search,
      ignore.case = TRUE,
      value = TRUE
    )
    cols_to_keep <- c(cols_to_keep, cols_to_add)
  }

  # select columns
  DT <- DT[, .SD, .SDcols = cols_to_keep]

  # ---------- restore state

  # Except for grouped tibbles, restores non-data.table data frames
  # to same class as input.
  dframe <- restore_non_dt_class(DT, prior_class)

  dframe[]
}
