#' Named series of 6-digit CIP codes
#'
#' Collected Classification of Instructional Programs (CIP) 6-digit codes
#' for groups of programs.
#'
#' @name cip_series
#' @format A character vector of 6-digit CIP codes.
#' \describe{
#' \item{\code{cip_bio_sci}}{Biological and biomedical science programs,
#'   26 series, e.g., 260001.}
#' \item{\code{cip_engr}}{Engineering programs, series 14, e.g., 140201.}
#' \item{\code{cip_math_stat}}{Mathematics and statistics programs, series 27,
#'   e.g., 270103.}
#' \item{\code{cip_other_stem}}{Other STEM programs not in \code{cip_bio_sci},
#'   \code{cip_engr}, \code{cip_math_stat}, or \code{cip_phys_sci}.}
#' \item{\code{cip_phys_sci}}{Physical science programs, series 40, e.g.
#'   400202.}
#' \item{\code{cip_stem}}{All Science, Technology, Engineering, and Mathematics
#'   (STEM) programs.}
#' }
#' @source
#' NSF STEM programs, \url{https://www.ice.gov/sites/default/files/documents/Document/2016/stem-list.pdf}
#'
#' CIP 2010, US National Center for Education Statistics,
#'   \url{https://nces.ed.gov/ipeds/cipcode}.
#' @examples
#' head(cip_math_stat, n = 10L)
#' head(cip_phys_sci, n = 10L)
#'
#' cip_filter(series = cip_math_stat)
#' cip_filter(series = cip_phys_sci)
NULL

#' @rdname cip_series
"cip_bio_sci"
#' @rdname cip_series
"cip_engr"
#' @rdname cip_series
"cip_math_stat"
#' @rdname cip_series
"cip_other_stem"
#' @rdname cip_series
"cip_phys_sci"
#' @rdname cip_series
"cip_stem"

#' Stickiness case data
#'
#' An example of program stickiness data grouped by student race and sex.
#'
#' @format A data frame with columns:
#' \describe{
#'  \item{program}{Instructional programs selected for study.}
#'  \item{race}{Student race and sex from \code{midfieldstudents} data.}
#'  \item{sex}{Student sex from \code{midfieldstudents} data.}
#'  \item{ever}{Number of students ever enrolled in a program. Grouped and
#'  summarized from \code{midfieldterms} data.}
#'  \item{grad}{Number of students graduating from the program. Grouped and
#'  summarized from \code{midfielddegrees} data.}
#'  \item{stick}{Program stickiness: the ratio of the number of students
#'  graduating from a program to the number ever enrolled in the program.}
#' }
#' @examples
#' case_stickiness
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
#' mid, light, pale) and 5 hues (Br, BG, PR, Gn, Gray or Grey).
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{rcb_name}{Character variable of names.}
#'   \item{rcb_code}{Character variable of hex color codes.}
#' }
#' @source Cynthia Brewer (\url{http://colorbrewer2.org}) and RColorBrewer
#' (\url{https://cran.r-project.org/package=RColorBrewer}).
#' @examples
#' rcb_colors
#'
#' rcb("dark_Br")
#'
#' rcb("light_Gn")
"rcb_colors"

#' Classification of Instructional Programs (CIP) data
#'
#' A dataset of codes and names for 1544 instructional programs organized on
#' three levels: a 2-digit series, a 4-digit series, and a 6-digit series.
#'
#' 6-digit codes are used in the midfieldr datasets (\code{midfieldstudents},
#' \code{midfieldcourses}, \code{midfieldterms}, and  \code{midfielddegrees})
#' to encode program information as reported by the member institutions.
#'
#' In addition to the standard codes and names, the midfieldr taxonomy includes
#' the codes "99", "9999", and "999999", all named
#' "NonIPEDS - Undecided/Unspecified", for instances in which institutions
#' reported no program information or that students were not enrolled in a
#' program (undecided).
#'
#' @format A tidy data frame (tibble) with 1544 observations and 6 variables.
#' All variables are characters. An observation is a unique program.
#' \describe{
#'   \item{CIP2}{An instructional program's 2-digit code,  representing "the
#'   most general groupings of related programs" (US National Center for
#'   Education Statistics).}
#'   \item{CIP2name}{Name of a program at the 2-digit level.}
#'   \item{CIP4}{An instructional program's 4-digit code, representing
#'   "intermediate groupings of programs that have comparable content and
#'   objectives".}
#'   \item{CIP4name}{Name of a program at the 4-digit level.}
#'   \item{CIP6}{An instructional program's 6-digit code, representing
#'   "specific instructional programs".}
#'   \item{CIP6name}{Name of a program at the 6-digit level.}
#' }
#' @source Based on the 2010 codes curated by the US National Center for
#' Education Statistics (\url{https://nces.ed.gov/ipeds/cipcode}).
#' @examples
#' # view the CIP data
#' cip
#' # Use the data as an argument for cip_filter()
#' cip_filter(data = cip, series = "^1410")
"cip"
