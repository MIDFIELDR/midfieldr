#' Classification of instructional programs (CIP) data
#'
#' A dataset of codes and names for 1584 instructional programs organized
#' on three levels: a 2-digit series, a 4-digit series, and a 6-digit series.
#'
#' 6-digit codes are used in the midfielddata datasets
#' (\code{midfieldstudents},  \code{midfieldcourses},  \code{midfieldterms},
#' and  \code{midfielddegrees}) to encode program information as reported by
#' the member institutions.
#'
#' In addition to the standard codes and names, the midfielddata
#' taxonomy includes following three non-IPEDS codes:
#' \describe{
#'   \item{14XXXX}{First-Year Engineering (FYE). First-Year Engineering
#'   students are neither undecided nor undeclared. Their institutions
#'   admitted them as engineering students. We just don't know what
#'   their engineering starting major would have been had they not been
#'   required to enroll in the FYE program.}
#'   \item{14YYYY}{Engineering-Focused Curricula (pseudo-FYE). For instances
#'   in which a student is eligible for admission to the institution but has
#'   not been admitted to an engineering program. Some institutions without
#'   FYE programs use such a designation in lieu of undecided or unspecified.}
#'   \item{999999}{Undecided or Unspecified. For instances in which
#'   institutions reported no program information or that students were
#'   not enrolled in a program.}
#' }
#' @format Data frame (tibble) with 1584 observations and 6 variables.
#' All variables are characters. An observation is a unique program.
#'
#' \describe{
#'   \item{cip6}{An instructional program's 6-digit code, representing
#'   "specific instructional programs" (US National Center for Education
#'    Statistics).}
#'   \item{cip6name}{Name of a specific program at the 6-digit level.}
#'   \item{cip4}{The first 4 digits of \code{cip6} are an instructional
#'   program's 4-digit code, representing "intermediate groupings of
#'   programs that have comparable content and objectives".}
#'   \item{cip4name}{Name of a program grouping at the 4-digit level.}
#'   \item{cip2}{The first 2 digits of \code{cip6} are an instructional
#'   program's 2-digit code, representing "the most general groupings of
#'   related programs".}
#'   \item{cip2name}{Name of a program grouping at the 2-digit level.}
#' }
#' @family cip_data
#' @seealso The "Explore program CIP codes" vignette.
#' @source US National Center for Education Statistics (NCES),
#' Integrated Postsecondary Education Data System (IPEDS), 2020 CIP
#' (\url{https://nces.ed.gov/ipeds/cipcode}).
#' @examples
#' # View the CIP data
#' print(cip)
#'
#' # View the programs at the top level of the taxonomy
#' unique(cip[, 1:2])
#'
#' # As the data argument for get_cip()
#' get_cip(cip, "^1410")
"cip"




#' Example CIP codes and names
#'
#' Subset of the \code{cip} data set. CIP codes and names for Civil,
#' Electrical, Industrial, and Mechanical Engineering. Used in a case
#' study in the vignettes.
#'
#' @format A data frame (tibble) with 12 observations and 6 variables.
#' The variables are characters.
#' \describe{
#'   \item{cip6}{6-digit program code.}
#'   \item{cip6name}{6-digit program name.}
#'   \item{cip4}{4-digit program code.}
#'   \item{cip4name}{4-digit program name.}
#'   \item{cip2}{2-digit program code.}
#'   \item{cip2name}{2-digit program name.}
#' }
#' @family example_data
#' @source \href{https://midfieldr.github.io/midfielddata/}{midfielddata}
#'  package
#' @examples
#' exa_cip
#' label_programs(data = exa_cip, label = "cip4name")
"exa_cip"




