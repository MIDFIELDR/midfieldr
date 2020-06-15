



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

#' Creates my own shorter version of session_info for vignettes
#' from the sessioninfo package
#' @NoRd
my_session <- function(package_string) {
  # platform
  x <- sessioninfo::platform_info()
  print(x)
  cat("\n")
  # packages
  y        <- sessioninfo::package_info()
  sel      <- stringr::str_detect(y$package, package_string)
  pkgs     <- y[sel, ]
  pkgs[11] <- NULL
  print(pkgs)
  cat("* packages attached to the search path, dependencies not shown")
}




#' function to print to html using kable, control font size
#' @NoRd
kable2html <- function(...) {
  knitr::kable(..., "html") %>%
    kableExtra::kable_styling(font_size = 12)
}






