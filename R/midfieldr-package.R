#' @importFrom Rdpack reprompt
NULL

#' \code{midfieldr}: Tools for Student Records Research
#'
#' The *Multiple-Institution Database for Investigating Engineering
#' Longitudinal Development* (MIDFIELD) is a partnership of US higher
#' education institutions with engineering programs. MIDFIELD contains
#' registrar's data for 1.7M undergraduates in all majors at 19 institutions
#' from 1987--2019 \insertCite{Ohland+Long:2016}{midfieldr}.
#'
#' The software environment comprises two R packages:
#' \itemize{
#'   \item{\package{midfieldr} An R package providing functions specialized for
#'   manipulating MIDFIELD data to examine the intersectionality of
#'   race/ethnicity, sex, and discipline in persistence metrics such as
#'   stickiness (retention by a discipline) and graduation rate.}
#'   \item{\package{midfielddata} An R  package with practice data for users to
#'   learn about student record analysis using R. However, these data are
#'   not suitable for drawing inferences about student performance, i.e.,
#'   not for research.}
#' }
#'
#' \package{midfielddata} provides a proportionate stratified random sample
#' of the MIDFIELD research data. The sampling strata are institution, cip4
#' (the first four digits of the 6-digit CIP code), transfer status,
#' race/ethnicity, and sex. Contains four data tables: \code{student},
#' \code{course}, \code{term}, and \code{degree} keyed by an anonymized
#' student ID.
#'
#' Complete MIDFIELD data suitable for student-records research are
#' available to researchers under the following conditions:
#' \enumerate{
#'   \item{Your institutional IRB has granted approval for your project
#'   to study students using MIDFIELD. At most institutions, the
#'   use of MIDFIELD data for research is  in the IRB "Exempt" category,
#'   but institutional practices vary.}
#'   \item{Your institutional IRB has granted approval for your project
#'   to study students using MIDFIELD. At most institutions, the
#'   use of MIDFIELD data for research is  in the IRB "Exempt" category,
#'   but institutional practices vary.}
#' }
#' @docType package
#' @name midfieldr-package
#' @references
#'   \insertAllCited{}
#' @family package
NULL

# visible binding for global variables to satisfy R CMD chk
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    ".",  ":=", ".SD",
    # column names in the four midfielddata data sets
    "mcid", "institution", "cip6", "race", "sex", "term",
    "degree", "hours_transfer", "hours_term", "transfer",
    "age", "us_citizen", "home_zip", "high_school", "sat_math", "sat_verbal",
    "act_comp", "level", "standing", "coop", "hours_term_attempt", "gpa_term",
    "hours_cumul_attempt", "hours_cumul", "gpa_cumul",
    "abbrev", "number", "section", "hours_course", "type", "pass_fail",
    "grade", "faculty_rank"
  ))
}
