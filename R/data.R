# -------------------------------------------------------------------

#' Classification of instructional programs (CIP) data
#'
#' A dataset based on the US National Center for Education Statistics
#' (NCES), Integrated Postsecondary Education Data System (IPEDS), 2020
#' CIP, \url{https://nces.ed.gov/ipeds/cipcode}. The data are codes and
#' names for 1584 instructional programs organized on three levels: a
#' 2-digit series, a 4-digit series, and a 6-digit series.
#'
#' The midfielddata taxonomy includes three non-IPEDS codes:
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
#'
#' @format \code{data.table} with 1584 rows and 6 columns keyed by the
#' 6-digit CIP code. The variables are:
#' \describe{
#'   \item{cip6}{character 6-digit code representing "specific
#'   instructional programs" (US National Center for Education Statistics)}
#'   \item{cip6name}{character program name at the 6-digit level}
#'   \item{cip4}{character 4-digit code (the first 4 digits of \code{cip6})
#'   representing "intermediate groupings of programs that have
#'   comparable content and objectives"}
#'   \item{cip4name}{character program name at the 4-digit level}
#'   \item{cip2}{character 2-digit code (the first 2 digits of \code{cip6})
#'   representing "the most general groupings of related programs"}
#'   \item{cip2name}{character program name at the 2-digit level}
#' }
#'
#' @examples
#' # overview
#' str(cip)
#'
#' # get_cip() argument
#' get_cip(data = cip, keep_any = "^1410")
#'
#' @family cip_data
#'
"cip"

# -------------------------------------------------------------------

#' Example CIP codes and names
#'
#' A subset of the \code{cip} data set containing CIP codes and names for a
#' case study of Civil, Electrical, Industrial, and Mechanical Engineering
#' programs in \href{https://midfieldr.github.io/midfielddata/}{midfielddata}.
#'
#' @format \code{data.table} with 12 rows and 6 columns keyed by the
#' 6-digit CIP code. The variables are:
#' \describe{
#'   \item{cip6}{character 6-digit code representing "specific
#'   instructional programs" (US National Center for Education Statistics)}
#'   \item{cip6name}{character program name at the 6-digit level}
#'   \item{cip4}{character 4-digit code (the first 4 digits of \code{cip6})
#'   representing "intermediate groupings of programs that have
#'   comparable content and objectives"}
#'   \item{cip4name}{character program name at the 4-digit level}
#'   \item{cip2}{character 2-digit code (the first 2 digits of \code{cip6})
#'   representing "the most general groupings of related programs"}
#'   \item{cip2name}{character program name at the 2-digit level}
#' }
#'
#' @examples
#' program_group <- label_programs(data = exa_cip, label = "cip4name")
#' program_group$cip6name <- NULL
#' program_group
#'
#' @family example_data
#'
"exa_cip"

# -------------------------------------------------------------------

#' Example program group
#'
#' Six-digit CIP codes and custom program names for a case study of Civil,
#' Electrical, Industrial, and Mechanical Engineering programs in
#' \href{https://midfieldr.github.io/midfielddata/}{midfielddata}.
#'
#' @format \code{data.table} with 12 rows and 2 columns keyed by the
#' 6-digit CIP code. The variables are:
#' \describe{
#'   \item{cip6}{6-digit program code}
#'   \item{program}{program name assigned for grouping, summarizing,
#'   and joining}
#' }
#'
#' @examples
#' library(midfielddata)
#'
#' # attributes of students matriculating in programs
#' cips_we_want <- exa_group$cip6
#' rows_we_want <- midfieldstudents$cip6 %in% cips_we_want
#' matriculants <- midfieldstudents[rows_we_want]
#' str(matriculants)
#'
#' # attributes of students graduating in programs
#' cips_we_want <- exa_group$cip6
#' rows_we_want <- midfielddegrees$cip6 %in% cips_we_want
#' graduates <- midfielddegrees[rows_we_want]
#' str(graduates)
#'
#' @family example_data
#'
"exa_group"

