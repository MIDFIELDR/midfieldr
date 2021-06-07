#' @importFrom Rdpack reprompt
NULL

#' \code{midfieldr}: Tools for Student Records Research
#'
#' For investigating undergraduate student records. Designed to work with data
#' from the MIDFIELD project, a partnership of post-secondary US institutions.
#' MIDFIELD contains registrar's data for 1.7M undergraduates in all majors at
#' 19 institutions from 1987--2019.
#'
#' Functions in midfieldr are designed to work with the MIDFIELD research data
#' (available to MIDFIELD partners) as well as with the
#' publicly-available practice data in the midfielddata package.
#'
#' Operations such subsetting, joining, grouping, and summarizing
#' are performed using one's preferred tools in base R or more advanced systems
#' such as dplyr or data.table. The vignettes use base R and data.table
#' for data carpentry and ggplot2 for graphs.
#'
#' @docType package
#' @name midfieldr
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