#' Example program group
#'
#' Six-digit CIP codes and names plus a custom program name for
#' Civil, Electrical, Industrial, and Mechanical Engineering. Used for
#' grouping, summarizing, and joining in a case study in the vignettes.
#'
#' @format A data frame (tibble) with 12 observations and 3 variables.
#' All variables are characters. An observation is a unique program.
#' \describe{
#'   \item{cip6}{6-digit program code.}
#'   \item{cip6name}{6-digit program name.}
#'   \item{program}{A short program name assigned for grouping,
#'   summarizing, and joining.}
#' }
#' @family example_data
#' @seealso The "Gather program data" vignette.
#' @source \href{https://midfieldr.github.io/midfielddata/}{midfielddata}
#'  package
#' @examples
#' x <- unique(exa_group[["cip6"]])
#' y <- unique(exa_group[["program"]])
"exa_group"







#' Example student IDs
#'
#' Students IDs from midfielddata for Civil, Electrical, Industrial,
#' and Mechanical Engineering. Used in a case study in the vignettes.
#'
#' \describe{
#' \item{\code{exa_ever}}{IDs of students ever enrolled in the example
#' programs.}
#' \item{\code{exa_grad}}{IDs of students graduating from the example
#' programs.}
#' }
#' @family example_data
#' @name exa_id
#' @format Character vector of student IDs.
#' @source \href{https://midfieldr.github.io/midfielddata/}{midfielddata}
#'  package
#' @examples
#' library(midfielddata)
#' midfieldstudents[midfieldstudents[["id"]] %in% exa_ever, ]
#' midfieldstudents[midfieldstudents[["id"]] %in% exa_grad, ]
NULL

#' @rdname exa_id
#' @format NULL
"exa_ever"
#' @rdname exa_id
#' @format NULL
"exa_grad"








#' Example stickiness data
#'
#' Stickiness metric results for Civil, Electrical, Industrial, and
#' Mechanical Engineering. Data are grouped by program, student
#' race/ethnicity, and sex. Used for graphing the results in a case study
#' in the vignettes.
#'
#' @format A data frame (tibble) with 32 observations and 6 variables.
#' \describe{
#'  \item{program}{Instructional programs selected for study. Character
#'  variable.}
#'  \item{race}{Student race and sex from \code{midfieldstudents} data.
#'   Character variable.}
#'  \item{sex}{Student sex from \code{midfieldstudents} data.  Character
#'  variable.}
#'  \item{ever}{Number of students ever enrolled in a program. Grouped
#'  and summarized from \code{midfieldterms} data.}
#'  \item{grad}{Number of students graduating from the program. Grouped
#'  and summarized from \code{midfielddegrees} data.}
#'  \item{stick}{Program stickiness: the ratio of the number of
#'  students graduating from a program to the number ever enrolled in the
#'  program.}
#' }
#' @family example_data
#' @seealso The "Compute stickiness" vignette.
#' @source \href{https://midfieldr.github.io/midfielddata/}{midfielddata}
#'  package
#' @examples
#' exa_stickiness
"exa_stickiness"








#' FYE students and imputed starting majors
#'
#' Imputed starting majors for nearly 6000 first-year engineering (FYE)
#' students in the \pkg{midfielddata} package.
#'
#' Some US institutions have first year engineering (FYE) programs---typically
#' a common first year curriculum that is a prerequisite for declaring
#' an engineering major. For some persistence metrics, we have to determine
#' what we call a "starting major" for FYE students---the predicted
#' engineering program such as Civil, Electrical, or Mechanical, the
#' student would have declared had they not been required to enroll in FYE.
#'
#' @format A data frame (tibble) with 5992 observations and 2 variables.
#' All variables are characters.
#'
#' \describe{
#'    \item{id}{unique, anonymized MIDFIELD student identifier}
#'    \item{cip6}{imputed starting major (6-digit CIP code) of FYE students}
#' }
#'
#' @family cip_data
#' @seealso The "Impute FYE starting majors" vignette.
#' @source \href{https://midfieldr.github.io/midfielddata/}{\pkg{midfielddata}
#'  package}
"midfield_fye"





