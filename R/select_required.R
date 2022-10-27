
#' Select required midfieldr variables
#'
#' Subset a data frame, selecting columns by matching or partially matching a 
#' vector of character strings. A convenience function to reduce the dimensions 
#' of a MIDFIELD data table at the start of a session by selecting only those 
#' columns typically required by other midfieldr functions. Particularly useful 
#' in interactive sessions when viewing the data tables at various stages of  
#' an analysis. 
#' 
#' Several midfieldr functions are designed to operate on one or more of the 
#' MIDFIELD data tables, usually \code{student}, \code{term}, or \code{degree}. 
#' This family of functions requires only a small subset of available 
#' variables, e.g., \code{mcid}, \code{cip6}, or \code{term}. We have 
#' identified the names of all required variables and collected 
#' appropriate search strings in the default \code{select} vector. 
#' 
#' The column names of \code{dframe} are searched for matches or partial matches 
#' in \code{select} using \code{grep()}, thus search terms can include regular 
#' expressions. Variables with names that match or partially match the search 
#' terms are returned; all other columns are dropped. Rows are unaffected. 
#' Search terms not present are silently ignored. 
#' 
#' One could use this function to select columns from a non-MIDFIELD data frame, 
#' but with no benefit to the user---conventional column selection syntax is 
#' better suited to that task. Here, we specialize the column selection to 
#' serve midfieldr functions. 
#'
#' @param dframe Data frame from which columns are selected, typically 
#'        \code{student}, \code{term}, or \code{degree}. 
#' @param ... Not used, force later arguments to be used by name.
#' @param select Optional character vector of column names to return,
#'        default \code{c("mcid", "institution", "race", "sex", "^term", 
#'        "cip6", "level")}.
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'     \item Rows are not modified. 
#'     \item Columns with names that match or partially match the values 
#'           in \code{select}.
#'     \item Grouping structures are not preserved.
#' }
#'
#'
#' @family select_*
#'
#'
# @example man/examples/select_required_exa.R
#'
#'
#' @export
#'
#'
select_required <- function(dframe, ..., select = NULL) {

  # remove all keys
  on.exit(setkey(dframe, NULL))

  # required argument
  qassert(dframe, "d+")

  # assert arguments after dots used by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    paste(
      "Arguments after ... must be named.\n",
      "* Did you forget to write `select = `?\n *"
    )
  )

  # optional arguments
  select <- select %?% c("mcid", "institution", "race", "sex", "^term", "cip6", 
                         "level")
  
  # assertions for optional arguments
  qassert(select, "s+") # missing is OK

  # input modified (or not) by reference
  setDT(dframe)

  # required columns
  # NA
  # class of required columns
  # NA
  # bind names due to NSE notes in R CMD check
  # NA

  # do the work
  DT <- copy(dframe)
  on.exit(setkey(DT, NULL))
  
  # Create one string separated by OR
  search_pattern <- paste(select, collapse = "|")
  
  # Find names of columns matching or partially matching 
  cols_we_want  <- grep(search_pattern, 
                        names(DT), 
                        ignore.case = TRUE, 
                        value = TRUE)
 
  # Select with conventional data.table syntax
  DT <- DT[, .SD, .SDcols = cols_we_want]

  # stop if all columns have been eliminated
  if (abs(ncol(dframe) - 0) < .Machine$double.eps^0.5) {
    stop(
      paste(
        "The result is empty. Possible causes are:\n",
        "* 'dframe' contained no matches to terms in 'select'.\n"
      ),
      call. = FALSE
    )
  }

  # enable printing (see data.table FAQ 2.23)
  DT[]
}
