

#' @importFrom data.table setkey setkeyv setcolorder setnames setorderv
#' @importFrom data.table fcase fifelse copy as.data.table shift
#' @importFrom data.table setDF setDT
#' @importFrom data.table `%chin%` `%like%` `.SD` `.N` `:=`
#'
#' @importFrom checkmate assert_data_frame assert_int qassert
#' @importFrom checkmate assert_subset assert_names
#'
#' @importFrom wrapr stop_if_dot_args let `%?%`
#'
#' @importFrom stats na.omit median reorder
NULL


#' Tools for Studying MIDFIELD Student Unit Record Data in R
#'
#' The goal of midfieldr is to provide tools for working with MIDFIELD data,
#' a resource of longitudinal, de-identified, individual student unit records.
#'
#' \href{https://engineering.purdue.edu/MIDFIELD}{MIDFIELD} contains individual
#' Student Unit Record (SUR) data for 1.7M students at 33 US institutions (as
#' of June 2021). MIDFIELD is large enough to permit grouping and summarizing
#' by multiple characteristics, enabling researchers to examine student
#' characteristics (race/ethnicity, sex, prior achievement) and curricular
#' pathways (including coursework and major) by institution and over time.
#'
#' A proportionate stratified sample of these data (for practice) is
#' available in
#' \href{https://midfieldr.github.io/midfielddata/}{midfielddata}, an R
#' data package with longitudinal student unit-records for 98,000
#' undergraduates at 12 institutions from  1987--2016 organized in four data
#' tables:
#' \itemize{
#'  \item {\href{https://midfieldr.github.io/midfielddata/reference/student.html}{student}}
#'  \item {\href{https://midfieldr.github.io/midfielddata/reference/course.html}{course}}
#'  \item {\href{https://midfieldr.github.io/midfielddata/reference/term.html}{term}}
#'  \item {\href{https://midfieldr.github.io/midfielddata/reference/degree.html}{degree}}
#' }
#'
#' The tools in midfieldr work equally well with the practice data in
#' midfielddata and the research data in MIDFIELD.
#'
#' This work is supported by a grant from the US National Science
#' Foundation (EEC 1545667).
#'
#'
#' @docType package
#' @name midfieldr-package
#'
#'
#' @family package
#'
#'
NULL


# bind names due to NSE notes in R CMD check
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    ".",
    # midfielddata column names
    "mcid", "institution", "cip6", "race", "sex", "term",
    "degree", "hours_transfer", "hours_term", "transfer",
    "age", "us_citizen", "home_zip", "high_school", "sat_math",
    "sat_verbal", "act_comp", "level", "standing", "coop",
    "hours_term_attempt", "gpa_term", "hours_cumul_attempt",
    "hours_cumul", "gpa_cumul", "abbrev", "number", "section",
    "hours_course", "type", "pass_fail", "grade", "faculty_rank"
  ))
}
