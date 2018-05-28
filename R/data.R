#' CIP codes for programs in biological and biomedical science
#'
#' All 6-digit codes from the 2010 CIP 26 series.
#'
#' @source NSF STEM programs: \url{https://www.ice.gov/sites/default/files/documents/Document/2016/stem-list.pdf}.
#' @format A character vector.
#' @examples
#' \dontrun{
#'  bio_sci
#' }
"bio_sci"

#' CIP codes for programs in engineering
#'
#' All 6-digit codes from the 2010 CIP 14 series.
#'
#' @source NSF STEM programs: \url{https://www.ice.gov/sites/default/files/documents/Document/2016/stem-list.pdf}.
#' @format A character vector.
#' @examples
#' \dontrun{
#'  engr
#' }
"engr"

#' CIP codes for programs in mathematics and statistics
#'
#' All 6-digit codes from the 2010 CIP 27 series.
#'
#' @source NSF STEM programs: \url{https://www.ice.gov/sites/default/files/documents/Document/2016/stem-list.pdf}.
#' @format A character vector.
#' @examples
#' \dontrun{
#'  math_stat
#' }
"math_stat"

#' CIP codes for programs in physical science
#'
#' All 6-digit codes from the 2010 CIP 40 series.
#'
#' @source NSF STEM programs: \url{https://www.ice.gov/sites/default/files/documents/Document/2016/stem-list.pdf}.
#' @format A character vector.
#' @examples
#' \dontrun{
#'  phys_sci
#' }
"phys_sci"

#' CIP codes for other programs in STEM
#'
#' All 6-digit codes for STEM programs excluding \code{bio_sci}, \code{engr},
#' \code{math_stat}, and \code{phys_sci}.
#'
#' @source NSF STEM programs: \url{https://www.ice.gov/sites/default/files/documents/Document/2016/stem-list.pdf}.
#' @format A character vector.
#' @examples
#' \dontrun{
#'  other_stem
#' }
"other_stem"

#' CIP codes for all programs in STEM
#'
#' All 6-digit codes for STEM programs. Concatenates all named series:
#' \code{bio_sci}, \code{engr}, \code{math_stat}, \code{other_stem},
#' and \code{phys_sci}.
#'
#' @source NSF STEM programs: \url{https://www.ice.gov/sites/default/files/documents/Document/2016/stem-list.pdf}.
#' @format A character vector.
#' @examples
#' \dontrun{
#'  stem
#' }
"stem"

#' Stickiness case data
#'
#' An example of stickiness data
#'
#' @source A pre-processed data frame constructed following the steps described in the \code{stickiness} vignette.
#' @format A data frame with columns:
#' \describe{
#'  \item{program}{Instructional programs selected for study.}
#'  \item{race}{Student race from \code{midfieldstudents} data.}
#'  \item{sex}{Student sex from \code{midfieldstudents} data.}
#'  \item{ever}{Number of students ever enrolled in a program. Grouped and
#'  summarized from \code{midfieldterms} data.}
#'  \item{grad}{Number of students graduating from the program. Grouped and
#'  summarized from \code{midfielddegrees} data.}
#'  \item{stick}{Program stickiness: the ratio of the number of students
#'  graduating from a program to the number ever enrolled in the program.}
#' }
#' @examples
#' \dontrun{
#'  case_stickiness
#' }
"case_stickiness"

#' Named colors from the ColorBrewer palettes
#'
#' Shorthand names are assigned to selected colors from the
#' ColorBrewer palettes.
#'
#' This dataset provides convenient access to selected ColorBrewer palettes:
#' diverging brown-bluegreen (BrBG) with 8 levels; diverging purple-green
#' (PRGn) with 8 levels; and sequential gray (Greys) with the middle four of 6
#' levels.
#'
#' The color names have the form "level_hue" with 4 saturation levels (dark,
#' mid, light, pale) and 5 hues (Br, BG, PR, Gn, Gray or Grey). For example,
#' "dark_Br", "mid_BG", "light_Gn", and "pale_Gray" are all recognized names.
#'
#' The color codes are assigned in an R script using
#' \code{midfieldr::rcb(name)}.
#'
#' @source Cynthia Brewer (\url{http://colorbrewer2.org}) and RColorBrewer
#' (\url{https://cran.r-project.org/package=RColorBrewer}).
#' @format A data frame with columns:
#' \describe{
#'   \item{rcb_name}{Character variable of names.}
#'   \item{rcb_code}{Character variable of hex color codes.}
#' }
#' @examples
#' \dontrun{
#'  rcb_colors
#' }
"rcb_colors"
