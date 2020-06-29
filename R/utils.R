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
      "a data package available from a drat",
      "repository on GitHub. Instructions at",
      "https://midfieldr.github.io/midfieldr."
    ))
  }
  assign("has_data", has_data_package, envir = .pkgglobalenv)
}














#' Vector type predicate
#'
#' Check for a given type and whether it is atomic
#'
#' @param x Object to be tested
#' @keywords internal
#' @export
is_atomic_character <- function(x){
  isTRUE(identical(class(x), "character") && isTRUE(is.atomic(x)))
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

#' Filter by ID
#'
#' Internal function for filtering a midfielddata data set by student iD
#'
#' @param data One of the midfielddata data sets, e.g., \code{midfieldstudents}
#' or  \code{midfieldterms}. Must have a student ID variable.
#' @param input_id Character vector of student IDs used to filter
#' \code{data}.
#' @param ... Not used for values. Forces the subsequent optional arguments
#' to only be usable by name.
#' @param id Column name in quotes of the student ID variable in
#' \code{data}. Default is "id". Optional argument.
#' @keywords internal
#' @export
id_filter <- function(data = NULL, input_id = NULL, ..., id = "id") {

  # argument checks
  if (!(is.data.frame(data) || dplyr::is.tbl(data))) {
    stop("id_filter data argument must be a data frame or tbl")
  }
  if (is.null(input_id)) {
    stop("id_filter input_id argument cannot be NULL.")
  }
  if (!id %in% names(data)) {
    stop("id_filter incorrect value for id argument.")
  }
  wrapr::stop_if_dot_args(substitute(list(...)), "id_filter")

  # addresses "no visible binding" in R CMD check
  ID <- NULL

  # use wrapr::let() to allow alternate column names
  mapping <- c(ID = id)
  wrapr::let(
    alias = mapping,
    expr = {
      df <- dplyr::filter(data, ID %in% input_id)
    }
  )
}

#' Separate YYYYT into year and term
#'
#' Internal function for separating a MIDFIELD term variable (encoding YYYYT)
#' into a YYYY column and a T column.
#'
#' The original columns in \code{data} remain. Two columns are added, one for
#' the year YYYY and the second for the term T.
#'
#' @param data Data frame having a YYYYT term variable.
#' @param col Column name in quotes of the term variable in \code{data}.
#' @keywords internal
#' @export
term_separate <- function(data = NULL, col = NULL) {

  # argument checks
  if (!(is.data.frame(data) || dplyr::is.tbl(data))) {
    stop("term_separate data argument must be a data frame or tbl")
  }
  if (is.null(col)) { # this check comes before the names() check
    stop("term_separate col argument cannot be NULL.")
  }
  if (!col %in% names(data)) {
    stop("term_separate incorrect value for col argument.")
  }

  col_year <- paste0(col, "_year")
  col_term <- paste0(col, "_term")

  # fixes "no visible binding" in R CMD check
  COL <- NULL
  COL_YEAR <- NULL
  COL_TERM <- NULL

  # use wrapr::let() to allow alternate column names
  mapping <- c(
    COL = col,
    COL_YEAR = col_year,
    COL_TERM = col_term
  )

  wrapr::let(
    alias = mapping,
    expr = {
      # check that YYYYT values have exactly 5 digits
      df1 <- data %>%
        select(COL) %>%
        mutate(n_digits = floor(log10(COL)) + 1) %>%
        filter(n_digits != 5)
      if (nrow(df1) != 0) {
        stop("term_separate YYYYT values can have 5 digits only.")
      }
      # do the work
      df <- data %>%
        dplyr::mutate(yyyyt = as.character(COL)) %>%
        tidyr::separate(yyyyt, into = c(col_year, col_term), sep = 4) %>%
        dplyr::mutate(COL_YEAR = round(as.double(COL_YEAR))) %>%
        dplyr::mutate(COL_TERM = round(as.double(COL_TERM)))
    }
  )
}
