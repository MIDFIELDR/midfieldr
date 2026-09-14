#' Choose unique columns
#'
#' Subset a data frame to retain unique columns. A variable in a data frame is
#' dropped if, after splitting its name at a period separator ("."), its name
#' and values are identical to those of another variable. Primarily used
#' internally in midfieldr functions that add columns to a data frame.
#'
#' Several midfieldr functions add columns to a working data frame. The goal
#' of this function is to prevent overwriting existing columns in the data
#' frame that happen to have the same name as one of the added columns. At
#' the same time, if both the name and values of a new column duplicate
#' an existing column, the new column is redundant and can be dropped.
#'
#' If the name of an existing column happens to match that of a new variable,
#' the new variable name is made unique by adding a suffix such as ".1", ".2",
#' etc. Before the final data frame is returned, all variable names are
#' temporarily split from their dot suffixes. Columns are dropped if their
#' values and dot-split name duplicate a previous column. Columns are not
#' dropped if their split names are unique nor if the row-wise values differ.
#'
#' @param dframe `r dframe`
#' @returns Data frame with the following properties:
#' * `r preserv_class_not_grp_keys`
#' * Rows are preserved.
#' * Unique columns preserved. Redundant columns dropped.
#' @export
#'
# @examples
select_unique_cols <- function(dframe) {
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
