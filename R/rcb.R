#' @importFrom dplyr filter select
#' @importFrom magrittr %>%
#' @importFrom stringr str_detect
NULL

#' Hex color codes from RColorBrewer
#'
#' Accesses the \code{midfieldr::rcb_colors} dataset and returns a hex color code.
#'
#' @param pattern A character variable of a custom color name of the form
#'  "level_hue",  with 4 levels (dark, mid, light, pale) and 5 hues
#'   (Br, BG, PR, Gn, Gray or Grey). For example, "dark_Br", "mid_BG",
#'   "light_Gn", or "pale_Gray."
#'
#' @return A hexadecimal color code in character form "#nnnnnn"
#'
#' @examples
#' rcb("dark_Br")
#'
#' @export
rcb <- function(pattern) {
  hex_code <- rcb_colors %>%
    filter(str_detect(rcb_name, pattern)) %>%
    select(rcb_code) %>%
    unlist(use.names = FALSE)
  return(hex_code)
}
