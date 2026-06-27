# See R/roxygen.R for documentation below that uses inline R code

# ---------- deprecated version

#' midfieldr deprecated functions
#' @param keep_text Deprecated `filter_cip()`. Character vector of search text to keep.
#' @param drop_text Deprecated `filter_cip()`. Character vector of search text to drop.
#' @param cip Deprecated `filter_cip()`. Data frame of programs to be searched.
#' @param select Deprecated `filter_cip()`. Character vector of column names to select.
#' @rdname midfieldr-deprecated
#' @export
filter_cip <- function(keep_text = NULL,
                       drop_text = NULL,
                       cip = NULL,
                       select = NULL) {
  .Deprecated(
    new = "filter_cip_rows",
    package = "midfieldr",
    msg = "This function was deprecated to put the data frame as the
    first argument making it possible to chain with other functions.
    Please use `filter_cip_rows()` instead."
  )

  # attempt to continue to use original function with partial success
  if (is.null(cip)) cip <- midfieldr::cip
  negate <- FALSE

  if (!is.null(drop_text)) {
    keep_text <- drop_text
    negate <- TRUE
  }

  filter_cip_rows(dframe = cip, pattern = keep_text, negate = negate)
}
NULL

#' Subset rows that include matches to search strings
#'
#' Subset a CIP data frame, retaining rows that match or partially match a
#' vector of character strings. Search terms can include regular expressions.
#' Uses `grepl()`, therefore non-character columns (if any) that can be
#' coerced to character are also searched for matches.
#'
#' @param dframe Data frame of CIP program codes to be searched, typically
#'        `cip` that loads with midfieldr.
#' @param pattern Character vector of search strings for retaining rows,
#'        not case-sensitive. Can include regular expressions.
#' @param ... `r param_dots`
#' @param negate Logical. If true, searches for not-pattern. Default FALSE.
#'
#' @returns A data frame of the same type as `dframe`. The output has the
#' following properties:
#'
#' * Rows are a subset of the input, but appear in the same order.
#' * Columns are not modified.
#' * Groups are not preserved.
#' * Data frame attributes are preserved for classes `data.frame`, `data.table`,
#'   or `tbl_df`.
#'
#'
#'
#'
#'
#' @family filter_*
#' @example man/examples/exa_filter_cip_rows.R
#' @export
#'
filter_cip_rows <- function(dframe, pattern, ..., negate = FALSE) {
  # ---------- checks, use base R syntax

  # assert arguments after dots used by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    "Arguments after ... must be named, e.g., arg = val."
  )

  # required argument
  qassert(dframe, "d+")

  # assertions for optional arguments
  # qassert(select, "s+") # missing is OK
  # if (!is.null(keep_text)) qassert(keep_text, "s+")
  # if (!is.null(drop_text)) qassert(drop_text, "s+")

  # ---------- preparation

  # to restore class (tibble, data.frame, etc.) before return
  prior_class <- class(dframe)

  # Convert non-data.table input to data.table class. By-ref changes to
  # dframe in global environment remain active for data.tables.
  dframe <- copy_setDT_non_DT(dframe)

  # required columns
  # NA
  # class of required columns
  # NA
  # bind names due to NSE notes in R CMD check
  # cip <- NULL

  # do the work

  if (length(pattern) > 0) {
    pattern <- paste0(pattern, collapse = "|")

    DT <- dframe[apply(dframe, 1, function(i) {
      if (negate) {
        !any(grepl(pattern, i, ignore.case = TRUE))
      } else {
        any(grepl(pattern, i, ignore.case = TRUE))
      }
    }), ]
  }

  # ---------- restore state

  # Except for grouped tibbles, restores non-data.table data frames
  # to same class as input.
  DT <- restore_non_dt_class(DT, prior_class)

  DT[]
}
