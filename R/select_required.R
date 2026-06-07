# Documentation described below using an inline R code chunk, e.g.,
# "`r param_dots`" or "`r return_select_required`", are documented in the
# R/roxygen.R file.


#' Select required midfieldr variables
#'
#' Subset a data frame, selecting columns by matching or partially matching a
#' vector of character strings. A convenience function to reduce the dimensions
#' of a MIDFIELD data table by selecting only those columns required by 
#' other midfieldr functions or that are required to form a composite key. 
#' Particularly useful in interactive sessions when viewing the
#' data tables at various stages of an analysis.
#' 
#' Several midfieldr functions require that their input data frames contain 
#' specific variables (column names) such as `mcid` or `cip6`. In addition, 
#' the MIDFIELD data tables have specific variables that act as keys 
#' or composite keys to the information in that table. All such are assembled 
#' in a character vector that comprises the default set of column names 
#' returned by `select_required()`. The default column set is  
#' `c(mcid, institution, race, sex, term, term_course, term_degree, cip6, level, abbrev, number)`. 
#'
#' Additional column names or partial names can be included by using the
#' `select_add` argument.
#'
#' The column names of `midfield_x` are searched for matches or partial matches
#' using `grep(colnames, ignore.case = TRUE, value = TRUE)`, thus names 
#' that match or partially match search terms are returned; all other 
#' columns are dropped. Regular expressions can be used. Search terms not
#' found are silently ignored.
#'
#' @param midfield_x Data frame from which columns are selected.
#' @param ... `r param_dots`
#' @param select_add Character vector of additional column names to return.
#' @return `r return_select_required`
#'
#' @family select_*
#' @example man/examples/select_required_exa.R
#' @export
#'
select_required <- function(midfield_x, ..., select_add = NULL) {
  
  # remove keys the function sets (if any)
  on.exit(setkey(midfield_x, NULL), add = TRUE)
  
  # attempt to preserve class of incoming data frame
  incoming_class <- class(midfield_x)
  on.exit(class(midfield_x) <- incoming_class, add = TRUE)
  
  # assert arguments after dots used by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    paste(
      "Arguments after ... must be named.\n",
      "* Did you forget to write `select_add = `?\n *"
    )
  )
  
  # required argument
  qassert(midfield_x, "d+")
  
  # assertions for optional arguments
  if(!is.null(select_add)){
    qassert(select_add, "s+") # missing is OK
  }
  
  # input modified (or not) by reference
  setDT(midfield_x)
  
  # required columns
  # NA
  # class of required columns
  # NA
  # bind names due to NSE notes in R CMD check
  # NA
  
  # do the work
  DT <- copy(midfield_x)
  
  # canonical set of column names (could be a midfieldr option in the future)
  default_colnames <- c(
    "mcid", "institution", "race", "sex", "cip6", "level", 
    "abbrev", "number", "term", "term_course", "term_degree"
  )
  
  # separate default and non-default column names
  cols_we_want <- intersect(colnames(DT), default_colnames)
  cols_to_search <- setdiff(colnames(DT), default_colnames)
  
  # from select_add, create search pattern for grep()
  search_patterns <- paste(select_add, collapse = "|")

  # partial match to non-canonical names
  if (nchar(search_patterns) > 0){
    added_cols <- grep(search_patterns,
                      cols_to_search,
                      ignore.case = TRUE,
                      value = TRUE)
    cols_we_want <- c(cols_we_want, added_cols)
  }
  
  # Select with conventional data.table syntax
  DT <- DT[, .SD, .SDcols = cols_we_want]
  
  # stop if all columns have been eliminated
  if (length(names(DT)) < .Machine$double.eps^0.5) {
    stop(
      paste(
        "The result is empty. Possible causes are:\n",
        "* Column names of the input data frame\n",
        "  do not match any of the search terms.\n"
      ),
      call. = FALSE
    )
  }
  
  # attempt to return same class as incoming
  setkey(DT, NULL)
  class(DT) <- incoming_class
  return(DT)
}
