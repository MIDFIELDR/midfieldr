#' @importFrom Rdpack reprompt
NULL

#' \code{midfieldr}: Tools for Student Records Research
#'
#' For investigating undergraduate student records in the MIDFIELD database
#' that comprises data from registrar's at participating US institutions.
#' Designed to work with MIDFIELD-structured data, providing
#' tools for accessing and manipulating student, term, course, and
#' degree information. Data are available for 97,640 undergraduate students
#' from 1987 to 2016.
#'
#' A typical midfieldr workflow might include:
#'
#' \itemize{
#'   \item \code{filter_text()} search the CIP data set for program codes
#'   \item \code{prepare_fye_mi()} predict starting programs of
#'       first-year-engineering (FYE) students
#'   \item \code{subset_feasible()} subset students for 6-year
#'       completion feasibility
#'   \item \code{prepare_multiway()} condition multiway data for graphing
#' }
#'
#' Operations such subsetting, joining, and grouping and summarizing
#' are performed using one's preferred tools in base R or more advanced systems
#' such as dplyr or data.table. The examples use base R for data carpentry
#' and ggplot2 for graphs.
#'
#' @section Data:
#'
#' Instructional program data is provided in \code{cip}, a data frame of names
#' and codes of academic programs from the 2010 IPEDS Classification of
#' Instructional Programs (CIP) by the US Department of Education.
#'
#' Student record data is provided in a companion data package midfielddata.
#' Data are provided in four data sets: \code{midfieldstudents},
#' \code{midfieldcourses}, \code{midfieldterms}, and \code{midfielddegrees}.
#'
#' @section For more information:
#'
#' \itemize{
#'   \item vignette(package = 'midfieldr')
#'   \item website \href{https://midfieldr.github.io/midfieldr/}{midfieldr}
#'   \item website
#'   \href{https://midfieldr.github.io/midfielddata/}{midfielddata}
#'   \item website \href{https://engineering.purdue.edu/MIDFIELD}{MIDFIELD}
#' }
#'
#' @docType package
#' @name midfieldr
#' @family package
NULL

# binding
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    ".", ":=", "..cols_we_want", ".SD", "..columns", "..cols_we_want",
    "..keep_col",
    # following are column names in the four midfielddata data sets
    "id", "institution", "cip6", "race", "sex", "term", "term_degree",
    "term_enter", "degree", "hours_transfer", "hours_term", "transfer",
    "age", "us_citizen", "home_zip", "high_school", "sat_math", "sat_verbal",
    "act_comp", "level", "standing", "coop", "hours_term_attempt", "gpa_term",
    "hours_cumul_attempt", "hours_cumul", "gpa_cumul", "term_course",
    "abbrev", "number", "section", "hours_course", "type", "pass_fail",
    "grade", "faculty_rank"
  ))
}
