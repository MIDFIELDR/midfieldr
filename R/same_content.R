
#' Test for equal content between two data tables
#' 
#' This function is deprecated in favor of [wrapr::check_equiv_frames()] imported from 
#' the wrapr package, accessible by loading 'midfieldr'. 
#'
#' Test of data equality between data.table objects. Convenience function used
#' in 'midfieldr' articles.
#'
#' Wrapper around `all.equal()` for class data.table that ignores row order,
#' column order, and data.table keys. Both inputs must be date frames.
#' Equivalent to:
#'
#' `all.equal(target, current, ignore.row.order = TRUE, ignore.col.order = TRUE)`
#'
#' @param x Data frame to be compared. Same as `target` argument in
#'   `all.equal()`
#' @param y Data frame to be compared. Same as `current` argument in
#'   `all.equal()`
#' 
#' @return Either TRUE or a description of the differences between `x` and `y`. 
#' @name same_content-deprecated
#' @usage same_content(x, y)
#' @seealso \code{\link{midfieldr-deprecated}}
#' @keywords internal
NULL

#' @rdname midfieldr-deprecated
#' @section `same_content`:
#' For `same_content()`, use `check_equiv_frames()`
#' @export
same_content <- function(x, y) {
    
    # deprecated
    .Deprecated(old = "same_content", 
                new = "check_equiv_frames",
                package = "wrapr",
                msg = '`same_content()` is deprecated. Please use   
                `check_equiv_frames()` imported from the wrapr 
                package and accessible when you load midfieldr.')
    
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
