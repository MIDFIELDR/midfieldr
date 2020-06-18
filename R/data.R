#' Classification of instructional programs (CIP) data
#'
#' A dataset of codes and names for 1584 instructional programs organized on three levels: a 2-digit series, a 4-digit series, and a 6-digit series.
#'
#' 6-digit codes are used in the midfieldr datasets (\code{midfieldstudents}, \code{midfieldcourses}, \code{midfieldterms}, and  \code{midfielddegrees}) to encode program information as reported by the member institutions. In addition to the standard codes and names, the midfieldr taxonomy includes three non-IPEDS codes:
#'
#' \describe{
#'   \item{14XXXX}{First-Year Engineering (FYE).}
#'   \item{14YYYY}{Engineering-Focused Curricula (pseudo-FYE). For instances in which a student is eligible for admission to the institution but has not been admitted to an engineering program. Some institutions without FYE programs use such a designation in lieu of undecided or unspecified.} \item{999999}{Undecided or Unspecified. For instances in which institutions reported no program information or that students were not enrolled in a program.}
#' }
#'
#' @format A data frame (tibble) with 1584 observations and 6 variables. All variables are characters. An observation is a unique program.
#'
#' \describe{
#'   \item{cip2}{An instructional program's 2-digit code,  representing "the most general groupings of related programs" (US National Center for Education Statistics).}
#'   \item{cip2name}{Name of a program grouping at the 2-digit level.}
#'   \item{cip4}{An instructional program's 4-digit code, representing "intermediate groupings of programs that have comparable content and objectives".}
#'   \item{cip4name}{Name of a program grouping at the 4-digit level.}
#'   \item{cip6}{An instructional program's 6-digit code, representing "specific instructional programs".}
#'   \item{cip6name}{Name of a specific program at the 6-digit level.}
#' }
#'
#' @source Based on the 2010 codes curated by the US National Center for Education Statistics (\url{https://nces.ed.gov/ipeds/cipcode}).
#'
#' @examples
#' # View the CIP data
#' cip
#'
#' # View the programs at the top level of the taxonomy
#' unique(cip[, 1:2])
#'
#' # As the data argument for cip_filter()
#' cip_filter(data = cip, keep_any = "^1410")
"cip"






#' Named series of 6-digit CIP codes
#'
#' Atomic character vectors of 6-digit CIP codes for specified groups of programs.
#'
#' @name cip_series
#'
#' @format An atomic character vector of 6-digit CIP codes.
#'
#' \describe{
#' \item{\code{cip_bio_sci}}{Biological and biomedical science programs, series 26.}
#' \item{\code{cip_engr}}{Engineering programs, series 14.}
#' \item{\code{cip_math_stat}}{Mathematics and statistics programs, series 27.}
#' \item{\code{cip_phys_sci}}{Physical science programs, series 40.}
#' \item{\code{cip_other_stem}}{Other STEM programs, not individually named.}
#' \item{\code{cip_stem}}{All Science, Technology, Engineering, and Mathematics (STEM) programs.}
#' }
#'
#' @source
#' NSF STEM programs, \url{https://www.ice.gov/sites/default/files/documents/Document/2016/stem-list.pdf}
#'
#' CIP 2010, US National Center for Education Statistics, \url{https://nces.ed.gov/ipeds/cipcode}.
#'
#' @examples
#' head(cip_math_stat, n = 10L)
#' head(cip_phys_sci, n = 10L)
#'
#' cip_filter(data = cip, keep_any = cip_math_stat)
#' cip_filter(data = cip, keep_any = cip_phys_sci)
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






#' CIP case data for four programs
#'
#' A subset of the [\code{cip}](cip.html) data frame for four engineering programs.
#'
#' The 6-digit CIP codes and names plus a user-selected program name for Civil, Electrical, Industrial, and Mechanical Engineering. The "Select and label programs" vignette describes how these data were assembled. The data frame is used by several other vignettes as a starting point.
#'
#' @format A data frame (tibble) with 12 observations and 3 variables. All variables are characters. An observation is a unique program.
#'
#' \describe{
#'   \item{cip6}{An instructional program's 6-digit code, representing "specific instructional programs".}
#'   \item{cip6name}{Name of a program at the 6-digit level}
#'   \item{program}{A program name used for grouping, summarizing, and graphing.}
#' }
#'
#' @source \href{https://midfieldr.github.io/midfielddata/}{midfielddata} package
"case_program_group"






#' Stickiness case data
#'
#' An data frame of stickiness data grouped by program and student race/ethnicity and sex.
#'
#' For Civil, Electrical, Industrial, and Mechanical Engineering, the number of students ever enrolled, the number of graduates, and the resulting stickiness.
#'
#' @format A data frame (tibble) with 32 observations and 6 variables.
#'
#' \describe{
#'  \item{program}{Instructional programs selected for study.}
#'  \item{race}{Student race and sex from \code{midfieldstudents} data.}
#'  \item{sex}{Student sex from \code{midfieldstudents} data.}
#'  \item{ever}{Number of students ever enrolled in a program. Grouped and summarized from \code{midfieldterms} data.}
#'  \item{grad}{Number of students graduating from the program. Grouped and summarized from \code{midfielddegrees} data.}
#'  \item{stick}{Program stickiness: the ratio of the number of students graduating from a program to the number ever enrolled in the program.}
#' }
#'
#' @source \href{https://midfieldr.github.io/midfielddata/}{midfielddata} package
"case_stickiness"








#' Imputed starting majors for FYE students
#'
#' Imputed starting majors for nearly 6000 first-year engineering (FYE) students in the midfielddata package.
#'
#' Some US institutions have first year engineering (FYE) programs---typically a common first year curriculum that is a prerequisite for declaring an engineering major. For some persistence metrics, we have to determine what we call a "starting major" for FYE students---the predicted engineering program such as Civil, Electrical, or Mechanical, the student would have declared had they not been required to enroll in FYE.
#'
#' @format A data frame (tibble) with 5992 observations and 2 variables.
#'
#' \describe{
#'  \item{id}{Unique, anonymized MIDFIELD student identifier.}
#'  \item{cip6}{Imputed starting major (6-digit CIP code) of FYE students. }
#' }
#'
#' @source \href{https://midfieldr.github.io/midfielddata/}{midfielddata} package
"case_fye"




#' Named colors from the ColorBrewer palettes
#'
#' Shorthand color names assigned to selected colors from the ColorBrewer palettes.
#'
#' This dataset provides convenient access to selected ColorBrewer palettes: diverging brown-bluegreen (BrBG) with 8 levels; diverging purple-green (PRGn) with 8 levels; and sequential gray (Greys) with the middle four of 6 levels.
#'
#' The color names have the form "level_hue" with 4 saturation levels (dark, mid, light, pale) and 5 hues (Br, BG, PR, Gn, Gray or Grey).
#'
#' @format A data frame (tibble) with 24 observations and 2 variables.
#'
#' \describe{
#'   \item{rcb_name}{Character variable of names.}
#'   \item{rcb_code}{Character variable of hex color codes.}
#' }
#'
#' @source Cynthia Brewer (\url{http://colorbrewer2.org}) and RColorBrewer  (\url{https://cran.r-project.org/package=RColorBrewer}).
#'
#' @examples
#' rcb_colors
#' rcb("dark_Br")
#' rcb("light_Gn")
"rcb_colors"












