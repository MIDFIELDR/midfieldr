



#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
NULL



# adapted from
# G. Brooke Anderson and Dirk Eddelbuettel
# The R Journal (2017) 9:1, pages 486-497
# https://journal.r-project.org/archive/2017/RJ-2017-026/index.html

.pkgglobalenv <- new.env(parent = emptyenv())

.onAttach <- function(libname, pkgname) {
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






#' Session information
#'
#' Internal function to print a less verbose session information output for
#' vignettes using sessioninfo::session_info
#'
#' @param pkg_names A character vector of package names
#' @keywords internal
#' @export
my_session <- function(pkg_names) {
  # platform
  print(sessioninfo::platform_info())
  cat("\n")

  # packages
  pkg_str  <- stringr::str_c(pkg_names, collapse = "|")
  y        <- sessioninfo::package_info()
  sel      <- stringr::str_detect(y$package, pkg_str)
  pkgs     <- y[sel, ]
  pkgs[11] <- NULL
  print(pkgs)
  cat("* dependent packages not listed")
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
    kableExtra::kable_styling(font_size = 10)
}






