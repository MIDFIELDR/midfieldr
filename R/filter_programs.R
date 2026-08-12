# See R/roxygen.R for documentation below that uses inline R code

#' Choose rows of CIP data
#'
#' Subset a CIP data frame, retaining rows that match or partially match
#' any string in a vector of character strings.
#'
#' Each element of the `pattern` vector is matched row-wise to every
#' value in `dframe` using `grepl().` If `negate = FALSE` (default), a
#' match retains the full row; if `negate = TRUE,` a match removes the full row.
#'
#' @param dframe `r dframe` with CIP program names and codes, e.g., the
#'        `cip` dataset.
#'
#' @param pattern Character vector of search strings, including regular
#'        expressions.
#'
#' @param ... `r param_dots`
#'
#' @param negate Logical (default FALSE). If TRUE, inverts the
#'        resulting Boolean vector.
#'
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * Rows are a subset of the input and appear in the same order.
#'   Duplicated rows are removed.
#' * Columns are not modified.
#' * `r not_preserved`
#'
#' @example man/examples/exa_filter_programs.R
#' @export
#'
filter_programs <- function(dframe, pattern, ..., negate = FALSE) {
  #
  # ---------- base R checks (all data frame classes)

  wrapr::stop_if_dot_args(
    substitute(list(...)),
    "Arguments after ... must be named, e.g., arg = val."
  )

  # arguments
  qassert(dframe, "d+")
  if (!is.null(pattern)) qassert(pattern, "s+")
  qassert(negate, "B1") # missing not allowed

  # ---------- preparation

  # to restore class except grouped tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  setDT(dframe)

  # ---------- do the work

  if (length(pattern) > 0) {
    pattern <- paste0(pattern, collapse = "|")

    dframe <- dframe[apply(dframe, 1, function(i) {
      if (negate) {
        !any(grepl(pattern, i, ignore.case = TRUE, fixed = FALSE))
      } else {
        any(grepl(pattern, i, ignore.case = TRUE, fixed = FALSE))
      }
    }), ]
  }

  # ---------- prepare to return

  # ensure unique rows
  dframe <- unique(dframe)

  # restore class
  setattr(dframe, "class", prior_class)

  # done
  dframe[]
}







# ---------- deprecated version
#
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
    new = "filter_programs",
    package = "midfieldr",
    msg = "This function was deprecated to put the data frame as the
    first argument making it possible to chain with other functions.
    Please use `filter_programs()` instead."
  )

  # attempt to continue to use original function with partial success
  if (is.null(cip)) cip <- midfieldr::cip
  negate <- FALSE

  if (!is.null(drop_text)) {
    keep_text <- drop_text
    negate <- TRUE
  }

  filter_programs(dframe = cip, pattern = keep_text, negate = negate)
}
