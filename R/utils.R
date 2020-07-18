# ------------------------------------------------------------------------

#' Vignette table
#'
#' Prints a data frame as an HTML table in a vignette. Uses knitr::kable
#' and kableExtra::kable_styling to adjust font size. Function is exported
#' to simplify use in vignettes.
#'
#' @param x data frame
#' @param font_size (optional) in points, 11 pt default
#' @keywords internal
#' @export
kable2html <- function(x, font_size = NULL) {
  font_size <- font_size %||% 11
  kable_in <- knitr::kable(x, "html")
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

#' Get first and last term in data by institution
#'
#' @param data data frame of term attributes
#' @noRd
inst_data_limits <- function(data = NULL){

  # default
  data <- data %||% midfielddata::midfieldterms

  # check arguments
  assert_class(data, "data.frame")
  assert_required_column(data, "institution")
  assert_required_column(data, "term")

  # bind names
  term         <- NULL
  institution  <- NULL
  first_record <- NULL
  data_limit   <- NULL

  # do the work
  DT <- data.table::as.data.table(data)
  DT <- DT[, .(institution, term)]
  DT[, first_record := max(term), by = institution]
  DT[, data_limit   := max(term), by = institution]
  DT <- DT[, .(institution, first_record, data_limit)]
  DT <- unique(DT)
  DT <- DT[order(institution)]
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
  term         <- NULL
  year         <- NULL
  iterm        <- NULL
  cols_we_want <- NULL

  # do the work
  DT <- data.table::as.data.table(data)
  DT[, term  := get(term_col)]
  DT[, year  := as.double(substr(term, 1, 4))]
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

# ------------------------------------------------------------------------

#' Matriculation limit from data limit
#'
#' Does term arithmetic, subtracting years from data limit
#'
#' @param data data frame with columns data_limit, year, iterm
#' @param span typically 6 years
#' @noRd
construct_limits <- function(data, span = NULL){

  # default
  span <- span %||% 6

  # check arguments
  assert_class(data, "data.frame")
  assert_class(span, "numeric")
  assert_required_column(data, "data_limit")
  assert_required_column(data, "year")
  assert_required_column(data, "iterm")

  # bind names
  enter_y      <- NULL
  iterm        <- NULL
  year         <- NULL
  enter_t      <- NULL
  matric_limit <- NULL
  data_limit   <- NULL

  # do the work
  DT <- data.table::as.data.table(data)
  DT[, enter_y := ifelse(iterm > 2,
                           year - span + 1,
                           year - span)
  ][
    , enter_t := ifelse(iterm > 2, 1, 3)
  ][
    , matric_limit := 10 * enter_y + enter_t
  ]
  DT <- unique(DT[, .(matric_limit, data_limit)])
  data.table::setDF(DT)
}

# ------------------------------------------------------------------------




