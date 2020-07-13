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

# checks argument class in functions
assert_class <- function (x, y) {
  if (!is.null(x)) {
    if (!inherits(x, y)) {
      stop("`", deparse(substitute(x)), "` must be of class ",
           paste0(y, collapse = ", ")
           , call. = FALSE)
    }
  }
}

# function_that_might_return_null_or_empty() %||% default value
# z <- a %||% b
`%||%` <- function(a, b) {
  if (!is.null(a) && length(a) > 0) a else b
  }


# vignette only print html table
kable2html <- function(df) {
  knitr::kable(df, "html") %>%
    kableExtra::kable_styling(font_size = 11)
}




# filter 'data' by student IDs
# id_filter <- function(data, keep_id) {
#   id <- NULL
#   data.table::setDT(data)
#   DT <- data[id %chin% keep_id, ]
#   DT <- unique(DT)
#   data.table::setDF(DT)
# }
