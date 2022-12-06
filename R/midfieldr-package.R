
#' @importFrom checkmate assert_data_frame assert_int qassert
#' @importFrom checkmate assert_subset assert_names
#' 
#' @importFrom data.table setkey setkeyv setcolorder setnames setorderv setorder
#' @importFrom data.table fcase fifelse copy as.data.table shift
#' @importFrom data.table setDF setDT
#' @importFrom data.table %chin% %like% .SD .N :=
#' 
#' @importFrom stats na.omit reorder
#' 
#' @importFrom wrapr let stop_if_dot_args %?%
NULL

#' Tools and Methods for Working with MIDFIELD Data in 'R'
#'
#' Provides tools and demonstrates methods for working with individual
#' undergraduate student unit records (registrar's data) in 'R'. Tools include
#' filters for program codes, data sufficiency, and timely completion. Methods
#' include gathering blocs of records, computing quantitative metrics such as
#' graduation rate, and creating charts to visualize comparisons. 'midfieldr' is
#' designed to work with data from the MIDFIELD research database, a sample of
#' which is available in the 'midfielddata' data package.
#'
#' [MIDFIELD](https://midfield.online/) is a database containing (as of October,
#' 2022) individual Student Unit Records (SURs) for 1.7M undergraduate students
#' at 19 US institutions from 1987 through 2018. Access to the MIDFIELD research
#' database is currently limited to MIDFIELD partner institutions, but a sample
#' of the data is available in the 'midfielddata' package.
#' 
#' ['midfielddata'](https://midfieldr.github.io/midfielddata/) is a companion
#' 'R' data package that provides anonymized SURs for approximately 98,000
#' students at three US institutions from 1988 through 2018 organized in four
#' tables --- `student`, `course`, `term`, and `degree` --- keyed by student ID.
#' 
#' This work is supported by a grant from the US National Science Foundation
#' (EEC 1545667).
#'
#' @source Data provided by MIDFIELD: \url{https://midfield.online/}.
#' @docType package
#' @family package
#' @name midfieldr-package
#'   
NULL

# bind names due to NSE notes in R CMD check
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    ".",
    # midfield data table names
    "student", "term", "course", "degree", 
    # midfielddata column names
    "abbrev", "act_comp", "age_desc", "cip6", "coop", "course", "degree", 
    "discipline_midfield", "faculty_rank", "gpa_cumul", "gpa_term", "grade", 
    "high_school", "home_zip", "hours_course", "hours_cumul", 
    "hours_cumul_attempt", "hours_term", "hours_term_attempt", "hours_transfer", 
    "institution", "level", "mcid", "number", "race", "sat_math", "sat_verbal", 
    "section", "sex", "standing", "term", "term_course", "term_degree", 
    "transfer", "type", "us_citizen"
  ))
}
