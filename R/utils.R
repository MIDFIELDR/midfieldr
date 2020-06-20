#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
NULL

# midfielddata installed
.pkgglobalenv <- new.env(parent = emptyenv())
.onAttach <- function(libname, pkgname) {

  # G. Brooke Anderson and Dirk Eddelbuettel
  # The R Journal (2017) 9:1, pages 486-497
  # https://journal.r-project.org/archive/2017/RJ-2017-026/index.html

  has_data_package <- requireNamespace("midfielddata")

  if (!has_data_package) {
    packageStartupMessage(paste(
      "midfieldr depends on midfielddata,",
      "a data package available from a drat repository on GitHub.",
      "Instructions at https://midfieldr.github.io/midfieldr."
    ))
  }
  assign("has_data", has_data_package, envir = .pkgglobalenv)
}

#' Create table
#'
#' Internal function for vignettes to print to html using knitr::kable
#' and set font size with kableExtra::kable_styling.
#'
#' @param x An object to be printed
#' @keywords internal
#' @export
kable2html <- function(x) {
  knitr::kable(x, "html") %>%
    kableExtra::kable_styling(font_size = 11)
}
