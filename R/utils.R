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
#' @example man/examples/catch_error_exa.R
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
#' @example man/examples/look_at_exa.R
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
#' @example man/examples/sort_uniq_exa.R
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

#' Set column order and row order
#'
#' Use the vector of column names in `cols` as the ordering argument in
#' `data.table::setcolorder()`` and as the key argument in
#' `data.table::setkeyv()` to order the rows.
#'
#' @param dframe data frame
#' @param cols character vector of column names to use as keys
#' @noRd
#'
set_colrow_order <- function(dframe, cols) {
  on.exit(setkey(dframe, NULL))

  # ensure dframe is data.table class
  setDT(dframe)

  # column order of data frame by vector of names
  setcolorder(dframe, neworder = cols)

  # order rows by using names as keys
  setkeyv(dframe, cols = cols)
}

# ------------------------------------------------------------------------
#
#' Return column names not overwritten by the function
#'
#' Identifies the names of columns unaffected by the function operation.
#' Used by several midfieldr "add_" functions.
#'
#' @param dframe data frame
#' @param new_cols character vector of column names added by the function
#' @noRd
#'
find_old_cols <- function(dframe, new_cols) {
  all_cols <- colnames(dframe)
  old_cols <- all_cols[!all_cols %chin% new_cols]
  return(old_cols)
}


# ------------------------------------------------------------------------
#
#' Add a column of institution names
#'
#' Add a column of character values with institution names (or labels) using
#' student ID as the join-by variable. Obtains the information from the MIDFIELD
#' `term` data table or equivalent. In the MIDFIELD practice data, the labels
#' are de-identified.
#'
#' If a student is associated with more than one institution, the institution at
#' which they completed the most terms is returned. An existing column with the
#' same name as the added column is overwritten.
#'
#' @param dframe Data frame with required variable `mcid.`
#' @param midfield_term MIDFIELD `term` data table or equivalent with required
#' variables `mcid`, `institution`, and `term`.
#' @noRd
#'
add_institution <- function(dframe,
                            midfield_term = term) {
  # remove all keys
  on.exit(setkey(dframe, NULL))
  on.exit(setkey(midfield_term, NULL), add = TRUE)

  # required arguments
  qassert(dframe, "d+")
  qassert(midfield_term, "d+")

  # optional arguments
  # NA

  # inputs modified (or not) by reference
  dframe <- copy(as.data.table(dframe)) #  must copy
  setDT(midfield_term) # immediately subset, so side-effect OK

  # required columns
  assert_names(colnames(dframe),
    must.include = c("mcid")
  )
  assert_names(colnames(midfield_term),
    must.include = c("mcid", "institution", "term")
  )

  # class of required columns
  qassert(dframe[, mcid], "s+")
  qassert(midfield_term[, mcid], "s+")
  qassert(midfield_term[, institution], "s+")
  qassert(midfield_term[, term], "s+")

  # bind names due to NSE notes in R CMD check
  N <- NULL

  # do the work
  # Inner join using three columns of term
  x <- midfield_term[, .(mcid, institution, term)]
  y <- unique(dframe[, .(mcid)])
  DT <- y[x, on = .(mcid), nomatch = NULL]

  # count terms at institutions
  DT <- DT[, .N, by = c("mcid", "institution")]

  # what if there is a tie? can we select the most recent institution?
  # keep the institution with the most terms (if more than one)
  setkeyv(DT, c("mcid", "N"))
  DT <- DT[, .SD[.N], by = "mcid"]
  DT[, N := NULL]

  # join to dframe, overwrite institution if any
  if ("institution" %chin% names(dframe)) {
    dframe[, institution := NULL]
  }

  # left join, keep all rows of dframe
  setkeyv(DT, "mcid")
  setkeyv(dframe, "mcid")
  dframe <- DT[dframe]
  return(dframe)
}




# ------------------------------------------------------------------------
#
#' Prepare non-data.table data frames
#'
#' Converts data.frames or tibbles to data.tables to enable data.table syntax
#' in midfieldr functions. No effect on data.table inputs. Employs `copy()`
#' on non-data.tables only.
#'
#' @param df Data frame of any class input to a midfieldr function
#' @noRd
prep_non_dt_input <- function(df) {
  # convert data.frames or tibbles to data.table
  # data.tables: no effect, by-ref changes still possible in global env
  # tibbles or base R data.frames: prevents by-ref changes in global env

  if ("data.table" %chin% class(df)) {
    # No change to input. Avoids copy(), but enables by-ref changes to df
    # in global env, OK if we're editing and returning the original df,
    # and moot if df is subset before any by-ref operations
    return(df)
  } else {
    # Convert input to enable data.table syntax throughout. copy()
    # required, otherwise setDT() converts input tibbles or base R
    # data.frames to data.tables by-ref in the global env.
    DT <- copy(df)
    setDT(DT)
    return(DT)
  }
}


# ------------------------------------------------------------------------
#
#' Restore class of non-data.table data frames
#'
#' Attempt to assign class to output data frame to match class of input data
#' frame. No effect on data.tables. Used to attempt to preserve tibbles for
#' users of dplyr and friends.
#'
#' @param DT Data frame in data.table format just prior to exiting a midfieldr
#'        function.
#' @param prior_class Character, result of applying `class()` to input argument
#'        of midfieldr function. Passed to `setattr()`.
#' @noRd
restore_non_dt_class <- function(DT, prior_class) {
  # restore input class if tibble or base R data.frames
  # except grouped tibble returned as data.frame

  if ("data.table" %chin% prior_class) {
    # case: data.table
    return(DT)
  } else if (!"grouped_df" %chin% prior_class) {
    # case: not data.table, not grouped tibble
    setattr(DT, "class", prior_class)
    return(DT)
  } else {
    # case: not data.table, is grouped tibble
    setDF(DT)
    return(DT)
  }
}
