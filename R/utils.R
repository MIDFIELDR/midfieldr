
# all internal (utility) functions

# ------------------------------------------------------------------------

#' Vignette table
#'
#' Prints a data frame as an HTML table in a vignette. Uses knitr::kable
#' and kableExtra::kable_styling to adjust font size. Function is exported
#' to simplify use in vignettes.
#'
#' @param x data frame
#' @param font_size (optional) in points, 11 pt default
#' @param caption (optional) character
#' @keywords internal
#' @export
kable2html <- function(x, font_size = NULL, caption = NULL) {
  font_size <- font_size %||% 11
  kable_in <- knitr::kable(x, format = "html", caption = caption)
  kableExtra::kable_styling(kable_input = kable_in, font_size = font_size)
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
  if (!is.null(a) && length(a) > 0) a else b
}

# ------------------------------------------------------------------------

#' Subset rows of character data frame by matching patterns
#'
#' @param data data frame of character variables
#' @param keep_any character vector of search patterns for retaining rows
#' @param drop_any character vector of search patterns for dropping rows
#' @noRd
filter_char_frame <- function(data = NULL, keep_any = NULL, drop_any = NULL) {

  # check arguments
  assert_explicit(data)
  assert_class(data, c("data.frame", "data.table"))
  assert_class(keep_any, "character")
  assert_class(drop_any, "character")

  # to preserve data.frame, data.table, or tibble
  dat_class <- get_df_class(data)
  DT <- data.table::as.data.table(data)

  # filter to keep rows
  if (length(keep_any) > 0) {
    keep_any <- paste0(keep_any, collapse = "|")
    DT <- DT[apply(DT, 1, function(i) {
      any(grepl(keep_any, i, ignore.case = TRUE))
    }), ]
  }

  # filter to drop rows
  if (length(drop_any) > 0) {
    drop_any <- paste0(drop_any, collapse = "|")
    DT <- DT[apply(DT, 1, function(j) {
      !any(grepl(drop_any, j, ignore.case = TRUE))
    }), ]
  }

  # works by reference
  revive_class(DT, dat_class)
}

# ------------------------------------------------------------------------

#' Split term into two columns
#'
#' @param data data frame with a term column
#' @param col name of the term column
#' @noRd
split_term <- function(data, term_col) {

  # check arguments
  assert_class(data, "data.frame")
  assert_class(term_col, "character")
  assert_required_column(data, term_col)

  # bind names
  term <- NULL
  year <- NULL
  iterm <- NULL
  cols_we_want <- NULL

  # to preserve data.frame, data.table, or tibble
  dat_class <- get_df_class(data)
  DT <- data.table::as.data.table(data)

  # do the work
  DT[, term := get(term_col)]
  DT[, year := as.double(substr(term, 1, 4))]
  DT[, iterm := as.double(substr(term, 5, 5))]

  cols_we_want <- c(term_col, "year", "iterm")
  DT <- DT[, ..cols_we_want]

  # set keys for fast unique()
  data.table::setkeyv(DT, cols_we_want)
  DT <- subset(unique(DT))
  data.table::setkey(DT, NULL)

  revive_class(DT, dat_class)
}

# ------------------------------------------------------------------------

#' Round term digit down to 1 or 3
#'
#' @param data data frame with a T column
#' @param col name of the T column
#' @noRd
round_term <- function(data, iterm_col) {

  # check arguments
  assert_class(data, "data.frame")
  assert_class(iterm_col, "character")
  assert_required_column(data, iterm_col)

  # to preserve data.frame, data.table, or tibble
  dat_class <- get_df_class(data)
  DT <- data.table::as.data.table(data)

  # do the work
  DT[, (iterm_col) := ifelse(get(iterm_col) >= 3, 3, 1)]

  # works by reference
  revive_class(DT, dat_class)
}

# ------------------------------------------------------------------------

#' Get the class of a data frame
#'
#' Used as argument in revive_class()
#'
#' @param x data.frame, tibble, or data.table
#' @noRd
get_df_class <- function(x){
  class_x <- class(x)
  if(sum(class_x %in% "data.table") > 0){
    df_class <- "data.table"
  } else if(sum(class_x %in% c("tbl_df", "tbl")) > 0) {
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
revive_class <- function (x, df_class){
  if(df_class == "tbl"){
    data.table::setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
  } else if (df_class == "data.table"){
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
  col_class <- sapply(x, FUN = class)
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
dt_unique_rows <- function(DT, cols) {
  data.table::setkeyv(DT, cols)
  DT <- subset(unique(DT))
  data.table::setkey(DT, NULL)
}

