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
