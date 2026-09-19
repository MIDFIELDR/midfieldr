#' Remove redundant columns
#'
#' Subset a data frame to remove redundant columns. The goal
#' of this function is to prevent overwriting existing columns and to avoid
#' duplicating columns. Primarily used internally in midfieldr functions that
#' add columns to a data frame.
#'
#' Several midfieldr functions add columns to a working data frame. If the name
#' of a new variable matches that of an existing  variable,
#' the new variable name acquires a suffix ".1", ".2", etc., provided by
#' `base::make.unique().` Before the final data frame is returned, all variable names
#' (including existing variables) are temporarily split from their dot suffixes, if any.
#' Resulting columns are dropped if they duplicate a previous column (where
#' 'previous' means to the left of the duplicate in the data frame).
#'
#' @param dframe `r dframe`
#' @returns Data frame with the following properties:
#' * `r keep_class_rm_groups_rm_keys`
#' * Rows are preserved.
#' * Unique columns preserved. Redundant columns dropped.
#' @example man/examples/exa_rm_redundant_cols.R
#' @export
rm_redundant_cols <- function(dframe) {
  #
  # ---------- initial assertions

  qassert(dframe, "d+")

  # ---------- declarations

  # bind names for R CMD check
  V1 <- NULL
  V2 <- NULL

  # ---------- preparation

  # for restoring class except grouped tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)

  # convert class for analysis
  setDT(dframe)

  # ---------- do the work

  uniq_names <- colnames(dframe)

  # make.unique() adds .1, .2, etc. suffix to make unique names
  # so we split at the "." only
  root_names <- tstrsplit(uniq_names, split = "\\.")[[1]]

  # at least one pair column names differ only by suffix .1, .2, etc.
  if (sum(uniq_names != root_names) > 0) {
    # pairwise combinations of column integers
    idx_pairs <- t(combn(1:length(uniq_names), m = 2))
    idx_pairs <- as.data.table(idx_pairs)

    names_to_drop <- as.character()
    for (i in 1:nrow(idx_pairs)) {
      idx_1 <- idx_pairs[i, (V1)]
      idx_2 <- idx_pairs[i, (V2)]

      # isolate two columns in separate data tables
      p <- dframe[, .SD, .SDcols = uniq_names[idx_1]]
      setnames(p, old = uniq_names[idx_1], new = root_names[idx_1])

      q <- dframe[, .SD, .SDcols = uniq_names[idx_2]]
      setnames(q, old = uniq_names[idx_2], new = root_names[idx_2])

      # drop name.j column if it duplicates name.i column
      if (identical(p, q)) {
        names_to_drop <- unique(c(names_to_drop, uniq_names[idx_2]))
      }
    }
    if (!is.null(names_to_drop)) {
      dframe[, c(names_to_drop) := NULL]
    }
  }

  # ---------- prepare to return

  # NULL keys, return vars, unique, class
  dframe <- utils_prep_return(dframe, return_vars = NULL, prior_class)

  # done
  dframe[]
}
