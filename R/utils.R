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
#' @importFrom utils capture.output object.size
NULL

#' Obtain the traits of a data frame
#'
#' Returns a list with number of observations (rows), number of variables
#' (columns), and size of the file (bytes). The return object is a list named
#' components n_obs, n_var, n_bytes, n_inst, and year_limits.  Function is
#' exported to simplify use in vignettes.
#'
#' @param data data frame
#' @keywords internal
#' @export
data_traits <- function(data) {
  n_obs   <- nrow(data)
  n_var   <- ncol(data)
  n_bytes <- utils::capture.output(print(utils::object.size(data),
                                  units = "auto",
                                  standard = "SI"))

  n_inst <- nrow(get_institution_limits())

  terms  <- unique(midfielddata::midfieldterms$term)
  years  <- sort(floor(terms / 10))
  year_limits <- c(min(years), max(years))

  output  <- list(n_obs = n_obs,
                  n_var = n_var,
                  n_bytes = n_bytes,
                  n_inst = n_inst,
                  year_limits = year_limits)
}

# ------------------------------------------------------------------------

#' Verify class of argument
#'
#' @param x object
#' @param y character string of required class
#' @noRd
assert_class <- function(x, y) {
  if (!is.null(x)) {
    if (!inherits(x, y)) {
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

  # do the work
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
  data.table::setDF(DT)
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

  # do the work
  DT <- data.table::as.data.table(data)
  DT[, term := get(term_col)]
  DT[, year := as.double(substr(term, 1, 4))]
  DT[, iterm := as.double(substr(term, 5, 5))]

  cols_we_want <- c(term_col, "year", "iterm")
  DT <- DT[, ..cols_we_want]
  DT <- unique(DT)
  data.table::setDF(DT)
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

  # do the work
  DT <- data.table::as.data.table(data)
  DT[, (iterm_col) := ifelse(get(iterm_col) >= 3, 3, 1)]
  data.table::setDF(DT)
}