# -------------------------------------------------------------------

#' Collections of student IDs
#'
#' Character vectors of student IDs at different points in a case study of
#' Civil, Electrical, Industrial, and Mechanical Engineering programs in
#' \href{https://midfieldr.github.io/midfielddata/}{midfielddata}.
#'
#' @format character vector. The names of the available data vectors are:
#' \describe{
#' \item{exa_ever}{IDs of unique students ever enrolled in
#'   the example programs}
#' \item{exa_ever_fc}{subset of \code{exa_ever} for whom
#'   program completion is feasible in 6 years}
#' \item{exa_grad}{IDs of unique students graduating from
#'   the example programs}
#' }
#'
#' @examples
#' library(midfielddata)
#'
#' # ever enrolled
#' rows_we_want <- midfieldstudents$id %in% exa_ever
#' enrollees <- midfieldstudents[rows_we_want]
#' head(enrollees)
#'
#' # graduates
#' rows_we_want <- midfieldstudents$id %in% exa_grad
#' graduates <- midfieldstudents[rows_we_want]
#' head(graduates)
#'
#' @family example_data
#' @name exa_id
#'
NULL

#' @rdname exa_id
#' @format NULL
"exa_ever"
#' @rdname exa_id
#' @format NULL
"exa_grad"
#' @rdname exa_id
#' @format NULL
"exa_ever_fc"

# -------------------------------------------------------------------

#' Example stickiness data
#'
#' Stickiness metric results for a case study of Civil, Electrical,
#' Industrial, and Mechanical Engineering programs in
#' \href{https://midfieldr.github.io/midfielddata/}{midfielddata}. Results
#' are grouped by program, race/ethnicity, and sex.
#'
#' @format \code{data.table} with 32 rows and 6 columns keyed by
#' program, race/ethnicity, and sex. The variables are:
#' \describe{
#'  \item{program}{instructional programs selected for study}
#'  \item{race}{student race/ethnicity}
#'  \item{sex}{student sex}
#'  \item{ever}{number of students ever enrolled in a program and completion
#'  is feasible}
#'  \item{grad}{number of students graduating from the program}
#'  \item{stick}{program stickiness, a persistence metric}
#' }
#'
#' @examples
#' # prepare data for multiway graph
#' exa_stickiness$race_sex <- paste(exa_stickiness$race, exa_stickiness$sex)
#' columns_we_want <- c("program", "race_sex", "stick")
#' pre_mw <- exa_stickiness[, ..columns_we_want]
#'
#' @family example_data
#'
"exa_stickiness"

# -------------------------------------------------------------------

#' FYE students and imputed starting majors
#'
#' Imputed starting majors for all first-year engineering (FYE) students in
#' \href{https://midfieldr.github.io/midfielddata/}{midfielddata}.
#'
#' Some US institutions have first year engineering (FYE) programs---typically
#' a common first year curriculum that is a prerequisite for declaring
#' an engineering major. For some persistence metrics, we have to determine
#' what we call a "starting major" for FYE students---the predicted
#' engineering program such as Civil, Electrical, or Mechanical, for example,
#' the student would have declared had they not been required to enroll in FYE.
#'
#' @format \code{data.frame} with 5992 rows and 2 columns keyed by student ID.
#' The variables are:
#' \describe{
#'    \item{id}{unique anonymized MIDFIELD student identifier}
#'    \item{cip6}{imputed starting major of FYE students}
#' }
#'
#' @examples
#' # examine the data
#' str(midfield_fye)
#'
#' # degree status of FYE students
#' library(midfielddata)
#' ids_we_want <- midfield_fye$id
#' rows_we_want <- midfielddegrees$id %in% ids_we_want &
#'   !is.na(midfielddegrees$degree)
#' fye_grads <- midfielddegrees[rows_we_want]
#'
#' @family cip_data
#'
"midfield_fye"

# -------------------------------------------------------------------
