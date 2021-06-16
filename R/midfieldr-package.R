

#' @importFrom Rdpack reprompt
NULL


#' \code{midfieldr}: Tools for Student Records Research
#'
#' Provides functions for studying US undergraduate student-record
#' data provided by registrars at participating institutions.
#' The practice data set includes all student records for approximately
#' 98,000 students at 12 institutions from 1987 to 2016. For privacy
#' protection, personal and institutional identities are anonymized.
#'
#' The *Multiple-Institution Database for Investigating Engineering
#' Longitudinal Development* (MIDFIELD) is a partnership of US higher
#' education institutions with engineering programs. The MIDFIELD research
#' database contains registrar's data for 1.7M undergraduates in all majors
#' at 19 institutions from 1987--2019 \insertCite{Ohland+Long:2016}{midfieldr}.
#'
#' The software environment comprises two R packages:
#' \itemize{
#'   \item{midfieldr: An R package providing functions specialized for
#'   manipulating MIDFIELD data to examine the intersectionality of
#'   race/ethnicity, sex, and discipline in persistence metrics such as
#'   stickiness (retention by a discipline) and graduation rate.}
#'   \item{midfielddata: An R  package with practice data for users to
#'   learn about student record analysis using R. However, these data are
#'   not suitable for drawing inferences about student performance, i.e.,
#'   not for research.}
#' }
#'
#' @section Data:
#' midfielddata provides a proportionate stratified random sample
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
#'   \item{Each researcher using the data signs a letter of
#'   confidentiality describing  the guidelines for how the data may be
#'   reported.}
#' }
#' The research data and practice data have the same structure with
#' the same variable names, though some research variables are
#' omitted from the practice data. Thus R scripts written for the practice
#' data should generally work with the research data.
#'
#'
#' @docType package
#' @name midfieldr-package
#'
#'
#' @references
#'   \insertAllCited{}
#'
#'
#' @family package
#'
#'
NULL


# bind names due to NSE notes in R CMD check
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    ".", ":=", ".SD",
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
