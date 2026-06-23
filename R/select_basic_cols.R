# See R/roxygen.R for documentation below that uses inline R code

#' Select basic columns of student-level records
#'
#' Subset a data frame, selecting columns by matching a vector of character
#' strings. A convenience function to reduce the dimensions of a MIDFIELD
#' data table by selecting only those columns required by other midfieldr
#' functions or that are required to form a composite key. Particularly
#' useful in interactive sessions when viewing the data tables at various
#' stages of an analysis.
#'
#' Several midfieldr functions require that their input data frames contain
#' specific variables (column names) such as `mcid` or `cip6`. In addition,
#' the MIDFIELD data tables have specific variables that act as keys
#' or composite keys to the information in that table. All such are assembled
#' in a character vector that comprises the default set of column names
#' returned by `select_basic_cols()`. The default column set is
#' `c(mcid, institution, race, sex, term, term_course, term_degree, cip6, level, abbrev, number)`.
#'
#' The column names of `dframe` are searched for exact matches to the default
#' set of names. Additional column names can be included by using the
#' `patternv` argument---a vector of search terms for matches or partial
#' matches to the patterns. Regular expressions are permitted. Column names
#' and search terms not found are silently ignored.
#'
#' @param dframe Data frame from which columns are selected.
#' @param ... `r param_dots`
#' @param patternv Character vector of additional search terms. Can include
#'        regular expressions.
#'
#' @returns `r return_select_basic_cols`
#'          `r preserve_class`
#'
#' @example man/examples/select_basic_cols_exa.R
#' @export
select_basic_cols <- function(dframe, ..., patternv = NULL) {
  # If misc keys are set within this function
  on.exit(setkey(dframe, NULL), add = TRUE)

  # ---------- checks

  # arguments after ... must be named
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    "Arguments after ... must be named, as in arg = val."
  )

  # required arguments
  checkmate::qassert(dframe, "d+")

  # optional arguments
  if (!is.null(patternv)) {
    checkmate::qassert(patternv, "s+")
  }

  # ---------- preparation

  # to restore class (tibble, data.frame, etc.) before return
  prior_class <- class(dframe)

  # convert non-data.table input to data.table class. By-ref changes to
  # dframe in global environment remain active for data.tables.
  DT <- prep_non_dt_input(dframe)

  # bind names due to NSE notes in R CMD check
  # x <- NULL

  # ---------- do the work

  # column names, minimum required plus keys
  active_cols <- c(
    "mcid", "institution", "race", "sex", "cip6", "level",
    "abbrev", "number", "term", "term_course", "term_degree"
  )

  # separate canonical from non-canonical names
  cols_to_search <- setdiff(colnames(DT), active_cols)
  cols_to_keep <- intersect(colnames(DT), active_cols)

  # use search to update columns to keep
  search_pattern <- paste(patternv, collapse = "|")
  if (nchar(search_pattern) > 0) {
    cols_to_add <- grep(search_pattern,
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
