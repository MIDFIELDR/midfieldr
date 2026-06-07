
#' Extract unique elements and sort
#' 
#' A strict version of `sort()` and `unique()` (without ...). 
#'
#' @param x             Vector of values to be sorted with any duplicate 
#'                      values removed. 
#' @param ...          `r param_dots`
#' @param incomparables A vector of values. See `unique()`. 
#' @param MARGIN 	    An integer. The array margin to be held fixed. Passed 
#'                      to `unique()`. 
#' @param fromLast      Logical. Indicates if duplication should be considered 
#'                      from the last. Passed to `unique()`. 
#' @param decreasing    Logical. Should the sort be increasing or decreasing? 
#'                      Passed to `sort()`. 
#' @param na.last       Logical. Position of NA values. Passed to `sort()`. 
#'
#' @returns A vector of unique values, sorted. 
#' 
#' @example man/examples/sort_uniq_exa.R
#' 
#' @export
sort_uniq <- function(x, 
                      ..., 
                      incomparables = FALSE, # passed to unique()
                      MARGIN = 1,            # to unique()
                      fromLast = FALSE,      # to unique()
                      decreasing = FALSE,    # passed to sort()
                      na.last = FALSE) {     # to sort()
    
    wrapr::stop_if_dot_args(substitute(list(...)), "midfieldr::sort_uniq")
    
    x <- base::unique(x, 
                      incomparables = incomparables, 
                      MARGIN = MARGIN, 
                      fromLast = fromLast)
    base::sort(x, 
               decreasing = decreasing, 
               na.last = na.last)    
}
