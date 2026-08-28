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
#' @param x Any R object.
#' @returns Does not return anything. The side effect is to output to the terminal.
#' @example man/examples/exa_look_at.R
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
#' @param x             Vector of values to be sorted with any duplicate
#'                      values removed.
#' @param ...          `r param_dots`
#' @param na.rm         Logical. Indicates if missing values (including NaN)
#'                      should be removed. Passed to `unique()`.
#' @param decreasing    Logical. Should the sort be increasing or decreasing?
#'                      Passed to `sort()`.
#' @param na.last       Logical. Position of NA values. Passed to `sort()`.
#' @returns A vector of unique values, sorted.
#' @example man/examples/exa_sort_uniq.R
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
#' @param dframe Data frame to which columns are being added.
#' @param proposed_new_names Vector of column names being added internally
#'        in the function, excluding the names of columns that are the output
#'        of the function.
#' @noRd
utils_edit_colnames <- function(dframe, proposed_new_names) {
  # prevent any possible by-ref changes (probably not necessary here)
  dframe <- copy(dframe)

  # existing column names
  exist_names <- colnames(dframe)

  # add suffix .1, .2, etc. to new names as needed if they match existing
  uniq_names <- make.unique(c(exist_names, proposed_new_names))

  # return the edited new names
  new_names <- setdiff(uniq_names, exist_names)[]
}


#' Check required variables in data frame
#'
#' Checkmate assertions on required variables. Suitable for any class data
#' frame.
#' - Required variables exist
#' - Their class is character or factor
#' @param dframe Data frame expected to contain the required variables
#' @param reqd_vars Character vector of required column names to be checked
#' @noRd
utils_check_reqd_vars <- function(dframe, reqd_vars) {
  # required variables exist
  assert_names(colnames(dframe), must.include = reqd_vars)

  # class is string or factor, any length (including zero)
  for (var in reqd_vars) qassert(dframe[[var]], c("s*", "f*"))
}


#' Required variable checks
#'
#' Condition and subset data frame
#' - setDT()
#' - as.character() applied to required variables
#' - na.omit() applied to required variable columns
#' - unique()
#' @param dframe Data frame to be subset
#' @param reqd_vars Character vector of required column names to be checked
#' @noRd
utils_prep_DT <- function(dframe, reqd_vars) {
  # convert class
  setDT(dframe)

  # ensure character
  dframe[, names(.SD) := lapply(.SD, as.character), .SDcols = reqd_vars]

  # filter NAs in required variables
  dframe <- na.omit(dframe, cols = reqd_vars)

  # ensure unique rows
  dframe <- unique(dframe)

  # done
  dframe[]
}

#' Prepare data frame output to be returned
#'
#' Operate on output data frame to:
#' - restore row order via idx
#' - restore column order and drop temporary columns
#' - unique rows
#' - restore class
#' @param dframe Data frame to be returned
#' @param idx Character name of column for restoring row order
#' @param returned_vars Character vector of variables to return
#' @param prior_class Character vector to restore data frame class
#' @noRd
utils_prepare_return <- function(dframe, idx, returned_vars, prior_class) {
  # defaults NULL if absent
  idx <- idx %?% NULL
  returned_vars <- returned_vars %?% NULL
  prior_class <- prior_class %?% NULL

  # bind names for R CMD check
  IDX <- NULL

  # restore row order
  if (!is.null(idx)) {
    setkeyv(dframe, idx)
    # drop idx column, needed for NULL returned_vars
    dframe[, IDX := NULL, env = list(IDX = idx)]
  }

  # restore column order and drop temporary columns
  if (!is.null(returned_vars)) {
    dframe <- dframe[, .SD, .SDcols = returned_vars]
  }

  # ensure unique rows
  dframe <- unique(dframe)

  # restore class
  if (!is.null(prior_class)) {
    setattr(dframe, "class", prior_class)
  }
}
