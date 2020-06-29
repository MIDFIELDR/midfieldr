#' @importFrom dplyr filter select
#' @importFrom stringr str_detect
NULL

#' Hex color codes from RColorBrewer
#'
#' Accesses the \code{midfieldr::rcb_colors} dataset and returns a hex color
#' code.
#'
#' @param pattern Character variable of a custom color name of the form
#'  "level_hue",  with 4 levels (dark, mid, light, pale) and 5 hues (Br, BG, PR,
#'  Gn, Gray or Grey). For example, "dark_Br", "mid_BG", "light_Gn", or
#'  "pale_Gray."
#'
#' @return Hexadecimal color code in character form "#nnnnnn"
#' @family graph_helper
#' @examples
#' rcb("dark_Br")
#' @export
rcb <- function(pattern) {

  # indicate these are not unbound symbols, helps with R CMD check
  rcb_code <- NULL
  rcb_name <- NULL

  # experimenting with removing pipes
  x <- rcb_colors
  x <- filter(x, str_detect(rcb_name, pattern))
  x <- select(x, rcb_code)
  x <- unlist(x, use.names = FALSE)
  return(x)
}
