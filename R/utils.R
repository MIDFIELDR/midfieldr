# Re-export functions, external utilities, and internal utilities

# ------------------------------------------ RE-EXPORTS

#' @export
#' @importFrom wrapr check_equiv_frames
wrapr::check_equiv_frames


# ------------------------------------------ EXTERNAL UTILITIES

#' Error handling
#'
#' A wrapper on `base::tryCatch()` for previewing an error message, if any.
#'
#' @param f Function with arguments expecting an error
#' @returns Does not return anything. The side effect is to output to the terminal.
#' @example man/examples/exa_catch_error.R
#' @export
catch_error <- function(f) {
  tryCatch(
    {
      f
    },
    error = function(e) {
      cat("Error:", e$message, "\n")
    }
  )
}

#' Display structure
#'
#' A wrapper on `base::str()` with arguments set to not show attributes,
#' to not show length, and to cut the width.
#'
#' @param x Any R object.
#'
#' @returns Does not return anything. The side effect is to output to the terminal.
#'
#' @example man/examples/exa_look_at.R
#'
#' @export
look_at <- function(x) {
  str(x,
    give.attr = FALSE,
    give.length = FALSE,
    width = 80,
    strict.width = "cut"
  )
}

#' Extract unique elements and sort
#'
#' A strict version of `sort()` and `unique()` (without ...)
#'                      applied to vectors only.
#'
#' @param x             Vector of values to be sorted with any duplicate
#'                      values removed.
#' @param ...          `r param_dots`
#' @param na.rm         Logical. Indicates if missing values (including NaN)
#'                      should be removed. Passed to `unique()`.
#' @param decreasing    Logical. Should the sort be increasing or decreasing?
#'                      Passed to `sort()`.
#' @param na.last       Logical. Position of NA values. Passed to `sort()`.
#'
#' @returns A vector of unique values, sorted.
#'
#' @example man/examples/exa_sort_uniq.R
#'
#' @export
sort_uniq <- function(x,
                      ...,
                      na.rm = FALSE, # passed to unique()
                      decreasing = FALSE, # passed to sort()
                      na.last = FALSE) { # to sort()

  wrapr::stop_if_dot_args(substitute(list(...)), "midfieldr::sort_uniq")

  checkmate::check_atomic_vector(x)

  x <- unique(x, na.rm = na.rm)

  base::sort(x,
    decreasing = decreasing,
    na.last = na.last
  )
}


# ------------------------------------------ INTERNAL UTILITIES

#' Edit names of new columns
#'
#' Prevents overwriting existing columns in data frame that happen to match
#' internal, temporary column names within the function.
#'
#' @param dframe Data frame to which columns are being added.
#' @param proposed_new_names Vector of column names being added internally
#'        in the function, excluding the names of columns that are the output
#'        of the function.
#' @noRd
edit_new_col_names <- function(dframe, proposed_new_names) {
  # prevent any possible by-ref changes (probably not necessary here)
  dframe <- copy(dframe)

  # existing column names
  exist_names <- colnames(dframe)

  # add suffix .1, .2, etc. to new names as needed if they match existing
  uniq_names <- make.unique(c(exist_names, proposed_new_names))

  # return the edited new names
  new_names <- setdiff(uniq_names, exist_names)[]
}
