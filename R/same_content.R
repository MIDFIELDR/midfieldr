
#' Test for equal content between two data tables
#' 
#' Test of data equality between data.table objects. Convenience function 
#' used in vignettes. 
#'
#' Wrapper around \code{all.equal()} for class data.table that ignores row 
#' order, column order, and data.table keys. Both inputs must be date frames. 
#' Equivalent to:
#' 
#' \code{all.equal(target, current, ignore.row.order = TRUE, ignore.col.order = TRUE)}
#' 
#' 
#'
#' @param x Data frame to be compared. Same as \code{target} argument in 
#'          \code{all.equal()}
#' @param y Data frame to be compared. Same as \code{current} argument in 
#'          \code{all.equal()}
#' 
#' 
#' @return Either TRUE or a description of the differences between \code{x} 
#'         and \code{y}. 
#'
#'
#'
#' @example man/examples/same_content_exa.R
#'
#'
#'
#' @export
#'
#'
#'
same_content <- function(x, y) {
    
    # Required argument
    qassert(x, "d+")
    qassert(y, "d+")
    
    # Do the work. 
    # Copy to prevent by-reference changes to x, y
    p <- copy(x)
    q <- copy(y)
    
    # Clear the keys
    setkey(p, NULL)
    setkey(q, NULL)
    
    # Check equality
    all.equal(p, q, ignore.row.order = TRUE, ignore.col.order = TRUE)
}
