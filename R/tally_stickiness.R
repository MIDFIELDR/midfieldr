#' @importFrom dplyr left_join mutate na_if
#' @importFrom magrittr %>%
NULL

#' Compute stickiness
#'
#' Stickiness is the ratio of the number of students graduating from a program
#' to the number of students ever enrolled in a program.
#'
#' The two input arguments must have at least one categorical variable in
#' common for joining.
#'
#' @param ever A data frame with at least one categorical variable and a
#' numeric variable named \code{ever}
#'
#' @param grad A data frame with at least one categorical variable and a
#' numeric variable named \code{grad}
#'
#' @return A data frame with all the original columns of the two input
#' arguments plus a stickiness column.
#'
#' The two input data frames are joined by the set of variables they have in
#' common.
#'
#' @export
tally_stickiness <- function(ever, grad) {
  stopifnot(is.data.frame(ever))
  stopifnot(is.data.frame(grad))
  stopifnot(identical(dim(ever)[[1]], dim(grad)[[1]]))
  stopifnot("ever" %in% names(ever))
  stopifnot("grad" %in% names(grad))

  stickiness <- dplyr::left_join(ever, grad) %>%
    dplyr::mutate(stick = round(grad / dplyr::na_if(ever, 0), 3))

  # Check that multiple matches have not ocurred during left_join()
  # by checking output dimensions
  stopifnot(identical(dim(stickiness)[[1]], dim(grad)[[1]]))
  return(stickiness)
}
"tally_stickiness"
