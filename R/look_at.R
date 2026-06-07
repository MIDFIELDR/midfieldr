
#' Display structure
#' 
#' A wrapper on `base::str()` with arguments set to not show attributes, 
#' to not show length, and to cut the width. 
#'
#' @param x Any R object. 
#'
#' @returns Does not return anything. The side effect is to output to the terminal. 
#'   
#' @example man/examples/look_at_exa.R
#'
#' @export
look_at <- function(x) {
    str(x, 
        give.attr = FALSE, 
        give.length = FALSE,
        width = 80, 
        strict.width = "cut")
}
