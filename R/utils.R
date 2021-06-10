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

  # bind names due to nonstandard evaluation notes in R CMD check
  # key_names <- NULL

  # prepare dframe, preserve column order for return
  # omit existing column(s) that match column(s) we add
  setDT(dframe)
  added_cols <- c("inst_limit")
  names_dframe <- colnames(dframe)
  key_names <- names_dframe[!names_dframe %chin% added_cols]
  dframe <- dframe[, key_names, with = FALSE]

  # get max term by institution
  cols_we_want <- c("institution", "term")
  DT <- midfield_table[, cols_we_want, with = FALSE]
  DT <- DT[, list(inst_limit = max(term)), by = "institution"]

  # left-outer join, keep all rows of dframe
  dframe <-  merge(dframe, DT, by = "institution", all.x = TRUE)

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

#' Verify class of argument
#'
#' @param x object
#' @param y character string of required class
#' @noRd
assert_class <- function(x, y) {
  if (!is.null(x)) {
    if (!inherits(x, what = y)) {
      stop("`", deparse(substitute(x)), "` must be of class ",
        paste0(y, collapse = ", "),
        call. = FALSE
      )
    }
  }
}

# ------------------------------------------------------------------------

#' Verify that an argument is explicit, not NULL
#'
#' @param x object
#' @noRd
assert_explicit <- function(x) {
  if (is.null(x)) {
    stop("Explicit `", deparse(substitute(x)), "` argument required",
      call. = FALSE
    )
  }
}

# ------------------------------------------------------------------------

#' Verify required column name exists
#'
#' @param data data frame
#' @param col column name to be verified
#' @noRd
assert_required_column <- function(data, col) {
  assert_class(data, "data.frame")
  assert_class(col, "character")
  if (!col %in% names(data)) {
    stop("Column name `", col, "` required",
      call. = FALSE
    )
  }
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

  # check arguments
  assert_explicit(data)
  assert_class(data, "data.frame")
  assert_class(keep_text, "character")
  assert_class(drop_text, "character")

  # to preserve data.frame, data.table, or tibble
  dat_class <- get_dframe_class(data)
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
  revive_class(DT, dat_class)
  return(DT)
}

# ------------------------------------------------------------------------

#' Get the class of a data frame
#'
#' Used as argument in revive_class()
#'
#' @param x data.frame, tibble, or data.table
#' @noRd
get_dframe_class <- function(x) {

  # argument check
  assert_class(x, "data.frame")

  class_x <- class(x)
  if (sum(class_x %in% "data.table") > 0) {
    df_class <- "data.table"
  } else if (sum(class_x %in% c("tbl_df", "tbl")) > 0) {
    df_class <- "tbl"
  } else {
    df_class <- "data.frame"
  }
  return(df_class)
}

# ------------------------------------------------------------------------

#' Revive the class of a data frame
#'
#' In midfieldr functions, resets the class of a data frame: tibble,
#' data.frame, or data.table
#'
#' @param x data.frame, tibble, or data.table
#' @param df_class character "data.frame", "tbl", or "data.table"
#' @noRd
revive_class <- function(x, df_class) {

  # argument check
  assert_class(x, "data.frame")

  if (df_class == "tbl") {
    data.table::setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
  } else if (df_class == "data.table") {
    x <- data.table::as.data.table(x)
  } else {
    x <- as.data.frame(x)
  }
  return(x)
}

# ------------------------------------------------------------------------

#' Get the class of a data frame column
#'
#' @param x data.frame, tibble, or data.table
#' @noRd
get_col_class <- function(x) {

  # argument check
  assert_class(x, "data.frame")

  col_class <- unlist(lapply(x, FUN = class))
  col_class <- as.data.frame(col_class)
  col_class$col_name <- row.names(col_class)
  row.names(col_class) <- NULL
  return(col_class)
}


# ------------------------------------------------------------------------

#' Unique rows in a data.table using keys
#'
#' @param DT data.table
#' @param cols character vector of column names as keys
#' @noRd
unique_by_keys <- function(DT, cols = NULL) {

  # argument check
  assert_class(DT, "data.frame")

  if (is.null(cols)) {cols <- names(DT)}

  # argument check
  assert_class(cols, "character")

  data.table::setkeyv(DT, cols)
  DT <- subset(unique(DT))
  data.table::setkey(DT, NULL)
  return(DT)
}
