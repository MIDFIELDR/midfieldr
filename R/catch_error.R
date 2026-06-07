
#' Error handling
#' 
#' A wrapper on `base::tryCatch()` for previewing an error message, if any. 
#'
#' @param f Function with arguments expecting an error
#' @returns Does not return anything. The side effect is to output to the terminal. 
#' @example man/examples/catch_error_exa.R
#' @export
catch_error <- function (f) {
    
    tryCatch({
        f
    }, error = function(e) {
        cat("Error:", e$message, "\n")
    })

}
