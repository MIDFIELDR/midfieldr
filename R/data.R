# -------------------------------------------------------------------

#' Classification of instructional programs (CIP)
#'
#' A data set based on the US National Center for Education Statistics
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
#'   FYE programs use such a designation in lieu of undecided or
#'   unspecified.}
#'   \item{999999}{Undecided or Unspecified. For instances in which
#'   institutions reported no program information or that students were
#'   not enrolled in a program.}
#' }
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
#' @family "cip data"
"cip"

# -------------------------------------------------------------------

#' Case CIP codes
#'
#' Representative case study. A subset of the \code{cip} data set containing
#' CIP codes and names for Civil, Electrical, Industrial,
#' and Mechanical Engineering programs in
#' \href{https://midfieldr.github.io/midfielddata/}{midfielddata}.
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
#' @family "example data"
"rep_cip"

# -------------------------------------------------------------------

#' Case program group
#'
#' Representative case study. Six-digit CIP codes and custom program names
#' for Civil, Electrical, Industrial, and Mechanical Engineering programs in
#' \href{https://midfieldr.github.io/midfielddata/}{midfielddata}.
#'
#' @format \code{data.table} with 12 rows and 2 columns keyed by the
#' 6-digit CIP code. The variables are:
#' \describe{
#'   \item{cip6}{6-digit program code}
#'   \item{program}{program name assigned for grouping, summarizing,
#'   and joining}
#' }
#' @family "example data"
"rep_group"

# -------------------------------------------------------------------

#' Case student IDs
#'
#' Representative case study. Character vector of 12,409 student IDs
#' ever enrolled in Civil, Electrical, Industrial, and Mechanical
#' Engineering programs (including predicted starting programs for
#' FYE students) in
#' \href{https://midfieldr.github.io/midfielddata/}{midfielddata}.
#'
#' @format character vector
#' @family "example data"
"rep_ever"

# -------------------------------------------------------------------

#' Case stickiness results
#'
#' Representative case study. Stickiness metric results for Civil, Electrical,
#' Industrial, and Mechanical Engineering programs in
#' \href{https://midfieldr.github.io/midfielddata/}{midfielddata}. Results
#' are grouped by program, race/ethnicity, and sex.
#'
#' @format \code{data.table} with 63 rows and 6 columns keyed by
#' program, race/ethnicity, and sex. The variables are:
#' \describe{
#'  \item{program}{character, instructional programs selected for study}
#'  \item{race}{character, student race/ethnicity}
#'  \item{sex}{character, student sex}
#'  \item{ever}{numerical, number of students ever enrolled in a program
#'  and completion
#'  is feasible}
#'  \item{grad}{numerical, number of students graduating from the program}
#'  \item{stick}{numerical, program stickiness, a persistence metric}
#' }
#' @family "example data"
"rep_stickiness"

# -------------------------------------------------------------------

#' Case stickiness multiway results
#'
#' Representative case study. Stickiness metric results with two categorical
#' variables as factors with levels ordered by the median stickiness.
#'
#' @format \code{data.table} with 32 rows and 3 columns keyed by
#' program, race/ethnicity, and sex. The variables are:
#' \describe{
#'  \item{program}{factor, instructional programs selected for study}
#'  \item{race_sex}{factor, student race/ethnicity and sex}
#'  \item{stick}{numerical, program stickiness, a persistence metric}
#' }
#' @family "example data"
"rep_stickiness_mw"

# -------------------------------------------------------------------

#' Predicted starting CIP for FYE students
#'
#' Predicted starting programs for all FYE students in midfielddata.
#' Includes degree-granting programs that substitute for
#' first-year-engineering (FYE) programs when needed for a persistence
#' metric, e.g., graduation rate.
#'
#' Starting programs for FYE students are the engineering programs we
#' predict they would have declared had they not been required to enroll in
#' FYE. The prediction is based on their first post-FYE program and an
#' imputation suitable for multiple categorical variables using the mice
#' package. The predictor variables are institution, race, and sex. The
#' predicted variable is the 6-digit CIP code.
#'
#' @format \code{data.table} with 5992 rows and 2 columns keyed by student
#' ID. The variables are:
#' \describe{
#'    \item{id}{student ID}
#'    \item{start}{starting program 6-digit CIP code}
#'    }
#' @family "cip data"
"fye_start"
