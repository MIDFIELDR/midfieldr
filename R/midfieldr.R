#' @importFrom Rdpack reprompt
NULL

#' Tools for Student Records Research
#'
#' A package for investigating data from the MIDFIELD database. Provides
#' functions for manipulating student record data such as those provided in
#' the midfielddata package, which provides a sample of student records from
#' registrars at participating US universities, including demographic, term,
#' course, and degree information for 97,640 undergraduate students from 1987
#' to 2016.
#'
#' Provides functions to access and manipulate student
#' record data. To illustrate the workflow, we would use these functions
#' to compute and display a persistence metric such as "stickiness":
#'
#' \itemize{
#'   \item \code{get_cip()} to find the CIP codes of programs we
#'   want to study
#'   \item \code{label_programs()} to isolate and label the 6-digit CIPs
#'   \item \code{get_enrollees()} to gather students ever enrolled
#'   \item \code{get_graduates()} to gather graduating students
#'   \item \code{get_race_sex()} to gather student sex and race/ethnicity
#'   \item \code{order_multiway()} to condition the multiway data for graphing
#' }
#'
#' Operations such subsetting, joining, and grouping and summarizing
#' are performed using one's preferred tools in base R or packages such
#' as dplyr or data.table. In our examples, we use base R functions for
#' data carpentry and ggplot2 for graphing.
#'
#' @section Data:
#'
#' Instructional program data is provided in \code{cip}, a data frame of names
#' and codes of academic programs from the 2010 IPEDS Classification of
#' Instructional Programs (CIP) by the US Department of Education.
#'
#' Student record data is provided in the companion data package,
#' \href{https://github.com/MIDFIELDR/midfielddata}{midfielddata}. Data
#' are provided in four datasets: \code{midfieldcourses},
#' \code{midfielddegrees}, \code{midfieldstudents}, and  \code{midfieldterms}.
#'
#' @source Data provided by the MIDFIELD project:
#' \url{https://engineering.purdue.edu/MIDFIELD}
#' @docType package
#' @name midfieldr
#' @family package
NULL

# binding
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(".", ":="))
}
