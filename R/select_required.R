# Documentation described below using an inline R code chunk, e.g.,
# "`r param_dots`" or "`r return_select_required`", are documented in the
# R/roxygen.R file.



#' Select required midfieldr variables
#'
#' Subset a data frame, selecting columns by matching or partially matching a
#' vector of character strings. A convenience function to reduce the dimensions
#' of a MIDFIELD data table at the start of a session by selecting only those
#' columns required by other midfieldr functions or that are required to form a 
#' composite key. Particularly useful in interactive sessions when viewing the 
#' data tables at various stages of an analysis.
#'
#' Several midfieldr functions require one or more of the variables `mcid`, 
#' `institution`, `race`, `sex`, `^term`, `cip6`, and `level`. And if 
#' one requires a composite key to uniquely identify rows in the course or 
#' degree tables, the variables `abbrev`, `number` and degree variable 
#' `degree` are also required. A vector of these names comprises the default 
#' subset.   
#' 
#' Additional column names or partial names can be included by using the 
#' `select_add` argument. 
#'
#' The column names of `midfield_x` are searched for matches or partial matches
#' using `grep()`, thus search terms can include regular expressions. Variables
#' with names that match or partially match the search terms are returned; all
#' other columns are dropped. Rows are unaffected. Search terms not present are
#' silently ignored.
#'
#' One could use this function to select columns from a non-MIDFIELD data frame,
#' but with no benefit to the user---conventional column selection syntax is
#' better suited to that task. Here, we specialize the column selection to serve
#' midfieldr functions.
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
    
    # remove all keys
    on.exit(setkey(midfield_x, NULL))
    
    # required argument
    qassert(midfield_x, "d+")
    
    # assert arguments after dots used by name
    wrapr::stop_if_dot_args(
        substitute(list(...)),
        paste(
            "Arguments after ... must be named.\n",
            "* Did you forget to write `select_add = `?\n *"
        )
    )
    
    # optional arguments
    default_select <- c("mcid", "institution", "race", "sex", "^term", "cip6", 
                        "level", "abbrev", "number", "degree")
    select <- c(default_select, select_add)
    select <- unique(select)
    
    # assertions for optional arguments
    qassert(select, "s+") # missing is OK
    
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
    
    # enable printing (see data.table FAQ 2.23)
    DT[]
}
