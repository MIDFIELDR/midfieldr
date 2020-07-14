# checks that midfielddata installed (from drat repo)
# G. Brooke Anderson and Dirk Eddelbuettel
# The R Journal (2017) 9:1, pages 486-497
# https://journal.r-project.org/archive/2017/RJ-2017-026/index.html
.pkgglobalenv <- new.env(parent = emptyenv())
.onAttach <- function(libname, pkgname) {
  has_data_package <- requireNamespace("midfielddata")

  if (!has_data_package) {
    packageStartupMessage(paste(
      "midfieldr depends on midfielddata,",
      "a data package available from a drat",
      "repository on GitHub. Instructions at",
      "https://midfieldr.github.io/midfieldr."
    ))
  }
  assign("has_data", has_data_package, envir = .pkgglobalenv)
}

#' Vignette table
#'
#' Prints a data frame as an HTML table in a vignette. Uses knitr::kable
#' and kableExtra::kable_styling to adjust font size. Function is exported
#' so it can be used in vignettes.
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

#' Check argument class
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

#' Check argument is explicit, not NULL
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

  data.table::setDT(data)

  # filter to keep rows
  if (length(keep_any) > 0) {
    keep_any <- paste0(keep_any, collapse = "|")
    data <- data[apply(data, 1, function(i) {
      any(grepl(keep_any, i, ignore.case = TRUE))
    }), ]
  }

  # filter to drop rows
  if (length(drop_any) > 0) {
    drop_any <- paste0(drop_any, collapse = "|")
    data <- data[apply(data, 1, function(j) {
      !any(grepl(drop_any, j, ignore.case = TRUE))
    }), ]
  }
  data.table::setDF(data)
}
