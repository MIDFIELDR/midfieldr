#' @import data.table
NULL

# internal utility functions

# ------------------------------------------------------------------------

#' Add term range by institution
#'
#' Determine the latest academic term by institution in \code{midfield_table}.
#' Left-join by institution to \code{dframe} in a new column \code{inst_limit}.
#'
#' @param dframe data frame that received added column
#' @param midfield_table data frame of term attributes
#' @noRd
add_inst_limit <- function(dframe, midfield_table) {

  # prepare dframe, preserve column order for return
  # omit existing column(s) that match column(s) we add
  setDT(dframe)
  setDT(midfield_table)
  added_cols <- c("inst_limit")
  names_dframe <- colnames(dframe)
  key_names <- names_dframe[!names_dframe %chin% added_cols]
  dframe <- dframe[, key_names, with = FALSE]

  # get max term by institution
  cols_we_want <- c("institution", "term")
  DT <- midfield_table[, cols_we_want, with = FALSE]
  DT <- DT[, list(inst_limit = max(term)), by = "institution"]

  # left-outer join, keep all rows of dframe
  dframe <- merge(dframe, DT, by = "institution", all.x = TRUE)

  # original columns as keys, order columns and rows
  set_colrow_order(dframe, key_names)
  return(dframe)
}

# ------------------------------------------------------------------------

#' Set column order and row order
#'
#' Use the vector of column names in \code{cols} as the ordering argument
#' in \code{data.table::setcolorder()} and as the key argument in
#' \code{data.table::setkeyv()} to order the rows.
#'
#' @param dframe data frame
#' @param cols character vector of column names to use as keys
#' @noRd
set_colrow_order <- function(dframe, cols) {
  # ensure dframe is data.table class
  setDT(dframe)

  # column order of data frame by vector of names
  setcolorder(dframe, neworder = cols)

  # order rows by using names as keys
  setkeyv(dframe, cols = cols)

  # remove keys
  setkey(dframe, NULL)
  return(dframe)
}

# ------------------------------------------------------------------------

#' Assign default arguments in functions
#'
#' Infix operator. If 'a' is NULL, assign default 'b'.
#' a <- a %||% b
#'
#' @param a object that might be NULL
#' @param b default argument in case of NULL
#' @noRd
`%||%` <- function(a, b) {
  if (!is.null(a) && length(a) > 0) a else data.table::copy(b)
}

# ------------------------------------------------------------------------

#' Subset rows of character data frame by matching keep_texts
#'
#' @param data data frame of character variables
#' @param keep_text character vector of search keep_texts for retaining rows
#' @param drop_text character vector of search keep_texts for dropping rows
#' @noRd
filter_char_frame <- function(data, keep_text = NULL, drop_text = NULL) {

  DT <- data.table::as.data.table(data)

  # filter to keep rows
  if (length(keep_text) > 0) {
    keep_text <- paste0(keep_text, collapse = "|")
    DT <- DT[apply(DT, 1, function(i) {
      any(grepl(keep_text, i, ignore.case = TRUE))
    }), ]
  }

  # filter to drop rows
  if (length(drop_text) > 0) {
    drop_text <- paste0(drop_text, collapse = "|")
    DT <- DT[apply(DT, 1, function(j) {
      !any(grepl(drop_text, j, ignore.case = TRUE))
    }), ]
  }

  # works by reference
  return(DT)
}

# # ------------------------------------------------------------------------
#
# #' Get the class of a column in a data frame
# #'
# #' @param x data.frame, tibble, or data.table
# #' @noRd
# get_col_class <- function(x) {
#
#   # assert data frame with at least one column
#   qassert(x, "d+")
#
#   col_class <- unlist(lapply(x, FUN = class))
#   col_class <- as.data.frame(col_class)
#   col_class$col_name <- row.names(col_class)
#   row.names(col_class) <- NULL
#   return(col_class)
# }

# ------------------------------------------------------------------------

#' Unique rows in a data.table using keys
#'
#' @param DT data.table
#' @param cols character vector of column names as keys
#' @noRd
unique_by_keys <- function(DT, cols = NULL) {

  # assert data frame with at least one column
  qassert(DT, "d+")

  if (is.null(cols)) {
    cols <- names(DT)
  }

  # argument check
  qassert(cols, "s+")

  data.table::setkeyv(DT, cols)
  DT <- subset(unique(DT))
  data.table::setkey(DT, NULL)
  return(DT)
}
