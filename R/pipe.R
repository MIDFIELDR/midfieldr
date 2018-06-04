#' Pipe operator
#'
#' Re-exports the magrittr pipe operator, \code{\%>\%}.
#'
#' The goal of re-exporting this function is to make it accessible to the
#' examples in the midfieldr package.
#'
#' @importFrom magrittr %>%
#' @name %>%
#' @rdname pipe
#' @export
#' @param lhs,rhs An object and a function to apply to it.
#' @source https://github.com/rstudio/ggvis/blob/master/R/pipe.R
#' @examples
#' cip_filter(series = "History") %>% cip_filter(series = "American")
#' cip_filter(series = "^14") %>% cip_filter(series = "Electrical")
NULL
