#' Named colors from ColorBrewer palettes
#'
#' Names are assigned to a dataset of selected colors from the ColorBrewer
#' palettes with the hex color codes assigned using RColorBrewer.
#'
#' The purpose of this dataset is to provide convenient access to my preferred
#' ColorBrewer palettes: diverging brown-bluegreen (BrBG) with 8 levels;
#' diverging purple-green (PRGn) with 8 levels; and sequential gray (Greys)
#' using the middle four of 6 levels.
#'
#' Named colors include 4 saturation levels (dark, mid, light, pale) and 5 hues
#' (Br, BG, PR, Gn, Gray or Grey). The color names have the form "level_hue",
#' for example, "dark_Br", "mid_BG", "light_Gn", and "pale_Gray."
#'
#' The color codes can be assigned in an R script using
#' \code{midfieldr::rcb(name)}.
#'
#' @format A data frame of names and colors
#' \describe{
#'   \item{rcb_name}{Character variable of names.}
#'   \item{rcb_code}{Character variable of hex color codes.}
#' }
#' @source Cynthia Brewer (\url{http://colorbrewer2.org}) and RColorBrewer
#' (\url{https://cran.r-project.org/package=RColorBrewer}).
"rcb_colors"
